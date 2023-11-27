import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/logger.dart';
import '../../../widgets/default_dialog.dart';

class SendErrorDialog extends StatelessWidget {
  const SendErrorDialog({super.key});

  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: Text(
          AppLocalizations.of(context)!.sendErrorLog,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        content: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.sendErrorLogDescription,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.showPrivacyPolicy,
                    ),
                    onPressed: () => launchUrl(Uri.parse('https://netknights.it/en/privacy-statement/'))),
              ),
            ],
          ),
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
          TextButton(
            onPressed: () => Logger.sendErrorLog(),
            child: const Icon(Icons.email),
          )
        ],
      );
}

class NoLogDialog extends StatelessWidget {
  const NoLogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      scrollable: true,
      title: Text(
        AppLocalizations.of(context)!.errorLogEmpty,
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
