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
import '../../../../../utils/view_utils.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/elevated_delete_button.dart';

class ForceDeleteContainerDialog extends ConsumerWidget {
  final TokenContainer container;

  const ForceDeleteContainerDialog(this.container, {super.key});

  static Future<bool?> showDialog(TokenContainer container) => showAsyncDialog<bool>(
        builder: (context) => ForceDeleteContainerDialog(container),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.deleteContainerDialogTitle(container.serial)),
      content: Text(appLocalizations.forceDeleteDialogContent),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(appLocalizations.cancel),
        ),
        ElevatedDeleteButton(
          onPressed: () async {
            final success = await ref.read(tokenContainerProvider.notifier).deleteContainer(container);
            if (!context.mounted) return;
            Navigator.of(context).pop(success);
          },
          text: appLocalizations.delete,
        ),
      ],
    );
  }
}
