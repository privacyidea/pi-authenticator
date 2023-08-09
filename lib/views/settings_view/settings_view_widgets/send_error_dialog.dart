import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/logger.dart';

class SendErrorDialog extends StatelessWidget {
  const SendErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: FutureBuilder<String>(
        future: Logger.instance.errorLog,
        builder: (context, errorLog) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.sendErrorDialogHeader,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context)!.sendErrorDialogBody,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorLog.data?.toString() ?? '',
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.dismiss,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Icon(Icons.email),
                onPressed: () async {
                  Logger.sendErrorLog();
                },
              )
            ],
          );
        },
      ),
    );
  }
}

class NoLogDialog extends StatelessWidget {
  const NoLogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.noLogToSend,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.ok,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
