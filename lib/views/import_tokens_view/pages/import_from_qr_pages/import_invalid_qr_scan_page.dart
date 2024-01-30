import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_import_source.dart';
import '../../import_tokens_view.dart';

class ImportInvalidQrScanPage extends StatelessWidget {
  final TokenImportQrScanSource selectedSource;
  final void Function(BuildContext? Function(), TokenImportQrScanSource) startQrScan;

  const ImportInvalidQrScanPage({super.key, required this.selectedSource, required this.startQrScan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSource.appName),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code,
                  color: Theme.of(context).colorScheme.error,
                  size: ImportTokensView.iconSize,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                Text(
                  AppLocalizations.of(context)!.scanNoValidBackupFrom(selectedSource.appName),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                ElevatedButton(
                  onPressed: () => startQrScan(() => context, selectedSource),
                  child: Text(AppLocalizations.of(context)!.selectFile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
