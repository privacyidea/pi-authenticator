import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/send_error_dialog.dart';

class LoggingMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final verboseLogging = settings.verboseLogging;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        titlePadding: EdgeInsets.all(12),
        contentPadding: EdgeInsets.all(0),
        title: Text(AppLocalizations.of(context)!.logMenu),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.enableVerboseLogging),
              trailing: Switch(value: verboseLogging, onChanged: (value) => ref.read(settingsProvider.notifier).setVerboseLogging(value)),
              style: ListTileStyle.drawer,
              onTap: () => ref.read(settingsProvider.notifier).toggleVerboseLogging(),
            ),
            Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context)!.sendErrorHint),
              trailing: ElevatedButton(
                onPressed: () => _pressSendErrorLog(context),
                child: Text(AppLocalizations.of(context)!.open),
              ),
              style: ListTileStyle.drawer,
              onTap: () => _pressSendErrorLog(context),
            ),
            Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context)!.clearErrorLogHint),
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
      showDialog(context: context, builder: (context) => SendErrorDialog());
    } else {
      showDialog(context: context, builder: (context) => NoLogDialog());
    }
  }

  void _pressClearErrorLog(BuildContext context) {
    Navigator.pop(context);
    Logger.clearErrorLog();
  }
}
