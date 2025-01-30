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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class TransferOfflineTokenDialog extends StatelessWidget {
  final int offlineTokenCount;

  const TransferOfflineTokenDialog(this.offlineTokenCount, {super.key});

  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: Text(AppLocalizations.of(context)!.transferOfflineTokenDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.transferOfflineTokenDialogContent(offlineTokenCount)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      );
}
