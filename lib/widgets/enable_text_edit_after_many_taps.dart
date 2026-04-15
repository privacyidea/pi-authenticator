/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
  State<EnableTextEditAfterManyTaps> createState() =>
      _EnableTextEditAfterManyTapsState();
}

class _EnableTextEditAfterManyTapsState
    extends State<EnableTextEditAfterManyTaps> {
  bool enabled = false;
  int counter = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void tapped(int taps) {
    if (enabled) return;

    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          counter = 0;
        });
      }
      timer = null;
    });

    setState(() {
      counter += taps;
      if (counter >= widget.maxTaps) {
        enabled = true;
        timer?.cancel();
        timer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return TextFormField(
        key: Key('enabled_${widget.controller.hashCode}'),
        controller: widget.controller,
        decoration: InputDecoration(labelText: widget.labelText),
        autovalidateMode: widget.autovalidateMode,
        validator: widget.validator,
      );
    }

    return GestureDetector(
      onDoubleTap: () => tapped(2),
      child: ReadOnlyTextFormField(
        key: Key('readonly_${widget.controller.hashCode}'),
        text: widget.controller.text,
        labelText: widget.labelText,
        onTap: () => tapped(1),
      ),
    );
  }
}
