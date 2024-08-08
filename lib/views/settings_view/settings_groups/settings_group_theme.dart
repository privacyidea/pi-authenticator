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
              style: Theme.of(context).textTheme.bodyMedium,
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
              style: Theme.of(context).textTheme.bodyMedium,
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
              style: Theme.of(context).textTheme.bodyMedium,
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
