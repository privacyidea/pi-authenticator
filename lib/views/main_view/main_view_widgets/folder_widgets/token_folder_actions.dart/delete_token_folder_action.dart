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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_folder.dart';
import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../token_widgets/slideable_action.dart';

class DeleteTokenFolderAction extends ConsumerSlideableAction {
  final TokenFolder folder;

  const DeleteTokenFolderAction({super.key, required this.folder});
  @override
  CustomSlidableAction build(BuildContext context, ref) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<TokenTileTheme>()!.deleteColor,
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
          const Icon(Icons.delete),
          Text(
            AppLocalizations.of(context)!.delete,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      ),
    );
  }

  void _showDialog() => showAsyncDialog(
        builder: (BuildContext context) => DefaultDialog(
          scrollable: true,
          title: Text(
            AppLocalizations.of(context)!.confirmDeletion,
          ),
          content: Text(AppLocalizations.of(context)!.confirmDeletionOf(folder.label)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            TextButton(
              onPressed: () async {
                final tokens = (await globalRef?.read(tokenProvider.future))?.tokensInFolder(folder);
                if (tokens == null) return;
                globalRef?.read(tokenProvider.notifier).updateTokens(tokens, (p0) => p0.copyWith(folderId: () => null));
                globalRef?.read(tokenFolderProvider.notifier).removeFolder(folder);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        ),
      );
}
