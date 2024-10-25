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

import '../../../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/riverpod_states/settings_state.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../settings_view_widgets/settings_group.dart';
import '../settings_view_widgets/update_firebase_token_dialog.dart';

class SettingsGroupPushToken extends ConsumerWidget {
  const SettingsGroupPushToken({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider).tokens;
    final enrolledPushTokenList = tokens.whereType<PushToken>().where((e) => e.isRolledOut).toList();
    final unsupportedPushTokens = enrolledPushTokenList.where((e) => e.url == null).toList();
    return SettingsGroup(
      title: AppLocalizations.of(context)!.pushToken,
      isActive: enrolledPushTokenList.isNotEmpty,
      onPressed: () => showDialog(
        useRootNavigator: false,
        context: context,
        builder: (_) => SettingsGroupPushTokenDialog(
          unsupportedPushTokens: unsupportedPushTokens,
        ),
      ),
      trailingIcon: Icons.notifications,
    );
  }
}

class SettingsGroupPushTokenDialog extends ConsumerWidget {
  final List<PushToken> unsupportedPushTokens;
  const SettingsGroupPushTokenDialog({
    super.key,
    required this.unsupportedPushTokens,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider).whenOrNull(data: (data) => data);
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.pushToken),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.synchronizePushTokens,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.synchronizesTokensWithServer,
              overflow: TextOverflow.fade,
            ),
            trailing: ElevatedButton(
              onPressed: () => showDialog(
                useRootNavigator: false,
                context: context,
                barrierDismissible: false,
                builder: (context) => const UpdateFirebaseTokenDialog(),
              ),
              child: Text(
                AppLocalizations.of(context)!.sync,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ),
          ListTile(
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.enablePolling,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // Add clickable icon to inform user of unsupported push tokens (for polling)
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: unsupportedPushTokens.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _showPollingInfo(context, unsupportedPushTokens),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.red,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.requestPushChallengesPeriodically,
              overflow: TextOverflow.fade,
            ),
            trailing: Switch(
              value: settingsState?.enablePolling ?? SettingsState.enablePollingDefault,
              onChanged: (value) => ref.read(settingsProvider.notifier).setPolling(value),
            ),
          ),
          ListTile(
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.hidePushTokens,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.hidePushTokensDescription,
              overflow: TextOverflow.fade,
            ),
            trailing: Switch(
              value: settingsState?.hidePushTokens ?? SettingsState.hidePushTokensDefault,
              onChanged: (value) => ref.read(settingsProvider.notifier).setHidePushTokens(value),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to the user that displays all push tokens that do not
  /// support polling.
  void _showPollingInfo(BuildContext context, List<PushToken> unsupported) => showDialog(
        useRootNavigator: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('${AppLocalizations.of(context)!.someTokensDoNotSupportPolling}:'),
            content: Scrollbar(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: unsupported.length,
                itemBuilder: (context, index) => Text('${unsupported[index].label}'),
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.dismiss,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
}
