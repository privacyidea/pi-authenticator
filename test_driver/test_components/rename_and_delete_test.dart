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

    String tokenLabel = 'TokenLabel';
    String secret = 'TokenSecret';
    addTokenRoutine(tokenLabel, secret);

    test("Assert renaming works", () async {
      await driver!
          .scroll(find.text(tokenLabel), -500, 0, Duration(milliseconds: 100));

      await driver!.tap(find.text("Customize"));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text("Customize token"));

      await driver!.tap(find.byType("TextFormField"));

      await driver!.enterText("NewTestLabel");
      await driver!.tap(find.byType("FloatingActionButton"));

      // Assert new name is shown.
      await driver!.tap(find.text("NewTestLabel"));
    });

    test("Assert renaming works again", () async {
      await driver!.scroll(
          find.text("NewTestLabel"), -500, 0, Duration(milliseconds: 100));

      await driver!.tap(find.text("Customize"));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text("Customize token"));

      await driver!.tap(find.byType("TextFormField"));

      await driver!.enterText("OldTestLabel");
      await driver!.tap(find.byType("FloatingActionButton"));

      // Assert new name is shown.
      await driver!.tap(find.text("OldTestLabel"));
    });

    test("Assert delete works", () async {
      await driver!.scroll(
          find.text("OldTestLabel"), -500, 0, Duration(milliseconds: 100));

      // Delete the token.
      await driver!.tap(find.text("Delete"));

      // Wait for the dialog to open.
      await driver!.waitFor(find.text("Confirm deletion"));

      await driver!.tap(find.text("Delete"));

      await driver!.waitForAbsent(find.text("OldTestLabel"));
    });
  });
}
