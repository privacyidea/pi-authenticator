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
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_container.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import 'delete_container_force_dialog.dart';

class DeleteContainerDialog extends ConsumerWidget {
  final TokenContainer container;

  static void showDialog(TokenContainer container) =>
      showAsyncDialog(builder: (context) => DeleteContainerDialog(container));

  const DeleteContainerDialog(this.container, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultDialog(
      title: Text(
        AppLocalizations.of(
          context,
        )!.deleteContainerDialogTitle(container.serial),
      ),
      content: Text(AppLocalizations.of(context)!.deleteContainerDialogContent),
      actions: [
        DialogAction(
          label: AppLocalizations.of(context)!.cancel,
          intent: ActionIntent.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogAction(
          label: AppLocalizations.of(context)!.delete,
          intent: ActionIntent.destructive,
          onPressed: () => _onPressDelete(context, ref),
        ),
      ],
    );
  }

  Future<void> _onPressDelete(BuildContext context, WidgetRef ref) async {
    var wasContainerDeleted = await _deleteContainer(ref);
    if (!wasContainerDeleted) {
      wasContainerDeleted =
          (await ForceDeleteContainerDialog.showDialog(container)) == true;
    }
    if (!context.mounted || !wasContainerDeleted) return;
    Navigator.of(context).pop();
  }

  Future<bool> _deleteContainer(WidgetRef ref) {
    if (container is TokenContainerFinalized) {
      return ref
          .read(tokenContainerProvider.notifier)
          .unregisterDelete(container as TokenContainerFinalized);
    } else {
      return ref
          .read(tokenContainerProvider.notifier)
          .deleteContainer(container);
    }
  }
}
