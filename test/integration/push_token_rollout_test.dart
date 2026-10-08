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
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';

import 'harness/app_harness.dart';
import 'harness/fake_push_endpoint.dart';

final _deviceKeys = generateShortRsaKeyPair();

Uri _rolloutLink({
  required String serial,
  String credential = FakePushServer.enrollmentCredential,
}) => Uri.parse(
  'otpauth://pipush/$serial?url=${Uri.encodeComponent(FakePushServer.url)}'
  '&ttl=10&issuer=privacyIDEA&enrollment_credential=$credential&v=1'
  '&serial=$serial&sslverify=1&poll_only=True',
);

PushToken? _pushToken(AppHarness app) =>
    app.tokenState.tokens.whereType<PushToken>().firstOrNull;

void main() {
  appTest(
    'a pipush link enrolls the token against the server, and the first '
    'challenge it polls is answered with the new key',
    rsaUtils: FastKeyRsaUtils([_deviceKeys]),
    (app) async {
      final push = FakePushEndpoint(
        FakePushServer.advertising(serial: 'PIPU0042'),
        app.backend,
      );
      await app.start();

      app.platform.appLinks.open(_rolloutLink(serial: 'PIPU0042'));
      await app.pumpUntil(
        () => _pushToken(app)?.isRolledOut == true,
        reason: 'the rollout',
      );

      final enrollment = app.backend.posts.single;
      expect(enrollment.url, Uri.parse(FakePushServer.url));
      expect(enrollment.data['serial'], 'PIPU0042');
      expect(
        enrollment.data['enrollment_credential'],
        FakePushServer.enrollmentCredential,
      );
      expect(enrollment.data['fbtoken'], NoFirebaseUtils.NO_FIREBASE_TOKEN);
      expect(enrollment.data['capabilities'], isNotNull);
      expect(
        push.server.smartphonePublicKey?.modulus,
        _deviceKeys.publicKey.modulus,
      );

      final token = _pushToken(app)!;
      expect(token.rolloutState, PushTokenRollOutState.rolloutComplete);
      expect(
        token.rsaPublicServerKey?.modulus,
        push.server.keyPair.publicKey.modulus,
        reason: 'the app keeps the key the server sent back',
      );
      expect(
        app.storage.storedTokens[token.id]!['isRolledOut'],
        true,
        reason: 'the rolled out token is persisted',
      );

      final challenge = push.queueChallenge(question: 'First login?');
      await app.pullToRefresh();
      await app.pumpUntilFound(find.byType(PushDefaultDialog));
      await app.tap(
        find.descendant(
          of: find.byType(PushDefaultDialog),
          matching: find.text(l10n.accept),
        ),
      );
      await app.pumpUntilGone(find.byType(PushDefaultDialog));

      expect(
        push.server.sessionOf(challenge['nonce'] as String),
        ChallengeSession.answered,
      );
      app.expectNoErrorLogs();
    },
  );

  appTest(
    'a rollout the server refuses leaves the token failed and tells the user',
    rsaUtils: FastKeyRsaUtils([_deviceKeys]),
    (app) async {
      final push = FakePushEndpoint(
        FakePushServer.advertising(serial: 'PIPU0043'),
        app.backend,
      );
      await app.start();

      app.platform.appLinks.open(
        _rolloutLink(serial: 'PIPU0043', credential: 'outdated-credential'),
      );
      await app.pumpUntil(
        () =>
            _pushToken(app)?.rolloutState ==
            PushTokenRollOutState.sendRSAPublicKeyFailed,
        reason: 'the failed rollout',
      );

      expect(push.server.smartphonePublicKey, isNull);
      expect(_pushToken(app)!.isRolledOut, false);
      expect(
        app.statusMessages.single,
        contains(l10n.errorRollOutFailed('PIPU0043')),
      );
      expect(
        app.statusMessages.single,
        contains('Invalid enrollment credential'),
      );
    },
  );
}
