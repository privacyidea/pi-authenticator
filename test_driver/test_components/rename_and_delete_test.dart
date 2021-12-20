/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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

void renameAndDeleteTest() {
  group('Rename and delete', () {
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

    test('Assert renaming works', () async {
      await driver!.scroll(
          find.text(tokenName), -500, 0, Duration(milliseconds: 100));

      await driver!.tap(find.text('Rename'));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text('Rename token'));

      await driver!.enterText('NewTestName');
      await driver!.tap(find.text('Rename'));

      // Assert new name is shown.
      await driver!.tap(find.text('NewTestName'));
    });

    test('Assert renaming works again', () async {
      await driver!.scroll(
          find.text('NewTestName'), -500, 0, Duration(milliseconds: 100));

      await driver!.tap(find.text('Rename'));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text('Rename token'));

      await driver!.enterText('OldTestName');
      await driver!.tap(find.text('Rename'));

      // Assert new name is shown.
      await driver!.tap(find.text('OldTestName'));
    });

    test('Assert delete works', () async {
      await driver!.scroll(
          find.text('OldTestName'), -500, 0, Duration(milliseconds: 100));

      // Delete the token.
      await driver!.tap(find.text('Delete'));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text('Confirm deletion'));

      await driver!.tap(find.text('Delete'));

      await driver!.waitForAbsent(find.text('OldTestName'));
    });
  });
}
