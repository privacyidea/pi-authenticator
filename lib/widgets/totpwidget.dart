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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/util.dart';

class TOTPWidget extends StatefulWidget {
  final TOTPToken token;

  TOTPWidget({this.token});

  @override
  State<StatefulWidget> createState() => _TOTPWidgetState(
        token: token,
      );
}

class _TOTPWidgetState extends State<TOTPWidget>
    with SingleTickerProviderStateMixin {
  final TOTPToken token;
  String otpValue;
  AnimationController
      controller; // Controller for animating the LinearProgressAnimator

  _TOTPWidgetState({this.token}) {
    otpValue = calculateTotpValue(token);
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: token.period),
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
      debugPrint('SystemChannels> $msg');
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
        LinearProgressIndicator(
          value: controller.value,
        ),
      ],
    );
  }

  _updateOtpValue() {
    setState(() {
      otpValue = calculateTotpValue(token);
    });
  }
}
