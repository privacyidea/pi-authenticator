/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

class EnterPassphraseDialog extends StatefulWidget {
  final String question;

  static Future<String?> show(String question) => showAsyncDialog(
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: EnterPassphraseDialog(question: question),
        ),
      );

  const EnterPassphraseDialog({super.key, required this.question});

  @override
  State<EnterPassphraseDialog> createState() => _EnterPassphraseDialogState();
}

class _EnterPassphraseDialogState extends State<EnterPassphraseDialog> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(appLocalizations.enterPassphraseDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.question, style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 8),
          TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: appLocalizations.enterPassphraseDialogHint,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            onChanged: (value) => setState(() {
              text = value;
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: text.isNotEmpty ? () => Navigator.of(context).pop(text) : null,
          child: Text(appLocalizations.ok),
        ),
      ],
    );
  }
}
