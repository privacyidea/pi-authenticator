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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/storageUtils.dart';
import 'package:privacyidea_authenticator/utils/util.dart';

class TokenWidget extends StatefulWidget {
  final Token _token;

  TokenWidget(this._token);

  @override
  State<StatefulWidget> createState() {
    if (_token is HOTPToken) {
      return _HotpWidgetState(_token);
    } else if (_token is TOTPToken) {
      return _TotpWidgetState(_token);
    } else {
      return null; // The token must be one of the above.
    }
  }
}

abstract class _TokenWidgetState extends State<TokenWidget> {
  final Token _token;
  String _otpValue;
  String _label;

  _TokenWidgetState(this._token) {
    _saveThisToken();
    _label = _token.label;
  }

  @override
  void initState() {
    super.initState();
    _updateOtpValue();
  }

  void _saveThisToken() {
    StorageUtil.saveOrReplaceToken(this._token);
  }

  void _updateOtpValue();
}

class _HotpWidgetState extends _TokenWidgetState {
  _HotpWidgetState(Token token) : super(token);

  @override
  void _updateOtpValue() {
    setState(() {
      (_token as HOTPToken).incrementCounter();
      _otpValue = calculateHotpValue(_token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListTile(
          title: Center(
            child: Text(
              insertCharAt(_otpValue, " ", _otpValue.length ~/ 2),
              textScaleFactor: 2.5,
            ),
          ),
          subtitle: Center(
            child: Text(
              _label,
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
}

class _TotpWidgetState extends _TokenWidgetState
    with SingleTickerProviderStateMixin {
  AnimationController
      controller; // Controller for animating the LinearProgressAnimator

  _TotpWidgetState(Token token) : super(token);

  @override
  void _updateOtpValue() {
    setState(() {
      _otpValue = calculateTotpValue(_token);
    });
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: (_token as TOTPToken).period),
      // Animate the progress for the duration of the tokens period.
      vsync:
          this, // By extending SingleTickerProviderStateMixin we can use this object as vsync, this prevents offscreen animations.
    )
      ..addListener(() {
        // Adding a listener to update the view for the animation steps.
        setState(() => {
              // The state that has changed here is the animation object’s value.
            });
      })
      ..addStatusListener((status) {
        // Add listener to restart the animation after the period, also updates the otp value.
        if (status == AnimationStatus.completed) {
          controller.forward(from: 0.0);
          _updateOtpValue();
        }
      })
      ..forward(); // Start the animation.

    // Update the otp value when the android app resumes, this prevents outdated otp values
    // ignore: missing_return
    SystemChannels.lifecycle.setMessageHandler((msg) {
      log(
        "SystemChannels:",
        name: "totpwidget.dart",
        error: msg,
      );
      if (msg == AppLifecycleState.resumed.toString()) {
        _updateOtpValue();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose the controller to prevent memory leak.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Center(
            child: Text(
              insertCharAt(_otpValue, " ", _otpValue.length ~/ 2),
              textScaleFactor: 2.5,
            ),
          ),
          subtitle: Center(
            child: Text(
              _label,
              textScaleFactor: 2.0,
            ),
          ),
        ),
        LinearProgressIndicator(
          value: controller.value,
        ),
      ],
    );
  }
}
