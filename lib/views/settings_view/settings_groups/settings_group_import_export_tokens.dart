import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/encryption/token_encryption.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../l10n/app_localizations.dart';
import '../../../mains/main_netknights.dart';
import '../../../utils/riverpod_providers.dart';
import '../../import_tokens_view/import_tokens_view.dart';
import '../settings_view_widgets/settings_groups.dart';
import '../settings_view_widgets/settings_list_tile_button.dart';

class SettingsGroupImportExportTokens extends ConsumerStatefulWidget {
  const SettingsGroupImportExportTokens({super.key});

  @override
  ConsumerState<SettingsGroupImportExportTokens> createState() => _SettingsGroupImportExportTokensState();
}

class _SettingsGroupImportExportTokensState extends ConsumerState<SettingsGroupImportExportTokens> {
  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Import/Export Tokens',
      children: [
        SettingsListTileButton(
          title: Text(
            'Export non-privacyIDEA tokens to file',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.fade,
          ),
          icon: const RotatedBox(
            quarterTurns: 3,
            child: Icon(FluentIcons.arrow_exit_20_filled),
          ),
          onPressed: () async {
            final isExported = await _selectTokensDialog();
            if (isExported == true && context.mounted) Navigator.of(context).pop(isExported);
          },
        ),
        SettingsListTileButton(
          onPressed: () {
            Navigator.pushNamed(context, ImportTokensView.routeName);
          },
          title: Text(
            AppLocalizations.of(context)!.importTokens,
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          icon: const RotatedBox(
            quarterTurns: 1,
            child: Icon(FluentIcons.arrow_enter_20_filled),
          ),
        ),
      ],
    );
  }

  Future<bool?> _selectTokensDialog() => showDialog<bool>(
        context: context,
        builder: (context) => const SelectTokensDialog(),
      );
}

class SelectTokensDialog extends ConsumerStatefulWidget {
  const SelectTokensDialog({super.key});

  @override
  ConsumerState<SelectTokensDialog> createState() => _SelectTokensDialogState();
}

class _SelectTokensDialogState extends ConsumerState<SelectTokensDialog> {
  Set<Token> _selectedTokens = {};
  @override
  Widget build(BuildContext context) {
    final tokens = ref.read(tokenProvider).nonPiTokens;
    final exportEveryToken = tokens.length == _selectedTokens.length && _selectedTokens.containsAll(tokens);
    return DefaultDialog(
      title: const Text('Select tokens to export'),
      content: SizedBox(
        width: ref.watch(appConstraintsProvider)!.maxWidth * 0.8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: (tokens.isEmpty)
              ? const Text('No tokens available')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Export all tokens',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Checkbox(
                                value: exportEveryToken,
                                onChanged: ((value) => setState(() => value == true ? _selectedTokens = tokens.toSet() : _selectedTokens.clear()))),
                          ),
                        ],
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (final token in tokens)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: TextButton(
                                    style: _selectedTokens.contains(token)
                                        ? ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary.withAlpha(80)),
                                          )
                                        : null,
                                    onPressed: () {
                                      setState(() {
                                        if (_selectedTokens.contains(token)) {
                                          _selectedTokens.remove(token);
                                        } else {
                                          _selectedTokens.add(token);
                                        }
                                      });
                                    },
                                    child: TokenWidgetBuilder.previewFromToken(token),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final isExported = await _showExportDialog();
            if (isExported == true && context.mounted) Navigator.of(context).pop(isExported);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }

  Future<bool?> _showExportDialog() => showDialog<bool>(
        context: context,
        builder: (context) => ExportTokensDialog(tokens: _selectedTokens),
      );
}

class ExportTokensDialog extends ConsumerStatefulWidget {
  final Iterable<Token>? tokens;
  const ExportTokensDialog({super.key, this.tokens});

  @override
  ConsumerState<ExportTokensDialog> createState() => _ExportTokensDialogState();
}

class _ExportTokensDialogState extends ConsumerState<ExportTokensDialog> {
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: const Text('Export Tokens'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please choose a Password to encrypt the tokens'),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
              onPressed: textController.text.isNotEmpty
                  ? () async {
                      final tokensToEncrypt = widget.tokens ?? ref.read(tokenProvider).tokens;
                      final encryptedTokens = await TokenEncryption.encrypt(tokens: tokensToEncrypt, password: textController.text);
                      if (!context.mounted) return;
                      final isExported = await _saveToFile(context, encryptedTokens);
                      if (context.mounted) Navigator.of(context).pop(isExported);
                    }
                  : null,
              child: const Text('Export')),
        ],
      );
  Future<bool> _saveToFile(BuildContext context, String encryptedTokens) async {
    // save to downloads folder
    try {
      final time = DateTime.now();
      final timeString = '${time.year}'
          '-${time.month}'
          '-${time.day}'
          '_${time.hour.toString().padLeft(2, '0')}'
          '${time.minute.toString().padLeft(2, '0')}'
          '${time.second.toString().padLeft(2, '0')}';
      final appName = PrivacyIDEAAuthenticator.currentCustomization!.appName;
      final path = 'storage/emulated/0/Download/${appName}_backup_$timeString.json'.replaceAll(RegExp(r'\s'), '-');
      final file = File(path);
      await file.writeAsString(encryptedTokens);

      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File saved to downloads folder')));
      return true;
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save file:$e')));
      return false;
    }
  }
}
