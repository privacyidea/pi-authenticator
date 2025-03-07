import 'package:flutter/material.dart';

class CooldownButton extends StatefulWidget {
  final Future Function()? onPressed;
  final Widget child;
  final Widget? childWhenCooldown;
  final EdgeInsetsGeometry? padding;
  final int minThreshold;
  final ButtonStyle? style;
  final bool isPressable;
  final CooldownButtonStyleType styleType;

  const CooldownButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.childWhenCooldown,
    this.padding,
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
          widget.onPressed?.call() ?? Future.delayed(Duration.zero),
          Future.delayed(Duration(milliseconds: widget.minThreshold)),
        ],
      );
      if (mounted) setState(() => isPressable = true);
    }
  }

  @override
  Widget build(BuildContext context) => switch (widget.styleType) {
        CooldownButtonStyleType.elevatedButton => Padding(
            padding: widget.padding ?? const EdgeInsets.all(0),
            child: ElevatedButton(
              onPressed: isPressable && widget.isPressable ? press : null,
              style: widget.style ?? Theme.of(context).elevatedButtonTheme.style,
              child: isPressable && widget.isPressable ? widget.child : widget.childWhenCooldown ?? widget.child,
            ),
          ),
        CooldownButtonStyleType.iconButton => IconButton(
            padding: widget.padding ?? const EdgeInsets.all(0),
            splashRadius: 26,
            onPressed: isPressable && widget.isPressable ? press : null,
            style: widget.style ?? Theme.of(context).iconButtonTheme.style,
            icon: isPressable && widget.isPressable ? widget.child : widget.childWhenCooldown ?? widget.child,
          ),
        CooldownButtonStyleType.textButton => TextButton(
            onPressed: isPressable && widget.isPressable ? press : null,
            style: widget.style ?? Theme.of(context).textButtonTheme.style,
            child: isPressable && widget.isPressable ? widget.child : widget.childWhenCooldown ?? widget.child,
          ),
      };
}

enum CooldownButtonStyleType {
  elevatedButton,
  iconButton,
  textButton,
}
