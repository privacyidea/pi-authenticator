import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

class ImageConverter {
  final imglib.Image image;
  final Size size;

  ImageConverter({
    required this.image,
  }) : size = Size(image.width.toDouble(), image.height.toDouble());

  factory ImageConverter.fromCameraImage(CameraImage image, int rotation, {bool isFrontCamera = false}) {
    if (image.format.group != ImageFormatGroup.yuv420 || image.planes.length != 3) {
      throw ArgumentError('Only support YUV_420 format');
    }
    return ImageConverter._rotatedCameraImage(image, rotation: rotation, mirror: isFrontCamera);
  }

  factory ImageConverter._rotatedCameraImage(CameraImage image, {required int rotation, required bool mirror}) {
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
