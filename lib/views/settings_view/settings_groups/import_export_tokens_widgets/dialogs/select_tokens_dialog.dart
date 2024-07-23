import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/states/token_state.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_providers/app_constraints_provider.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../main_view/main_view_widgets/token_widgets/token_widget_builder.dart';

class SelectTokensDialog extends ConsumerStatefulWidget {
  final bool multiSelect;
  final Widget Function(Iterable<Token> tokens) exportDialogBuilder;
  const SelectTokensDialog({this.multiSelect = true, required this.exportDialogBuilder, super.key});

  @override
  ConsumerState<SelectTokensDialog> createState() => _SelectTokensDialogState();
}

class _SelectTokensDialogState extends ConsumerState<SelectTokensDialog> {
  Set<Token> _selectedTokens = {};
  @override
  Widget build(BuildContext context) {
    final tokens = ref.read(tokenProvider).tokens.nonPiTokens;
    final exportEveryToken = tokens.length == _selectedTokens.length && _selectedTokens.containsAll(tokens);
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(appLocalizations.selectTokensToExport(widget.multiSelect ? 2 : 1))),
          GestureDetector(
            onTap: _showHelpDialog,
            child: Icon(
              Icons.help_outline_rounded,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: ref.watch(appConstraintsProvider)!.maxWidth * 0.8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: (tokens.isEmpty)
              ? Text(
                  appLocalizations.noTokenToExport,
                  textAlign: TextAlign.center,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...[
                      if (widget.multiSelect)
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (exportEveryToken) {
                                _selectedTokens.clear();
                              } else {
                                _selectedTokens = tokens.toSet();
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                appLocalizations.exportAllTokens,
                                textAlign: TextAlign.right,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Checkbox(
                                    value: exportEveryToken,
                                    onChanged: ((value) => setState(() => value == true ? _selectedTokens = tokens.toSet() : _selectedTokens.clear()))),
                              ),
                            ],
                          ),
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
                                            backgroundColor: WidgetStateProperty.all(theme.colorScheme.secondary.withAlpha(80)),
                                          )
                                        : null,
                                    onPressed: () async {
                                      if (!widget.multiSelect) {
                                        _showExportDialog([token]);
                                        return;
                                      }
                                      setState(() {
                                        if (_selectedTokens.contains(token)) {
                                          _selectedTokens.remove(token);
                                        } else {
                                          if (widget.multiSelect || _selectedTokens.isEmpty) {
                                            _selectedTokens.add(token);
                                          }
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
          child: Text(appLocalizations.cancel),
        ),
        if (widget.multiSelect)
          TextButton(
            onPressed: _selectedTokens.isNotEmpty
                ? () {
                    _showExportDialog(_selectedTokens);
                  }
                : null,
            child: Text(appLocalizations.export),
          ),
      ],
    );
  }

  void _showExportDialog(Iterable<Token> tokens) async {
    if (tokens.isEmpty) return;
    final isExported = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => widget.exportDialogBuilder(tokens),
    );
    if (isExported == true && mounted) Navigator.of(context).pop(isExported);
  }

  void _showHelpDialog() => showDialog(
        context: context,
        builder: (context) => DefaultDialog(
          title: Text(AppLocalizations.of(context)!.selectTokensToExportHelpTitle),
          content: Text(AppLocalizations.of(context)!.selectTokensToExportHelpContent),
        ),
      );
}
