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
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/introduction.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../widgets/button_widgets/delayed_elevated_button.dart';
import '../../../widgets/dialog_widgets/default_dialog.dart';
import '../../import_tokens_view/import_tokens_view.dart';
import '../settings_view_widgets/settings_group.dart';
import '../settings_view_widgets/settings_list_tile_button.dart';
import 'import_export_tokens_widgets/dialogs/select_export_type_dialog.dart';
import 'import_export_tokens_widgets/dialogs/select_tokens_dialog.dart';

class SettingsGroupImportExportTokens extends ConsumerStatefulWidget {
  const SettingsGroupImportExportTokens({super.key});

  @override
  ConsumerState<SettingsGroupImportExportTokens> createState() => _SettingsGroupImportExportTokensState();
}

class _SettingsGroupImportExportTokensState extends ConsumerState<SettingsGroupImportExportTokens> {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return SettingsGroup(
      title: appLocalizations.importExportTokens,
      children: [
        SettingsListTileButton(
          onPressed: _routeToImport,
          title: Text(
            appLocalizations.importTokens,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          icon: const RotatedBox(
            quarterTurns: 1,
            child: Icon(FluentIcons.arrow_enter_20_filled),
          ),
        ),
        SettingsListTileButton(
          title: Text(
            appLocalizations.exportNonPrivacyIDEATokens,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.fade,
          ),
          icon: const RotatedBox(
            quarterTurns: 3,
            child: Icon(FluentIcons.arrow_exit_20_filled),
          ),
          onPressed: _exportDialog,
        ),
      ],
    );
  }

  void _exportDialog() async {
    bool? isAccepted = (await ref.read(introductionNotifierProvider.future)).isCompleted(Introduction.exportTokens) ? true : null;
    if (!mounted) return;
    final appLocalizations = AppLocalizations.of(context)!;
    isAccepted ??= await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => DefaultDialog(
        title: Text(appLocalizations.exportTokensHintDialogTitle),
        content: SelectTokensToExportHelpContentWidget(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appLocalizations.cancel),
          ),
          DelayedElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            delaySeconds: 10,
            child: Text(appLocalizations.ok),
          ),
        ],
      ),
    );
    if (isAccepted == true) await ref.read(introductionNotifierProvider.notifier).complete(Introduction.exportTokens);
    if (isAccepted != true || !mounted) return;
    final isExported = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => const SelectExportTypeDialog(),
    );
    if (isExported == true && mounted) Navigator.of(context).pop(isExported);
  }

  void _routeToImport() => Navigator.pushNamed(context, ImportTokensView.routeName)
      .then((isImported) => (isImported == true && mounted) ? Navigator.of(context).pop(isImported) : null);
}
