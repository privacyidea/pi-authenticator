import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/views/import_tokens_view/import_tokens_view.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_import_source.dart';

class ImportInvalidFilePage extends StatefulWidget {
  final TokenImportFileSource selectedSource;
  final void Function(BuildContext? Function(), TokenImportFileSource) pickAFile;

  const ImportInvalidFilePage({super.key, required this.selectedSource, required this.pickAFile});

  @override
  State<ImportInvalidFilePage> createState() => _ImportInvalidFilePageState();
}

class _ImportInvalidFilePageState extends State<ImportInvalidFilePage> {
  BuildContext? _currentContext;
  @override
  void initState() {
    _currentContext = context;
    super.initState();
  }

  @override
  void dispose() {
    _currentContext = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedSource.appName),
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
                  Icons.file_present,
                  color: Theme.of(context).colorScheme.error,
                  size: ImportTokensView.iconSize,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                Text(
                  AppLocalizations.of(context)!.fileNoValidBackupFrom(widget.selectedSource.appName),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.pickAFile(() => _currentContext, widget.selectedSource),
                    child: Text(
                      AppLocalizations.of(context)!.selectFile,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
