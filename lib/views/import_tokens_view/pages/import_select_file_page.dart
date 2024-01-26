import 'dart:developer';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/token_import_source.dart';
import '../../../utils/logger.dart';
import 'import_decrypted_file_page.dart';
import 'import_encrypted_file_page.dart';
import 'import_invalid_file_page.dart';

class ImportSelectFilePage extends StatelessWidget {
  final TokenImportSource? selectedSource;
  const ImportSelectFilePage({super.key, this.selectedSource});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(selectedSource!.appName),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_present,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(selectedSource!.importHint(context), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _pickAFile(() => context),
                    child: Text(AppLocalizations.of(context)!.selectFile),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _pickAFile(BuildContext Function() getContext) async {
    final buildContext = getContext();
    final XTypeGroup typeGroup = XTypeGroup(label: AppLocalizations.of(buildContext)!.selectFile);
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) {
      Logger.warning("No file selected", name: "_pickAFile#ImportSelectFilePage");
      return;
    }

    final fileContentIsValid = await selectedSource!.processor?.fileIsValid(file: file) ?? false;
    log("File content is valid: $fileContentIsValid", name: "_pickAFile#ImportSelectFilePage");
    if (fileContentIsValid == false) {
      _pushReplacementAsync(
        page: ImportInvalidFilePage(selectedSource: selectedSource!, pickAFile: _pickAFile),
        getContext: getContext,
      );
      return;
    }

    final passwordIsNeeded = await selectedSource!.processor?.fileNeedsPassword(file: file) ?? false;
    if (passwordIsNeeded) {
      _pushReplacementAsync(
        page: ImportEncryptedFilePage(
          importFunction: ({required String password}) async => await selectedSource!.processor!.process(file: file, password: password),
          appName: selectedSource!.appName,
        ),
        getContext: getContext,
      );
    } else {
      _pushReplacementAsync(
        page: ImportDecryptedFilePage(
          importFunction: () async => await selectedSource!.processor!.process(file: file),
          appName: selectedSource!.appName,
        ),
        getContext: getContext,
      );
    }
  }

  void _pushReplacementAsync({required Widget page, required BuildContext Function() getContext}) async {
    await Navigator.of(getContext()).pushReplacement(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}
