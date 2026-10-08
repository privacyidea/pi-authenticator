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
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/views/import_tokens_view/pages/import_plain_tokens_page.dart';

import 'harness/app_harness.dart';

/// The app reads the launch link once per isolate, so every test in this file
/// is a cold start through this link.
final _launchLink = Uri.parse(
  'otpauth://hotp/Example:vpn-gateway?secret=JBSWY3DPEHPK3PXP'
  '&issuer=Example&algorithm=SHA1&digits=6&counter=4',
);

void main() {
  PlatformFakes.coldStartLink = _launchLink;

  appTest('a cold start through an otpauth link adds the token exactly once', (
    app,
  ) async {
    await app.start();
    await app.pumpUntil(() => app.tokenState.tokens.isNotEmpty);
    await app.settle(const Duration(seconds: 2));

    final token = app.tokenState.tokens.single as HOTPToken;
    expect(token.label, 'vpn-gateway');
    expect(token.counter, 4);
    expect(app.storage.storedTokens, hasLength(1));
    expect(find.text('vpn-gateway'), findsOneWidget);
    expect(find.byType(ImportPlainTokensPage), findsNothing);
    app.expectNoErrorLogs();
  });
}
