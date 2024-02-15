import 'package:flutter/material.dart';

class DefaultDialogButton extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;

  const DefaultDialogButton({required this.child, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) => TextButton(onPressed: onPressed, child: child);
}
