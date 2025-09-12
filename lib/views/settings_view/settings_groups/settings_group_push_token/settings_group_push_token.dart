/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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

import '../../../../l10n/app_localizations.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../settings_view_widgets/settings_group.dart';
import 'dialogs/settings_group_push_token_dialog.dart';

class SettingsGroupPushToken extends ConsumerWidget {
  const SettingsGroupPushToken({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider).value?.tokens ?? [];
    final enrolledPushTokenList = tokens.whereType<PushToken>().where((e) => e.isRolledOut).toList();
    final unsupportedPushTokens = enrolledPushTokenList.where((e) => e.url == null).toList();
    return SettingsGroup(
      title: AppLocalizations.of(context)!.pushToken,
      isActive: enrolledPushTokenList.isNotEmpty,
      onPressed: () => showDialog(
        useRootNavigator: false,
        context: context,
        builder: (_) => SettingsGroupPushTokenDialog(unsupportedPushTokens: unsupportedPushTokens),
      ),
      trailingIcon: Icons.notifications,
    );
  }
}
