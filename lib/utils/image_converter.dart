import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:privacyidea_authenticator/utils/logger.dart';

class ImageConverter {
  final imglib.Image image;
  final Size size;

  ImageConverter({
    required this.image,
  }) : size = Size(image.width.toDouble(), image.height.toDouble());

  factory ImageConverter.fromCameraImage(CameraImage image, int rotation,
      {bool isFrontCamera = false, int? cropLeft, int? cropRight, int? cropTop, int? cropBottom}) {
    return switch (image.format.group) {
      ImageFormatGroup.yuv420 => ImageConverter._fromYUV420(image, rotation, isFrontCamera, cropLeft ?? 0, cropRight ?? 0, cropTop ?? 0, cropBottom ?? 0),
      ImageFormatGroup.bgra8888 => ImageConverter._fromBGRA8888(image, rotation, isFrontCamera, cropLeft ?? 0, cropRight ?? 0, cropTop ?? 0, cropBottom ?? 0),
      ImageFormatGroup.jpeg => ImageConverter._fromJPEG(image),
      ImageFormatGroup.nv21 => ImageConverter._fromNV21(image,
          rotation: rotation, mirror: isFrontCamera, cropLeft: cropLeft ?? 0, cropRight: cropRight ?? 0, cropTop: cropTop ?? 0, cropBottom: cropBottom ?? 0),
      ImageFormatGroup.unknown => throw ArgumentError('Unknown image format', 'image.format.group'),
    };
  }

  factory ImageConverter._fromNV21(CameraImage image,
      {int rotation = 0, bool mirror = false, int cropLeft = 0, int cropRight = 0, int cropTop = 0, int cropBottom = 0}) {
    Uint8List yuv420sp = image.planes[0].bytes;
    rotation = 360 - (rotation % 360); // if the rotation is 90, we need to rotate by 270 to get the correct rotation
    Logger.info(
        'Converting NV21 image with rotation: $rotation, mirror: $mirror, cropLeft: $cropLeft, cropRight: $cropRight, cropTop: $cropTop, cropBottom: $cropBottom, width: ${image.width}, height: ${image.height}');
    final height = image.height;
    final width = image.width;
    final int frameSize = width * height;

    final int outputWidth;
    final int outputHeight;
    final int rotatedCropLeft;
    final int rotatedCropRight;
    final int rotatedCropTop;
    final int rotatedCropBottom;

    Function(int x, int y) getNewX;
    Function(int x, int y) getNewY;

    switch (rotation) {
      case 90:
        outputWidth = height;
        outputHeight = width;
        if (mirror) {
          // rotate by 90 degrees and flip horizontally
          getNewX = (x, y) => height - y - 1;
          getNewY = (x, y) => width - x - 1;
          rotatedCropRight = cropBottom;
          rotatedCropBottom = cropRight;
          rotatedCropLeft = cropTop;
          rotatedCropTop = cropLeft;
        } else {
          // rotate by 90 degrees
          getNewX = (x, y) => y;
          getNewY = (x, y) => width - x - 1;
          rotatedCropRight = cropTop;
          rotatedCropBottom = cropRight;
          rotatedCropLeft = cropBottom;
          rotatedCropTop = cropLeft;
        }
        break;
      case 180:
        outputWidth = width;
        outputHeight = height;
        if (mirror) {
          // rotate by 180 degrees and flip horizontally
          getNewX = (x, y) => x;
          getNewY = (x, y) => height - y - 1;

          rotatedCropBottom = cropTop;
          rotatedCropLeft = cropLeft;
          rotatedCropTop = cropBottom;
          rotatedCropRight = cropRight;
        } else {
          // rotate by 180 degrees
          getNewX = (x, y) => width - x - 1;
          getNewY = (x, y) => height - y - 1;
          rotatedCropBottom = cropTop;
          rotatedCropLeft = cropRight;
          rotatedCropTop = cropBottom;
          rotatedCropRight = cropLeft;
        }
        break;
      case 270:
        outputWidth = height;
        outputHeight = width;
        if (mirror) {
          // rotate by 270 degrees and flip horizontally
          getNewX = (x, y) => y;
          getNewY = (x, y) => height - x;

          rotatedCropLeft = cropBottom;
          rotatedCropTop = cropRight;
          rotatedCropRight = cropTop;
          rotatedCropBottom = cropLeft;
        } else {
          // rotate by 270 degrees
          getNewX = (x, y) => height - y - 1;
          getNewY = (x, y) => x;
          rotatedCropLeft = cropTop;
          rotatedCropTop = cropRight;
          rotatedCropRight = cropBottom;
          rotatedCropBottom = cropLeft;
        }
        break;

      default:
        outputWidth = width;
        outputHeight = height;
        if (mirror) {
          // do not rotate, flip horizontally
          getNewX = (x, y) => x;
          getNewY = (x, y) => height - y - 1;
          rotatedCropTop = cropTop;
          rotatedCropRight = cropLeft;
          rotatedCropBottom = cropBottom;
          rotatedCropLeft = cropRight;
        } else {
          // do not rotate
          getNewX = (x, y) => x;
          getNewY = (x, y) => y;
          rotatedCropTop = cropTop;
          rotatedCropRight = cropRight;
          rotatedCropBottom = cropBottom;
          rotatedCropLeft = cropLeft;
        }
        break;
    }

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var convertedImage = imglib.Image(width: outputWidth, height: outputHeight); // Create Image buffer

    for (int yAxisPixel = cropTop, yp = cropLeft + cropTop * width; yAxisPixel < height - cropBottom; yAxisPixel++, yp += cropLeft + cropRight) {
      int uvp = frameSize + (yAxisPixel >> 1) * width + cropLeft, u = 0, v = 0;
      for (int xAxisPixel = cropLeft; xAxisPixel < width - cropRight; xAxisPixel++, yp++) {
        int y = (0xff & yuv420sp[yp]) - 16;
        if (y < 0) y = 0;
        if ((xAxisPixel & 1) == 0) {
          v = (0xff & yuv420sp[uvp++]) - 128;
          u = (0xff & yuv420sp[uvp++]) - 128;
        }
        int y1192 = 1192 * y;
        int r = (y1192 + 1634 * v).clamp(0, 262143);
        int g = (y1192 - 833 * v - 400 * u).clamp(0, 262143);
        int b = (y1192 + 2066 * u).clamp(0, 262143);

        // getting their 8-bit values.
        convertedImage.setPixelRgba(
          getNewX(xAxisPixel, yAxisPixel),
          getNewY(xAxisPixel, yAxisPixel),
          ((r << 6) & 0xff0000) >> 16,
          ((g >> 2) & 0xff00) >> 8,
          (b >> 10) & 0xff,
          0xff,
        );
      }
    }

    return ImageConverter(
      image: imglib.copyCrop(
        convertedImage,
        x: rotatedCropLeft,
        y: rotatedCropTop,
        width: convertedImage.width - rotatedCropLeft - rotatedCropRight,
        height: convertedImage.height - rotatedCropTop - rotatedCropBottom,
      ),
    );
  }

