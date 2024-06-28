import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/token_import_file_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img_lib;

import '../../model/enums/token_origin_source_type.dart';
import '../../utils/logger.dart';
import '../../utils/token_import_origins.dart';
import '../scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';

class GoogleAuthenticatorQrfileProcessor extends TokenImportFileProcessor {
  const GoogleAuthenticatorQrfileProcessor();
  @override
  Future<bool> fileIsValid(XFile file) async {
    try {
      final img_lib.Image? qrImage = img_lib.decodeImage(await file.readAsBytes());
      if (qrImage == null) {
        Logger.warning("Error decoding file to image..", name: "_pickQrFile#ImportStartPage");
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
      Logger.warning("Error decoding file to image..", name: "_pickQrFile#ImportStartPage");
      throw Exception("Error decoding file to image.."); //TODO: Better error handling
    }
    if (!kIsWeb && Platform.isAndroid) {
      final size = min(qrImage.width, qrImage.height);
      Logger.info("Cropping image to square: from ${qrImage.width}x${qrImage.height} to ${size}x$size");
      qrImage = img_lib.copyCrop(qrImage, x: (qrImage.width - size) ~/ 2, y: (qrImage.height - size) ~/ 2, width: size, height: size);
      Logger.info("Cropped image to square: ${qrImage.width}x${qrImage.height}");
    } else if (!kIsWeb && Platform.isIOS) {
      Logger.info("Cropping image: from ${qrImage.width}x${qrImage.height} to ${qrImage.width}x${qrImage.height * 0.78}");
      qrImage = img_lib.copyCrop(qrImage, x: 0, y: (qrImage.height * 0.22).floor(), width: qrImage.width, height: qrImage.height);
      Logger.info("Cropped image : ${qrImage.width}x${qrImage.height}");
    }
    const maxZoomLevel = 10;
    globalRef?.read(progressStateProvider.notifier).initProgress(maxZoomLevel * 360, 0);
    for (var zoomLevel = 0; zoomLevel <= maxZoomLevel && qrResult == null && globalRef?.read(progressStateProvider) != null; zoomLevel++) {
      for (var rotation = 0; rotation < 360; rotation += 90) {
        globalRef?.read(progressStateProvider.notifier).setProgressValue(zoomLevel * 360 + rotation);
        try {
          qrResult = await compute(_decodeQrImageIsolate, [qrImage, rotation, zoomLevel]);

          break;
        } on FormatReaderException catch (_) {
          Logger.info("Qr-Code detected but not valid. Zoom level: $zoomLevel|rotation: $rotation");
          if (zoomLevel != maxZoomLevel) break;
        } on NotFoundException catch (_) {
          Logger.info("Qr-Code not detected. Zoom level: $zoomLevel|rotation: $rotation");
        }
      }
    }
    if (qrResult == null) {
      Logger.warning("Error decoding QR file..", name: "_pickQrFile#ImportStartPage");
      throw Exception("Error decoding QR file.."); //TODO: Better error handling
    }

    final Uri uri;
    try {
      uri = Uri.parse(qrResult.text);
    } on FormatException catch (_) {
      Logger.warning("Error parsing QR file content..", name: "_pickQrFile#ImportStartPage");
      throw Exception("Error parsing QR file content.."); //TODO: Better error handling
    }
    var processorResults = await const GoogleAuthenticatorQrProcessor().processUri(uri);
    if (processorResults.isEmpty) {
      Logger.warning("Error processing QR file content..", name: "_pickQrFile#ImportStartPage");
      throw Exception("Error processing QR file content.."); //TODO: Better error handling
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
