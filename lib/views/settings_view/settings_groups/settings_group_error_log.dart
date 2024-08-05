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

import '../../../l10n/app_localizations.dart';
import '../settings_view_widgets/logging_menu.dart';
import '../settings_view_widgets/settings_groups.dart';

class SettingsGroupErrorLog extends StatelessWidget {
  const SettingsGroupErrorLog({super.key});

  @override
  Widget build(BuildContext context) => SettingsGroup(
        title: AppLocalizations.of(context)!.errorLogTitle,
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.logMenu,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            style: ListTileStyle.list,
            trailing: ElevatedButton(
              child: Text(
                AppLocalizations.of(context)!.open,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const LoggingMenu(),
                useRootNavigator: false,
              ),
            ),
          ),
        ],
      );
}
