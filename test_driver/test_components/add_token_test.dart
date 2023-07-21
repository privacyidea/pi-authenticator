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

void addTokenTest() {
  group('Add token manually', () {
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

    final buttonFinder = find.byType('PopupMenuButton<String>');
    final addTokenButton = find.text('Add token');

    test('Click the "add" button', () async {
      await driver!.tap(buttonFinder);
      await driver!.tap(addTokenButton);
    });

    test('Enter name and secret', () async {
      await driver!.tap(find.ancestor(of: find.text('Name'), matching: find.byType('TextFormField')));

      await driver!.enterText('TestName');

      await driver!.tap(find.ancestor(of: find.text('Secret'), matching: find.byType('TextFormField')));

      await driver!.enterText('TestSecret');
    });

    test('Change token type', () async {
      await driver!.tap(find.text('SHA1'));
      await driver!.tap(find.text('SHA512'));

      await driver!.tap(find.text('6'));
      await driver!.tap(find.text('8'));
    });

    test('Click "add" token', () async {
      await driver!.tap(find.text('Add token'));
    });

    test('Assert the token exists', () async {
      await driver!.tap(find.text('TestName'));
      await driver!.tap(find.text('3058 7488'));
    });

    test('Clean up', () async {
      await driver!.scroll(find.text('TestName'), -500, 0, Duration(milliseconds: 100));

      // Delete the token.
      await driver!.tap(find.text('Delete'));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text('Confirm deletion'));

      await driver!.tap(find.text('Delete'));

      await driver!.waitForAbsent(find.text('TestName'));
    });
  });
}
