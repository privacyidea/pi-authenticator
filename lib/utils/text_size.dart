import 'package:flutter/material.dart';

Size textSizeOf(String text, TextStyle style, {int? maxLines = 1, double minWidth = 0, double maxWidth = double.infinity}) {
  final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: maxLines, textDirection: TextDirection.ltr)
    ..layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.size;
}
