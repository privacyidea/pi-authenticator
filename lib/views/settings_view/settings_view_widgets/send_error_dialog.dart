import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/logger.dart';
import '../../../widgets/default_dialog.dart';

class SendErrorDialog extends StatelessWidget {
  const SendErrorDialog({super.key});

  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: const Text(
          'Fehlerbericht senden', //TODO: Translate
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        content: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  'Es wird eine vorgefertigte E-Mail erstellt.\nSie enthält Informationen über die App, den Fehler und das Gerät.\nSie können die E-Mail vor dem Senden bearbeiten.', //TODO: Translate
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: TextButton(
                    child: const Text('Datenschutzerklärung anzeigen'), onPressed: () => launchUrl(Uri.parse('https://netknights.it/en/privacy-statement/'))),
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
      title: const Text(
        'Das Fehlerprotokoll ist leer.', //TODO: Translate
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
