/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gms_check/gms_check.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zxing2/qrcode.dart';

import '../../../../../../../mains/main_netknights.dart';
import '../../../../../../../model/extensions/sortable_list.dart';
import '../../../../../../../utils/logger.dart';
import '../../../../../../../utils/riverpod/riverpod_providers/generated_providers/sortable_notifier.dart';
import '../../../../../../../views/main_view/main_view_widgets/loading_indicator.dart';
import '../model/enums/token_origin_source_type.dart';
import '../model/mixins/sortable_mixin.dart';
import '../model/processor_result.dart';
import '../model/token_folder.dart';
import '../model/tokens/token.dart';
import '../processors/scheme_processors/scheme_processor_interface.dart';
import 'customization/application_customization.dart' show ApplicationCustomization;
import 'object_validator.dart';
import 'riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import 'view_utils.dart';

final urlRegExp = RegExp(r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');

/// Inserts [char] at the position [pos] in the given String ([str]),
/// and returns the resulting String.
///
/// Example: insertCharAt('ABCD', ' ', 2) --> 'AB CD'
String insertCharAt(String str, String char, int pos) {
  return str.substring(0, pos) + char + str.substring(pos, str.length);
}

/// Inserts [' '] after every [period] characters in [str].
/// Trims leading and trailing whitespaces. Returns the resulting String.
///
/// Example: 'ABCD', 1 --> 'A B C D'
/// Example: 'ABCD', 2 --> 'AB CD'
///
/// If [period] is less than 1, the original String is returned.
String splitPeriodically(String str, int period) {
  if (period < 1) return str;
  String result = '';
  for (int i = 0; i < str.length; i++) {
    i % period == 0 ? result += ' ${str[i]}' : result += str[i];
  }

  return result.trim();
}

/// If permission is already given, this function does nothing
void checkNotificationPermission() async {
  if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) return;
  var status = await Permission.notification.status;
  Logger.info('Notification permission status: $status');
  // Add a dialog before requesting?

  if (!status.isPermanentlyDenied) {
    if (status.isDenied) {
      try {
        await Permission.notification.request();
      } catch (e) {
        await Future.delayed(const Duration(seconds: 5));
        checkNotificationPermission();
        Logger.warning('Error requesting notification permission: $e');
      }
    }
  } else {
    Logger.info('Notification permission is permanently denied!');
  }
}

String? getErrorMessageFromResponse(Response response) {
  String body = response.body;
  String? errorMessage;
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    errorMessage = json['result']?['error']?['message'] as String?;
  } catch (e) {
    errorMessage = null;
  }
  return errorMessage;
}

Size textSizeOf(
    {required String text, required TextStyle style, required TextScaler? textScaler, int? maxLines, double minWidth = 0, double maxWidth = double.infinity}) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), maxLines: maxLines, textDirection: TextDirection.ltr, textScaler: textScaler ?? TextScaler.noScaling)
    ..layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.size;
}

Future<String> getPackageName() async => (await PackageInfo.fromPlatform()).packageName.replaceAll('.debug', '');

String removeIllegalFilenameChars(String filename) => filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');

bool doesThrow(Function() f) {
  try {
    f();
    return false;
  } catch (_) {
    return true;
  }
}

String getCurrentAppName() => PrivacyIDEAAuthenticator.currentCustomization?.appName ?? ApplicationCustomization.defaultCustomization.appName;

dynamic tryJsonDecode(String json) {
  try {
    return jsonDecode(json);
  } catch (_) {
    return null;
  }
}

void dragSortableOnAccept({
  required SortableMixin? previousSortable,
  required SortableMixin dragedSortable,
  required SortableMixin? nextSortable,
  TokenFolder? dependingFolder,
  required WidgetRef ref,
}) {
  var allSortables = ref.read(sortablesProvider);
  if (dragedSortable is TokenFolder) {
    final tokensInFolder = ref.read(tokenProvider).tokens.where((element) => element.folderId == dragedSortable.folderId).toList();
    final allMovingItems = [dragedSortable, ...tokensInFolder];
    allSortables = allSortables.moveAllBetween(moveAfter: previousSortable, movedItems: allMovingItems, moveBefore: nextSortable);
  } else if (dragedSortable is Token) {
    allSortables = allSortables.moveBetween(moveAfter: previousSortable, movedItem: dragedSortable, moveBefore: nextSortable);
    allSortables = allSortables.map((e) {
      return e is Token && e.id == dragedSortable.id ? e.copyWith(folderId: () => dependingFolder?.folderId) : e;
    }).toList();
  }
  final modifiedTokens = allSortables.whereType<Token>().toList();
  final modifiedFolders = allSortables.whereType<TokenFolder>().toList();
  final futures = [
    ref.read(tokenProvider.notifier).addOrReplaceTokens(modifiedTokens),
    ref.read(tokenFolderProvider.notifier).addOrReplaceFolders(modifiedFolders),
  ];
  final draggingSortableProviderNotifier = ref.read(draggingSortableProvider.notifier);
  Future.wait(futures).then((_) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      draggingSortableProviderNotifier.state = null;
    });
  });
}

