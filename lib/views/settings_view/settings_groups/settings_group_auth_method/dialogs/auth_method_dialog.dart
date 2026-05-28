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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/force_biometric_option.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class AuthMethodDialog extends ConsumerWidget {
  const AuthMethodDialog({super.key});

  static const _options = [
    ForceBiometricOption.any,
    ForceBiometricOption.biometric,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context)!;
    final current = ref.watch(appAuthMethodProvider);
    return DefaultDialog(
      title: Text(localization.authMethodTitle),
      content: RadioGroup<ForceBiometricOption>(
        groupValue: current,
        onChanged: (value) {
          if (value == null) return;
          Navigator.of(context).pop(value);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                localization.authMethodDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                localization.authMethodDescriptionNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            for (final option in _options)
              RadioListTile<ForceBiometricOption>(
                value: option,
                title: Text(_labelFor(localization, option)),
              ),
          ],
        ),
      ),
      actions: [
        DialogAction(
          label: localization.cancel,
          intent: ActionIntent.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  String _labelFor(AppLocalizations l, ForceBiometricOption option) {
    switch (option) {
      case ForceBiometricOption.any:
        return l.authMethodAny;
      case ForceBiometricOption.biometric:
        return l.authMethodBiometric;
      case ForceBiometricOption.pin:
        return l.authMethodPin;
      case ForceBiometricOption.none:
        return l.authMethodAny;
    }
  }
}
