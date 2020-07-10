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
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
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
                        // TODO
                        print('Deactivate');
                        setState(() => _isPINSet = false);
                      } else if (!_isPINSet && value) {
                        // Enable pin
                        // TODO
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

  void changeBrightness(Brightness value) {
    DynamicTheme.of(context).setBrightness(value);
  }
}
