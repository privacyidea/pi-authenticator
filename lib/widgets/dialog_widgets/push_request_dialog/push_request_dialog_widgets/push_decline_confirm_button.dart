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

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/customization/theme_extentions/push_request_theme.dart';
import '../../../button_widgets/cooldown_button.dart';
import '../push_request_dialog.dart';
import 'push_decline_confirm_dialog.dart';

class PushDeclineConfirmButton extends StatelessWidget {
  final Future<void> Function() onDecline;
  final Future<void> Function() onDiscard;
  final String confirmationTitle;
  final double? height;
  final DateTime expirationDate;

  const PushDeclineConfirmButton({
    super.key,
    required this.onDecline,
    required this.onDiscard,
    required this.confirmationTitle,
    required this.expirationDate,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final pushRequestTheme = (Theme.of(context).extensions[PushRequestTheme] as PushRequestTheme);
    final localizations = AppLocalizations.of(context)!;
    return CooldownButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(pushRequestTheme.declineColor),
        shape: PushRequestDialog.getButtonShape(context),
      ),
      onPressed: () => PushDeclineConfirmDialog.showDialogWidget(
        context: context,
        onDecline: onDecline,
        onDiscard: onDiscard,
        title: confirmationTitle,
        expirationDate: expirationDate,
      ),
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              localizations.decline,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
