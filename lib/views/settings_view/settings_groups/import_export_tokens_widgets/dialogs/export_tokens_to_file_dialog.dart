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
import '../../../../../utils/validators.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class ExportTokensToFileDialog extends ConsumerStatefulWidget {
  final Iterable<Token> tokens;
  const ExportTokensToFileDialog({super.key, required this.tokens});

  @override
  ConsumerState<ExportTokensToFileDialog> createState() => _ExportTokensToFileDialogState();
}

class _ExportTokensToFileDialogState extends ConsumerState<ExportTokensToFileDialog> {
  final _passwordTextController = TextEditingController();
  bool _passwordHidden = true;
  final _confirmTextController = TextEditingController();
  bool _confirmHidden = true;

  bool _exportPressed = false;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(appLocalizations.exportTokens),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: (!_exportPressed)
            ? [
                Text(
                  appLocalizations.enterPasswordToEncrypt,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordTextController,
                        obscureText: _passwordHidden,
                        onChanged: (value) => setState(() {}),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: Validators(appLocalizations).password,
                        decoration: InputDecoration(
                          labelText: appLocalizations.password,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _passwordHidden = false),
                        onTapUp: (_) => setState(() => _passwordHidden = true),
                        onTapCancel: () => setState(() => _passwordHidden = true),
                        child: const Icon(Icons.visibility),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _confirmTextController,
                        obscureText: _confirmHidden,
                        onChanged: (value) => setState(() {}),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => Validators(appLocalizations).confirmPassword(_passwordTextController.text, value),
                        decoration: InputDecoration(
                          labelText: appLocalizations.confirmPassword,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _confirmHidden = false),
                        onTapUp: (_) => setState(() => _confirmHidden = true),
                        onTapCancel: () => setState(() => _confirmHidden = true),
                        child: const Icon(Icons.visibility),
                      ),
                    )
                  ],
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(appLocalizations.exportingTokens),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              ],
      ),
      actions: _exportPressed == false
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(appLocalizations.cancel),
              ),
              TextButton(
                  onPressed: _passwordTextController.text.isNotEmpty && _passwordTextController.text == _confirmTextController.text
                      ? () async {
                          if (_passwordTextController.text.isEmpty || _passwordTextController.text != _confirmTextController.text) {
                            return;
                          }
                          setState(() => _exportPressed = true);
                          final tokensToEncrypt = widget.tokens.map((e) => e.copyWith(folderId: () => null));
                          _saveToFile(await TokenEncryption.encrypt(tokens: tokensToEncrypt, password: _passwordTextController.text));
                        }
                      : null,
                  child: Text(appLocalizations.export)),
            ]
          : [],
    );
  }

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
      setState(() => _exportPressed = false);
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
      setState(() => _exportPressed = false);
      return false;
    }
  }

  String _getFileName() {
    final time = DateTime.now();
    final appName = PrivacyIDEAAuthenticator.currentCustomization!.appName;
    return '${appName}_backup_${time.year}-${time.month}-${time.day}_${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}${time.second.toString().padLeft(2, '0')}.json';
  }
}
