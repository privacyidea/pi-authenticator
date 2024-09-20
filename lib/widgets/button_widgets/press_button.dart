import 'package:flutter/material.dart';

class CooldownButton extends StatefulWidget {
  final Future Function() onPressed;
  final Widget child;
  final int buttonCooldown;
  final ButtonStyle? style;

  const CooldownButton({super.key, required this.onPressed, required this.child, this.buttonCooldown = 1000, this.style});

  @override
  State<StatefulWidget> createState() => _CooldownButtonState();
}

class _CooldownButtonState extends State<CooldownButton> {
  bool isPressable = true;

  void press() async {
    if (isPressable) {
      setState(() {
        isPressable = false;
      });
      await Future.wait(
        [
          widget.onPressed(),
          Future.delayed(Duration(milliseconds: widget.buttonCooldown)),
        ],
      );
      if (mounted) {
        setState(() {
          isPressable = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: isPressable ? press : null,
          style: widget.style?.merge(Theme.of(context).elevatedButtonTheme.style) ?? Theme.of(context).elevatedButtonTheme.style,
          child: widget.child,
        ),
      );
}
