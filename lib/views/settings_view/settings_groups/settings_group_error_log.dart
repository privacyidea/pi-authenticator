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
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../settings_view_widgets/logging_menu.dart';
import '../settings_view_widgets/settings_group.dart';

class SettingsGroupErrorLog extends StatelessWidget {
  const SettingsGroupErrorLog({super.key});

  @override
  Widget build(BuildContext context) => SettingsGroup(
        title: AppLocalizations.of(context)!.errorLogTitle,
        onPressed: () => showDialog(
          useRootNavigator: false,
          context: context,
          builder: (_) => const SettingsGroupErrorLogDialog(),
        ),
        trailingIcon: Icons.error_outline,
      );
}

class SettingsGroupErrorLogDialog extends StatelessWidget {
  const SettingsGroupErrorLogDialog({super.key});

  @override
  Widget build(BuildContext context) => const LoggingMenu();
}
