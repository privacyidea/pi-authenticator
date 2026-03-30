/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../button_widgets/push_action_button.dart';

class PushDeclineConfirmDialog extends StatelessWidget {
  static Future<void> showDialogWidget({
    required BuildContext context,
    required Future<void> Function() onDecline,
    required Future<void> Function() onDiscard,
    required String title,
    required DateTime expirationDate,
  }) => showDialog(
    useRootNavigator: false,
    context: context,
    builder: (BuildContext context) => PushDeclineConfirmDialog(
      onDecline: onDecline,
      onDiscard: onDiscard,
      title: title,
      expirationDate: expirationDate,
    ),
  );

  final Future<void> Function() onDecline;
  final Future<void> Function() onDiscard;
  final String title;
  final DateTime? expirationDate;

  const PushDeclineConfirmDialog({
    super.key,
    required this.onDecline,
    required this.onDiscard,
    required this.title,
    required this.expirationDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return DefaultDialog(
      title: Text(
        title,
        style: textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              l10n.requestTriggerdByUserQuestion,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          PushActionButton(
            onPressed: () async {
              await onDiscard();
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.yes, style: textTheme.titleSmall),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.butDiscardIt,
                    style: textTheme.bodySmall?.copyWith(
                      color: textTheme.titleSmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          PushActionButton(
            intent: DialogActionIntent.destructive,
            onPressed: () async {
              await onDecline();
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.no, style: textTheme.titleSmall),
                Text(
                  l10n.declineIt,
                  style: textTheme.bodySmall?.copyWith(
                    color: textTheme.titleSmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
