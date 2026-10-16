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

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';

import 'harness/app_harness.dart';

void main() {
  appTest('one unreadable folder entry does not take the other folders with it', (
    app,
  ) async {
    await app.storage.setPreference(
      'TOKEN_CATEGORIES',
      jsonEncode([
        {'label': 'Work', 'folderId': 1},
        {'label': 'Broken', 'folderId': 'not a number'},
        {'label': 'Private', 'folderId': 2},
      ]),
    );

    await app.start();

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('Broken'), findsNothing);
    expect(app.container.read(tokenFolderProvider).folders, const [
      TokenFolder(label: 'Work', folderId: 1),
      TokenFolder(label: 'Private', folderId: 2),
    ]);
  });

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
