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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/settings_provider.dart';
import '../../../widgets/dialog_widgets/default_dialog.dart';
import 'errorlog_buttons/delete_errorlog_button.dart';
import 'errorlog_buttons/send_errorlog_button.dart';
import 'errorlog_buttons/show_errorlog_button.dart';

class LoggingMenu extends ConsumerWidget {
  const LoggingMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final verboseLogging = settings.verboseLogging;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DefaultDialog(
        scrollable: true,
        title: Text(
          AppLocalizations.of(context)!.logMenu,
          style: Theme.of(context).listTileTheme.titleTextStyle,
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.verboseLogging,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              contentPadding: const EdgeInsets.all(0),
              trailing: Switch(value: verboseLogging, onChanged: (value) => ref.read(settingsProvider.notifier).setVerboseLogging(value)),
              style: ListTileStyle.list,
              onTap: () => ref.read(settingsProvider.notifier).toggleVerboseLogging(),
            ),
            const Divider(),
            const ShowErrorLogButton(),
            const DeleteErrorlogButton(),
            const SendErrorLogButton(),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.dismiss,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
