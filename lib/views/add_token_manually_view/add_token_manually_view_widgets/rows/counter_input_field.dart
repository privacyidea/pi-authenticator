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
import 'package:privacyidea_authenticator/widgets/pi_text_field.dart';

import '../../../../l10n/app_localizations.dart';
import '../add_token_manually_row.dart';

class CounterInputField extends StatelessWidget {
  static final FocusNode counterFieldFocus = FocusNode(debugLabel: 'CounterInputField');
  static String? validator(String? value, {AppLocalizations? locale}) {
    if (value == null || value.isEmpty) {
      counterFieldFocus.requestFocus();
      return locale?.mustNotBeEmpty(locale.counter) ?? 'Must not be empty';
    }
    return int.tryParse(value) == null ? locale?.notAnInteger ?? 'Must be a number' : null;
  }

  final ValueNotifier<int?> counterNotifier;
  const CounterInputField({
    super.key,
    required this.counterNotifier,
  });
  @override
  Widget build(BuildContext context) {
    counterNotifier.value ??= 0;
    return AddTokenManuallyRow(
      label: AppLocalizations.of(context)!.counter,
      child: PiTextField(
        keyboardType: TextInputType.number,
        initialValue: counterNotifier.value.toString(),
        onChanged: (value) {
          final number = int.tryParse(value);
          if (number != null) counterNotifier.value = number;
          counterNotifier.value = int.tryParse(value);
        },
        validator: (value) => validator(value, locale: AppLocalizations.of(context)),
        focusNode: CounterInputField.counterFieldFocus,
      ),
    );
  }
}
