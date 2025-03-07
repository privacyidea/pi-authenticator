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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../model/enums/introduction.dart';
import '../../../../../../model/tokens/hotp_token.dart';
import '../../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../../../../widgets/focused_item_as_overlay.dart';
import '../../default_token_actions/default_edit_action_dialog.dart';
import '../../slideable_action.dart';

class EditHOTPTokenAction extends ConsumerSlideableAction {
  final HOTPToken token;

  const EditHOTPTokenAction({
    super.key,
    required this.token,
  });

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) => CustomSlidableAction(
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
        onPressed: (context) async {
          if (token.isLocked && !await lockAuth(reason: (localization) => localization.editLockedToken, localization: AppLocalizations.of(context)!)) {
            return;
          }
          _showDialog();
        },
        child: FocusedItemAsOverlay(
          tooltipWhenFocused: AppLocalizations.of(context)!.introEditToken,
          childIsMoving: true,
          alignment: Alignment.bottomCenter,
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
                AppLocalizations.of(context)!.edit,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ],
          ),
        ),
      );

  void _showDialog() => showAsyncDialog(
        builder: (BuildContext context) => DefaultEditActionDialog(
          token: token,
          additionalChildren: [
            ReadOnlyTextFormField(
              text: token.algorithm.name,
              labelText: AppLocalizations.of(context)!.algorithm,
            ),
            ReadOnlyTextFormField(
              text: token.counter.toString(),
              labelText: AppLocalizations.of(context)!.counter,
            ),
          ],
        ),
      );
}
