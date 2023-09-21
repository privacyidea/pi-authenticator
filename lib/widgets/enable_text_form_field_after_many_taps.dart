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
    this.maxTaps = 7,
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
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          timer?.cancel();
          timer = Timer(const Duration(milliseconds: 500), () {
            counter = 0;
          });
          counter++;
          if (counter == widget.maxTaps) {
            setState(() {
              enabled = true;
            });
          }
        },
        child: TextFormField(
          enabled: enabled,
          controller: widget.controller,
          decoration: widget.decoration,
          validator: widget.validator,
        ),
      );
}
