import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/widgets/countdown_button.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/dialog_widgets/default_dialog.dart';
import '../../import_tokens_view/import_tokens_view.dart';
import '../settings_view_widgets/settings_groups.dart';
import '../settings_view_widgets/settings_list_tile_button.dart';
import 'import_export_tokens_widgets/dialogs/select_export_type_dialog.dart';

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
          onPressed: _importDialog,
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
    bool? isAccepted = ref.read(introductionProvider).isCompleted(Introduction.exportTokens) ? true : null;
    isAccepted ??= await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => DefaultDialog(
        title: Text(AppLocalizations.of(context)!.confirmation),
        content: Text(AppLocalizations.of(context)!.selectTokensToExportHelpContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          CountdownButton(
            onPressed: () => Navigator.of(context).pop(true),
            countdownSeconds: 5,
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
    if (isAccepted == true) await ref.read(introductionProvider.notifier).complete(Introduction.exportTokens);
    if (isAccepted != true || !mounted) return;
    final isExported = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => const SelectExportTypeDialog(),
    );
    if (isExported == true && mounted) Navigator.of(context).pop(isExported);
  }

  void _importDialog() async {
    final isImported = await Navigator.pushNamed(
      context,
      ImportTokensView.routeName,
    );
    if (isImported == true && mounted) Navigator.of(context).pop(isImported);
  }
}
