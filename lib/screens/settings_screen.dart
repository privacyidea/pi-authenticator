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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen(this.title);

  final String title;

  bool _hideOTP = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Theme'),
            ListTile(
              title: Text('Theme'),
              subtitle: Text('Description'),
              trailing: FlatButton(
                child: Text('click'),
              ),
            ),
            Divider(),
            Text('Behavior'),
            ListTile(
              title: Text('Hide otp'),
              subtitle: Text('Description'),
              trailing: Switch(
                value: _hideOTP,
                onChanged: (value) {
                  _hideOTP = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
