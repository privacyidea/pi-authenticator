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

class TokenTileTheme extends ThemeExtension<TokenTileTheme> {
  final Color deleteColor;
  final Color editColor;
  final Color lockColor;
  final Color transferColor;

  final Color actionDisabledColor;

  final Color actionForegroundColor;

  final Color defaultOtpColor;
  final Color? warningOtpColor;
  final Color? criticalOtpColor;
  final Color defaultCountdownColor;
  final Color? warningCountdownColor;
  final Color? criticalCountdownColor;

  final Color tileSubtitleColor;
  final Color tileIconColor;

  const TokenTileTheme({
    required this.deleteColor,
    required this.editColor,
    required this.lockColor,
    required this.transferColor,
    required this.actionDisabledColor,
    required this.actionForegroundColor,
    required this.defaultOtpColor,
    this.warningOtpColor,
    this.criticalOtpColor,
    required this.defaultCountdownColor,
    this.warningCountdownColor,
    this.criticalCountdownColor,
    required this.tileSubtitleColor,
    required this.tileIconColor,
  });

  @override
  ThemeExtension<TokenTileTheme> lerp(covariant TokenTileTheme? other, double t) => TokenTileTheme(
        deleteColor: Color.lerp(deleteColor, other?.deleteColor, t) ?? deleteColor,
        editColor: Color.lerp(editColor, other?.editColor, t) ?? editColor,
        lockColor: Color.lerp(lockColor, other?.lockColor, t) ?? lockColor,
        transferColor: Color.lerp(transferColor, other?.transferColor, t) ?? transferColor,
        actionDisabledColor: Color.lerp(actionDisabledColor, other?.actionDisabledColor, t) ?? actionDisabledColor,
        actionForegroundColor: Color.lerp(actionForegroundColor, other?.actionForegroundColor, t) ?? actionForegroundColor,
        defaultOtpColor: Color.lerp(defaultOtpColor, other?.defaultOtpColor, t) ?? defaultOtpColor,
        warningOtpColor: Color.lerp(warningOtpColor, other?.warningOtpColor, t) ?? warningOtpColor,
        criticalOtpColor: Color.lerp(criticalOtpColor, other?.criticalOtpColor, t) ?? criticalOtpColor,
        defaultCountdownColor: Color.lerp(defaultCountdownColor, other?.defaultCountdownColor, t) ?? defaultCountdownColor,
        warningCountdownColor: Color.lerp(warningCountdownColor, other?.warningCountdownColor, t) ?? warningCountdownColor,
        criticalCountdownColor: Color.lerp(criticalCountdownColor, other?.criticalCountdownColor, t) ?? criticalCountdownColor,
        tileSubtitleColor: Color.lerp(tileSubtitleColor, other?.tileSubtitleColor, t) ?? tileSubtitleColor,
        tileIconColor: Color.lerp(tileIconColor, other?.tileIconColor, t) ?? tileIconColor,
      );

  @override
  ThemeExtension<TokenTileTheme> copyWith({
    Color? deleteColor,
    Color? editColor,
    Color? lockColor,
    Color? transferColor,
    Color? actionDisabledColor,
    Color? actionForegroundColor,
    Color? defaultOtpColor,
    Color? Function()? warningOtpColor,
    Color? Function()? criticalOtpColor,
    Color? defaultCountdownColor,
    Color? Function()? warningCountdownColor,
    Color? Function()? criticalCountdownColor,
    Color? tileSubtitleColor,
    Color? tileIconColor,
  }) =>
      TokenTileTheme(
        deleteColor: deleteColor ?? this.deleteColor,
        editColor: editColor ?? this.editColor,
        lockColor: lockColor ?? this.lockColor,
        transferColor: transferColor ?? this.transferColor,
        actionDisabledColor: actionDisabledColor ?? this.actionDisabledColor,
        actionForegroundColor: actionForegroundColor ?? this.actionForegroundColor,
        defaultOtpColor: defaultOtpColor ?? this.defaultOtpColor,
        warningOtpColor: warningOtpColor != null ? warningOtpColor() : this.warningOtpColor,
        criticalOtpColor: criticalOtpColor != null ? criticalOtpColor() : this.criticalOtpColor,
        defaultCountdownColor: defaultCountdownColor ?? this.defaultCountdownColor,
        warningCountdownColor: warningCountdownColor != null ? warningCountdownColor() : this.warningCountdownColor,
        criticalCountdownColor: criticalCountdownColor != null ? criticalCountdownColor() : this.criticalCountdownColor,
        tileSubtitleColor: tileSubtitleColor ?? this.tileSubtitleColor,
        tileIconColor: tileIconColor ?? this.tileIconColor,
      );
}
