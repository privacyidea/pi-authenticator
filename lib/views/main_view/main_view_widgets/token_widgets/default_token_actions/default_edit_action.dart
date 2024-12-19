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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/introduction.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../widgets/focused_item_as_overlay.dart';
import '../slideable_action.dart';
import 'default_edit_action_dialog.dart';

class DefaultEditAction extends ConsumerSlideableAction {
  final Token token;
  const DefaultEditAction({required this.token, super.key});

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) {
    return CustomSlidableAction(
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
        onPressed: (context) async {
          if (token.isLocked && !await lockAuth(reason: (localization) => localization.editLockedToken, localization: AppLocalizations.of(context)!)) {
            return;
          }
          _showDialog();
        },
        child: FocusedItemAsOverlay(
          tooltipWhenFocused: AppLocalizations.of(context)!.editToken,
          childIsMoving: true,
          isFocused: ref.watch(introductionNotifierProvider).when(
                data: (value) => value.isConditionFulfilled(ref, Introduction.editToken),
                error: (Object error, StackTrace stackTrace) => false,
                loading: () => false,
              ),
          onComplete: () => ref.read(introductionNotifierProvider.notifier).complete(Introduction.editToken),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.edit),
              Text(
                AppLocalizations.of(context)!.saveButton,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ],
          ),
        ));
  }

  void _showDialog() => showAsyncDialog(
        builder: (BuildContext context) => DefaultEditActionDialog(
          token: token,
          onSaveButtonPressed: ({required newLabel, newImageUrl}) async {
            if (newLabel.isEmpty) return;
            final edited = await globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(label: newLabel, tokenImage: newImageUrl));
            if (edited == null) {
              Logger.error('Token editing failed');
              return;
            }
            Logger.info('Token edited: ${token.label} -> ${edited.label}, ${token.tokenImage} -> ${edited.tokenImage}');
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      );
}
