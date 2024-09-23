/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img_lib;
import 'package:zxing2/qrcode.dart';

import '../../model/enums/token_origin_source_type.dart';
import '../../model/extensions/enums/token_origin_source_type.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/logger.dart';
import '../../utils/token_import_origins.dart';
import '../scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';
import 'token_import_file_processor_interface.dart';

class GoogleAuthenticatorQrfileProcessor extends TokenImportFileProcessor {
  static get resultHandlerType => TokenImportFileProcessor.resultHandlerType;
  const GoogleAuthenticatorQrfileProcessor();
  @override
  Future<bool> fileIsValid(XFile file) async {
    try {
      final img_lib.Image? qrImage = img_lib.decodeImage(await file.readAsBytes());
      if (qrImage == null) {
        Logger.warning("Error decoding file to image..");
        return Future.value(false);
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> fileNeedsPassword(XFile file) => Future.value(false);

  @override
  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password}) async {
    Result? qrResult;
    img_lib.Image? qrImage = img_lib.decodeImage(await file.readAsBytes());
    if (qrImage == null) {
      Logger.warning("Error decoding file to image..");
      throw Exception("Error decoding file to image.."); //TODO: Better error handling
    }
    int maxZoomLevel = 10;
    if (!kIsWeb && Platform.isAndroid) {
      final size = min(qrImage.width, qrImage.height);
      Logger.info("Cropping image to square: from ${qrImage.width}x${qrImage.height} to ${size}x$size");
      qrImage = img_lib.copyCrop(qrImage, x: (qrImage.width - size) ~/ 2, y: (qrImage.height - size) ~/ 2, width: size, height: size);
      Logger.info("Cropped image to square: ${qrImage.width}x${qrImage.height}");
    }

    // var progress = globalRef?.read(progressStateProvider.notifier).initProgress(maxZoomLevel * 360, 0).progress;
    for (var zoomLevel = 0; zoomLevel <= maxZoomLevel && qrResult == null; zoomLevel++) {
      for (var rotation = 0; rotation < 360; rotation += 90) {
        // await Future.delayed(const Duration(milliseconds: 1));
        // globalRef?.read(progressStateProvider.notifier).setProgressValue(zoomLevel * 360 + rotation);
        try {
          qrResult = await compute(_decodeQrImageIsolate, [qrImage, rotation, zoomLevel]);

          break;
        } on FormatReaderException catch (_) {
          Logger.info("Qr-Code detected but not valid. Zoom level: $zoomLevel|rotation: $rotation");
          if (zoomLevel != maxZoomLevel) break;
        } on NotFoundException catch (_) {
          Logger.info("Qr-Code not detected. Zoom level: $zoomLevel|rotation: $rotation");
        }
        // progress = globalRef?.read(progressStateProvider).progress;
      }
    }
    if (qrResult == null) {
      Logger.warning("Error decoding QR file..");
      throw NotFoundException();
    }

    final Uri uri;
    try {
      uri = Uri.parse(qrResult.text);
    } on FormatException catch (_) {
      Logger.warning("Error parsing QR file content..");
      throw FormatReaderException();
    }
    var processorResults = await const GoogleAuthenticatorQrProcessor().processUri(uri);
    if (processorResults.isEmpty) {
      Logger.warning("Error processing QR file content..");
      throw FormatReaderException();
    }
    processorResults = processorResults.map<ProcessorResult<Token>>((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.qrFile.addOriginToToken(
          appName: TokenImportOrigins.googleAuthenticator.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: t.resultData.origin?.data ?? qrResult!.text,
        ),
        resultHandlerType: resultHandlerType,
      );
    }).toList();
    return processorResults;
  }
}

Future<Result?> _decodeQrImageIsolate(List<dynamic> args) async {
  var image = args[0] as img_lib.Image;
  final int rotation = args[1] as int;
  final int zoomLevel = args[2] as int;
  if (zoomLevel > 0) {
    final cropWidth = (image.width * 0.02).floor() * zoomLevel;
    final cropHeight = (image.height * 0.02).floor() * zoomLevel;
    image = img_lib.copyCrop(image, x: cropWidth, y: cropHeight, width: image.width - cropWidth, height: image.height - cropHeight);
  }
  if (rotation > 0) {
    image = img_lib.copyRotate(image, angle: rotation);
  }

  LuminanceSource source = RGBLuminanceSource(
    image.width,
    image.height,
    image.convert(numChannels: 4).getBytes(order: img_lib.ChannelOrder.abgr).buffer.asInt32List(),
  );

  return QRCodeReader().decode(
    BinaryBitmap(GlobalHistogramBinarizer(source)),
    hints: DecodeHints()
      ..put(DecodeHintType.tryHarder)
      ..put(DecodeHintType.possibleFormats, [BarcodeFormat.qrCode]),
  );
}
