/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

// Imports the Flutter Driver API.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../integration_test_utils.dart';

void copyToClipboardTest() {
  group('Copy otp value to clipboard', () {
    FlutterDriver? driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver!.close();
      }
    });

    String tokenName = 'TokenName';
    String secret = 'TokenSecret';
    addTokenRoutine(tokenName, secret);

    test('Copy otp value', () async {
      await doLongPress(driver!, find.text(tokenName));
    });

    test('Clean up', () async {
      await driver!.scroll(find.text('TokenName'), -500, 0, Duration(milliseconds: 100));

      // Delete the token.
      await driver!.tap(find.text('Delete'));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text('Confirm deletion'));

      await driver!.tap(find.text('Delete'));

      await driver!.waitForAbsent(find.text('TestName'));
    });

    test('Verify value is in clipboard', () async {
      await driver!.tap(find.byType('PopupMenuButton<String>'));
      await driver!.tap(find.text('Add token'));

      await doLongPress(driver!, find.ancestor(of: find.text('Name'), matching: find.byType('TextFormField')));

      await driver!.tap(find.text('Paste'));

      await driver!.waitFor(find.text('591668'));
    });
  });
}
