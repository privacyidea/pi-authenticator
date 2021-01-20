/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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

import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/widgets/settings_groups.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen(this._title);

  final String _title;

  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isSystemDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget._title,
          textScaleFactor: screenTitleScaleFactor,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingsGroup(
              title: Localization.of(context).theme,
              children: <Widget>[
                RadioListTile(
                  title: Text(Localization.of(context).lightTheme),
                  value: Brightness.light,
                  groupValue: Theme.of(context).brightness,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: !isSystemDarkMode
                      ? (value) {
                          setState(() => _changeBrightness(value));
                        }
                      : null,
                ),
                RadioListTile(
                  title: Text(Localization.of(context).darkTheme),
                  value: Brightness.dark,
                  groupValue: Theme.of(context).brightness,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: !isSystemDarkMode
                      ? (value) {
                          setState(() => _changeBrightness(value));
                        }
                      : null,
                ),
              ],
            ),
            SettingsGroup(
              title: Localization.of(context).misc,
              children: <Widget>[
                FutureBuilder<List<Token>>(
                  initialData: [],
                  future: StorageUtil.loadAllTokens(),
                  builder: (context, value) {
                    Function onChange;
                    List<PushToken> tokens = [];
                    List<PushToken> unsupported = [];

                    // Check if any push tokens exist, if not, this cannot be
                    //  enabled.
                    if (value.hasData) {
                      tokens = value.data.whereType<PushToken>().toList();

                      unsupported = tokens
                          .where((element) => element.url == null)
                          .toList();

                      if (tokens.any((element) =>
                          element.isRolledOut && element.url != null)) {
                        onChange = (value) =>
                            AppSettings.of(context).setEnablePolling(value);
                      }
                    }

                    var title = RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: Localization.of(context).enablePolling,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: unsupported.isNotEmpty && tokens.isNotEmpty
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

                    return PreferenceBuilder<bool>(
                      preference: AppSettings.of(context).streamEnablePolling(),
                      builder: (context, value) {
                        return ListTile(
                          title: title,
                          subtitle:
                              Text(Localization.of(context).pollingDescription),
                          trailing: Switch(
                            value: value,
                            onChanged: onChange,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Divider(),
            SettingsGroup(
              title: 'Language', // TODO Add translation
              children: [
                StreamBuilder<bool>(
                  stream: AppSettings.of(context).streamUseSystemLocale(),
                  builder: (context, snapshot) {
                    bool isActive = true;
                    Function onChanged;

                    if (snapshot.hasData) {
                      isActive = snapshot.data;
                      onChanged = (value) {
                        AppSettings.of(context).setUseSystemLocale(value);
                        // Add locale that represents the devices language
                        Locale locale;
                        if (value) {
                          List split = Platform.localeName.split("_");
                          locale = Locale(split[0], split[1]);
                        } else {
                          locale =
                              AppSettings.of(context).getLocalePreference();
                        }

                        Localization.load(locale);
                        setState(() {});
                      };
                    }

                    // TODO Add Title and description
                    return SwitchListTile(
                        title: Text('Use device language'),
                        subtitle: Text('Use device language if it is supported,'
                            ' otherwise default to english.'),
                        value: isActive,
                        onChanged: onChanged);
                  },
                ),
                StreamBuilder<bool>(
                  stream: AppSettings.of(context).streamUseSystemLocale(),
                  builder: (context, snapshot) {
                    bool isActive = false;
                    Function onChanged;

                    if (snapshot.hasData) {
                      isActive = !snapshot.data;
                    }

                    if (isActive) {
                      onChanged = (Locale locale) {
                        AppSettings.of(context).setLocalePreference(locale);
                        Localization.load(locale);
                        setState(() {});
                      };
                    }

                    return StreamBuilder<Locale>(
                      stream: AppSettings.of(context).streamLocalePreference(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.hasError) {
                          return Placeholder();
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButton<Locale>(
                              disabledHint: Text(
                                "${snapshot.data}",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: Colors.grey),
                              ),
                              isExpanded: true,
                              value: snapshot.data,
                              // Initial value and current value
                              items: supportedLocales
                                  .map<DropdownMenuItem<Locale>>(
                                      (Locale value) {
                                return DropdownMenuItem<Locale>(
                                  value: value,
                                  child: Text(
                                    "$value",
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
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

  void _changeBrightness(Brightness value) {
    DynamicTheme.of(context).setBrightness(value);
  }

  void _showPollingInfo(List<PushToken> unsupported) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Localization.of(context).pollingInfoTitle + ':'),
            content: Scrollbar(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: unsupported.length,
                itemBuilder: (context, index) {
                  return Text('${unsupported[index].label}');
                },
                separatorBuilder: (context, index) => Divider(),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  Localization.of(context).dismiss,
                  style: getDialogTextStyle(isDarkModeOn(context)),
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
  static String _loadLegacyKey = 'KEY_LOAD_LEGACY';
  static String _localePreferenceKey = 'KEY_LOCALE_PREFERENCE';
  static String _useSystemLocaleKey = 'KEY_USE_SYSTEM_LOCALE';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>();

  AppSettings({Widget child, StreamingSharedPreferences preferences})
      : _hideOpts = preferences.getBool(_prefHideOtps, defaultValue: false),
        _enablePolling =
            preferences.getBool(_prefEnablePoll, defaultValue: false),
        _loadLegacy = preferences.getBool(_loadLegacyKey, defaultValue: true),
        _localePreference = preferences.getString(_localePreferenceKey,
            defaultValue: _encodeLocale(supportedLocales[0])),
        _useSystemLocale =
            preferences.getBool(_useSystemLocaleKey, defaultValue: true),
        super(child: child);

  final Preference<bool> _hideOpts;
  final Preference<bool> _enablePolling;
  final Preference<bool> _loadLegacy;
  final Preference<String> _localePreference;
  final Preference<bool> _useSystemLocale;

  Stream<bool> streamUseSystemLocale() => _useSystemLocale;

  bool getUseSystemLocale() => _useSystemLocale.getValue();

  void setUseSystemLocale(bool value) => _useSystemLocale.setValue(value);

  Stream<bool> streamHideOpts() => _hideOpts;

  Stream<bool> streamEnablePolling() => _enablePolling;

  void setHideOpts(bool value) => _hideOpts.setValue(value);

  void setEnablePolling(bool value) => _enablePolling.setValue(value);

  void setLoadLegacy(bool value) => _loadLegacy.setValue(value);

  bool getLoadLegacy() => _loadLegacy.getValue();

  void setLocalePreference(Locale locale) =>
      _localePreference.setValue(_encodeLocale(locale));

  Locale getLocalePreference() => _decodeLocale(_localePreference.getValue());

  Stream<Locale> streamLocalePreference() {
    return _localePreference.map((String str) => _decodeLocale(str));
  }

  static String _encodeLocale(Locale locale) {
    return '${locale.languageCode}#${locale.countryCode}';
  }

  static Locale _decodeLocale(String str) {
    var split = str.split('#');
    return Locale(split[0], split[1]);
  }
}
