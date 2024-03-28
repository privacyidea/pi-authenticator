import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../mains/main_netknights.dart';
import '../../../../../model/encryption/token_encryption.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class ExportTokensToFileDialog extends ConsumerStatefulWidget {
  final Iterable<Token> tokens;
  const ExportTokensToFileDialog({super.key, required this.tokens});

  @override
  ConsumerState<ExportTokensToFileDialog> createState() => _ExportTokensToFileDialogState();
}

class _ExportTokensToFileDialogState extends ConsumerState<ExportTokensToFileDialog> {
  final passwordTextController = TextEditingController();
  bool passwordHidden = true;
  final confirmTextController = TextEditingController();
  bool confirmHidden = true;

  bool exportPressed = false;
  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: Text(AppLocalizations.of(context)!.exportTokens),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: (!exportPressed)
              ? [
                  Text(AppLocalizations.of(context)!.enterPasswordToEncrypt),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passwordTextController,
                          obscureText: passwordHidden,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => passwordHidden = false),
                          onTapUp: (_) => setState(() => passwordHidden = true),
                          onTapCancel: () => setState(() => passwordHidden = true),
                          child: const Icon(Icons.visibility),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: confirmTextController,
                          obscureText: confirmHidden,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.confirmPassword,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => confirmHidden = false),
                          onTapUp: (_) => setState(() => confirmHidden = true),
                          onTapCancel: () => setState(() => confirmHidden = true),
                          child: const Icon(Icons.visibility),
                        ),
                      )
                    ],
                  ),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context)!.exportingTokens),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(),
                  ),
                ],
        ),
        actions: exportPressed == false
            ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                    onPressed: passwordTextController.text.isNotEmpty && passwordTextController.text == confirmTextController.text
                        ? () async {
                            if (passwordTextController.text.isEmpty || passwordTextController.text != confirmTextController.text) {
                              return;
                            }
                            setState(() => exportPressed = true);
                            final tokensToEncrypt = widget.tokens.map((e) => e.copyWith(folderId: () => null));
                            _saveToFile(await TokenEncryption.encrypt(tokens: tokensToEncrypt, password: passwordTextController.text));
                          }
                        : null,
                    child: Text(AppLocalizations.of(context)!.export)),
              ]
            : [],
      );
  void _saveToFile(String encryptedTokens) async {
    if (kIsWeb) return;
    bool isExported = false;
    if (Platform.isAndroid && mounted) isExported = await _saveToFileAndroid(context, encryptedTokens);
    if (Platform.isIOS && mounted) isExported = await _saveToFileIOS(context, encryptedTokens);

    if (mounted && isExported) Navigator.of(context).pop(isExported);
  }

  Future<bool> _saveToFileAndroid(BuildContext context, String encryptedTokens) async {
    try {
      final path = 'storage/emulated/0/Download/${_getFileName()}'.replaceAll(RegExp(r'\s'), '-');
      final file = File(path);
      await file.writeAsString(encryptedTokens);

      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.fileSavedToDownloadsFolder)));
      return true;
    } catch (e) {
      if (context.mounted) ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(context)!.errorSavingFile, null);
      setState(() => exportPressed = false);
      return false;
    }
  }

  Future<bool> _saveToFileIOS(BuildContext context, String encryptedTokens) async {
    final Directory downloadsDir = await getApplicationDocumentsDirectory();
    final file = File('${downloadsDir.path}/${_getFileName()}');
    try {
      await file.writeAsString(encryptedTokens);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.fileSavedToDownloadsFolder)));
      return true;
    } catch (e) {
      if (context.mounted) ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(context)!.errorSavingFile, null);
      setState(() => exportPressed = false);
      return false;
    }
  }

  String _getFileName() {
    final time = DateTime.now();
    final appName = PrivacyIDEAAuthenticator.currentCustomization!.appName;
    return '${appName}_backup_${time.year}-${time.month}-${time.day}_${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}${time.second.toString().padLeft(2, '0')}.json';
  }
}
