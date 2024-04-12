import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as img_lib;

/// Converts a [CameraImage] to a [img_lib.Image] object.
/// Args: [SendPort] sendPort, [CameraImage] image, [bool] isFrontCamera, [int] cropLeft, [int] cropRight, [int] cropTop, [int] cropBottom
void _imageConverterIsolate(List args) async {
  final SendPort sendPort = args[0] as SendPort;
  BackgroundIsolateBinaryMessenger.ensureInitialized(args[7]);
  final imageConverted = await ImageConverter._fromCameraImage(
    args[1],
    isFrontCamera: args[2],
    cropLeft: args[3],
    cropRight: args[4],
    cropTop: args[5],
    cropBottom: args[6],
  );
  sendPort.send(imageConverted);
}

class ImageConverter {
  static final converterNative = ConvertNativeImgStream();
  static Future<img_lib.Image?> fromCameraImage(
    CameraImage image, {
    bool isFrontCamera = false,
    int cropLeft = 0,
    int cropRight = 0,
    int cropTop = 0,
    int cropBottom = 0,
  }) async =>
      _startIsolate(image, isFrontCamera: isFrontCamera, cropLeft: cropLeft, cropRight: cropRight, cropTop: cropTop, cropBottom: cropBottom);

  static Future<img_lib.Image?> _fromCameraImage(
    CameraImage image, {
    bool isFrontCamera = false,
    int cropLeft = 0,
    int cropRight = 0,
    int cropTop = 0,
    int cropBottom = 0,
  }) async {
    final jpegBytes = await ConvertNativeImgStream().convertImgToBytes(image.planes.first.bytes, image.width, image.height);
    if (jpegBytes == null) return null;
    img_lib.Image? imageConverted = img_lib.decodeJpg(jpegBytes);
    if (imageConverted == null) return null;
    if (isFrontCamera) imageConverted = img_lib.flipHorizontal(imageConverted);
    imageConverted = ImageConverter.copyCrop(
      imageConverted,
      cropLeft: cropLeft,
      cropRight: cropRight,
      cropTop: cropTop,
      cropBottom: cropBottom,
    );
    return imageConverted;
  }

  static img_lib.Image copyCrop(img_lib.Image image, {int cropLeft = 0, int cropRight = 0, int cropTop = 0, int cropBottom = 0}) {
    if (cropLeft == 0 && cropRight == 0 && cropTop == 0 && cropBottom == 0) return image;
    return img_lib.copyCrop(
      image,
      x: cropLeft,
      y: cropTop,
      width: image.width - cropLeft - cropRight,
      height: image.height - cropTop - cropBottom,
    );
  }

  static Future<img_lib.Image?> _startIsolate(
    CameraImage image, {
    bool isFrontCamera = false,
    int cropLeft = 0,
    int cropRight = 0,
    int cropTop = 0,
    int cropBottom = 0,
  }) async {
    final response = ReceivePort();
    try {
      await Isolate.spawn(
          _imageConverterIsolate, [response.sendPort, image, isFrontCamera, cropLeft, cropRight, cropTop, cropBottom, RootIsolateToken.instance!]);
    } catch (e) {
      response.close();
    }
    final img_lib.Image? imageConverted = await response.first;
    return imageConverted;
  }
}
