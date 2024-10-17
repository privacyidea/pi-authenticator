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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../settings_view_widgets/settings_list_tile_button.dart';
import 'export_tokens_to_file_dialog.dart';
import 'select_tokens_dialog.dart';
import 'show_qr_code_dialog.dart';

class SelectExportTypeDialog extends StatelessWidget {
  const SelectExportTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(appLocalizations.exportTokens),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsListTileButton(
            title: Text(appLocalizations.asFile, style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () async => _selectTokensDialog(context),
            icon: const Icon(Icons.file_present, size: 24),
          ),
          SettingsListTileButton(
              title: Text(appLocalizations.asQrCode, style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () async => _selectTokenDialog(context),
              icon: const Icon(Icons.qr_code, size: 24)),
        ],
      ),
    );
  }

  void _selectTokensDialog(BuildContext context) async {
    final isExported = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => SelectTokensDialog(
        exportDialogBuilder: (tokens) {
          if (tokens.isEmpty) {
            return DefaultDialog(
              content: Text(AppLocalizations.of(context)!.noTokenToExport),
            );
          }
          return ExportTokensToFileDialog(tokens: tokens);
        },
      ),
    );
    if (isExported == true && context.mounted) Navigator.of(context).pop(isExported);
  }

  void _selectTokenDialog(BuildContext context) async {
    final authenticated = await lockAuth(
      localizedReason: AppLocalizations.of(context)!.exportLockedTokenReason,
      autoAuthIfUnsupported: true,
    );
    if (!authenticated || !context.mounted) return;
    final isExported = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => SelectTokensDialog(
        multiSelect: false,
        exportDialogBuilder: (tokens) {
          if (tokens.isEmpty) {
            return DefaultDialog(
              content: Text(AppLocalizations.of(context)!.noTokenToExport),
            );
          }

          return ShowQrCodeDialog(token: tokens.first);
        },
      ),
    );
    if (isExported == true && context.mounted) Navigator.of(context).pop(isExported);
  }
}
