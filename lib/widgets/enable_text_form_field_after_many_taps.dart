import 'dart:async';
import 'package:flutter/material.dart';

class EnableTextFormFieldAfterManyTaps extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final String? Function(String?)? validator;
  final int maxTaps;

  const EnableTextFormFieldAfterManyTaps({
    required this.controller,
    required this.decoration,
    this.maxTaps = 6,
    this.validator,
    super.key,
  });

  @override
  State<EnableTextFormFieldAfterManyTaps> createState() => _EnableTextFormFieldAfterManyTapsState();
}

class _EnableTextFormFieldAfterManyTapsState extends State<EnableTextFormFieldAfterManyTaps> {
  bool enabled = false;
  int counter = 0;
  Timer? timer;

  void tapped(int taps) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 1000), () {
      counter = 0;
      timer = null;
    });
    counter = counter + taps;
    if (counter == widget.maxTaps) {
      setState(() {
        enabled = true;
        timer?.cancel();
        timer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onDoubleTap: !enabled ? () => tapped(2) : null,
        child: TextFormField(
          readOnly: !enabled,
          onTap: !enabled ? () => tapped(1) : null,
          style: enabled ? null : Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
          controller: widget.controller,
          decoration: widget.decoration,
          validator: widget.validator,
        ),
      );
}
