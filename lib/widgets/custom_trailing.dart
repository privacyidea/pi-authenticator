import 'package:flutter/material.dart';

class CustomTrailing extends StatelessWidget {
  final Widget child;

  const CustomTrailing({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth * 0.275,
        height: constraints.maxWidth * 0.20,
        child: child,
      ),
    );
  }
}
