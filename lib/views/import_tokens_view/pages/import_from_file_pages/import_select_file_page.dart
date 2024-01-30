import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_import_source.dart';
import '../../../../utils/logger.dart';
import '../../import_tokens_view.dart';
import 'import_decrypted_file_page.dart';
import 'import_encrypted_file_page.dart';
import 'import_invalid_file_page.dart';

class ImportSelectFilePage extends StatefulWidget {
  final TokenImportFileSource selectedSource;
  const ImportSelectFilePage({required this.selectedSource, super.key});

  @override
  State<ImportSelectFilePage> createState() => _ImportSelectFilePageState();
}

class _ImportSelectFilePageState extends State<ImportSelectFilePage> {
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
                const Icon(
                  Icons.file_present,
                  size: ImportTokensView.iconSize,
                ),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                Text(widget.selectedSource.importHint(context), textAlign: TextAlign.center),
                const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _pickAFile(() => _currentContext, widget.selectedSource),
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

void _pickAFile(BuildContext? Function() getCurrentContext, TokenImportFileSource tokenSource) async {
  final BuildContext? currentContext = getCurrentContext();
  if (currentContext == null || currentContext.mounted == false) return;
  final XTypeGroup typeGroup = XTypeGroup(label: AppLocalizations.of(currentContext)!.selectFile);
  final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  if (file == null) {
    Logger.warning("No file selected", name: "_pickAFile#ImportSelectFilePage");
    return;
  }
  if (await tokenSource.processor.fileIsValid(file: file) == false) return _routeInvalidFile(getCurrentContext, tokenSource);
  if (await tokenSource.processor.fileNeedsPassword(file: file)) return _routeEncryptedFile(getCurrentContext, file, tokenSource);

  _routeDecryptedFile(getCurrentContext, file, tokenSource);
}

void _routeInvalidFile(BuildContext? Function() getCurrentContext, TokenImportFileSource tokenSource) {
  final currentContext = getCurrentContext();
  if (currentContext == null || currentContext.mounted == false) return;
  Navigator.of(currentContext)
      .pushReplacement(MaterialPageRoute(builder: (context) => ImportInvalidFilePage(selectedSource: tokenSource, pickAFile: _pickAFile)));
}

void _routeEncryptedFile(BuildContext? Function() getCurrentContext, XFile file, TokenImportFileSource tokenSource) {
  final currentContext = getCurrentContext();
  if (currentContext == null || currentContext.mounted == false) return;
  Navigator.of(currentContext).pushReplacement(MaterialPageRoute(
      builder: (context) => ImportEncryptedFilePage(
          importFunction: ({required String password}) async => await tokenSource.processor.processFile(file: file, password: password),
          appName: tokenSource.appName)));
}

void _routeDecryptedFile(BuildContext? Function() getCurrentContext, XFile file, TokenImportFileSource tokenSource) {
  final currentContext = getCurrentContext();
  if (currentContext == null || currentContext.mounted == false) return;
  Navigator.of(currentContext).pushReplacement(MaterialPageRoute(
      builder: (context) =>
          ImportDecryptedFilePage(importFunction: () async => await tokenSource.processor.processFile(file: file), appName: tokenSource.appName)));
}
