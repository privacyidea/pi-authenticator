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

import 'dart:developer';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/widgets/settings_groups.dart';
import 'package:privacyidea_authenticator/widgets/update_firebase_token_dialog.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen(this._title);

  final String _title;

  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    bool isSystemDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
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
            FutureBuilder<List<Token>>(
              initialData: [],
              future: StorageUtil.loadAllTokens(),
              builder: (context, snapshot) {
                bool show = true;
                List<PushToken> pushTokenList = snapshot.hasData
                    ? snapshot.data.whereType<PushToken>().toList()
                    : [];

                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    pushTokenList.isEmpty) {
                  log('No push tokens exist, settings are hidden.',
                      name: 'settings_screen.dart');
                  show = false;
                }

                return Visibility(
                    visible: show,
                    child: SettingsGroup(
                      title: Localization.of(context).push,
                      children: <Widget>[
                        ListTile(
                          title: Text('Update firebase token'),
                          // TODO Translate
                          subtitle: Text('Sends the current firebase token of'
                              ' this application to the privacyIDEA server.'),
                          trailing: RaisedButton(
                            // TODO Position this right
                            child: Text('Update'), // TODO Translate
                            onPressed: () => showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => UpdateFirebaseTokenDialog(),
                            ),
                          ),
                        ),
                        FutureBuilder<List<Token>>(
                          // TODO This can be removed
                          initialData: [],
                          future: StorageUtil.loadAllTokens(),
                          builder: (context, value) {
                            Function onChange;
                            List<PushToken> tokens = [];
                            List<PushToken> unsupported = [];

                            // Check if any push tokens exist, if not, this cannot be
                            //  enabled.
                            if (value.hasData) {
                              tokens =
                                  value.data.whereType<PushToken>().toList();

                              unsupported = tokens
                                  .where((element) => element.url == null)
                                  .toList();

                              if (tokens.any((element) =>
                                  element.isRolledOut && element.url != null)) {
                                // Set onChange to acitvate switch in ui
                                onChange = (value) => AppSettings.of(context)
                                    .setEnablePolling(value);
                              }
                            }

                            var title = RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        Localization.of(context).enablePolling,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  // Add clickable icon to inform user of unsupported push tokens (for polling)
                                  WidgetSpan(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: unsupported.isNotEmpty &&
                                              tokens.isNotEmpty
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
                              preference:
                                  AppSettings.of(context).streamEnablePolling(),
                              builder: (context, value) {
                                return ListTile(
                                  title: title,
                                  subtitle: Text(Localization.of(context)
                                      .pollingDescription),
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
                    ));
              },
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

  /// Shows a dialog to the user that displays all push tokens that do not support polling.
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
                itemBuilder: (context, index) =>
                    Text('${unsupported[index].label}'),
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

  _showMessage(String message, Duration duration) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
    ));
  }
}

class AppSettings extends InheritedWidget {
  // Preferences
  static String _prefHideOtps = 'KEY_HIDE_OTPS';
  static String _prefEnablePoll = 'KEY_ENABLE_POLLING';
  static String _loadLegacyKey = 'KEY_LOAD_LEGACY';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>();

  AppSettings({Widget child, StreamingSharedPreferences preferences})
      : _hideOpts = preferences.getBool(_prefHideOtps, defaultValue: false),
        _enablePolling =
            preferences.getBool(_prefEnablePoll, defaultValue: false),
        _loadLegacy = preferences.getBool(_loadLegacyKey, defaultValue: true),
        super(child: child);

  final Preference<bool> _hideOpts;
  final Preference<bool> _enablePolling;
  final Preference<bool> _loadLegacy;

  Stream<bool> streamHideOpts() => _hideOpts;

  Stream<bool> streamEnablePolling() => _enablePolling;

  void setHideOpts(bool value) => _hideOpts.setValue(value);

  void setEnablePolling(bool value) => _enablePolling.setValue(value);

  void setLoadLegacy(bool value) => _loadLegacy.setValue(value);

  bool getLoadLegacy() => _loadLegacy.getValue();
}
