import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/logger.dart';
import '../../../utils/riverpod_providers.dart';
import 'send_error_dialog.dart';

class LoggingMenu extends ConsumerWidget {
  const LoggingMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final verboseLogging = settings.verboseLogging;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titlePadding: const EdgeInsets.all(12),
        contentPadding: const EdgeInsets.all(0),
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
              ),
              trailing: Switch(value: verboseLogging, onChanged: (value) => ref.read(settingsProvider.notifier).setVerboseLogging(value)),
              style: ListTileStyle.list,
              onTap: () => ref.read(settingsProvider.notifier).toggleVerboseLogging(),
            ),
            const Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.sendErrorHint,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: ElevatedButton(
                onPressed: () => _pressSendErrorLog(context),
                child: Text(AppLocalizations.of(context)!.open),
              ),
              style: ListTileStyle.drawer,
              onTap: () => _pressSendErrorLog(context),
            ),
            const Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.clearErrorLogHint,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: ElevatedButton(
                onPressed: () => _pressClearErrorLog(context),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
              style: ListTileStyle.drawer,
              onTap: () => _pressClearErrorLog(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.dismiss),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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
