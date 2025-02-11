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
import '../../../../../utils/view_utils.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/elevated_delete_button.dart';

class DeleteContainerTokenDialog extends ConsumerWidget {
  final TokenContainer container;

  const DeleteContainerTokenDialog(this.container, {super.key});

  static Future<bool?> showDialog(TokenContainer container) async {
    final returnValue = await showAsyncDialog(
      builder: (context) => DeleteContainerTokenDialog(container),
    );
    assert(returnValue is bool?, "The return value of the DeleteContainerTokenDialog must be a bool or null.");
    return returnValue;
  }

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
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedDeleteButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
          },
          text: appLocalizations.deleteAllButtonText,
        ),
      ],
    );
  }
}
