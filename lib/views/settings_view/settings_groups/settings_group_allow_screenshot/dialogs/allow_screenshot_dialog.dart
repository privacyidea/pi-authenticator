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
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/view_utils.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class AllowScreenshotDialog extends StatelessWidget {
  const AllowScreenshotDialog({super.key});

  static Future<bool?> showDialog() => showAsyncDialog(
        builder: (context) => AllowScreenshotDialog(),
      );

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.allowScreenshotsTitle),
      content: Text(AppLocalizations.of(context)!.allowScreenshotsDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            // authenticate with fingerprint or password
            final authenticated = await lockAuth(
              reason: (l) => l.allowScreenshotsReason,
              localization: AppLocalizations.of(context)!,
              autoAuthIfUnsupported: true,
            );
            if (!context.mounted || !authenticated) return;
            Navigator.of(context).pop(true);
          },
          child: Text(AppLocalizations.of(context)!.allowButton),
        ),
      ],
    );
  }
}
