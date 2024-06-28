import 'dart:ui';

import 'package:flutter/material.dart';

class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderPaddingPercent;

  const ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.overlayColor = const Color(0x88000000),
    required this.borderPaddingPercent,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..fillType = PathFillType.evenOdd
    ..addPath(getOuterPath(rect), Offset.zero);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..moveTo(rect.left, rect.bottom)
    ..lineTo(rect.left, rect.top)
    ..lineTo(rect.right, rect.top)
    ..lineTo(rect.right, rect.bottom)
    ..lineTo(rect.left, rect.bottom);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    const lineSize = 30;

    final isPortrait = rect.height > rect.width;

    final width = rect.width;
    final double borderWidthSize;
    final height = rect.height;
    final double borderHeightSize;

    if (isPortrait) {
      borderWidthSize = width * borderPaddingPercent / 100;
      borderHeightSize = height - (width - borderWidthSize);
    } else {
      borderHeightSize = height * borderPaddingPercent / 100;
      borderWidthSize = width - (height - borderHeightSize);
    }

    final borderSize = Size(borderWidthSize / 2, borderHeightSize / 2);

    var paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.top, rect.right, borderSize.height + rect.top),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.bottom - borderSize.height, rect.right, rect.bottom),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.top + borderSize.height, rect.left + borderSize.width, rect.bottom - borderSize.height),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.right - borderSize.width, rect.top + borderSize.height, rect.right, rect.bottom - borderSize.height),
        paint,
      );

    paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderOffset = borderWidth / 2;
    final realReact = Rect.fromLTRB(borderSize.width + borderOffset, borderSize.height + borderOffset + rect.top, width - borderSize.width - borderOffset,
        height - borderSize.height - borderOffset + rect.top);

    // Draw top right corner
    canvas
      ..drawPath(
          Path()
            ..moveTo(realReact.right, realReact.top)
            ..lineTo(realReact.right, realReact.top + lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.right, realReact.top)
            ..lineTo(realReact.right - lineSize, realReact.top),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.right, realReact.top)],
        paint,
      )

      // Draw top left corner
      ..drawPath(
          Path()
            ..moveTo(realReact.left, realReact.top)
            ..lineTo(realReact.left, realReact.top + lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.left, realReact.top)
            ..lineTo(realReact.left + lineSize, realReact.top),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.left, realReact.top)],
        paint,
      )

      // Draw bottom right corner
      ..drawPath(
          Path()
            ..moveTo(realReact.right, realReact.bottom)
            ..lineTo(realReact.right, realReact.bottom - lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.right, realReact.bottom)
            ..lineTo(realReact.right - lineSize, realReact.bottom),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.right, realReact.bottom)],
        paint,
      )

      // Draw bottom left corner
      ..drawPath(
          Path()
            ..moveTo(realReact.left, realReact.bottom)
            ..lineTo(realReact.left, realReact.bottom - lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.left, realReact.bottom)
            ..lineTo(realReact.left + lineSize, realReact.bottom),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.left, realReact.bottom)],
        paint,
      );
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderPaddingPercent: borderPaddingPercent,
    );
  }
}
