import 'dart:math';

import 'package:flutter/material.dart';

class CustomTrailing extends StatelessWidget {
  final Widget child;
  final double maxPercentWidth;
  final double maxPixelsWidth;
  final EdgeInsetsGeometry? padding;
  final BoxFit fit;

  /// Creates a widget that limits the width of [child] to [maxPercentWidth] of
  /// the parent width or [maxPixelsWidth] if the parent width is too small.
  /// Defaults: [maxPercentWidth] = 27.5, [maxPixelsWidth] = 85
  const CustomTrailing({required this.child, super.key, double? maxPercentWidth, double? maxPixelsWidth, this.padding, this.fit = BoxFit.contain})
      : maxPercentWidth = maxPercentWidth ?? 27.5,
        maxPixelsWidth = maxPixelsWidth ?? 85;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final boxSize = min(maxPixelsWidth, constraints.maxWidth * maxPercentWidth / 100);
      return SizedBox(
        width: boxSize,
        height: boxSize,
        child: FittedBox(
          fit: fit,
          child: child,
        ),
      );
    });
  }
}
