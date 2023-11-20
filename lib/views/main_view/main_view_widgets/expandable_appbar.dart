import 'package:flutter/material.dart';

import 'filter_token_widget.dart';

class ExpandableAppBar extends StatefulWidget {
  final Widget appBar;
  final Widget body;
  final bool startExpand;

  const ExpandableAppBar({
    required this.appBar,
    required this.body,
    required this.startExpand,
    super.key,
  });

  @override
  State<ExpandableAppBar> createState() => _ExpandableAppBarState();
}

class _ExpandableAppBarState extends State<ExpandableAppBar> {
  static const double maxExpansion = 50 + minExpansion;
  static const double minExpansion = 0;
  // static const double latchHeight = 14;
  bool searchActive = false;
  double currentExpansion = minExpansion;
  double expandTarget = minExpansion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        currentExpansion = widget.startExpand ? 0.1 : minExpansion;
        expandTarget = widget.startExpand ? maxExpansion : minExpansion;
      });
    });
  }

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
    if (widget.startExpand) {
      expandTarget = maxExpansion;
    } else {
      expandTarget = minExpansion;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentExpansion != expandTarget && mounted) {
        setState(() {
          currentExpansion = expandTarget;
        });
      }
    });
    return GestureDetector(
        onVerticalDragUpdate: _onVertivalDragUpdate,
        onVerticalDragEnd: _stopExpansion,
        child: Column(
          children: [
            widget.appBar,
            AnimatedContainer(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Theme.of(context).canvasColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              duration: Duration(milliseconds: 250 * (currentExpansion - expandTarget).abs() ~/ maxExpansion),
              height: expandTarget,
              onEnd: () {
                if (!mounted) return;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (currentExpansion == minExpansion) {
                    setState(() {
                      searchActive = false;
                    });
                  } else {
                    setState(() {
                      searchActive = true;
                    });
                  }
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: SearchTokenWidget(
                        searchActive: expandTarget != minExpansion || searchActive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.body,
              //  Stack(
              //   children: [

              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       children: [
              //         CustomPaint(
              //           painter: TrapezoidPainter(buildContext: context),
              //           child: SizedBox(
              //             height: latchHeight,
              //             width: latchHeight * 2,
              //             child: Padding(
              //               padding: const EdgeInsets.symmetric(horizontal: latchHeight / 2, vertical: latchHeight / 4),
              //               child: CustomPaint(
              //                 painter: HamburgerPainter(buildContext: context),
              //               ),
              //             ),
              //           ),
              //         ),
              //         const SizedBox(
              //           width: 8,
              //         )
              //       ],
              //     ),
              //   ],
              // ),
            ),
          ],
        ));
  }
}

// class TrapezoidPainter extends CustomPainter {
//   BuildContext buildContext;
//   TrapezoidPainter({required this.buildContext});
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Color color =
//         Theme.of(buildContext).navigationBarTheme.backgroundColor ?? Theme.of(buildContext).appBarTheme.backgroundColor ?? Theme.of(buildContext).primaryColor;
//     final Color shadowColor =
//         Theme.of(buildContext).navigationBarTheme.shadowColor ?? Theme.of(buildContext).appBarTheme.shadowColor ?? Theme.of(buildContext).shadowColor;
//     final elevation = Theme.of(buildContext).navigationBarTheme.elevation ?? 3;

//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final path = Path()..fillType = PathFillType.evenOdd;
//     path.moveTo(0, 0);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width / 4 * 3, size.height);
//     path.lineTo(size.width / 4 * 1, size.height);
//     path.lineTo(0, 0);
//     if (kIsWeb || Platform.isIOS == false) {
//       canvas.translate(0, -elevation / 4);
//       canvas.drawShadow(path, shadowColor, elevation / 2, false);
//       canvas.translate(0, elevation / 4);
//     }
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class HamburgerPainter extends CustomPainter {
//   BuildContext buildContext;
//   HamburgerPainter({required this.buildContext});
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Theme.of(buildContext).canvasColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;
//     final path = Path()..fillType = PathFillType.evenOdd;
//     path.moveTo(0, 0);
//     path.lineTo(size.width, 0);
//     path.moveTo(0, size.height / 2);
//     path.lineTo(size.width, size.height / 2);
//     path.moveTo(0, size.height);
//     path.lineTo(size.width, size.height);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
