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
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/customization/theme_extentions/action_theme.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../loading_indicator.dart';
import '../token_action.dart';

class DefaultDeleteAction extends TokenAction {
  final Token token;

  const DefaultDeleteAction({super.key, required this.token});

  @override
  CustomSlidableAction build(context, ref) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<ActionTheme>()!.deleteColor,
      foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
      onPressed: (_) async {
        if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.deleteLockedToken) == false) {
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

  void _showDialog() => globalNavigatorKey.currentContext == null
      ? null
      : showDialog(
          useRootNavigator: false,
          context: globalNavigatorKey.currentContext!,
          builder: (BuildContext context) {
            return DefaultDialog(
              scrollable: true,
              title: Text(
                AppLocalizations.of(context)!.confirmDeletion,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              content: Column(
                children: [
                  Text(AppLocalizations.of(context)!.confirmDeletionOf(token.label), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.confirmTokenDeletionHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    LoadingIndicator.show(context, () async => globalRef?.read(tokenProvider.notifier).removeToken(token));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            );
          });
}
