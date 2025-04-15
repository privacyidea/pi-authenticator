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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../../../widgets/pi_text_field.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_folder.dart';
import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../token_widgets/slideable_action.dart';

class RenameTokenFolderAction extends ConsumerSlideableAction {
  final TokenFolder folder;
  const RenameTokenFolderAction({required this.folder, super.key});

  @override
  CustomSlidableAction build(BuildContext context, ref) {
    return CustomSlidableAction(
        backgroundColor: Theme.of(context).extension<TokenTileTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<TokenTileTheme>()!.actionForegroundColor,
        onPressed: (context) async {
          if (folder.isLocked && !await lockAuth(reason: (localization) => localization.unlock, localization: AppLocalizations.of(context)!)) {
            return;
          }
          _showDialog();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.edit),
            Text(
              AppLocalizations.of(context)!.rename,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ));
  }

  void _showDialog() {
    TextEditingController nameInputController = TextEditingController(text: folder.label);
    showAsyncDialog(builder: (BuildContext context) {
      return DefaultDialog(
        scrollable: true,
        title: Text(
          AppLocalizations.of(context)!.renameTokenFolder,
        ),
        content: PiTextField(
          autofocus: true,
          controller: nameInputController,
          labelText: AppLocalizations.of(context)!.name,
          validator: (value) {
            if (value!.isEmpty) {
              return AppLocalizations.of(context)!.name;
            }
            return null;
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.cancel,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.rename,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            onPressed: () async {
              final newLabel = nameInputController.text.trim();
              if (newLabel.isEmpty) return;
              final success = await globalRef?.read(tokenFolderProvider.notifier).updateLabel(folder, newLabel);
              if (success != null) {
                Logger.info(
                  'Renamed token:',
                  error: '\'${folder.label}\' changed to \'$newLabel\'',
                );
              } else {
                Logger.warning(
                  'Failed to rename token',
                  error: '\'${folder.label}\' to \'$newLabel\'',
                );
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }
}
