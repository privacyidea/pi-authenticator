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
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/customization/theme_extentions/status_colors.dart';
import '../../button_widgets/delayed_elevated_button.dart';

class SendOTPsWithoutSSLDialog extends StatelessWidget {
  const SendOTPsWithoutSSLDialog({super.key});

  static Future<bool?> showDialog() async {
    final returnValue = await showAsyncDialog(builder: (context) => SendOTPsWithoutSSLDialog());
    assert(returnValue is bool?, "The return value of the SendOTPsWithoutSSLDialog must be a bool or null.");
    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(localizations.initialTokenAssignmentDialogTitle),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 36,
              color: Theme.of(context).extension<StatusColors>()!.warning,
            ),
            Flexible(
              child: Column(
                children: [
                  Text(
                    localizations.initialTokenAssignmentDialogSSLWarning1,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).extension<StatusColors>()!.warning),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    localizations.initialTokenAssignmentDialogSSLWarning2,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).extension<StatusColors>()!.warning),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.warning_amber_rounded,
              size: 36,
              color: Theme.of(context).extension<StatusColors>()!.warning,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(localizations.cancel),
        ),
        DelayedElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(localizations.send),
        ),
      ],
    );
  }
}
