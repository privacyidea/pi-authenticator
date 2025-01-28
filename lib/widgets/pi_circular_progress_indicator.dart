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
import 'package:flutter/material.dart';

import '../../../../../../../model/extensions/color_extension.dart';

class PiCircularProgressIndicator extends StatelessWidget {
  final double padding;
  final double size;
  final double strokeWidth;
  final double value;
  final String? semanticsLabel;
  final String? semanticsValue;
  final Color? _backgroundColor;
  final bool swapColors;

  const PiCircularProgressIndicator(
    this.value, {
    this.padding = 2.0,
    double? strokeWidth,
    this.size = 30,
    this.swapColors = false,
    Color? backgroundColor,
    this.semanticsLabel,
    this.semanticsValue,
    super.key,
  })  : _backgroundColor = backgroundColor,
        strokeWidth = size / 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var backgroundColor = _backgroundColor ?? theme.scaffoldBackgroundColor;
    return Padding(
      padding: EdgeInsets.all(strokeWidth / 2 + padding),
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          value: value,
          color: swapColors ? theme.colorScheme.primary.mixWith(backgroundColor, 0.6).withOpacity(1) : theme.colorScheme.primary,
          backgroundColor: swapColors ? theme.colorScheme.primary : theme.colorScheme.primary.mixWith(backgroundColor, 0.6).withOpacity(1),
          strokeCap: StrokeCap.round,
          strokeWidth: strokeWidth,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        ),
      ),
    );
  }
}
