import 'package:flutter/material.dart';

import 'filter_token_widget.dart';

class ExpandableAppBar extends StatefulWidget {
  final Widget appBar;

  const ExpandableAppBar({
    required this.appBar,
    super.key,
  });

  @override
  State<ExpandableAppBar> createState() => _ExpandableAppBarState();
}

class _ExpandableAppBarState extends State<ExpandableAppBar> {
  static const double maxExpansion = 50 + minExpansion;
  static const double minExpansion = 14;
  double currentExpansion = minExpansion;
  double expandTarget = minExpansion;

  void _onVertivalDragUpdate(DragUpdateDetails details) {
    if (expandTarget == maxExpansion && details.delta.dy > 0) return;
    if (expandTarget == minExpansion && details.delta.dy < 0) return;
    setState(() {
      if (expandTarget + details.delta.dy > maxExpansion) {
        expandTarget = maxExpansion;
      } else if (expandTarget + details.delta.dy < minExpansion) {
        expandTarget = minExpansion;
      } else {
        expandTarget += details.delta.dy;
      }
    });
  }

  void _stopExpansion(DragEndDetails details) {
    if ((minExpansion + maxExpansion) / 2 < expandTarget) {
      setState(() {
        expandTarget = maxExpansion;
      });
    } else {
      setState(() {
        expandTarget = minExpansion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentExpansion = expandTarget;
    });
    return GestureDetector(
        onVerticalDragUpdate: _onVertivalDragUpdate,
        onVerticalDragEnd: _stopExpansion,
        child: Column(
          children: [
            widget.appBar,
            AnimatedContainer(
              duration: Duration(milliseconds: 100 * (currentExpansion - expandTarget).abs() ~/ maxExpansion),
              height: expandTarget,
              child: Material(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: SearchTokenWidget(
                          searchActive: currentExpansion != minExpansion,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /*
                        Add a widget that is schaped like a trapezoid with 3 lines in it
                        */
                        CustomPaint(
                          painter: TrapezoidPainter(buildContext: context),
                          child: SizedBox(
                            height: minExpansion,
                            width: minExpansion * 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: minExpansion / 2, vertical: minExpansion / 4),
                              child: CustomPaint(
                                painter: HamburgerPainter(buildContext: context),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class TrapezoidPainter extends CustomPainter {
  BuildContext buildContext;
  TrapezoidPainter({required this.buildContext});
  @override
  void paint(Canvas canvas, Size size) {
    //fill out the trapezoid
    final paint = Paint()
      ..color = Theme.of(buildContext).primaryColor
      ..style = PaintingStyle.fill;
    final path = Path()..fillType = PathFillType.evenOdd;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 4 * 3, size.height);
    path.lineTo(size.width / 4 * 1, size.height);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HamburgerPainter extends CustomPainter {
  BuildContext buildContext;
  HamburgerPainter({required this.buildContext});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(buildContext).canvasColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..fillType = PathFillType.evenOdd;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
