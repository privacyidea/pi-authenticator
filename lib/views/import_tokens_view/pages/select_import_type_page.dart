import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../../../model/tokens/token.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/extensions/enums/token_import_type_extension.dart';
import '../../../model/token_import/token_import_origin.dart';
import '../../../model/token_import/token_import_source.dart';
import '../import_tokens_view.dart';
import 'import_start_page.dart';

class SelectImportTypePage extends StatelessWidget {
  final TokenImportOrigin tokenImportOrigin;

  const SelectImportTypePage({super.key, required this.tokenImportOrigin});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tokenImportOrigin.appName),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    FluentIcons.arrow_enter_20_filled,
                    size: ImportTokensView.iconSize,
                  ),
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                Text(
                  localizations.selectImportType,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                for (final importEntity in tokenImportOrigin.importSources) ...[
                  if (importEntity != tokenImportOrigin.importSources.first) const SizedBox(height: ImportTokensView.itemSpacingHorizontal / 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text(
                              switch (importEntity.type) {
                                const (TokenImportType.backupFile) => localizations.selectFile,
                                const (TokenImportType.qrScan) => localizations.scanQrCode,
                                const (TokenImportType.qrFile) => localizations.selectFile,
                                const (TokenImportType.link) => localizations.enterLink,
                              },
                              style: Theme.of(context).textTheme.headlineSmall,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ),
                          Expanded(
                            child: Icon(importEntity.type.icon),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      onPressed: () => _routeStartPage(context: context, importSource: importEntity),
                    ),
                  ),
                ],
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _routeStartPage({required TokenImportSource importSource, required BuildContext context}) async {
    final tokensToImport = await Navigator.of(context).push<List<Token>>(
      MaterialPageRoute(
        builder: (context) => ImportStartPage(appName: tokenImportOrigin.appName, selectedSource: importSource),
      ),
    );
    if (tokensToImport != null) {
      if (!context.mounted) return;
      Navigator.of(context).pop(tokensToImport);
    }
  }
}
