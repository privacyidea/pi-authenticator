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
      title: Text('Automatic Assignment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('The next two OTPs of your tokens with unknown origin will be send to the server that the container "${container.serial}" is connected with.'),
          Text('This will be used to automaticly assign your privacyIDEA token to this Container.'),
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
                          'SSL Verification is disabled!',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'To send OTPs to an unverified server is a high security risk!',
                          style: Theme.of(context).textTheme.bodyLarge,
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
            child: Text('Do you agree to send the information?'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text(localizations.no)),
        DelayedElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.sendOtps),
        ),
      ],
    );
  }
}
