import 'package:flutter/material.dart';

class CooldownButton extends StatefulWidget {
  final Future Function() onPressed;
  final Widget child;
  final Widget? childWhenCooldown;
  final int minThreshold;
  final ButtonStyle? style;
  final bool isPressable;
  final CooldownButtonStyleType styleType;

  const CooldownButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.childWhenCooldown,
    this.minThreshold = 1000,
    this.isPressable = true,
    this.style,
    this.styleType = CooldownButtonStyleType.elevatedButton,
  });

  @override
  State<StatefulWidget> createState() => _CooldownButtonState();
}

class _CooldownButtonState extends State<CooldownButton> {
  late bool isPressable = true;

  void press() async {
    if (isPressable) {
      setState(() => isPressable = false);
      await Future.wait(
        [
          widget.onPressed(),
          Future.delayed(Duration(milliseconds: widget.minThreshold)),
        ],
      );
      if (mounted) setState(() => isPressable = true);
    }
  }

  @override
  Widget build(BuildContext context) => switch (widget.styleType) {
        CooldownButtonStyleType.elevatedButton => Padding(
            padding: const EdgeInsets.all(3),
            child: ElevatedButton(
              onPressed: isPressable && widget.isPressable ? press : null,
              style: widget.style?.merge(Theme.of(context).elevatedButtonTheme.style) ?? Theme.of(context).elevatedButtonTheme.style,
              child: isPressable && widget.isPressable ? widget.child : widget.childWhenCooldown ?? widget.child,
            ),
          ),
        CooldownButtonStyleType.iconButton => IconButton(
            onPressed: isPressable && widget.isPressable ? press : null,
            style: widget.style?.merge(Theme.of(context).iconButtonTheme.style) ?? Theme.of(context).iconButtonTheme.style,
            icon: isPressable && widget.isPressable ? widget.child : widget.childWhenCooldown ?? widget.child,
          ),
      };
}

enum CooldownButtonStyleType {
  elevatedButton,
  iconButton,
}
