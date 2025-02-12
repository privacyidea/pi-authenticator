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

class ExtendedTextTheme extends ThemeExtension<ExtendedTextTheme> {
  final TextStyle tokenTile;
  final TextStyle tokenTileSubtitle;
  final String veilingCharacter;

  ExtendedTextTheme({
    this.veilingCharacter = '●',
    TextStyle? tokenTile,
    TextStyle? tokenTileSubtitle,
  })  : tokenTile = const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ).merge(tokenTile),
        tokenTileSubtitle = const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ).merge(tokenTileSubtitle);

  @override
  ThemeExtension<ExtendedTextTheme> copyWith({
    TextStyle? otpTextStyle,
    TextStyle? otpSubtitleTextStyle,
  }) =>
      ExtendedTextTheme(
        tokenTile: otpTextStyle ?? tokenTile,
        tokenTileSubtitle: otpSubtitleTextStyle ?? tokenTileSubtitle,
      );

  @override
  ThemeExtension<ExtendedTextTheme> lerp(ExtendedTextTheme? other, double t) => ExtendedTextTheme(
        tokenTile: TextStyle.lerp(tokenTile, other?.tokenTile, t) ?? tokenTile,
      );
}
