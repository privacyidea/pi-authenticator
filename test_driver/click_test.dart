// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Counter App', () {
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

//    final buttonFinder = find.byType(FloatingActionButton.toString());
    final buttonFinder = find.byType("FloatingActionButton");

    test('click the button', () async {
      await driver.tap(buttonFinder);
      await Future.delayed(Duration(seconds: 10));
    });
  });
}
