import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/home_widget_utils.dart';
import '../settings_view_widgets/settings_groups.dart';

class SettingsGroupTheme extends StatelessWidget {
  const SettingsGroupTheme({super.key});

  @override
  Widget build(BuildContext context) => SettingsGroup(
        title: AppLocalizations.of(context)!.theme,
        children: [
          RadioListTile(
            title: Text(
              AppLocalizations.of(context)!.lightTheme,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            value: ThemeMode.light,
            groupValue: EasyDynamicTheme.of(context).themeMode,
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (dynamic value) {
              EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: false);
              HomeWidgetUtils().setCurrentThemeMode(ThemeMode.light);
            },
          ),
          RadioListTile(
            title: Text(
              AppLocalizations.of(context)!.darkTheme,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            value: ThemeMode.dark,
            groupValue: EasyDynamicTheme.of(context).themeMode,
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (dynamic value) {
              EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: true);
              HomeWidgetUtils().setCurrentThemeMode(ThemeMode.dark);
            },
          ),
          RadioListTile(
            title: Text(
              AppLocalizations.of(context)!.systemTheme,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            value: ThemeMode.system,
            groupValue: EasyDynamicTheme.of(context).themeMode,
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (dynamic value) {
              EasyDynamicTheme.of(context).changeTheme(dynamic: true, dark: false);
              HomeWidgetUtils().setCurrentThemeMode(ThemeMode.system);
            },
          ),
        ],
      );
}
