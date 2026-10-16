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
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';

import 'harness/app_harness.dart';
import 'harness/reference_otp.dart';

TOTPToken _totp(String id, String label, {int? folderId}) => TOTPToken(
  id: id,
  label: label,
  issuer: 'Example',
  algorithm: Algorithms.SHA1,
  digits: 6,
  period: 30,
  secret: base32(utf8.encode('$id-0123456789')),
  folderId: folderId,
);

Finder _decryptDialog() => find.text(l10n.decryptErrorTitle);

void main() {
  appTest('a locked folder that was open when the app ended is closed on the '
      'next start', (app) async {
    await app.storage.setPreference(
      'TOKEN_CATEGORIES',
      jsonEncode([
        {'label': 'Vault', 'folderId': 1, 'isLocked': true, 'isExpanded': true},
      ]),
    );
    app.storage.putToken(_totp('vaulted', 'Vaulted token', folderId: 1));

    await app.start();

    expect(find.text('Vault'), findsOneWidget);
    expect(
      app.container.read(tokenFolderProvider).folders.single.isExpanded,
      isFalse,
    );
    app.expectNoErrorLogs();
  });

  group('a token storage that cannot be decrypted', () {
    appTest('shows the decryption dialog and changes nothing in the storage', (
      app,
    ) async {
      app.storage.putToken(_totp('kept', 'Kept token'));
      final before = Map.of(app.storage.secure);
      app.storage.keystore.unreadable = true;

      await app.start(untilMainView: false);
      await app.pumpUntilFound(_decryptDialog());
      await app.settle();

      expect(_decryptDialog(), findsOneWidget);
      expect(app.storage.secure, before);
    });

    appTest('retry shows the tokens once the storage can be read again', (
      app,
    ) async {
      app.storage.putToken(_totp('kept', 'Kept token'));
      app.storage.keystore.unreadable = true;
      await app.start(untilMainView: false);
      await app.pumpUntilFound(_decryptDialog());

      app.storage.keystore.unreadable = false;
      await app.tap(find.text(l10n.decryptErrorButtonRetry));
      await app.pumpUntilFound(find.byType(MainView));

      expect(_decryptDialog(), findsNothing);
      expect(find.text('Kept token'), findsOneWidget);
    });

    appTest('retry while the storage still cannot be read leaves exactly one '
        'dialog open', (app) async {
      app.storage.putToken(_totp('kept', 'Kept token'));
      app.storage.keystore.unreadable = true;
      await app.start(untilMainView: false);
      await app.pumpUntilFound(_decryptDialog());

      await app.tap(find.text(l10n.decryptErrorButtonRetry));
      await app.settle(const Duration(seconds: 2));

      expect(_decryptDialog(), findsOneWidget);
    });

    appTest(
      'delete wipes the unreadable storage and the app starts without tokens',
      (app) async {
        app.storage.putToken(_totp('lost', 'Lost token'));
        const containerKey = '${SECURE_REPO_PREFIX_TOKEN_CONTAINER}_SMPH0001';
        app.storage.secure[containerKey] = '{}';
        app.storage.keystore.unreadable = true;
        await app.start(untilMainView: false);
        await app.pumpUntilFound(_decryptDialog());

        await app.tap(find.text(l10n.decryptErrorButtonDelete));
        await app.pumpUntilFound(
          find.text(l10n.decryptErrorDeleteConfirmationContent),
        );
        await app.tap(find.text(l10n.decryptErrorButtonDelete).last);
        await app.pumpUntilFound(find.byType(MainView));

        expect(_decryptDialog(), findsNothing);
        expect(app.tokenState.tokens, isEmpty);
        expect(app.storage.storedTokens, isEmpty);
        expect(app.storage.secure.containsKey(containerKey), isFalse);
      },
    );
  });

  appTest(
    'one unreadable folder entry does not take the other folders with it',
    (app) async {
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
    },
  );

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
