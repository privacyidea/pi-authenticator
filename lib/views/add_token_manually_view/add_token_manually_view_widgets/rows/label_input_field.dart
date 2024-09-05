/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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

import '../../../../l10n/app_localizations.dart';

class LabelInputField extends StatefulWidget {
  static final FocusNode labelFieldFocus = FocusNode(debugLabel: 'LabelInputField');
  static String? validator(String? value, {AppLocalizations? locale}) {
    if (value == null || value.isEmpty) {
      labelFieldFocus.requestFocus();
      return locale?.pleaseEnterANameForThisToken ?? 'Not Valid';
    }
    return null;
  }

  final TextEditingController controller;
  final ValueNotifier<bool> autoValidate;

  const LabelInputField({
    super.key,
    required this.controller,
    required this.autoValidate,
  });

  @override
  State<LabelInputField> createState() => _LabelInputFieldState();
}

class _LabelInputFieldState extends State<LabelInputField> {
  void _setState() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.autoValidate.addListener(_setState);
  }

  @override
  void dispose() {
    widget.autoValidate.removeListener(_setState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        autovalidateMode: widget.autoValidate.value ? AutovalidateMode.always : AutovalidateMode.disabled,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
        validator: (value) => LabelInputField.validator(value, locale: AppLocalizations.of(context)),
        focusNode: LabelInputField.labelFieldFocus,
      );
}
