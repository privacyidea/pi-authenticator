import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/logger.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../widgets/default_dialog.dart';
import 'send_error_dialog.dart';

class LoggingMenu extends ConsumerWidget {
  const LoggingMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final verboseLogging = settings.verboseLogging;
    return DefaultDialog(
      scrollable: true,
      title: Text(
        AppLocalizations.of(context)!.logMenu,
        style: Theme.of(context).listTileTheme.titleTextStyle,
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.enableVerboseLogging,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.fade,
            ),
            contentPadding: const EdgeInsets.all(0),
            trailing: Switch(value: verboseLogging, onChanged: (value) => ref.read(settingsProvider.notifier).setVerboseLogging(value)),
            style: ListTileStyle.list,
            onTap: () => ref.read(settingsProvider.notifier).toggleVerboseLogging(),
          ),
          const Divider(),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.sendErrorHint,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.fade,
            ),
            contentPadding: const EdgeInsets.all(0),
            trailing: ElevatedButton(
              onPressed: () => _pressSendErrorLog(context),
              child: Text(
                AppLocalizations.of(context)!.open,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            style: ListTileStyle.drawer,
            onTap: () => _pressSendErrorLog(context),
          ),
          const Divider(),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.clearErrorLogHint,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.fade,
            ),
            contentPadding: const EdgeInsets.all(0),
            trailing: ElevatedButton(
              onPressed: () => _pressClearErrorLog(context),
              child: Text(
                AppLocalizations.of(context)!.delete,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            style: ListTileStyle.drawer,
            onTap: () => _pressClearErrorLog(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.dismiss,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _pressSendErrorLog(BuildContext context) {
    if (Logger.instance.logfileHasContent) {
      showDialog(context: context, builder: (context) => const SendErrorDialog());
    } else {
      showDialog(context: context, builder: (context) => const NoLogDialog());
    }
  }

  void _pressClearErrorLog(BuildContext context) {
    Navigator.pop(context);
    Logger.clearErrorLog();
  }
}
