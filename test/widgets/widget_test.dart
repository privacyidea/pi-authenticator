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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/util.dart';
import 'package:privacyidea_authenticator/widgets/token_widgets.dart';

void main() {
  _testHotpWidget();
  _testTotpWidget();
}

void _testTotpWidget() {
  // TODO widget contains name and initial value
  // TODO widget updates after 30s
  // TODO widget updates after 60s

  testWidgets("TOTP Widget shows name and initial value",
      (WidgetTester tester) async {
    TOTPToken token =
        TOTPToken("Office Time", null, SHA1, 6, utf8.encode("secret"), 30);

    await tester.pumpWidget(_WidgetTestWrapper(
      child: TokenWidget(token),
    ));

    final labelFinder = find.text("Office Time");
    final otpValueFinder = find.text(insertCharAt(
        calculateTotpValue(token), " ", calculateTotpValue(token).length ~/ 2));

    expect(labelFinder, findsOneWidget);
    expect(otpValueFinder, findsOneWidget);
  });

  // FIXME find a way to test this behavior.
//  testWidgets("TOTP Widgets updates after 30 seconds",
//      (WidgetTester tester) async {
//    TOTPToken token =
//        TOTPToken("Office Time", null, SHA1, 6, utf8.encode("secret"), 30);
//
//    await tester.pumpWidget(_WidgetTestWrapper(
//      child: TOTPWidget(token: token),
//    ));
//
//    String startOtp = calculateTotpValue(token);
//
//    final startOtpValueFinder = find.text(startOtp);
//
//    await tester.pump(Duration(seconds: 60));
//
//    String newOtpValue = calculateTotpValue(token);
//    final otpValueFinder = find.text(newOtpValue);
//
//    expect(otpValueFinder, findsOneWidget);
////    expect(startOtpValueFinder, findsNothing);
//
//    print("Old value: $startOtp \nNew value: $newOtpValue");
//  });
}

void _testHotpWidget() {
  group("Test HOTP tokens", () {
    testWidgets("HOTP Widgets shows name and initial otp value",
        (WidgetTester tester) async {
      HOTPToken token =
          HOTPToken("Office", null, SHA1, 6, utf8.encode("secret"), counter: 0);

      await tester.pumpWidget(_WidgetTestWrapper(
        child: TokenWidget(token),
      ));

      final labelFinder = find.text("Office");
      final otpValueFinder = find.text("814 628");

      expect(labelFinder, findsOneWidget);
      expect(otpValueFinder, findsOneWidget);
    });

    testWidgets("HOTP Widgets next button works", (WidgetTester tester) async {
      HOTPToken token =
          HOTPToken("Office", null, SHA1, 6, utf8.encode("secret"), counter: 0);

      await tester.pumpWidget(_WidgetTestWrapper(
        child: TokenWidget(token),
      ));

      final otpValueFinder = find.text("814 628");

      // test that the 'next' button works
      await tester.tap(find.byType(RaisedButton));
      final otpValueFinder2 = find.text("533 881");
      await tester.pump(Duration(milliseconds: 50));

      expect(otpValueFinder, findsNothing);
      expect(otpValueFinder2, findsOneWidget);
    });
  });
}

/// This wrapper widget is needed because ListTiles require a material app as an ancestor.
class _WidgetTestWrapper extends StatelessWidget {
  final Widget child;

  _WidgetTestWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    );
  }
}
