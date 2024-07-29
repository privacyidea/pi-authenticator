import 'package:flutter/material.dart';

class TooltipContainer extends StatelessWidget {
  final String tooltip;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double border;
  final TextStyle textStyle;
  final void Function()? onComplete;
  const TooltipContainer(
    this.tooltip, {
    super.key,
    required this.padding,
    required this.margin,
    required this.border,
    required this.textStyle,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: Theme.of(context).navigationBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).primaryColor, width: border),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: GestureDetector(
          onTapDown: (details) {
            onComplete?.call();
          },
          child: Text(
            tooltip,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),

      );
}
