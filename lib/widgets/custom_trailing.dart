/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/customization/theme_extentions/app_dimensions.dart';

class CustomTrailing extends StatelessWidget {
  final Widget child;
  final double maxPercentWidth;
  final double maxPixelsWidth;
  final BoxFit fit;

  /// Creates a widget that limits the width of [child] to [maxPercentWidth] of
  /// the parent width or [maxPixelsWidth] if the parent width is too small.
  const CustomTrailing({
    required this.child,
    super.key,
    double? maxPercentWidth,
    double? maxPixelsWidth,
    this.fit = BoxFit.contain,
  }) : maxPercentWidth = maxPercentWidth ?? 20,
       maxPixelsWidth = maxPixelsWidth ?? 85;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = min(
          maxPixelsWidth,
          constraints.maxWidth * maxPercentWidth / 100,
        );
        final dimensions =
            Theme.of(context).extension<AppDimensions>() ??
            const AppDimensions();
        return Padding(
          padding: EdgeInsets.only(right: dimensions.spacingSmall),
          child: SizedBox(
            width: boxSize,
            height: boxSize,
            child: FittedBox(fit: fit, child: child),
          ),
        );
      },
    );
  }
}
