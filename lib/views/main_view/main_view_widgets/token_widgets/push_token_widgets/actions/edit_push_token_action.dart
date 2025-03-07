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
import '../../../../../../model/tokens/push_token.dart';
import '../../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../../utils/globals.dart';
import '../../../../../../utils/lock_auth.dart';
import '../../../../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../../widgets/enable_text_edit_after_many_taps.dart';
import '../../../../../../widgets/focused_item_as_overlay.dart';
import '../../default_token_actions/default_edit_action_dialog.dart';
import '../../slideable_action.dart';

class EditPushTokenAction extends ConsumerSlideableAction {
  final PushToken token;

  const EditPushTokenAction({
    super.key,
    required this.token,
  });

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context)!;
    return CustomSlidableAction(
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
        onPressed: (context) async {
          if (token.isLocked && !await lockAuth(reason: (localization) => localization.editLockedToken, localization: appLocalizations)) {
            return;
          }
          _showDialog();
        },
        child: FocusedItemAsOverlay(
          tooltipWhenFocused: appLocalizations.introEditToken,
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
                appLocalizations.edit,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ],
          ),
        ));
  }

  String? _validatePushEndpointUrl(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.mustNotBeEmpty(AppLocalizations.of(context)!.pushEndpointUrl);
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty || uri.scheme.isEmpty || uri.path.isEmpty) {
      return AppLocalizations.of(context)!.exampleUrl;
    }
    return null;
  }

  void _showDialog() => showAsyncDialog(
        builder: (BuildContext context) {
          final pushUrl = TextEditingController(text: token.url.toString());
          final appLocalizations = AppLocalizations.of(context)!;
          return DefaultEditActionDialog(
            token: token,
            onSaveButtonPressed: ({required newLabel, newImageUrl}) async {
              globalRef?.read(tokenProvider.notifier).updateToken(
                    token,
                    (p0) => p0.copyWith(
                      label: newLabel,
                      url: Uri.parse(pushUrl.text),
                      tokenImage: newImageUrl,
                    ),
                  );
              Navigator.of(context).pop();
            },
            additionalChildren: [
              EnableTextEditAfterManyTaps(
                controller: pushUrl,
                labelText: appLocalizations.pushEndpointUrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validatePushEndpointUrl(value, context),
              ),
              const SizedBox(height: 10),
              ExpansionTile(
                title: Text(
                  appLocalizations.publicKey,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                children: [
                  SelectableText(
                    token.publicTokenKey ?? appLocalizations.noPublicKey,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Divider(),
              ExpansionTile(
                title: Text(
                  appLocalizations.firebaseToken,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                children: [
                  SelectableText(
                    token.fbToken != null ? token.fbToken.toString() : appLocalizations.noFbToken,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
            ],
          );
        },
      );
}
