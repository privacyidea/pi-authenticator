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

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/logger.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';

/// A dialog that asks the user if they sended the log. Clear logs if he did.
class AskLogSendedDialog extends StatelessWidget {
  const AskLogSendedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(
        AppLocalizations.of(context)!.confirmation,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              AppLocalizations.of(context)!.askLogSendedDescription,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.no,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            Logger.clearErrorLog();
          },
          child: Text(
            AppLocalizations.of(context)!.yes,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        )
      ],
    );
  }
}
