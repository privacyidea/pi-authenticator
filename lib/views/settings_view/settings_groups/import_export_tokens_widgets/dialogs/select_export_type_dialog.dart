import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../settings_view_widgets/settings_list_tile_button.dart';
import 'export_tokens_to_file_dialog.dart';
import 'select_tokens_dialog.dart';
import 'show_qr_code_dialog.dart';

class SelectExportTypeDialog extends StatelessWidget {
  const SelectExportTypeDialog({super.key});

  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: Text(AppLocalizations.of(context)!.exportTokens),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsListTileButton(
              title: Text(AppLocalizations.of(context)!.toFile, style: Theme.of(context).textTheme.titleMedium),
              onPressed: () async => _selectTokensDialog(context),
              icon: const Icon(Icons.file_present, size: 24),
            ),
            SettingsListTileButton(
                title: Text(AppLocalizations.of(context)!.asQrCode, style: Theme.of(context).textTheme.titleMedium),
                onPressed: () async => _selectTokenDialog(context),
                icon: const Icon(Icons.qr_code, size: 24)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      );

  void _selectTokensDialog(BuildContext context) async {
    final isExported = await showDialog<bool>(
      context: context,
      builder: (context) => SelectTokensDialog(
        exportDialogBuilder: (tokens) => ExportTokensToFileDialog(tokens: tokens),
      ),
    );
    if (isExported == true && context.mounted) Navigator.of(context).pop(isExported);
  }

  void _selectTokenDialog(BuildContext context) async {
    final isExported = await showDialog<bool>(
      context: context,
      builder: (context) => SelectTokensDialog(
        multiSelect: false,
        exportDialogBuilder: (tokens) => ShowQrCodeDialog(token: tokens.first),
      ),
    );
    if (isExported == true && context.mounted) Navigator.of(context).pop(isExported);
  }
}
