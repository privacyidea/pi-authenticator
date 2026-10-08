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

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';

import 'harness/app_harness.dart';

void main() {
  appTest('an empty device starts into the main view without traffic', (
    app,
  ) async {
    await app.start();

    expect(find.byType(MainView), findsOneWidget);
    expect(app.tokenState.tokens, isEmpty);
    expect(app.backend.requests, isEmpty);
    app.expectNoErrorLogs();
  });
}
