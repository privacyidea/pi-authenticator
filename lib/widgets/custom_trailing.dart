import 'dart:math';

import 'package:flutter/material.dart';

class CustomTrailing extends StatelessWidget {
  final Widget child;

  const CustomTrailing({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: min(85, size.width * 0.275),
      child: child,
    );
  }
}
