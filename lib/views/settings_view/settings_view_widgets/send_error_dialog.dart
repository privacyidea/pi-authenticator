/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/logger.dart';
import '../../../widgets/dialog_widgets/default_dialog.dart';
import '../settings_view.dart';
import 'dialogs/ask_log_sended_dialog.dart';

class SendErrorDialog extends StatefulWidget {
  const SendErrorDialog({super.key});

  @override
  State<SendErrorDialog> createState() => _SendErrorDialogState();
}

class _SendErrorDialogState extends State<SendErrorDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: Text(
          AppLocalizations.of(context)!.send,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.sendErrorLogDescription,
              ),
              TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.showPrivacyPolicy,
                  ),
                  onPressed: () => launchUrl(Uri.parse('https://netknights.it/en/privacy-statement/'))),
              const SizedBox(height: 8.0),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide(width: 1.5)),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.5)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.5)),
                  labelText: AppLocalizations.of(context)!.additionalErrorMessage,
                ),
                maxLines: 5,
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
            onPressed: () => _popDialogs(context),
          ),
          TextButton(
            onPressed: () {
              Logger.sendErrorLog(_textController.text);
              showDialog(context: context, builder: (context) => const AskLogSendedDialog()).then((value) {
                if (!context.mounted) return;
                value == true ? _popDialogs(context) : null;
              });
            },
            child: const Icon(Icons.email),
          )
        ],
      );
  void _popDialogs(BuildContext context) {
    Navigator.of(context).popUntil((route) => SettingsView.routeName == route.settings.name || route.isFirst);
  }
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
