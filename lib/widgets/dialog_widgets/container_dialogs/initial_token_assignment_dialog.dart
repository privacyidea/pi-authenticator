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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/status_colors.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../model/token_container.dart';
import '../../button_widgets/delayed_elevated_button.dart';

class InitialTokenAssignmentDialog extends StatelessWidget {
  final TokenContainer container;
  const InitialTokenAssignmentDialog({super.key, required this.container});

  static showDialog(TokenContainer container) => showAsyncDialog(builder: (context) => InitialTokenAssignmentDialog(container: container));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return DefaultDialog(
      title: Text(localizations.initialTokenAssignmentDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(localizations.initialTokenAssignmentDialogContent1(container.serial)),
          Text(localizations.initialTokenAssignmentDialogContent2),
          if (!container.sslVerify)
            Padding(
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(localizations.initialTokenAssignmentDialogQuestion),
          ),
        ],
      ),
      actions: [
        ElevatedButton(onPressed: () => Navigator.of(context).pop(false), child: Text(localizations.no)),
        DelayedElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(localizations.sendOtps),
        ),
      ],
    );
  }
}
