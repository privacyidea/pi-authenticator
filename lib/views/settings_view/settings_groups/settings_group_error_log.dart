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
