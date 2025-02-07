/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../model/token_container.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../select_tokens_widget.dart';
import 'send_otps_without_ssl_dialog.dart';

class InitialTokenAssignmentDialog extends ConsumerStatefulWidget {
  final TokenContainer container;
  final List<Token> tokens;
  const InitialTokenAssignmentDialog({super.key, required this.tokens, required this.container});

  static Future<Iterable<Token>?> showDialog(TokenContainer container, List<Token> tokens) async {
    final returnValue = await showAsyncDialog(builder: (context) => InitialTokenAssignmentDialog(container: container, tokens: tokens));
    assert(returnValue is Iterable<Token>?, "The return value of the InitialTokenAssignmentDialog must be an Iterable<Token> or null.");
    return returnValue;
  }

  @override
  ConsumerState<InitialTokenAssignmentDialog> createState() => _InitialTokenAssignmentDialogState();
}

class _InitialTokenAssignmentDialogState extends ConsumerState<InitialTokenAssignmentDialog> {
  Set<Token> _selectedTokens = {};
  Set<Token> _unselectedTokens = {};

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(localizations.initialTokenAssignmentDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(localizations.initialTokenAssignmentDialogContent1(widget.container.syncUrl.toString())),
          SizedBox(height: 8),
          Text(localizations.initialTokenAssignmentDialogContent2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(localizations.initialTokenAssignmentDialogQuestion),
          ),
          SelectTokensWidget(
            multiSelect: true,
            tokens: widget.tokens.toSet(),
            onSelect: (selected, unselected) => setState(() {
              _selectedTokens = selected;
              _unselectedTokens = unselected;
            }),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          child: Text(localizations.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _selectedTokens.isEmpty
              ? () => Navigator.of(context).pop(_selectedTokens)
              : () async {
                  if (!widget.container.sslVerify) {
                    final ok = await SendOTPsWithoutSSLDialog.showDialog();
                    if (ok != true || !context.mounted) return;
                  }
                  ref.read(tokenProvider.notifier).updateTokens(
                        _unselectedTokens.toList(),
                        (t) => t.copyWith(checkedContainer: t.checkedContainer..add(widget.container.serial)),
                      );
                  Navigator.of(context).pop(_selectedTokens);
                },
          child: _selectedTokens.isEmpty
              ? Text(localizations.initialTokenAssignmentDialogButtonZero)
              : Text(localizations.initialTokenAssignmentDialogButtonSelected),
        ),
      ],
    );
  }
}
