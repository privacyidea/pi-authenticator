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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/extensions/enums/push_token_rollout_state_extension.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../widgets/button_widgets/press_button.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class StartRolloutWidget extends ConsumerWidget {
  final PushToken token;

  const StartRolloutWidget({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: FittedBox(
              child: Text(
                token.rolloutState.rolloutMsg(localizations),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                flex: 12,
                child: SizedBox(),
              ),
              Expanded(
                flex: 35,
                child: CooldownButton(
                  onPressed: () => globalRef?.read(tokenProvider.notifier).rolloutPushToken(token) ?? Future.value(),
                  child: Text(
                    token.rolloutState.rolloutFailed ? localizations.retryRollout : token.rolloutState.rolloutMsg(localizations),
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              const Expanded(
                flex: 6,
                child: SizedBox(),
              ),
              Expanded(
                flex: 35,
                child: CooldownButton(
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                  onPressed: () => _showDialog(),
                  child: Text(
                    localizations.delete,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              const Expanded(
                flex: 12,
                child: SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDialog() => showDialog(
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context)!;
        return DefaultDialog(
          scrollable: true,
          title: Text(
            localizations.confirmDeletion,
          ),
          content: Text(localizations.confirmDeletionOf(token.label)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            TextButton(
              onPressed: () {
                globalRef?.read(tokenProvider.notifier).removeToken(token);
                Navigator.of(context).pop();
              },
              child: Text(
                localizations.delete,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        );
      });
}
