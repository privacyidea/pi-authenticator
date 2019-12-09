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
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/storageUtils.dart';
import 'package:privacyidea_authenticator/utils/util.dart';

class HOTPWidget extends StatefulWidget {
  final HOTPToken token;

  HOTPWidget({this.token});

  @override
  State<StatefulWidget> createState() => _HOTPWidgetState(
        token: token,
      );
}

class _HOTPWidgetState extends State<HOTPWidget> {
  final HOTPToken token;
  String otpValue;

  _HOTPWidgetState({this.token}) {
    otpValue = calculateHotpValue(token);
    _saveThisToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListTile(
          title: Center(
            child: Text(
              insertCharAt(otpValue, " ", otpValue.length ~/ 2),
              textScaleFactor: 2.5,
            ),
          ),
          subtitle: Center(
            child: Text(
              token.label,
              textScaleFactor: 2.0,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: RaisedButton(
            onPressed: () => _updateOtpValue(),
            child: Text(
              "Next",
              textScaleFactor: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  _saveThisToken() {
    StorageUtil.saveOrReplaceToken(this.token);
  }

  _updateOtpValue() {
    setState(() {
      token.incrementCounter();
      otpValue = calculateHotpValue(token);
    });
  }
}
