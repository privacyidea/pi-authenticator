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

void addTokenRoutine(String label, String secret) {
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

  test("Click the 'add' button", () async {
    await driver!.tap(find.byType("PopupMenuButton<String>"));
    await driver!.tap(find.text("Add token"));
  });

  test("Enter label and secret", () async {
    // Enter the name.
    await driver!.tap(find.ancestor(
        of: find.text("Label"), matching: find.byType("TextFormField")));

    await driver!.enterText(label);

    // Enter the secret.
    await driver!.tap(find.ancestor(
        of: find.text("Secret"), matching: find.byType("TextFormField")));

    await driver!.enterText(secret);
  });

  test("Click 'add token'", () async {
    await driver!.tap(find.text("Add token"));
  });

  test("Assert the token exists", () async {
    await driver!.tap(find.text(label));
  });
}

Future<bool> doLongPress(
    FlutterDriver driver, SerializableFinder target) async {
  // Pressing 2 seconds is needed to start the 'paste' dialog on a text field.
  await driver.scroll(target, 0, 0, Duration(seconds: 2));
  return true;
}
