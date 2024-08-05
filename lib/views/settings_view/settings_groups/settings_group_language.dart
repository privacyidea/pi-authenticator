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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/settings_provider.dart';
import '../settings_view_widgets/settings_groups.dart';

class SettingsGroupLanguage extends ConsumerWidget {
  const SettingsGroupLanguage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    return SettingsGroup(
      title: localizations.language,
      children: [
        SwitchListTile(
            title: Text(
              localizations.useDeviceLocaleTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              localizations.useDeviceLocaleDescription,
              overflow: TextOverflow.fade,
            ),
            value: ref.watch(settingsProvider).useSystemLocale,
            onChanged: (value) => ref.read(settingsProvider.notifier).setUseSystemLocale(value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButton<Locale>(
            disabledHint: Text(
              '${ref.watch(settingsProvider).currentLocale}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            isExpanded: true,
            value: ref.watch(settingsProvider).currentLocale,
            items: AppLocalizations.supportedLocales.map<DropdownMenuItem<Locale>>((Locale itemLocale) {
              return DropdownMenuItem<Locale>(
                value: itemLocale,
                child: Text(
                  '$itemLocale',
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ref.watch(settingsProvider).useSystemLocale ? Colors.grey : null),
                  softWrap: false,
                ),
              );
            }).toList(),
            onChanged: ref.watch(settingsProvider).useSystemLocale ? null : (value) => ref.read(settingsProvider.notifier).setLocalePreference(value!),
          ),
        ),
      ],
    );
  }
}
