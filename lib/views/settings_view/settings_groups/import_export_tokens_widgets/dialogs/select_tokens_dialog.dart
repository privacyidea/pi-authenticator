/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../model/extensions/token_folder_extension.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/select_tokens_widget.dart';

class SelectExportTokensDialog extends ConsumerStatefulWidget {
  final bool multiSelect;
  final Widget Function(Set<Token> tokens) dialogBuilder;
  const SelectExportTokensDialog({this.multiSelect = true, required this.dialogBuilder, super.key});

  @override
  ConsumerState<SelectExportTokensDialog> createState() => _SelectTokensDialogState();
}

class _SelectTokensDialogState extends ConsumerState<SelectExportTokensDialog> {
  final Set<Token> _selectedTokens = {};
  @override
  Widget build(BuildContext context) {
    final tokens = ref.read(tokenProvider).tokens.nonPiTokens.toSet();
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
      content: SelectTokensWidget(
        multiSelect: widget.multiSelect,
        tokens: tokens,
        onSelect: widget.multiSelect
            ? (selected, _) {
                setState(() {
                  _selectedTokens.clear();
                  _selectedTokens.addAll(selected);
                });
              }
            : (selected, _) {
                _showExportDialog(_selectedTokens);
              },
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

  void _showExportDialog(Set<Token> tokens) async {
    if (tokens.isEmpty) return;
    final isExported = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      builder: (context) => widget.dialogBuilder(tokens),
    );
    if (isExported == true && mounted) Navigator.of(context).pop(isExported);
  }

  void _showHelpDialog() => showDialog(
        context: context,
        builder: (context) => DefaultDialog(
          title: Text(AppLocalizations.of(context)!.selectTokensToExportHelpTitle),
          content: SelectTokensToExportHelpContentWidget(),
        ),
      );
}

class SelectTokensToExportHelpContentWidget extends StatelessWidget {
  const SelectTokensToExportHelpContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${appLocalizations.selectTokensToExportHelpContent1} ${appLocalizations.selectTokensToExportHelpContent2}'),
        SizedBox(height: 8),
        Text(appLocalizations.selectTokensToExportHelpContent3),
        SizedBox(height: 8),
        Text(appLocalizations.selectTokensToExportHelpContent4),
      ],
    );
  }
}