  factory ImageConverter._fromJPEG(CameraImage image) {
    Logger.info('Converting JPEG image to Image');
    return ImageConverter(image: imglib.decodeJpg(image.planes[0].bytes)!);
  }

  factory ImageConverter._fromBGRA8888(CameraImage image, int rotation, bool mirror, int cropLeft, int cropRight, int cropTop, int cropBottom) {
    Logger.info('Converting BGRA8888 image to Image');
    rotation = 360 - (rotation % 360); // if the image is rotated by 90, we need to rotate by another 270 to get the correct rotation (0/360)
    const numChannels = 4; // 1 for alpha, 3 for RGB
    var img = imglib.Image.fromBytes(
      width: image.width,
      height: image.height,
      rowStride: image.planes[0].bytesPerRow,
      numChannels: numChannels,
      bytesOffset: numChannels * 7, // i don't know why 7 pixels, but it works
      bytes: (image.planes[0].bytes).buffer,
      order: imglib.ChannelOrder.bgra,
    );
    if (rotation != 0) {
      img = imglib.copyRotate(img, angle: rotation);
    }
    if (mirror) {
      img = imglib.flip(img, direction: imglib.FlipDirection.horizontal);
    }
    img = imglib.copyCrop(
      img,
      x: cropLeft,
      y: cropTop,
      width: img.width - cropLeft - cropRight,
      height: img.height - cropTop - cropBottom,
    );
    return ImageConverter(image: img);
  }

