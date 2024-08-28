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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/introduction.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../widgets/focused_item_as_overlay.dart';
import '../slideable_action.dart';

class DefaultLockAction extends PiSlideableAction {
  final Token token;

  const DefaultLockAction({required this.token, super.key});

  @override
  CustomSlidableAction build(context, ref) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<ActionTheme>()!.lockColor,
      foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
      onPressed: (context) async {
        if (await lockAuth(localizedReason: AppLocalizations.of(context)!.authenticateToUnLockToken) == false) return;
        Logger.info('Changing lock status of token to isLocked = ${!token.isLocked}', name: 'token_widgets.dart#_changeLockStatus');

        globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(isLocked: !token.isLocked, isHidden: !token.isLocked));
      },
      child: FocusedItemAsOverlay(
        tooltipWhenFocused: AppLocalizations.of(context)!.introLockToken,
        childIsMoving: true,
        alignment: Alignment.bottomCenter,
        isFocused: ref.watch(introductionNotifierProvider).when(
              data: (value) => value.isConditionFulfilled(ref, Introduction.lockToken),
              error: (Object error, StackTrace stackTrace) => false,
              loading: () => false,
            ),
        onComplete: () => ref.read(introductionNotifierProvider.notifier).complete(Introduction.lockToken),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.lock),
            Text(
              token.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}
