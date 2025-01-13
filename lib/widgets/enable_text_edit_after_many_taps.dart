import 'dart:async';

import 'package:flutter/material.dart';

import '../views/main_view/main_view_widgets/token_widgets/default_token_actions/default_edit_action_dialog.dart';

class EnableTextEditAfterManyTaps extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final int maxTaps;

  const EnableTextEditAfterManyTaps({
    required this.controller,
    required this.labelText,
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
    counter += taps;
    if (counter == widget.maxTaps) {
      setState(() {
        enabled = true;
        timer?.cancel();
        timer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => enabled
      ? TextFormField(
          key: Key('${widget.controller.hashCode}_enableTextEditAfterManyTaps'),
          style: null,
          controller: widget.controller,
          decoration: InputDecoration(labelText: widget.labelText),
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator,
        )
      : GestureDetector(
          onDoubleTap: () => tapped(2),
          child: ReadOnlyTextFormField(
            text: widget.controller.text,
            labelText: widget.labelText,
            onTap: () => tapped(1),
          ),
        );
}
