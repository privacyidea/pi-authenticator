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
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../enums/image_file_type.dart';

extension ImageFileTypeX on ImageFileType {
  Widget buildImageWidget(Uint8List imageData) => switch (this) {
        ImageFileType.svg => SvgPicture.memory(
            imageData,
            colorFilter: ColorFilter.mode(
              Colors.transparent,
              BlendMode.srcOver,
            ),
          ),
        ImageFileType.svgz => SvgPicture.memory(
            imageData,
            colorFilter: ColorFilter.mode(
              Colors.transparent,
              BlendMode.srcOver,
            ),
          ),
        ImageFileType.png => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFileType.jpg => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFileType.jpeg => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFileType.gif => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFileType.bmp => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
        ImageFileType.webp => Image.memory(
            imageData,
            colorBlendMode: BlendMode.srcOver,
          ),
      };
}
