/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import '../../l10n/app_localizations.dart';
import '../../utils/app_settings_utils.dart';
import '../../utils/view_utils.dart';
import 'default_dialog.dart';

/// Dialog explaining that disabling battery optimization for the app
/// can help when the home screen widget has problems.
class BatteryOptimizationDialog extends StatelessWidget {
  const BatteryOptimizationDialog({super.key});

  static Future<void> showDialog() =>
      showAsyncDialog(builder: (context) => const BatteryOptimizationDialog());

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.batteryOptimizationTitle),
      content: Text(
        AppLocalizations.of(context)!.batteryOptimizationDialogBody,
      ),
      actions: [
        DialogAction(
          label: AppLocalizations.of(context)!.cancel,
          intent: ActionIntent.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogAction(
          label: AppLocalizations.of(context)!.disableButton,
          intent: ActionIntent.external,
          onPressed: () async {
            await requestIgnoreBatteryOptimizations();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

/// Dialog informing the user that battery optimization is already
/// disabled, with an option to open battery settings.
class BatteryOptimizationAlreadyDisabledDialog extends StatelessWidget {
  const BatteryOptimizationAlreadyDisabledDialog({super.key});

  static Future<void> showDialog() => showAsyncDialog(
    builder: (context) => const BatteryOptimizationAlreadyDisabledDialog(),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.batteryOptimizationTitle),
      content: Text(
        AppLocalizations.of(context)!.batteryOptimizationAlreadyDisabledBody,
      ),
      actions: [
        DialogAction(
          label: AppLocalizations.of(context)!.ok,
          intent: ActionIntent.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogAction(
          label: AppLocalizations.of(
            context,
          )!.batteryOptimizationSettingsButton,
          intent: ActionIntent.external,
          onPressed: () async {
            await openBatteryOptimizationSettings();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
