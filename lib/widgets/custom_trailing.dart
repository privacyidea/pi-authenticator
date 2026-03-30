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
