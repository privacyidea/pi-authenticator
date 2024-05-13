import 'package:flutter/material.dart';

class ActionTheme extends ThemeExtension<ActionTheme> {
  final Color deleteColor;
  final Color editColor;
  final Color lockColor;
  final Color foregroundColor;
  const ActionTheme({
    required this.deleteColor,
    required this.editColor,
    required this.lockColor,
    required this.foregroundColor,
  });

  @override
  ThemeExtension<ActionTheme> lerp(covariant ActionTheme? other, double t) => ActionTheme(
        deleteColor: Color.lerp(deleteColor, other?.deleteColor, t) ?? deleteColor,
        editColor: Color.lerp(editColor, other?.editColor, t) ?? editColor,
        lockColor: Color.lerp(lockColor, other?.lockColor, t) ?? lockColor,
        foregroundColor: Color.lerp(foregroundColor, other?.foregroundColor, t) ?? foregroundColor,
      );

  @override
  ThemeExtension<ActionTheme> copyWith({Color? deleteColor, Color? editColor, Color? lockColor, Color? foregroundColor}) => ActionTheme(
        deleteColor: deleteColor ?? this.deleteColor,
        editColor: editColor ?? this.editColor,
        lockColor: lockColor ?? this.lockColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
      );
}
