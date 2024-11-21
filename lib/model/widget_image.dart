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

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../../model/extensions/enums/image_file_type_extension.dart';
import '../utils/logger.dart';
import 'enums/image_file_type.dart';

part 'widget_image.g.dart';

class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}

@JsonSerializable()
@Uint8ListConverter()
class WidgetImage {
  final ImageFileType fileType;
  final Uint8List imageData;
  final String fileName;

  String get fullFileName => '$fileName.${fileType.extension}';

  WidgetImage({
    required this.fileType,
    required this.imageData,
    required this.fileName,
  });

  @override
  String toString() {
    return 'WidgetImage{fileType: $fileType, imageData: $imageData}';
  }

  @override
  bool operator ==(Object other) => other is WidgetImage && other.fileType == fileType && other.imageData == imageData;
  @override
  int get hashCode => Object.hash(runtimeType, fileType, imageData);

  Widget? _widget;
  Widget get getWidget {
    if (_widget != null) return _widget!;
    _widget = _buildImageWidget();
    return _widget!;
  }

  Widget _buildImageWidget() {
    try {
      return fileType.buildImageWidget(imageData);
    } catch (e) {
      Logger.error('Image is not an ${fileType.typeName}, or the image data is corrupted.', error: e);
      rethrow;
    }
  }

  factory WidgetImage.fromJson(Map<String, dynamic> json) => _$WidgetImageFromJson(json);
  Map<String, dynamic> toJson() => _$WidgetImageToJson(this);

  XFile? toXFile() {
    return fileType.buildXFile(imageData, fileName);
  }
}
