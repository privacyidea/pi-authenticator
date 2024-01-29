import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_import_source.dart';

class ImportInvalidQrScanPage extends StatelessWidget {
  final TokenImportSource selectedSource;
  final void Function(BuildContext Function()) startQrScan;

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
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code,
                  color: Theme.of(context).colorScheme.error,
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.scanNoValidBackupFrom(selectedSource.appName),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => startQrScan(() => context),
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
