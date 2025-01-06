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

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../../../widgets/dialog_widgets/push_request_dialog/push_request_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/customization/theme_extentions/push_request_theme.dart';
import '../../../button_widgets/cooldown_button.dart';
import '../../../padded_row.dart';

class PushDeclineConfirmDialog extends StatefulWidget {
  static Future<void> showDialogWidget({
    required BuildContext context,
    required Future<void> Function() onDecline,
    required Future<void> Function() onDiscard,
    required String title,
    required DateTime expirationDate,
  }) =>
      showDialog(
          useRootNavigator: false,
          context: context,
          builder: (BuildContext context) => PushDeclineConfirmDialog(
                onDecline: onDecline,
                onDiscard: onDiscard,
                title: title,
                expirationDate: expirationDate,
              ));

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
  State<PushDeclineConfirmDialog> createState() => _PushDeclineConfirmDialogState();
}

class _PushDeclineConfirmDialogState extends State<PushDeclineConfirmDialog> {
  late Timer expirationTimer;

  @override
  void initState() {
    super.initState();
    expirationTimer = Timer(widget.expirationDate!.difference(DateTime.now()), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    expirationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pushRequestTheme = (Theme.of(context).extensions[PushRequestTheme] as PushRequestTheme);
    final localizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.titleMedium!,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              localizations.requestTriggerdByUserQuestion,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PaddedRow(
                  peddingPercent: 0.33,
                  child: SizedBox(
                    child: CooldownButton(
                      // Discard button
                      style: ButtonStyle(
                        shape: PushRequestDialog.getButtonShape(context),
                        backgroundColor: WidgetStateProperty.all(pushRequestTheme.acceptColor),
                      ),
                      onPressed: () async {
                        await widget.onDiscard();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizations.yes,
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              localizations.butDiscardIt,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.titleSmall?.color),
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                PaddedRow(
                  peddingPercent: 0.33,
                  child: CooldownButton(
                    // Decline button
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(pushRequestTheme.declineColor),
                      shape: PushRequestDialog.getButtonShape(context),
                    ),
                    onPressed: () async {
                      await widget.onDecline();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localizations.no,
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          localizations.declineIt,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.titleSmall?.color),
                          textAlign: TextAlign.center,
                          softWrap: false,
                        ),
                      ],
                    ),
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
