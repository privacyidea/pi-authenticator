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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_container.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/view_utils.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/elevated_delete_button.dart';
import 'delete_container_force_dialog.dart';

class DeleteContainerTokenDialog extends ConsumerWidget {
  final TokenContainer container;

  const DeleteContainerTokenDialog(this.container, {super.key});

  static Future<void> showDialog(TokenContainer container) => showAsyncDialog(
        builder: (context) => DeleteContainerTokenDialog(container),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.deleteContainerDialogTitle(container.serial)),
      content: Text(appLocalizations.containerDeleteCorrespondingTokenDialogContent),
      hasCloseButton: true,
      actions: [
        ElevatedDeleteButton(
          text: appLocalizations.deleteOnlyContainerButtonText,
          onPressed: () async {
            final success = await _deleteContainer(ref);
            if (!success) {
              await ForceDeleteContainerDialog.showDialog(container);
            }
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
        ),
        ElevatedDeleteButton(
          onPressed: () async {
            final containerTokens = ref.read(tokenProvider).containerTokens(container.serial);
            var success = await _deleteContainer(ref);
            if (!success) {
              success = (await ForceDeleteContainerDialog.showDialog(container)) == true;
            }
            if (success) await ref.read(tokenProvider.notifier).removeTokens(containerTokens);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          text: appLocalizations.deleteAllButtonText,
        ),
      ],
    );
  }

  Future<bool> _deleteContainer(WidgetRef ref) {
    if (container is TokenContainerFinalized) {
      return ref.read(tokenContainerProvider.notifier).unregisterDelete(container as TokenContainerFinalized);
    } else {
      return ref.read(tokenContainerProvider.notifier).deleteContainer(container);
    }
  }
}
