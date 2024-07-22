import 'dart:async';

import 'package:flutter/material.dart';

class EnableTextEditAfterManyTaps extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final int maxTaps;

  const EnableTextEditAfterManyTaps({
    required this.controller,
    required this.decoration,
    this.maxTaps = 6,
    this.autovalidateMode,
    this.validator,
    super.key,
  });

  @override
  State<EnableTextEditAfterManyTaps> createState() => _EnableTextEditAfterManyTapsState();
}

class _EnableTextEditAfterManyTapsState extends State<EnableTextEditAfterManyTaps> {
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
          key: Key('${widget.controller.hashCode}_enableTextEditAfterManyTaps'),
          readOnly: !enabled,
          onTap: !enabled ? () => tapped(1) : null,
          style: enabled ? null : Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
          controller: widget.controller,
          decoration: widget.decoration,
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator,
        ),
      );
}
