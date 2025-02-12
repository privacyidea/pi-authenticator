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

import '../../../../l10n/app_localizations.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../../../model/token_container.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../utils/view_utils.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';

class RolloverContainerTokensDialog extends ConsumerStatefulWidget {
  final TokenContainerFinalized container;

  static Future<void> showDialog(BuildContext context, TokenContainerFinalized container) async {
    await showAsyncDialog(builder: (context) => RolloverContainerTokensDialog(container: container));
  }

  const RolloverContainerTokensDialog({required this.container, super.key});

  @override
  ConsumerState<RolloverContainerTokensDialog> createState() => _RolloverContainerTokensDialogState();
}

class _RolloverContainerTokensDialogState extends ConsumerState<RolloverContainerTokensDialog> {
  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.renewSecretsDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.renewSecretsDialogText),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final tokenState = ref.read(tokenProvider);
            _renewSecrets(tokenState: tokenState);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.renewSecretsButtonText),
        ),
      ],
    );
  }

  Future<void> _renewSecrets({required TokenState tokenState}) async {
    try {
      await ref.read(tokenContainerProvider.notifier).rolloverTokens(tokenState: tokenState, container: widget.container);
    } catch (e) {
      showErrorStatusMessage(message: (l) => l.failedToRenewSecrets, details: (_) => e.toString());
    }
  }
}
