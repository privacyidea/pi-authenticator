import 'package:flutter/material.dart';

class PressButton extends StatefulWidget {
  final void Function() onPressed;
  final Widget child;

  const PressButton({required this.onPressed, required this.child});

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
      Future.delayed(Duration(milliseconds: 1000), () {
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
    return ElevatedButton(onPressed: isPressable ? press : null, child: widget.child);
  }
}
