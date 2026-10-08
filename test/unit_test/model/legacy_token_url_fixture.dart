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

/// Shared fixture (no tests) of the "re-add url and sslverify to android legacy
/// tokens" step of `PushDefaultRequest.verifySignature`.
///
/// A legacy token has no `url`. When a push request arrives for it, the url and
/// sslVerify of the request are written into the token. The request is
/// untrusted until its signature was checked, so the write must only happen
/// after a successful check and never for a request that is rejected.
/// Otherwise a forged message that merely carries the serial of the token
/// could redirect the token to a server of the attacker.
///
/// The tests themselves live next to the class they exercise:
/// `push_default_request_test.dart`, `push_choice_test.dart` (inherits
/// `verifySignature`) and `push_code_to_phone_request_test.dart` (does not
/// override it).
library;

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

import 'fake_push_server.dart';

/// Run the tests of suspected bugs for real:
/// `flutter test --dart-define=RUN_BUG_TESTS=true <test file>`
const runBugTests = bool.fromEnvironment('RUN_BUG_TESTS');

const evilUrl = 'https://evil.example/ttype/push';

const _rsaUtils = RsaUtils();

/// A [TokenNotifier] that does not touch any repository. It records every
/// [updateToken] call together with the result of the updater, so a test can
/// see exactly which values would have been written into the token.
class RecordingTokenNotifier extends TokenNotifier {
  final List<({PushToken before, PushToken after})> updates = [];

  @override
  Future<TokenState> build({
    required firebaseUtils,
    required ioClient,
    required repo,
    required rsaUtils,
  }) async => const TokenState(tokens: []);

  @override
  Future<T?> updateToken<T extends Token>(
    T token,
    T Function(T) updater,
  ) async {
    // The recording happens before the first await, so a caller that does not
    // await the future (like verifySignature) is recorded synchronously.
    final after = updater(token);
    updates.add((before: token as PushToken, after: after as PushToken));
    return after;
  }
}

/// The keys, the fake servers and the helpers of the legacy token url tests.
class LegacyTokenUrlFixture {
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> serverKeys;
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> attackerKeys;
  late FakePushServer server;
  late FakePushServer attacker;

  /// A token as it is left behind by an android app version that did not store
  /// the url: rolled out, trusted server key, but `url == null`.
  PushToken legacyToken() => PushToken(
    serial: server.serial,
    id: 'legacy-id',
    isRolledOut: true,
    rolloutState: PushTokenRollOutState.rolloutComplete,
  ).withPublicServerKey(serverKeys.publicKey);

  /// Mounts a widget tree whose [globalRef] reads the overridden tokenProvider.
  Future<RecordingTokenNotifier> mountApp(WidgetTester tester) async {
    final notifier = RecordingTokenNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenProvider.overrideWith(() => notifier)],
        child: Consumer(
          builder: (context, ref, _) {
            globalRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    return notifier;
  }

  /// The signature an attacker without the server key can produce.
  String attackerSignature(String signedData) => _rsaUtils
      .createBase32Signature(attackerKeys.privateKey, utf8.encode(signedData));
}

/// Call inside a `group`: generates the keys once for the group and resets
/// [globalRef] after every test of it.
LegacyTokenUrlFixture useLegacyTokenUrlFixture() {
  final fixture = LegacyTokenUrlFixture();

  setUpAll(() {
    fixture.serverKeys = generateShortRsaKeyPair();
    fixture.attackerKeys = generateShortRsaKeyPair();
    fixture.server = FakePushServer.advertising(keyPair: fixture.serverKeys);
    fixture.attacker = FakePushServer.advertising(
      keyPair: fixture.attackerKeys,
    );
  });

  tearDown(() => globalRef = null);

  return fixture;
}

/// A test of the correct behaviour that fails because of a bug in lib. It is
/// skipped until the bug is fixed (testWidgets itself only takes a bool, so
/// the reason goes on a group).
void bugTestWidgets(
  String description,
  Future<void> Function(WidgetTester tester) body, {
  required String bug,
}) {
  group(
    'SUSPECTED BUG',
    () => testWidgets(description, body),
    skip: runBugTests ? null : bug,
  );
}
