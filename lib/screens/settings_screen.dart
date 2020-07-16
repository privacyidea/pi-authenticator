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

import 'dart:async';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/widgets/set_pin_dialog.dart';
import 'package:privacyidea_authenticator/widgets/settings_groups.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen(this._title);

  final String _title;

  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
//  bool _hideOTP = false;
  bool _isPINSet =
      true; // Initial value because we determine this asynchronously.

  @override
  void initState() {
    super.initState();
    getPINState();
  }

  void getPINState() async {
    _isPINSet = await StorageUtil.isPINSet();
    setState(() {}); // Tell the ui to refresh.
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
                ListTile(
                  title: Text('Lock app'), // TODO Translate
                  subtitle: Text('Ask for PIN on app start'), // TODO Translate
                  trailing: Switch(
                    value: _isPINSet,
                    onChanged: (value) async {
                      if (_isPINSet && !value) {
                        // Disable pin
                        _askForPIN(() async {
                          print('Deactivate');
                          await StorageUtil.deletePIN();
                          setState(() => _isPINSet = false);
                        });
                      } else if (!_isPINSet && value) {
                        // Enable pin
                        _setNewAppPIN();
                      }
                    },
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

  void _setNewAppPIN() async {
    String newPin = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SetPINDialog(),
    );
    if (newPin != null) {
      await StorageUtil.setPIN(newPin);
      setState(() => _isPINSet = true);
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
            child: buildPasscodeScreen(context,numberOfDigits, (enteredPIN) =>
                _onPINEntered(enteredPIN, callback), _verificationNotifier, allowCancel: true),
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
//      _setNewAppPIN();
    }
  }

  void changeBrightness(Brightness value) {
    DynamicTheme.of(context).setBrightness(value);
  }
}
