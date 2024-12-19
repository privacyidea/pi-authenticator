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
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_folder.dart';
import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../token_widgets/slideable_action.dart';

class LockTokenFolderAction extends ConsumerSlideableAction {
  final TokenFolder folder;

  const LockTokenFolderAction({super.key, required this.folder});
  @override
  CustomSlidableAction build(BuildContext context, ref) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<ActionTheme>()!.lockColor,
      foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
      onPressed: (context) async {
        if (await lockAuth(reason: (localization) => localization.unlock, localization: AppLocalizations.of(context)!) == false) return;
        globalRef?.read(tokenFolderProvider.notifier).toggleFolderLock(folder);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.lock),
          Text(
            folder.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
