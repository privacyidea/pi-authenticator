import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/logging_menu.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/migrate_legacy_tokens_dialog.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/settings_groups.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/update_firebase_token_dialog.dart';

class SettingsView extends ConsumerWidget {
  static const String routeName = '/settings';

  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final tokens = ref.watch(tokenProvider);
    final locale = settings.localePreference;
    final useSystemLocale = settings.useSystemLocale;
    final enablePolling = settings.pollingEnabled;

    List<PushToken> enrolledPushTokenList = tokens.whereType<PushToken>().where((e) => e.isRolledOut).toList();

    List<PushToken> unsupported = enrolledPushTokenList.where((e) => e.url == null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingsGroup(
              title: AppLocalizations.of(context)!.theme,
              children: <Widget>[
                RadioListTile(
                  title: Text(AppLocalizations.of(context)!.lightTheme),
                  value: ThemeMode.light,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (dynamic value) => EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: false),
                ),
                RadioListTile(
                  title: Text(AppLocalizations.of(context)!.darkTheme),
                  value: ThemeMode.dark,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (dynamic value) => EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: true),
                ),
                RadioListTile(
                  title: Text(AppLocalizations.of(context)!.systemTheme),
                  value: ThemeMode.system,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (dynamic value) => EasyDynamicTheme.of(context).changeTheme(dynamic: true, dark: false),
                ),
              ],
            ),
            Divider(),
            SettingsGroup(
              title: AppLocalizations.of(context)!.language,
              children: [
                SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.useDeviceLocaleTitle),
                    subtitle: Text(AppLocalizations.of(context)!.useDeviceLocaleDescription),
                    value: useSystemLocale,
                    onChanged: (value) => ref.read(settingsProvider.notifier).setUseSystemLocale(value)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButton<Locale>(
                    disabledHint: Text(
                      '$locale',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey),
                    ),
                    isExpanded: true,
                    value: locale,
                    // Initial value and current value
                    items: AppLocalizations.supportedLocales.map<DropdownMenuItem<Locale>>((Locale value) {
                      return DropdownMenuItem<Locale>(
                        value: value,
                        child: Text(
                          '$value',
                          style: useSystemLocale
                              ? Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).disabledColor)
                              : Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => ref.read(settingsProvider.notifier).setLocale(value!),
                  ),
                ),
              ],
            ),
            FutureBuilder<List<Token>>(
              initialData: [],
              future: StorageUtil.loadAllTokens(),
              builder: (context, snapshot) {
                bool showPushSettingsGroup = true;

                if (enrolledPushTokenList.isEmpty) {
                  Logger.info('No push tokens exist, push settings are hidden.', name: 'settings_screen.dart#build');
                  showPushSettingsGroup = false;
                }

                return Visibility(
                  visible: showPushSettingsGroup,
                  child: SettingsGroup(
                    title: AppLocalizations.of(context)!.pushToken,
                    children: <Widget>[
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.synchronizePushTokens),
                        subtitle: Text(AppLocalizations.of(context)!.synchronizesTokensWithServer),
                        trailing: ElevatedButton(
                          child: Text(AppLocalizations.of(context)!.sync),
                          onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => UpdateFirebaseTokenDialog(),
                          ),
                        ),
                      ),
                      ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!.enablePolling,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              // Add clickable icon to inform user of unsupported push tokens (for polling)
                              WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: unsupported.isNotEmpty && enrolledPushTokenList.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {}, // () => _showPollingInfo(unsupported),
                                          child: Icon(
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
                        subtitle: Text(AppLocalizations.of(context)!.requestPushChallengesPeriodically),
                        trailing: Switch(
                          value: enablePolling,
                          onChanged: (value) => ref.read(settingsProvider.notifier).setPolling(value),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(),
            SettingsGroup(
              title: AppLocalizations.of(context)!.migration,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.migrateTokens),
                  trailing: ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.migrate),
                    onPressed: () => showDialog(context: context, barrierDismissible: false, builder: (context) => MigrateLegacyTokensDialog()),
                  ),
                ),
              ],
            ),
            Divider(),
            SettingsGroup(title: AppLocalizations.of(context)!.errorLogTitle, children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.logMenu),
                style: ListTileStyle.list,
                trailing: ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.open),
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => LoggingMenu(),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
