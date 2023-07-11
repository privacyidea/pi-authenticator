import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/widgets/send_error_dialog.dart';

class LoggingMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              trailing: StreamBuilder<bool>(
                stream: AppSettings.of(context).streamVerboseLogging(),
                builder: (context, snapshot) {
                  bool isActive = true;
                  ValueChanged<bool>? onChanged;
                  if (snapshot.hasData) {
                    isActive = snapshot.data!;
                    onChanged = (_) {
                      AppSettings.of(context).toggleVerboseLogging();
                    };
                  }
                  return Switch(value: isActive, onChanged: onChanged);
                },
              ),
              style: ListTileStyle.drawer,
              onTap: () {
                AppSettings.of(context).toggleVerboseLogging();
              },
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
