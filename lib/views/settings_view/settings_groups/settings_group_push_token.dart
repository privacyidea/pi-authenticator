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

import '../../../l10n/app_localizations.dart';
import '../../../model/riverpod_states/settings_state.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../settings_view_widgets/settings_groups.dart';
import '../settings_view_widgets/update_firebase_token_dialog.dart';

class SettingsGroupPushToken extends ConsumerWidget {
  final bool enablePushSettingsGroup;
  final List<PushToken> unsupportedPushTokens;
  const SettingsGroupPushToken({
    required this.enablePushSettingsGroup,
    required this.unsupportedPushTokens,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider).whenOrNull(data: (data) => data);
    return SettingsGroup(
      isActive: enablePushSettingsGroup,
      title: AppLocalizations.of(context)!.pushToken,
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
            onPressed: enablePushSettingsGroup
                ? () {
                    showDialog(
                      useRootNavigator: false,
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const UpdateFirebaseTokenDialog(),
                    );
                  }
                : null,
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
                    child: unsupportedPushTokens.isNotEmpty && enablePushSettingsGroup
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
            onChanged: enablePushSettingsGroup ? (value) => ref.read(settingsProvider.notifier).setPolling(value) : null,
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
            onChanged: enablePushSettingsGroup && ref.watch(tokenProvider).hasOTPTokens
                ? (value) => ref.read(settingsProvider.notifier).setHidePushTokens(value)
                : null,
          ),
        )
      ],
    );
  }

  /// Shows a dialog to the user that displays all push tokens that do not
  /// support polling.
  void _showPollingInfo(BuildContext context, List<PushToken> unsupported) {
    showDialog(
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }
}