ByteData bigIntToByteData(BigInt bigInt) {
  final data = ByteData((bigInt.bitLength / 8).ceil());
  for (var i = 1; i <= data.lengthInBytes; i++) {
    data.setUint8(data.lengthInBytes - i, bigInt.toUnsigned(8).toInt());
    bigInt = bigInt >> 8;
  }

  return data;
}

BigInt byteDataToBigInt(ByteData data) {
  BigInt result = BigInt.zero;
  for (var i = 0; i < data.lengthInBytes; i++) {
    result = result << 8;
    result = result | BigInt.from(data.getUint8(i));
  }
  return result;
}

Uint8List bigIntToBytes(BigInt bigInt) => bigIntToByteData(bigInt).buffer.asUint8List();

BigInt bytesToBigInt(Uint8List bytes) => byteDataToBigInt(ByteData.sublistView(bytes));

Future<void> scanQrCode({BuildContext? context, required List<ResultHandler> resultHandlerList, required Object? qrCode}) async {
  Uri uri;
  try {
    if (qrCode == null) return;
    uri = switch (qrCode.runtimeType) {
      const (String) => Uri.parse(qrCode as String),
      const (Uri) => qrCode as Uri,
      _ => throw ArgumentError('Invalid type for qrCode: $qrCode'),
    };
  } catch (e) {
    showErrorStatusMessage(message: (l) => l.invalidUrl);
    Logger.warning('Scanned Data: $qrCode');
    return;
  }
  final processorResults = await SchemeProcessor.processUriByAny(uri);
  if (processorResults == null) return;
  final resultHandlerTypeMap = <ObjectValidator<ResultHandler>, List<ProcessorResult>>{};

  for (var result in processorResults) {
    final validator = result.resultHandlerType;
    if (validator == null) continue;
    if (resultHandlerTypeMap.containsKey(result.resultHandlerType)) {
      resultHandlerTypeMap[validator]!.add(result);
    } else {
      resultHandlerTypeMap[validator] = [result];
    }
  }
  Future<void> handleResults() async {
    for (var resultHandlerType in resultHandlerTypeMap.keys) {
      final results = resultHandlerTypeMap[resultHandlerType]!;
      final resultHandler = resultHandlerList.firstWhereOrNull((resultHandler) => resultHandlerType.isTypeOf(resultHandler));
      if (resultHandler != null) {
        await resultHandler.handleProcessorResults(results, args: {ResultHandler.argTokenOriginSourceType: TokenOriginSourceType.qrScan});
      }
    }
  }

  if (context == null || !context.mounted) return handleResults();

  LoadingIndicator.show(
    context: context,
    action: handleResults,
  );
}

Image generateQrCodeImage({required String data}) {
  final qrcode = Encoder.encode(
    data,
    ErrorCorrectionLevel.l,
    hints: EncodeHints()..put<CharacterSetECI>(EncodeHintType.characterSet, CharacterSetECI.ASCII),
  );
  final matrix = qrcode.matrix!;
  const scale = 4;
  const padding = 1;

  var image = img.Image(
    width: (matrix.width + padding + padding) * scale,
    height: (matrix.height + padding + padding) * scale,
    numChannels: 4,
  );
  img.fill(image, color: img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF));

  for (var x = 0; x < matrix.width; x++) {
    for (var y = 0; y < matrix.height; y++) {
      if (matrix.get(x, y) == 1) {
        img.fillRect(
          image,
          x1: (x + padding) * scale,
          y1: (y + padding) * scale,
          x2: (x + padding) * scale + scale - 1,
          y2: (y + padding) * scale + scale - 1,
          color: img.ColorRgba8(0, 0, 0, 0xFF),
        );
      }
    }
  }
  return Image.memory(img.encodePng(image));
}

bool get deviceHasFirebaseMessaging => !kIsWeb && (GmsCheck().isGmsAvailable || Platform.isIOS);
