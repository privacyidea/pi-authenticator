import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/riverpod_providers.dart';
import '../settings_view_widgets/settings_groups.dart';

class SettingsGroupLanguage extends ConsumerWidget {
  const SettingsGroupLanguage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsGroup(
        title: AppLocalizations.of(context)!.language,
        children: [
          SwitchListTile(
              title: Text(
                AppLocalizations.of(context)!.useDeviceLocaleTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.useDeviceLocaleDescription,
                overflow: TextOverflow.fade,
              ),
              value: ref.watch(settingsProvider).useSystemLocale,
              onChanged: (value) => ref.read(settingsProvider.notifier).setUseSystemLocale(value)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButton<Locale>(
              disabledHint: Text(
                '${ref.watch(settingsProvider).currentLocale}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
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
