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
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/views/import_tokens_view/pages/import_plain_tokens_page.dart';

import 'harness/app_harness.dart';

final _link = Uri.parse(
  'otpauth://totp/Example:build-server?secret=JBSWY3DPEHPK3PXP'
  '&issuer=Example&algorithm=SHA1&digits=6&period=30',
);

void main() {
  appTest(
    'an otpauth link opened while the app runs adds the token once, the same '
    'link again within two seconds is dropped',
    (app) async {
      await app.start();

      app.platform.appLinks.open(_link);
      await app.pumpUntil(() => app.tokenState.tokens.isNotEmpty);
      app.platform.appLinks.open(_link);
      await app.settle(const Duration(seconds: 2));

      final token = app.tokenState.tokens.single as TOTPToken;
      expect(token.label, 'build-server');
      expect(token.issuer, 'Example');
      expect(app.storage.storedTokens, hasLength(1));
      expect(find.text('build-server'), findsOneWidget);
      expect(find.byType(ImportPlainTokensPage), findsNothing);
      expect(app.logs.contains('dropped duplicate incoming uri'), true);
      app.expectNoErrorLogs();
    },
  );

  appTest('the same link after two seconds is handled again and offered as an '
      'import of a token that already exists', (app) async {
    await app.start();
    app.platform.appLinks.open(_link);
    await app.pumpUntil(() => app.tokenState.tokens.isNotEmpty);

    // The duplicate window is measured with the real clock.
    await app.tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2100)),
    );
    app.platform.appLinks.open(_link);
    await app.pumpUntilFound(find.byType(ImportPlainTokensPage));

    expect(app.tokenState.tokens, hasLength(1));
    expect(app.storage.storedTokens, hasLength(1));
  });
}
