/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:flutter/material.dart';

class PiTextField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final bool autofocus;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;

  const PiTextField({
    super.key,
    this.labelText,
    this.onChanged,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.focusNode,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          errorMaxLines: 2,
        ),
        onChanged: onChanged,
        controller: controller,
        initialValue: initialValue,
        keyboardType: keyboardType,
        focusNode: focusNode,
        autofocus: autofocus,
        style: Theme.of(context).textTheme.titleSmall,
        autovalidateMode: autovalidateMode,
        validator: validator,
      );
}
