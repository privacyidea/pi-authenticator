/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/// On-device smoke test: the real app with the real plugins (Android
/// keystore, shared preferences, Firebase, app links, home widget) starts into
/// the main view.
///
/// Run it on an EMULATOR only. A debug install on a phone replaces or
/// uninstalls the installed authenticator and its tokens.
///
///   flutter emulators --launch Pixel_7_API_34
///   flutter devices            # note the emulator id, e.g. emulator-5554
///   flutter test integration_test/app_smoke_test.dart \
///     --flavor netknights_debug -d emulator-5554
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart' as app;
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';

import '../test/integration/harness/log_capture.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the app starts into the main view on a device', (tester) async {
    final logs = LogCapture.install();
    final onError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = onError);

    app.main();

    final deadline = DateTime.now().add(const Duration(seconds: 60));
    while (find.byType(MainView).evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) {
        fail('MainView not reached within 60 s.\n${logs.dump()}');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MainView), findsOneWidget);
    expect(
      logs.errors.toList(),
      isEmpty,
      reason: 'The app logged errors on start:\n${logs.errors.join('\n')}',
    );
  });
}
