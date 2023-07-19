import 'package:flutter/material.dart';

class CustomPaintAppBar extends CustomPainter {
  BuildContext buildContext;

  CustomPaintAppBar({required this.buildContext});

  // paints the curves of the appbar
  @override
  void paint(Canvas canvas, Size size) {
    final ThemeData mode = Theme.of(buildContext);
    Color appBarColor =
        mode.brightness == Brightness.dark ? Color(0xFF303030) : Colors.white;
    Paint paint = Paint()
      ..color = appBarColor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(10.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawShadow(path, Colors.white, 10, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
