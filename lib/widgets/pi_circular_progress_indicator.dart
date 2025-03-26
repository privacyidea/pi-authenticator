/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
  final Color? _foregroundColor;
  final bool swapColors;

  const PiCircularProgressIndicator(
    this.value, {
    this.padding = 2.0,
    double? strokeWidth,
    this.size = 30,
    this.swapColors = false,
    Color? backgroundColor,
    Color? foregroundColor,
    this.semanticsLabel,
    this.semanticsValue,
    super.key,
  })  : _backgroundColor = backgroundColor,
        _foregroundColor = foregroundColor,
        strokeWidth = size / 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _backgroundColor ?? theme.scaffoldBackgroundColor;
    final foregroundColor = _foregroundColor ?? theme.colorScheme.primary;
    return Padding(
      padding: EdgeInsets.all(strokeWidth / 2 + padding),
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          value: value,
          color: swapColors ? foregroundColor.mixWith(backgroundColor, 0.6).withValues(alpha: 1) : foregroundColor,
          backgroundColor: swapColors ? foregroundColor : foregroundColor.mixWith(backgroundColor, 0.6).withValues(alpha: 1),
          strokeCap: StrokeCap.round,
          strokeWidth: strokeWidth,
          semanticsLabel: '$semanticsLabel',
          semanticsValue: semanticsValue,
        ),
      ),
    );
  }
}
