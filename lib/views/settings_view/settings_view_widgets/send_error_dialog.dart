import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../../utils/logger.dart';
import '../../../widgets/default_dialog.dart';

class SendErrorDialog extends StatefulWidget {
  const SendErrorDialog({super.key});

  @override
  State<SendErrorDialog> createState() => _SendErrorDialogState();
}

class _SendErrorDialogState extends State<SendErrorDialog> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: FutureBuilder<String>(
        future: Logger.instance.errorLog,
        builder: (context, errorLog) {
          return DefaultDialog(
            title: Text(
              AppLocalizations.of(context)!.sendErrorDialogHeader,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: Text(
                        AppLocalizations.of(context)!.sendErrorDialogBody,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Card(
                    child: Scrollbar(
                      scrollbarOrientation: ScrollbarOrientation.right,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: errorLog.data != null
                                ? Text(
                                    errorLog.data.toString(),
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 8),
                                  )
                                : const CircularProgressIndicator(),
                          ),
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
    return DefaultDialog(
      scrollable: true,
      title: Text(
        AppLocalizations.of(context)!.noLogToSend,
      ),
      actions: [
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.ok,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
