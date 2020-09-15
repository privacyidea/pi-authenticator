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

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
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
//  bool _hideOTP = false;

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
              title: 'Theme',
              children: <Widget>[
                RadioListTile(
                  title: Text('Light theme'),
                  value: Brightness.light,
                  groupValue: Theme.of(context).brightness,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: !isSystemDarkMode
                      ? (value) {
                          setState(() => changeBrightness(value));
                        }
                      : null,
                ),
                RadioListTile(
                  title: Text('Dark theme'),
                  value: Brightness.dark,
                  groupValue: Theme.of(context).brightness,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: !isSystemDarkMode
                      ? (value) {
                          setState(() => changeBrightness(value));
                        }
                      : null,
                ),
              ],
            ),
            SettingsGroup(
              title: 'Misc', // TODO Translate
              children: <Widget>[
                FutureBuilder<bool>(
                  initialData: false,
                  future: StorageUtil.loadAllTokens().then((value) => value.any(
                      (element) =>
                          element is PushToken &&
                          element.isRolledOut &&
                          element.url != null)),
                  builder: (context, value) {
                    Function onChange;

                    // Check if any push tokens exist, if not, this cannot be
                    //  enabled.

                    if (value.hasData && value.data) {
                      onChange = (value) =>
                          AppSettings.of(context).setEnablePolling(value);
                    }

                    return PreferenceBuilder<bool>(
                      preference: AppSettings.of(context).streamEnablePolling(),
                      builder: (context, value) {
                        return ListTile(
                          title: Text('Enable polling'),
                          // TODO Translate
                          subtitle: Text(
                              'Requests push challenges from the server'
                              ' periodically. Enable this if push challenges are'
                              ' not received normally.'),
                          // TODO Translate, find better text.
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

  void changeBrightness(Brightness value) {
    DynamicTheme.of(context).setBrightness(value);
  }
}

class AppSettings extends InheritedWidget {
  // Preferences
  static String _prefHideOtps = 'KEY_HIDE_OTPS';
  static String _prefEnablePoll = 'KEY_ENABLE_POLLING';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>();

  AppSettings({Widget child, StreamingSharedPreferences preferences})
      : _hideOpts = preferences.getBool(_prefHideOtps, defaultValue: false),
        _enablePolling =
            preferences.getBool(_prefEnablePoll, defaultValue: false),
        super(child: child);

  final Preference<bool> _hideOpts;
  final Preference<bool> _enablePolling;

  Stream<bool> streamHideOpts() => _hideOpts;

  Stream<bool> streamEnablePolling() => _enablePolling;

  void setHideOpts(bool value) => _hideOpts.setValue(value);

  void setEnablePolling(bool value) => _enablePolling.setValue(value);
}
