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

import 'package:flutter/material.dart';

class ElevatedDeleteButtonTheme extends ThemeExtension<ElevatedDeleteButtonTheme> {
  final ButtonStyle style;
  const ElevatedDeleteButtonTheme({required this.style});

  @override
  ThemeExtension<ElevatedDeleteButtonTheme> copyWith({
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? actionForegroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<Color?>? shadowColor,
    WidgetStateProperty<Color?>? surfaceTintColor,
    WidgetStateProperty<double?>? elevation,
    WidgetStateProperty<EdgeInsetsGeometry?>? padding,
    WidgetStateProperty<Size?>? minimumSize,
    WidgetStateProperty<Size?>? fixedSize,
    WidgetStateProperty<Size?>? maximumSize,
    WidgetStateProperty<Color?>? iconColor,
    WidgetStateProperty<double?>? iconSize,
    WidgetStateProperty<BorderSide?>? side,
    WidgetStateProperty<OutlinedBorder?>? shape,
    WidgetStateProperty<MouseCursor?>? mouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    Widget Function(BuildContext, Set<WidgetState>, Widget?)? backgroundBuilder,
    Widget Function(BuildContext, Set<WidgetState>, Widget?)? foregroundBuilder,
  }) =>
      ElevatedDeleteButtonTheme(
        style: style.copyWith(
          textStyle: textStyle,
          backgroundColor: backgroundColor,
          foregroundColor: actionForegroundColor,
          overlayColor: overlayColor,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          elevation: elevation,
          padding: padding,
          minimumSize: minimumSize,
          fixedSize: fixedSize,
          maximumSize: maximumSize,
          iconColor: iconColor,
          iconSize: iconSize,
          side: side,
          shape: shape,
          mouseCursor: mouseCursor,
          visualDensity: visualDensity,
          tapTargetSize: tapTargetSize,
          animationDuration: animationDuration,
          enableFeedback: enableFeedback,
          alignment: alignment,
          splashFactory: splashFactory,
          backgroundBuilder: backgroundBuilder,
          foregroundBuilder: foregroundBuilder,
        ),
      );

  @override
  ThemeExtension<ElevatedDeleteButtonTheme> lerp(covariant ElevatedDeleteButtonTheme? other, double t) =>
      ElevatedDeleteButtonTheme(style: ButtonStyle.lerp(style, other?.style, t) ?? style);
}
