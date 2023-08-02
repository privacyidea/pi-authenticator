import 'package:flutter/material.dart';

class CustomTrailing extends StatelessWidget {
  final Widget child;

  const CustomTrailing({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.width * 0.20,
      child: child,
    );
  }
}
