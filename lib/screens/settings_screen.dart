/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:developer';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/widgets/migrate_legacy_tokens_dialog.dart';
import 'package:privacyidea_authenticator/widgets/settings_groups.dart';
import 'package:privacyidea_authenticator/widgets/update_firebase_token_dialog.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settings,
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
              title: AppLocalizations.of(context).theme,
              children: <Widget>[
                RadioListTile(
                  title: Text(AppLocalizations.of(context).lightTheme),
                  value: ThemeMode.light,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) => EasyDynamicTheme.of(context)
                      .changeTheme(dynamic: false, dark: false),
                ),
                RadioListTile(
                  title: Text(AppLocalizations.of(context).darkTheme),
                  value: ThemeMode.dark,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) => EasyDynamicTheme.of(context)
                      .changeTheme(dynamic: false, dark: true),
                ),
                RadioListTile(
                  title: Text(AppLocalizations.of(context).systemTheme),
                  value: ThemeMode.system,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) => EasyDynamicTheme.of(context)
                      .changeTheme(dynamic: true, dark: false),
                ),
              ],
            ),
            FutureBuilder<List<Token>>(
              initialData: [],
              future: StorageUtil.loadAllTokens(),
              builder: (context, snapshot) {
                bool showPushSettingsGroup = true;

                List<PushToken> enrolledPushTokenList = snapshot.hasData
                    ? snapshot.data
                        .whereType<PushToken>()
                        .where((e) => e.isRolledOut)
                        .toList()
                    : [];

                if (enrolledPushTokenList.isEmpty) {
                  log('No push tokens exist, push settings are hidden.',
                      name: 'settings_screen.dart');
                  showPushSettingsGroup = false;
                }

                return Visibility(
                  visible: showPushSettingsGroup,
                  child: SettingsGroup(
                    title: AppLocalizations.of(context).pushToken,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                            AppLocalizations.of(context).synchronizePushTokens),
                        subtitle: Text(AppLocalizations.of(context)
                            .synchronizesTokensWithServer),
                        trailing: ElevatedButton(
                          child: Text(AppLocalizations.of(context).sync),
                          onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => UpdateFirebaseTokenDialog(),
                          ),
                        ),
                      ),
                      PreferenceBuilder<bool>(
                        preference:
                            AppSettings.of(context).streamEnablePolling(),
                        builder: (context, value) {
                          Function onChange;
                          List<PushToken> unsupported = enrolledPushTokenList
                              .where((e) => e.url == null)
                              .toList();

                          if (enrolledPushTokenList.any((element) =>
                              element.isRolledOut && element.url != null)) {
                            // Set onChange to activate switch in ui.
                            onChange = (value) =>
                                AppSettings.of(context).setEnablePolling(value);
                          }

                          Widget title = RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)
                                      .enablePolling,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                // Add clickable icon to inform user of unsupported push tokens (for polling)
                                WidgetSpan(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: unsupported.isNotEmpty &&
                                            enrolledPushTokenList.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () =>
                                                _showPollingInfo(unsupported),
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
                          );
                          return ListTile(
                            title: title,
                            subtitle: Text(AppLocalizations.of(context)
                                .requestPushChallengesPeriodically),
                            trailing: Switch(
                              value: value,
                              onChanged: onChange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            SettingsGroup(
              title: AppLocalizations.of(context).migration,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).migrateTokens),
                  trailing: ElevatedButton(
                    child: Text(AppLocalizations.of(context).migrate),
                    onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => MigrateLegacyTokensDialog()),
                  ),
                ),
              ],
            ),

//            Divider(),
//            SettingsGroup(
//              title: 'Behavior',
//              children: <Widget>[
//                ListTile(
//                  title: Text('Hide otp'),
//                  subtitle: Text('Description'),
//                  trailing: Switch(
//                    value: _hideOTP,
//                    onChanged: (value) {
//                      _hideOTP = value;
//                    },
//                  ),
//                ),
//              ],
//            ),
          ],
        ),
      ),
    );
  }

  /// Shows a dialog to the user that displays all push tokens that do not support polling.
  void _showPollingInfo(List<PushToken> unsupported) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                AppLocalizations.of(context).someTokensDoNotSupportPolling +
                    ':'),
            content: Scrollbar(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: unsupported.length,
                itemBuilder: (context, index) =>
                    Text('${unsupported[index].label}'),
                separatorBuilder: (context, index) => Divider(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context).dismiss,
                  style: Theme.of(context).textTheme.headline6,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }
}

class AppSettings extends InheritedWidget {
  // Preferences
  static String _prefHideOtps = 'KEY_HIDE_OTPS';
  static String _prefEnablePoll = 'KEY_ENABLE_POLLING';
  static String _showGuideOnStartKey = 'KEY_SHOW_GUIDE_ON_START';
  static String _crashReportRecipientsKey = 'KEY_CRASH_REPORT_RECIPIENTS';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>();

  AppSettings({Widget child, StreamingSharedPreferences preferences})
      : _hideOpts = preferences.getBool(_prefHideOtps, defaultValue: false),
        _enablePolling =
            preferences.getBool(_prefEnablePoll, defaultValue: false),
        isTestMode =
            const bool.fromEnvironment('testing_mode', defaultValue: false),
        _showGuideOnStart =
            preferences.getBool(_showGuideOnStartKey, defaultValue: true),
        _crashReportRecipients = preferences.getStringList(
            _crashReportRecipientsKey,
            defaultValue: [defaultCrashReportRecipient]),
        super(child: child);

  final Preference<bool> _hideOpts;
  final Preference<bool> _enablePolling;
  final Preference<bool> _showGuideOnStart;
  final Preference<List<String>> _crashReportRecipients;

  final bool isTestMode;

  void addCrashReportRecipient(String email) {
    var current = _crashReportRecipients.getValue();
    if (!current.contains(email)) {
      current.add(email);
    }
    _crashReportRecipients.setValue(current);
  }

  List<String> get crashReportRecipients => _crashReportRecipients.getValue();

  Stream<bool> streamHideOpts() => _hideOpts;

  Stream<bool> streamEnablePolling() => _enablePolling;

  void setHideOpts(bool value) => _hideOpts.setValue(value);

  void setEnablePolling(bool value) => _enablePolling.setValue(value);

  bool get showGuideOnStart => _showGuideOnStart.getValue();

  set showGuideOnStart(bool value) => _showGuideOnStart.setValue(value);

  Stream<bool> showGuideOnStartStream() => _showGuideOnStart;
}
