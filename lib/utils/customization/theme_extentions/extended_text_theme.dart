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
