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
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/widgets/pi_text_field.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/encodings.dart';

class SecretInputField extends StatefulWidget {
  static final FocusNode secretFieldFocus = FocusNode(debugLabel: 'SecretInputField');
  static String? validator(String? value, Encodings encoding, {AppLocalizations? locale}) {
    if (value == null || value.isEmpty) {
      secretFieldFocus.requestFocus();
      return locale?.pleaseEnterASecretForThisToken ?? 'Not Valid';
    }
    if (encoding.isInvalidEncoding(value)) {
      secretFieldFocus.requestFocus();
      return locale?.theSecretDoesNotFitTheCurrentEncoding ?? 'Not Valid';
    }
    return null;
  }

  final TextEditingController controller;

  final ValueNotifier<bool> autoValidate;
  final ValueNotifier<Encodings> encodingNotifier;

  const SecretInputField({
    super.key,
    required this.controller,
    required this.autoValidate,
    required this.encodingNotifier,
  });

  @override
  State<SecretInputField> createState() => _SecretInputFieldState();
}

class _SecretInputFieldState extends State<SecretInputField> {
  void _setState() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.autoValidate.addListener(_setState);
    widget.encodingNotifier.addListener(_setState);
  }

  @override
  void dispose() {
    widget.autoValidate.removeListener(_setState);
    widget.encodingNotifier.removeListener(_setState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PiTextField(
        controller: widget.controller,
        autovalidateMode: widget.autoValidate.value ? AutovalidateMode.always : AutovalidateMode.disabled,
        labelText: AppLocalizations.of(context)!.secretKey,
        validator: (value) => SecretInputField.validator(value, widget.encodingNotifier.value, locale: AppLocalizations.of(context)),
        focusNode: SecretInputField.secretFieldFocus,
      );
}