  factory ImageConverter._fromYUV420(
    CameraImage image,
    int rotation,
    bool mirror, [
    int cropLeft = 0,
    int cropRight = 0,
    int cropTop = 0,
    int cropBottom = 0,
  ]) {
    Logger.info('Converting YUV420 image to Image');
    rotation = 360 - (rotation % 360); // if the rotation is 90, we need to rotate by 270 to get the correct rotation

    const alpha = 0xFF;
    final height = image.height;
    final width = image.width;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int outputWidth;
    final int outputHeight;
    final int rotatedCropLeft;
    final int rotatedCropRight;
    final int rotatedCropTop;
    final int rotatedCropBottom;

    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel!;
    Function(int x, int y) getNewX;
    Function(int x, int y) getNewY;

    switch (rotation) {
      case 90:
        outputWidth = height;
        outputHeight = width;
        if (mirror) {
          // rotate by 90 and flip horizontally
          getNewX = (x, y) => height - y - 1;
          getNewY = (x, y) => width - x - 1;
          rotatedCropRight = cropBottom;
          rotatedCropBottom = cropRight;
          rotatedCropLeft = cropTop;
          rotatedCropTop = cropLeft;
        } else {
          getNewX = (x, y) => y;
          getNewY = (x, y) => width - x - 1;
          rotatedCropRight = cropTop;
          rotatedCropBottom = cropRight;
          rotatedCropLeft = cropBottom;
          rotatedCropTop = cropLeft;
        }
        break;
      case 180:
        outputWidth = width;
        outputHeight = height;
        if (mirror) {
          // rotate by 180 and flip horizontally
          getNewX = (x, y) => x;
          getNewY = (x, y) => height - y - 1;

          rotatedCropBottom = cropTop;
          rotatedCropLeft = cropLeft;
          rotatedCropTop = cropBottom;
          rotatedCropRight = cropRight;
        } else {
          getNewX = (x, y) => width - x - 1;
          getNewY = (x, y) => height - y - 1;
          rotatedCropBottom = cropTop;
          rotatedCropLeft = cropRight;
          rotatedCropTop = cropBottom;
          rotatedCropRight = cropLeft;
        }
        break;
      case 270:
        outputWidth = height;
        outputHeight = width;
        if (mirror) {
          // rotate by 270 and flip horizontally
          getNewX = (x, y) => y;
          getNewY = (x, y) => height - x;

          rotatedCropLeft = cropBottom;
          rotatedCropTop = cropRight;
          rotatedCropRight = cropTop;
          rotatedCropBottom = cropLeft;
        } else {
          getNewX = (x, y) => height - y - 1;
          getNewY = (x, y) => x;
          rotatedCropLeft = cropTop;
          rotatedCropTop = cropRight;
          rotatedCropRight = cropBottom;
          rotatedCropBottom = cropLeft;
        }
        break;

      default:
        outputWidth = width;
        outputHeight = height;
        if (mirror) {
          // flip horizontally
          getNewX = (x, y) => x;
          getNewY = (x, y) => height - y - 1;
          rotatedCropTop = cropTop;
          rotatedCropRight = cropLeft;
          rotatedCropBottom = cropBottom;
          rotatedCropLeft = cropRight;
        } else {
          getNewX = (x, y) => x;
          getNewY = (x, y) => y;
          rotatedCropTop = cropTop;
          rotatedCropRight = cropRight;
          rotatedCropBottom = cropBottom;
          rotatedCropLeft = cropLeft;
        }
        break;
    }

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width: outputWidth, height: outputHeight); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888

    for (int y = cropTop; y < height - cropBottom; y++) {
      for (int x = cropLeft; x < width - cropRight; x++) {
        // if (x % 100 == 0) log("x: $x, y: $y");
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = (y * width + x);

        final yp = yPlane.bytes[index];
        final up = uPlane.bytes[uvIndex];
        final vp = vPlane.bytes[uvIndex];
        // Calculate pixel color

        final int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        final int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        final int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        final newX = getNewX(x, y);
        final newY = getNewY(x, y);

        if ((img.isBoundsSafe(newX, newY))) {
          img.setPixelRgba(newX, newY, r, g, b, alpha);
        }
      }
    }
    final cropedImg = imglib.copyCrop(
      img,
      x: rotatedCropLeft,
      y: rotatedCropTop,
      width: img.width - rotatedCropLeft - rotatedCropRight,
      height: img.height - rotatedCropTop - rotatedCropBottom,
    );
    return ImageConverter(image: cropedImg);
  }

  factory ImageConverter.fromFile(String path) {
    final img = imglib.decodeImage(File(path).readAsBytesSync())!;
    return ImageConverter(image: img);
  }

  factory ImageConverter.fromBytes(Uint8List bytes) {
    final img = imglib.decodeImage(bytes)!;
    return ImageConverter(image: img);
  }

  Uint8List toBytes() {
    return Uint8List.fromList(imglib.encodePng(image));
  }

  imglib.Image toImage() {
    return image;
  }
}
