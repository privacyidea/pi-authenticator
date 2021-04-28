/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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

// Imports the Flutter Driver API.
import 'dart:convert';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:test/test.dart';

void totpTokenUpdateTest() {
  group('TOTP token update', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    final buttonFinder = find.byType("PopupMenuButton<String>");
    final addTokenButton = find.text("Add token");

    test("Click the 'add' button", () async {
      await driver.tap(buttonFinder);
      await driver.tap(addTokenButton);
    });

    test("Enter name and secret", () async {
      await driver.tap(find.ancestor(
          of: find.text("Name"), matching: find.byType("TextFormField")));

      await driver.enterText("TOTPTestName");

      await driver.tap(find.ancestor(
          of: find.text("Secret"), matching: find.byType("TextFormField")));

      await driver.enterText("TestSecret");
    });

    test("Change algorithm", () async {
      await driver.tap(find.text("HOTP"));
      await driver.tap(find.text("TOTP"));
    });

    test("Click 'add token'", () async {
      await driver.tap(find.text("Add token"));
    });

    test("Assert otp value gets updated", () async {
      // The opt value of this token is the same as the one of the added token.
      TOTPToken token = new TOTPToken(
        label: null,
        issuer: null,
        id: null,
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: encodeSecretAs(utf8.encode("TestSecret"), Encodings.base32),
        period: 30,
      );

      // We have to run this without waiting for all animations to stop
      // (the animation loops in this widget)
      await driver.runUnsynchronized(() async {
        String rawValue = calculateTotpValue(token).padLeft(6, '0');
        String value = insertCharAt(rawValue, " ", rawValue.length ~/ 2);
        print('1. Value: $value');

        await driver.tap(find.text(value));
      });

      await driver.runUnsynchronized(() async {
        // Wait until update is due.
        await Future.delayed(Duration(seconds: 32));

        String rawValue = calculateTotpValue(token).padLeft(6, '0');
        String value = insertCharAt(rawValue, " ", rawValue.length ~/ 2);

        print('2. Value: $value');

        await driver.waitFor(find.text(value), timeout: Duration(seconds: 40));
      });
    }, timeout: Timeout(Duration(seconds: 60)));

    test('Clean up', () async {
      await driver.runUnsynchronized(() async {
        await driver.scroll(
            find.text("TOTPTestName"), -500, 0, Duration(milliseconds: 100));

        // Delete the token.
        await driver.tap(find.text("Delete"));

        // Wait for the dialog to open.
        await driver.waitFor(find.text("Confirm deletion"));

        await driver.tap(find.text("Delete"));

        await driver.waitForAbsent(find.text("TOTPTestName"));
      });
    });
  });
}
