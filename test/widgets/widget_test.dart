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

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/widgets/token_widgets.dart';

void main() {
  _testHotpWidget();
  _testTotpWidget();
}

void _testTotpWidget() {
  testWidgets("TOTP Widget shows name and initial value",
      (WidgetTester tester) async {
    TOTPToken token = TOTPToken(
      label: "Office Time",
      issuer: null,
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
      period: 30,
    );

    await tester.pumpWidget(_WidgetTestWrapper(
      child: TokenWidget(
        token,
        onDeleteClicked: () => null,
      ),
    ));

    final labelFinder = find.text("Office Time");
    String value = calculateTotpValue(token).padLeft(token.digits, '0');
    final otpValueFinder =
        find.text(insertCharAt(value, " ", value.length ~/ 2));

    expect(labelFinder, findsOneWidget);
    expect(otpValueFinder, findsOneWidget);
  });
}

void _testHotpWidget() {
  group("Test HOTP tokens", () {
    testWidgets("HOTP Widgets shows name and initial otp value",
        (WidgetTester tester) async {
      HOTPToken token = HOTPToken(
        label: "Office",
        issuer: null,
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
        counter: 0,
      );

      await tester.pumpWidget(_WidgetTestWrapper(
        child: TokenWidget(
          token,
          onDeleteClicked: () => null,
        ),
      ));

      final labelFinder = find.text("Office");
      final otpValueFinder = find.text("814 628");

      expect(labelFinder, findsOneWidget);
      expect(otpValueFinder, findsOneWidget);
    });

    testWidgets("HOTP Widgets next button works", (WidgetTester tester) async {
      await tester.runAsync(() async {
        HOTPToken token = HOTPToken(
          label: "Office",
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 0,
        );

        await tester.pumpWidget(_WidgetTestWrapper(
          child: TokenWidget(
            token,
            onDeleteClicked: () => null,
          ),
        ));

        final otpValueFinder = find.text("814 628");

        // test that the 'next' button works
        await tester.tap(find.byType(RaisedButton));
        final otpValueFinder2 = find.text("533 881");
//      await tester.pump(Duration(milliseconds: 50));
        await tester.pumpAndSettle(const Duration(milliseconds: 50));

        expect(otpValueFinder, findsNothing);
        expect(otpValueFinder2, findsOneWidget);
      });
    });
  });
}

/// This wrapper widget is needed because ListTiles require a material app as an ancestor.
class _WidgetTestWrapper extends StatelessWidget {
  final Widget child;

  _WidgetTestWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => getApplicationTheme(brightness),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: child,
              ),
            ),
          );
        });
  }
}
