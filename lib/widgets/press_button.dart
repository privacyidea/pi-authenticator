import 'package:flutter/material.dart';

class PressButton extends StatefulWidget {
  final void Function() onPressed;
  final Widget child;
  final int delayInMilliseconds;
  final ButtonStyle? style;

  const PressButton({super.key, required this.onPressed, required this.child, this.delayInMilliseconds = 1000, this.style});

  @override
  State<StatefulWidget> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  bool isPressable = true;

  void press() {
    if (isPressable) {
      setState(() {
        isPressable = false;
      });
      widget.onPressed();
      Future.delayed(Duration(milliseconds: widget.delayInMilliseconds), () {
        if (mounted) {
          setState(() {
            isPressable = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isPressable ? press : null,
      style: widget.style?.merge(Theme.of(context).elevatedButtonTheme.style),
      child: widget.child,
    );
  }
}
