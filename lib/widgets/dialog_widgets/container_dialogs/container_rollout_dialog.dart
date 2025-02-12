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
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/tokens/token.dart';
import '../default_dialog.dart';

class ContainerSyncResultDialog extends StatelessWidget {
  final TokenContainerFinalized container;
  final List<Token> addedTokens;
  final List<Token> removedTokens;

  static void showDialog({required TokenContainerFinalized container, required List<Token> addedTokens, required List<Token> removedTokens}) {
    if (addedTokens.isEmpty && removedTokens.isEmpty) {
      // Nothing to show
      Logger.debug('No tokens added or removed during sync.');
      return;
    }
    showAsyncDialog(builder: (context) => ContainerSyncResultDialog(container: container, addedTokens: addedTokens, removedTokens: removedTokens));
  }

  const ContainerSyncResultDialog({
    required this.container,
    required this.addedTokens,
    required this.removedTokens,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final Map<String, int> tokenTypes = {};
    for (final token in addedTokens) {
      if (tokenTypes.containsKey(token.type)) {
        tokenTypes[token.type] = tokenTypes[token.type]! + 1;
      } else {
        tokenTypes[token.type] = 1;
      }
    }
    return DefaultDialog(
      hasCloseButton: true,
      title: Text(AppLocalizations.of(context)!.containerSyncDialogTitle(container.serial)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (addedTokens.isNotEmpty) ...[
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    AppLocalizations.of(context)!.containerSyncDialogNewTokens,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                for (var tokenType in tokenTypes.keys)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          size: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16,
                        ),
                        Expanded(
                          child: Text(
                            ' ${tokenTypes[tokenType]}x $tokenType',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if (removedTokens.isNotEmpty) ...[
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    AppLocalizations.of(context)!.containerSyncDialogRemovedTokens,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                for (var token in removedTokens)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_circle,
                          size: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16,
                        ),
                        Expanded(
                          child: Text(
                            ' ${token.label}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    );
  }
}
