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
import '../settings_view_widgets/settings_group.dart';

class SettingsGroupTheme extends StatelessWidget {
  const SettingsGroupTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final current = EasyDynamicTheme.of(context).themeMode;
    return SettingsGroup(
      title: AppLocalizations.of(context)!.theme,
      onPressed: () {
        switch (current) {
          case ThemeMode.light:
            EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: true);
            HomeWidgetUtils().setCurrentThemeMode(ThemeMode.dark);
            break;
          case ThemeMode.dark:
            EasyDynamicTheme.of(context).changeTheme(dynamic: true);
            HomeWidgetUtils().setCurrentThemeMode(ThemeMode.system);
            break;
          case ThemeMode.system:
            EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: false);
            HomeWidgetUtils().setCurrentThemeMode(ThemeMode.light);
            break;
          case null:
            EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: false);
            HomeWidgetUtils().setCurrentThemeMode(ThemeMode.light);
            break;
        }
      },
      trailingIcon: switch (current) {
        ThemeMode.light => Icons.brightness_5,
        ThemeMode.dark => Icons.brightness_4,
        ThemeMode.system => Icons.brightness_auto,
        null => Icons.question_mark,
      },
    );
  }
}
