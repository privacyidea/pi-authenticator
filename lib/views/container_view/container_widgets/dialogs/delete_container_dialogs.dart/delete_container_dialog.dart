/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/elevated_delete_button.dart';
import 'delete_container_token_dialog.dart';

class DeleteContainerDialog extends ConsumerWidget {
  final TokenContainer container;

  static void showDialog(TokenContainer container) => showAsyncDialog(builder: (context) => DeleteContainerDialog(container));

  const DeleteContainerDialog(this.container, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.deleteContainerDialogTitle(container.serial)),
      content: Text(AppLocalizations.of(context)!.deleteContainerDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedDeleteButton(
          onPressed: () {
            DeleteContainerTokenDialog.showDialog(container).then((v) {
              if (!context.mounted) return;
              Navigator.of(context).pop();
            });
          },
          text: AppLocalizations.of(context)!.delete,
        ),
      ],
    );
  }
}
