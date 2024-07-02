import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
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
          onPressed: _selectImportTypeDialog,
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
          onPressed: _selectExportTypeDialog,
        ),
      ],
    );
  }

  void _selectExportTypeDialog() async {
    final isExported = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => const SelectExportTypeDialog(),
    );
    if (isExported == true && mounted) Navigator.of(context).pop(isExported);
  }

  void _selectImportTypeDialog() async {
    final isImported = await Navigator.pushNamed(
      context,
      ImportTokensView.routeName,
    );
    if (isImported == true && mounted) Navigator.of(context).pop(isImported);
  }
}
