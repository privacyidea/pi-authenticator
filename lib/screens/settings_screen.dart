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
                  onChanged: (dynamic value) => EasyDynamicTheme.of(context)
                      .changeTheme(dynamic: false, dark: false),
                ),
                RadioListTile(
                  title: Text(AppLocalizations.of(context)!.darkTheme),
                  value: ThemeMode.dark,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (dynamic value) => EasyDynamicTheme.of(context)
                      .changeTheme(dynamic: false, dark: true),
                ),
                RadioListTile(
                  title: Text(AppLocalizations.of(context)!.systemTheme),
                  value: ThemeMode.system,
                  groupValue: EasyDynamicTheme.of(context).themeMode,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (dynamic value) => EasyDynamicTheme.of(context)
                      .changeTheme(dynamic: true, dark: false),
                ),
              ],
            ),
            Divider(),
            SettingsGroup(
              title: AppLocalizations.of(context)!.language,
              children: [
                StreamBuilder<bool>(
                  stream: AppSettings.of(context).streamUseSystemLocale(),
                  builder: (context, snapshot) {
                    bool isActive = true;
                    ValueChanged<bool>? onChanged;

                    if (snapshot.hasData) {
                      isActive = snapshot.data!;
                      onChanged = (value) {
                        AppSettings.of(context).setUseSystemLocale(value);
                      };
                    }

                    return SwitchListTile(
                        title: Text(
                            AppLocalizations.of(context)!.useDeviceLocaleTitle),
                        subtitle: Text(AppLocalizations.of(context)!
                            .useDeviceLocaleDescription),
                        value: isActive,
                        onChanged: onChanged);
                  },
                ),
                StreamBuilder<bool>(
                  stream: AppSettings.of(context).streamUseSystemLocale(),
                  builder: (context, snapshot) {
                    bool enableDropDown = false;
                    ValueChanged<Locale?>? onChanged;

                    if (snapshot.hasData) {
                      enableDropDown = !(snapshot.data!);
                    }

                    if (enableDropDown) {
                      onChanged = (Locale? locale) {
                        AppSettings.of(context).setLocalePreference(locale!);
                      };
                    }

                    return StreamBuilder<Locale>(
                      stream: AppSettings.of(context).streamLocalePreference(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.hasError) {
                          return Placeholder();
                        } else {
                          print(snapshot.data);
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButton<Locale>(
                              disabledHint: Text(
                                "${snapshot.data}",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(color: Colors.grey),
                              ),
                              isExpanded: true,
                              value: snapshot.data,
                              // Initial value and current value
                              items: AppLocalizations.supportedLocales
                                  .map<DropdownMenuItem<Locale>>(
                                      (Locale value) {
                                return DropdownMenuItem<Locale>(
                                  value: value,
                                  child: Text(
                                    "$value",
                                    style: onChanged == null
                                        ? Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor)
                                        : Theme.of(context).textTheme.subtitle1,
                                  ),
                                );
                              }).toList(),
                              onChanged: onChanged,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            FutureBuilder<List<Token>>(
              initialData: [],
              future: StorageUtil.loadAllTokens(),
              builder: (context, snapshot) {
                bool showPushSettingsGroup = true;

                List<PushToken> enrolledPushTokenList = snapshot.hasData
                    ? snapshot.data!
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
                    title: AppLocalizations.of(context)!.pushToken,
                    children: <Widget>[
                      ListTile(
                        title: Text(AppLocalizations.of(context)!
                            .synchronizePushTokens),
                        subtitle: Text(AppLocalizations.of(context)!
                            .synchronizesTokensWithServer),
                        trailing: ElevatedButton(
                          child: Text(AppLocalizations.of(context)!.sync),
                          onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => UpdateFirebaseTokenDialog(),
                          ),
                        ),
                      ),
                      PreferenceBuilder<bool>(
                        preference: AppSettings.of(context)
                            .streamEnablePolling() as Preference<bool>,
                        builder: (context, value) {
                          Function? onChange;
                          List<PushToken> unsupported = enrolledPushTokenList
                              .where((e) => e.url == null)
                              .toList();

                          if (enrolledPushTokenList.any((element) =>
                              element.isRolledOut && element.url != null)) {
                            // Set onChange to activate switch in ui.
                            onChange = (value) =>
                                AppSettings.of(context).enablePolling = value;
                          }

                          Widget title = RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!
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
                            subtitle: Text(AppLocalizations.of(context)!
                                .requestPushChallengesPeriodically),
                            trailing: Switch(
                              value: value,
                              onChanged: onChange as void Function(bool)?,
                            ),
                          );
                        },
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
                    onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => MigrateLegacyTokensDialog()),
                  ),
                ),
              ],
            ),
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
                AppLocalizations.of(context)!.someTokensDoNotSupportPolling +
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
                  AppLocalizations.of(context)!.dismiss,
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
  static String _localePreferenceKey = 'KEY_LOCALE_PREFERENCE';
  static String _useSystemLocaleKey = 'KEY_USE_SYSTEM_LOCALE';
  static String _isFirstRunKey = 'KEY_IS_FIRST_RUN';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>()!;

  AppSettings(
      {required Widget child, required StreamingSharedPreferences preferences})
      : _hideOpts = preferences.getBool(_prefHideOtps, defaultValue: false),
        _enablePolling =
            preferences.getBool(_prefEnablePoll, defaultValue: true),
        isTestMode =
            const bool.fromEnvironment('testing_mode', defaultValue: false),
        _showGuideOnStart =
            preferences.getBool(_showGuideOnStartKey, defaultValue: true),
        _crashReportRecipients = preferences.getStringList(
            _crashReportRecipientsKey,
            defaultValue: [defaultCrashReportRecipient]),
        _localePreference = preferences.getString(_localePreferenceKey,
            defaultValue: _encodeLocale(AppLocalizations.supportedLocales[0])),
        _useSystemLocale =
            preferences.getBool(_useSystemLocaleKey, defaultValue: true),
        _isFirstRun = preferences.getBool(_isFirstRunKey, defaultValue: true),
        super(child: child);

  final Preference<bool> _isFirstRun;
  final Preference<bool> _hideOpts;
  final Preference<bool> _enablePolling;
  final Preference<bool> _showGuideOnStart;
  final Preference<List<String>> _crashReportRecipients;
  final Preference<String> _localePreference;
  final Preference<bool> _useSystemLocale;

  final bool isTestMode;

  void addCrashReportRecipient(String email) {
    var current = _crashReportRecipients.getValue();
    if (!current.contains(email)) {
      current.add(email);
    }
    _crashReportRecipients.setValue(current);
  }

  List<String> get crashReportRecipients => _crashReportRecipients.getValue();

  set isFirstRun(bool value) => _isFirstRun.setValue(value);

  bool get isFirstRun => _isFirstRun.getValue();

  Stream<bool> streamHideOpts() => _hideOpts;

  Stream<bool> streamEnablePolling() => _enablePolling;

  set hideOTPs(bool value) => _hideOpts.setValue(value);

  set enablePolling(bool value) => _enablePolling.setValue(value);

  bool get showGuideOnStart => _showGuideOnStart.getValue();

  set showGuideOnStart(bool value) => _showGuideOnStart.setValue(value);

  Stream<bool> showGuideOnStartStream() => _showGuideOnStart;

  void setLocalePreference(Locale locale) =>
      _localePreference.setValue(_encodeLocale(locale));

  Locale getLocalePreference() => _decodeLocale(_localePreference.getValue());

  Stream<Locale> streamLocalePreference() {
    return _localePreference.map((String str) => _decodeLocale(str));
  }

  Stream<bool> streamUseSystemLocale() => _useSystemLocale;

  bool getUseSystemLocale() => _useSystemLocale.getValue();

  void setUseSystemLocale(bool value) => _useSystemLocale.setValue(value);

  static String _encodeLocale(Locale locale) {
    return '${locale.languageCode}#${locale.countryCode}';
  }

  static Locale _decodeLocale(String str) {
    var split = str.split('#');
    return split[1] == "null" ? Locale(split[0]) : Locale(split[0], split[1]);
  }
}
