import 'package:flutter/material.dart';

class CustomTrailing extends StatelessWidget {
  final Widget child;

  const CustomTrailing({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20.0),
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.width * 0.15,
      child: child,
    );
  }
}
