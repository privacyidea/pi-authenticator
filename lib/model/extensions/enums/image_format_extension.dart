/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/logger.dart';
import '../../enums/image_format.dart';

extension ImageFormatX on ImageFormat {
  static ImageFormat fromExtensionString(String ex) => switch (ex) {
        'svg' => ImageFormat.svg,
        'svgz' => ImageFormat.svgz,
        'png' => ImageFormat.png,
        'jpg' => ImageFormat.jpg,
        'jpeg' => ImageFormat.jpeg,
        'gif' => ImageFormat.gif,
        'bmp' => ImageFormat.bmp,
        'webp' => ImageFormat.webp,
        _ => ImageFormat.unknown,
      };

  static ImageFormat fromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return fromExtensionString(extension);
  }

  String get extension => switch (this) {
        ImageFormat.unknown => '',
        ImageFormat.svg => 'svg',
        ImageFormat.svgz => 'svgz',
        ImageFormat.png => 'png',
        ImageFormat.jpg => 'jpg',
        ImageFormat.jpeg => 'jpeg',
        ImageFormat.gif => 'gif',
        ImageFormat.bmp => 'bmp',
        ImageFormat.webp => 'webp',
      };

  Widget _tryAllFormats(Uint8List imageData) {
    try {
      return SvgPicture.memory(
        imageData,
        colorFilter: ColorFilter.mode(
          Colors.transparent,
          BlendMode.srcOver,
        ),
      );
      // ignore: empty_catches
    } catch (e) {}

    try {
      return Image.memory(
        imageData,
        colorBlendMode: BlendMode.srcOver,
      );
      // ignore: empty_catches
    } catch (e) {}
    Logger.warning('Could not decode image data for format: $this');
    return const SizedBox.shrink();
  }

  Widget buildImageWidget(Uint8List imageData) => switch (this) {
        ImageFormat.unknown => _tryAllFormats(imageData),
        ImageFormat.svg => SvgPicture.memory(
            imageData,
            colorFilter: ColorFilter.mode(
              Colors.transparent,
              BlendMode.srcOver,
            ),
          ),
        ImageFormat.svgz => SvgPicture.memory(
            imageData,
            colorFilter: ColorFilter.mode(
              Colors.transparent,
              BlendMode.srcOver,
            ),
          ),
        ImageFormat.png => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFormat.jpg => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFormat.jpeg => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFormat.gif => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFormat.bmp => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFormat.webp => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
      };

  Future<Size?> getImageSize(Uint8List imageData) async {
    double? width;
    double? height;
    switch (this) {
      case ImageFormat.unknown:
        final image = _tryAllFormats(imageData);
        if (image is SvgPicture) {
          width = image.width;
          height = image.height;
        } else if (image is Image) {
          final decodedImage = await decodeImageFromList(imageData);
          width = decodedImage.width.toDouble();
          height = decodedImage.height.toDouble();
        }
        break;
      case ImageFormat.svg:
      case ImageFormat.svgz:
        final image = SvgPicture.memory(imageData);
        width = image.width;
        height = image.height;
        break;
      // The following image formats are supported by decodeImageFromList JPEG, PNG, GIF, Animated GIF, WebP, Animated WebP, BMP, and WBMP.
      case ImageFormat.png:
      case ImageFormat.jpg:
      case ImageFormat.jpeg:
      case ImageFormat.gif:
      case ImageFormat.bmp:
      case ImageFormat.webp:
        final decodedImage = await decodeImageFromList(imageData);
        width = decodedImage.width.toDouble();
        height = decodedImage.height.toDouble();
        break;
    }
    if (width == null || height == null) {
      Logger.warning('Could not determine the size of the image.');
      return null;
    }
    return Size(width, height);
  }

  /// Adds the file extension to the given [fileName] based on the [ImageFormat] if it is not already present.
  /// If the [ImageFormat] is [ImageFormat.unknown], it returns the original [fileName].
  String addExtension(String fileName) {
    if (this == ImageFormat.unknown) return fileName;
    final extension = toString().split('.').last;
    if (fileName.endsWith(extension)) return fileName;
    return '$fileName.$extension';
  }

  String get name => switch (this) {
        ImageFormat.unknown => 'Unknown',
        ImageFormat.svg => 'Scalable Vector Graphic',
        ImageFormat.svgz => 'Scalable Vector Graphic (compressed)',
        ImageFormat.png => 'PNG',
        ImageFormat.jpg => 'JPEG',
        ImageFormat.jpeg => 'JPEG',
        ImageFormat.gif => 'GIF',
        ImageFormat.bmp => 'Bitmap',
        ImageFormat.webp => 'WebP',
      };

  String get mimeType => switch (this) {
        ImageFormat.unknown => 'application/octet-stream',
        ImageFormat.svg => 'image/svg+xml',
        ImageFormat.svgz => 'image/svg+xml',
        ImageFormat.png => 'image/png',
        ImageFormat.jpg => 'image/jpeg',
        ImageFormat.jpeg => 'image/jpeg',
        ImageFormat.gif => 'image/gif',
        ImageFormat.bmp => 'image/bmp',
        ImageFormat.webp => 'image/webp',
      };

  /// Builds an [XFile] from the given [imageData] and [fileName].
  /// The [fileName] is used as the name of the file.
  /// The file extension is determined by the [ImageFormat].
  XFile buildXFile(Uint8List imageData, String fileName) => XFile.fromData(imageData, name: addExtension(fileName), mimeType: mimeType);

  /// Compares the given [extension] with the extension of this [ImageFormat] case-insensitive.
  bool matches(String extension) => extension.toLowerCase() == toString().split('.').last.toLowerCase();
}
