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
import 'dart:ui';

import 'package:flutter/material.dart';

class AppDimensions extends ThemeExtension<AppDimensions> {
  /// Small spacing (default: 8.0).
  /// Use for: [gap], [padding], or [margin] between small, related sub-elements.
  final double spacingSmall;
  static const defaultSpacingSmall = 8.0;

  /// Medium spacing (default: 16.0).
  /// Use for: standard [padding] inside cards or [gap] and [margin] between content blocks.
  final double spacingMedium;
  static const defaultSpacingMedium = 16.0;

  /// Large spacing (default: 24.0).
  /// Use for: large [gap] or [margin] between major sections and layout containers.
  final double spacingLarge;
  static const defaultSpacingLarge = 24.0;

  /// The horizontal [padding] or [margin] between the screen edge and the main content.
  final double screenPadding;
  static const defaultScreenPadding = 16.0;

  /// The CSS [border-radius] equivalent for cards, buttons, and dialogs.
  final double borderRadius;
  static const defaultBorderRadius = 12.0;

  /// The size for small icons, such as those in [ListTile]s or [IconButton]s.
  final double iconSizeSmall;
  static const defaultIconSizeSmall = 20.0;

  /// The standard size for icons in the app, used in [Icon] widgets and [IconButton]s.
  final double iconSizeMedium;
  static const defaultIconSizeMedium = 24.0;

  /// The size for large icons, such as those in headers or important action buttons.
  final double iconSizeLarge;
  static const defaultIconSizeLarge = 32.0;

  /// The thickness of [Divider]s or [Border]s.
  /// Equivalent to CSS [border-width].
  final double strokeWidth;
  static const defaultStrokeWidth = 2.0;

  /// The standard height for interactive elements like [ElevatedButton] or [TextField].
  final double controlHeight;
  static const defaultControlHeight = 48.0;

  /// The maximum width for content on large screens (tablets/desktop) to maintain readability.
  final double maxContentWidth;
  static const defaultMaxContentWidth = 600.0;

  const AppDimensions({
    double? spacingSmall,
    double? spacingMedium,
    double? spacingLarge,
    double? screenPadding,
    double? borderRadius,
    double? iconSizeSmall,
    double? iconSizeMedium,
    double? iconSizeLarge,
    double? strokeWidth,
    double? controlHeight,
    double? maxContentWidth,
  }) : spacingSmall = spacingSmall ?? defaultSpacingSmall,
       spacingMedium = spacingMedium ?? defaultSpacingMedium,
       spacingLarge = spacingLarge ?? defaultSpacingLarge,
       screenPadding = screenPadding ?? defaultScreenPadding,
       borderRadius = borderRadius ?? defaultBorderRadius,
       iconSizeSmall = iconSizeSmall ?? defaultIconSizeSmall,
       iconSizeMedium = iconSizeMedium ?? defaultIconSizeMedium,
       iconSizeLarge = iconSizeLarge ?? defaultIconSizeLarge,
       strokeWidth = strokeWidth ?? defaultStrokeWidth,
       controlHeight = controlHeight ?? defaultControlHeight,
       maxContentWidth = maxContentWidth ?? defaultMaxContentWidth;

  @override
  AppDimensions lerp(ThemeExtension<AppDimensions>? other, double t) {
    if (other is! AppDimensions) return this;
    return AppDimensions(
      spacingSmall: lerpDouble(spacingSmall, other.spacingSmall, t)!,
      spacingMedium: lerpDouble(spacingMedium, other.spacingMedium, t)!,
      spacingLarge: lerpDouble(spacingLarge, other.spacingLarge, t)!,
      screenPadding: lerpDouble(screenPadding, other.screenPadding, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      iconSizeMedium: lerpDouble(iconSizeMedium, other.iconSizeMedium, t)!,
      strokeWidth: lerpDouble(strokeWidth, other.strokeWidth, t)!,
      controlHeight: lerpDouble(controlHeight, other.controlHeight, t)!,
      maxContentWidth: lerpDouble(maxContentWidth, other.maxContentWidth, t)!,
    );
  }

  @override
  AppDimensions copyWith({
    double? spacingSmall,
    double? spacingMedium,
    double? spacingLarge,
    double? screenPadding,
    double? borderRadius,
    double? iconSizeSmall,
    double? iconSizeMedium,
    double? iconSizeLarge,
    double? strokeWidth,
    double? controlHeight,
    double? maxContentWidth,
  }) {
    return AppDimensions(
      spacingSmall: spacingSmall ?? this.spacingSmall,
      spacingMedium: spacingMedium ?? this.spacingMedium,
      spacingLarge: spacingLarge ?? this.spacingLarge,
      screenPadding: screenPadding ?? this.screenPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      iconSizeSmall: iconSizeSmall ?? this.iconSizeSmall,
      iconSizeMedium: iconSizeMedium ?? this.iconSizeMedium,
      iconSizeLarge: iconSizeLarge ?? this.iconSizeLarge,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      controlHeight: controlHeight ?? this.controlHeight,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    );
  }

  /// Factory to create dimensions from a JSON map.
  /// Provides hardcoded fallbacks if keys are missing in the JSON.
  factory AppDimensions.fromJson(Map<String, dynamic> json) {
    return AppDimensions(
      borderRadius: (json['borderRadius'] as num?)?.toDouble(),
      iconSizeSmall: (json['iconSizeSmall'] as num?)?.toDouble(),
      iconSizeMedium: (json['iconSizeMedium'] as num?)?.toDouble(),
      iconSizeLarge: (json['iconSizeLarge'] as num?)?.toDouble(),
      controlHeight: (json['controlHeight'] as num?)?.toDouble(),
      spacingSmall: (json['spacingSmall'] as num?)?.toDouble(),
      spacingMedium: (json['spacingMedium'] as num?)?.toDouble(),
      spacingLarge: (json['spacingLarge'] as num?)?.toDouble(),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble(),
      screenPadding: (json['screenPadding'] as num?)?.toDouble(),
      maxContentWidth: (json['maxContentWidth'] as num?)?.toDouble(),
    );
  }

  /// Converts the dimensions to a JSON map for serialization.
  Map<String, dynamic> toJson() {
    return {
      'borderRadius': borderRadius,
      'iconSizeSmall': iconSizeSmall,
      'iconSizeMedium': iconSizeMedium,
      'iconSizeLarge': iconSizeLarge,
      'controlHeight': controlHeight,
      'spacingSmall': spacingSmall,
      'spacingMedium': spacingMedium,
      'spacingLarge': spacingLarge,
      'strokeWidth': strokeWidth,
    };
  }
}
