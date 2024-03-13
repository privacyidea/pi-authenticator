import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

class ImageConverter {
  final imglib.Image image;
  final Size size;

  ImageConverter({
    required this.image,
  }) : size = Size(image.width.toDouble(), image.height.toDouble());

  factory ImageConverter.fromCameraImage(CameraImage image, int rotation, {bool isFrontCamera = false}) {
    return switch (image.format.group) {
      ImageFormatGroup.yuv420 => ImageConverter._fromYUV420(image, rotation, isFrontCamera),
      ImageFormatGroup.bgra8888 => ImageConverter._fromBGRA8888(image),
      ImageFormatGroup.jpeg => ImageConverter._fromJPEG(image),
      ImageFormatGroup.nv21 => ImageConverter._fromNV21(image),
      ImageFormatGroup.unknown => throw ArgumentError('Unknown image format'),
    };
  }

  factory ImageConverter._fromNV21(CameraImage image) {
    log('ImageConverter._fromNV21');
    final width = image.width.toInt();
    final height = image.height.toInt();
    Uint8List yuv420sp = image.planes[0].bytes;
    final convertedImage = imglib.Image(height: height, width: width);
    final int frameSize = width * height;

    for (int j = 0, yp = 0; j < height; j++) {
      int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
      for (int i = 0; i < width; i++, yp++) {
        int y = (0xff & yuv420sp[yp]) - 16;
        if (y < 0) y = 0;
        if ((i & 1) == 0) {
          v = (0xff & yuv420sp[uvp++]) - 128;
          u = (0xff & yuv420sp[uvp++]) - 128;
        }
        int y1192 = 1192 * y;
        int r = (y1192 + 1634 * v);
        int g = (y1192 - 833 * v - 400 * u);
        int b = (y1192 + 2066 * u);

        if (r < 0) {
          r = 0;
        } else if (r > 262143) {
          r = 262143;
        }
        if (g < 0) {
          g = 0;
        } else if (g > 262143) {
          g = 262143;
        }
        if (b < 0) {
          b = 0;
        } else if (b > 262143) {
          b = 262143;
        }

        // getting their 8-bit values.
        convertedImage.setPixelRgba(
          i,
          j,
          ((r << 6) & 0xff0000) >> 16,
          ((g >> 2) & 0xff00) >> 8,
          (b >> 10) & 0xff,
          0xff,
        );
      }
    }

    return ImageConverter(
      image: convertedImage,
    );
  }

  factory ImageConverter._fromJPEG(CameraImage image) {
    log('ImageConverter._fromJPEG');
    return ImageConverter(image: imglib.decodeJpg(image.planes[0].bytes)!);
  }

  factory ImageConverter._fromBGRA8888(CameraImage image) {
    log('ImageConverter._fromBGRA8888');
    return ImageConverter(
      image: imglib.Image.fromBytes(
        width: (image.planes[0].bytesPerRow / 4).round(),
        height: image.height,
        bytes: (image.planes[0].bytes).buffer,
      ),
    );
  }

  factory ImageConverter._fromYUV420(CameraImage image, int rotation, bool mirror) {
    rotation = 360 - rotation; // if the rotation is 90, we need to rotate by 270 to get the correct rotation
    const alpha = 0xFF;
    final height = image.height;
    final width = image.width;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final int outputWidth = rotation == 90 || rotation == 270 ? height : width;
    final int outputHeight = rotation == 90 || rotation == 270 ? width : height;
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel!;
    Function(int x, int y) getNewX;
    Function(int x, int y) getNewY;

    switch (rotation) {
      case 90:
        if (mirror) {
          // rotate by 90 and flip horizontally
          getNewX = (x, y) => height - y - 1;
          getNewY = (x, y) => width - x - 1;
        } else {
          getNewX = (x, y) => y;
          getNewY = (x, y) => width - x - 1;
        }
        break;
      case 180:
        if (mirror) {
          // rotate by 180 and flip horizontally
          getNewX = (x, y) => x;
          getNewY = (x, y) => height - y - 1;
        } else {
          getNewX = (x, y) => width - x - 1;
          getNewY = (x, y) => height - y - 1;
        }
        break;
      case 270:
        if (mirror) {
          // rotate by 270 and flip horizontally
          getNewX = (x, y) => y;
          getNewY = (x, y) => outputHeight - x;
        } else {
          getNewX = (x, y) => height - y - 1;
          getNewY = (x, y) => x;
        }
        break;

      default:
        if (mirror) {
          // flip horizontally
          getNewX = (x, y) => x;
          getNewY = (x, y) => height - y - 1;
        } else {
          getNewX = (x, y) => x;
          getNewY = (x, y) => y;
        }
        break;
    }

    try {
      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var img = imglib.Image(width: outputWidth, height: outputHeight); // Create Image buffer

      // Fill image buffer with plane[0] from YUV420_888
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
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
      return ImageConverter(image: img);
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
      throw e;
    }
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
