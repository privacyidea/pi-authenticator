/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/logger.dart';

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

// / This implementation is taken from the library
// / [foundation](https://api.flutter.dev/flutter/foundation/describeEnum.html).
// / That library sadly depends on [dart.ui] and thus cannot be used in tests.
// / Therefore, only using this code enables us to use this library ([utils.dart])
// / in tests.
// String enumAsString(Enum enumEntry) {
//   final String description = enumEntry.toString();
//   final int indexOfDot = description.indexOf('.');
//   assert(indexOfDot != -1 && indexOfDot < description.length - 1);
//   return description.substring(indexOfDot + 1);
// }

/// If permission is already given, this function does nothing
void checkNotificationPermission() async {
  if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) return;
  var status = await Permission.notification.status;
  Logger.info('Notification permission status: $status');
  // TODO what to do if permanently denied?
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

dynamic tryJsonDecode(String json) {
  try {
    return jsonDecode(json);
  } catch (_) {
    return null;
  }
}
