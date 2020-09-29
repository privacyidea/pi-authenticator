/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

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

import 'dart:async';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/widgets/set_pin_dialog.dart';
import 'package:privacyidea_authenticator/widgets/settings_groups.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen(this._title);

  final String _title;

  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  StreamController<bool> _isPINSetController;

  Stream<bool> get isPinSet => _isPINSetController.stream;

  @override
  void initState() {
    super.initState();

    var checkPIN =
        () async => _isPINSetController.add(await StorageUtil.isPINSet());

    _isPINSetController = StreamController<bool>(
      onListen: checkPIN,
      onResume: checkPIN,
    );
  }

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
            Divider(),
            SettingsGroup(
              title: 'Security', // TODO Translate
              children: <Widget>[
//                ListTile(
//                  title: Text('Lock app'), // TODO Translate
//                  subtitle: Text('Ask for PIN on app start'), // TODO Translate
//                  trailing: StreamBuilder<bool>(
//                    stream: isPinSet,
//                    builder: (context, snapshot) {
//                      if (!snapshot.hasData) {
//                        // Because initial data causes weird ui update.
//                        return Switch(
//                          value: false,
//                          onChanged: (value) {},
//                        );
//                      }
//
//                      return Switch(
//                        value: snapshot.data,
//                        onChanged: (value) async {
//                          if (snapshot.data && !value) {
//                            // Disable pin
//                            _askForPIN(() async {
//                              await StorageUtil.deletePIN();
//                              _isPINSetController.add(false);
//                            });
//                          } else if (!snapshot.data && value) {
//                            // Enable pin
//                            _setNewAppPIN();
//                          }
//                        },
//                      );
//                    },
//                  ),
//                ),
                PreferenceBuilder<bool>(
                  preference: AppSettings.of(context).streamHideOpts(),
                  builder: (context, bool hideOTP) {
                    print('Rebuild switch');
                    return ListTile(
                      title: Text('Hide passwords'),
                      // TODO Translate
                      subtitle: Text('Obscure passwords'),
                      // TODO Translate
                      trailing: Switch(
                        value: hideOTP,
                        onChanged: (value) async {
                          AppSettings.of(context).setHideOpts(value);
//                            AppSettings.of(context).setHideOpts(value);
                        },
                      ),
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

  void _setNewAppPIN() async {
    String newPin = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SetPINDialog(),
    );
    if (newPin != null) {
      await StorageUtil.setPIN(newPin);
      _isPINSetController.add(true);
      print('Activate');
    }
  }

  bool _isAppUnlocked = false;
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  _askForPIN(VoidCallback callback) async {
    int numberOfDigits = (await StorageUtil.getPIN()).length;

    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => WillPopScope(
            onWillPop: () async => _isAppUnlocked,
            child: buildPasscodeScreen(
                context,
                numberOfDigits,
                (enteredPIN) => _onPINEntered(enteredPIN, callback),
                _verificationNotifier,
                allowCancel: true),
          ),
        ));
  }

  _onPINEntered(String enteredPIN, VoidCallback callback) async {
    bool isValid = (await StorageUtil.getPIN()) == enteredPIN;
    _verificationNotifier.add(isValid);
    if (isValid) {
      callback.call();
      setState(() {
        this._isAppUnlocked = isValid;
      });
    }
  }

  void changeBrightness(Brightness value) {
    DynamicTheme.of(context).setBrightness(value);
  }
}

class AppSettings extends InheritedWidget {
  // Preferences
  static String _prefHideOtps = 'KEY_HIDE_OTPS';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettings>();

  AppSettings({Widget child, StreamingSharedPreferences preferences})
      : _hideOpts = preferences.getBool(_prefHideOtps, defaultValue: false),
        super(child: child);

  final Preference<bool> _hideOpts;

  Stream<bool> streamHideOpts() => _hideOpts;

  void setHideOpts(bool value) => _hideOpts.setValue(value);
}
