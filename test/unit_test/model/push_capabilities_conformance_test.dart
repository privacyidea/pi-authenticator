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

/// Each test pins one statement of privacyidea#5618 (and the #5590 state it
/// describes) that the app has to fulfil. The quoted lines are from the issue.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/capabilities/capabilities.dart';
import 'package:privacyidea_authenticator/model/push_request/decline_reason.dart';
import 'package:privacyidea_authenticator/model/push_request/push_capabilities.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/helpers/json_canonicalizer.dart';

import 'fake_push_server.dart';

void main() {
  late FakePushServer server;
  late PushToken token;

  setUp(() {
    server = FakePushServer.advertising();
    token = enrollAgainst(server);
  });

  group('#5590, the state the app has to consume', () {
    // "every challenge carries a capabilities field plus a detached,
    //  nonce-bound signature (capabilities_signature)"
    test('both fields are read under the names the server uses', () {
      final data = server.createChallenge();

      expect(data.containsKey(SignedCapabilities.CAPABILITIES), isTrue);
      expect(data.containsKey(SignedCapabilities.SIGNATURE), isTrue);
      expect(SignedCapabilities.CAPABILITIES, 'capabilities');
      expect(SignedCapabilities.SIGNATURE, 'capabilities_signature');

      final request = PushRequestFactory.fromMessageData(data);
      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token).supports('decline_reason'), isTrue);
    });

    // "the detached signature keeps the main signature byte-identical for them"
    test(
      'the main signed data does not change when capabilities are added',
      () {
        final withCapabilities = server.createChallenge();
        final without = {...withCapabilities}
          ..remove(SignedCapabilities.CAPABILITIES)
          ..remove(SignedCapabilities.SIGNATURE);

        expect(
          PushRequestFactory.fromMessageData(withCapabilities).signedData,
          PushRequestFactory.fromMessageData(without).signedData,
        );
      },
    );

    // "older apps parse the challenge into a map and skip unknown fields"
    test('unknown fields do not affect parsing or the main signed data', () {
      final data = server.createChallenge();
      final withUnknown = {
        ...data,
        'a_field_from_the_future': 'x',
        'another_one': '1',
      };

      final request = PushRequestFactory.fromMessageData(withUnknown);
      expect(request.verifySignature(token), isTrue);
      expect(
        request.signedData,
        PushRequestFactory.fromMessageData(data).signedData,
      );
    });

    // "the version field in the smartphone payload is a feature marker, not a
    //  schema version [...] set to "2" only to signal presence-options"
    test('version is not treated as a schema version', () {
      final data = server.createChallenge();
      final versioned = {...data, 'version': '2'};

      final request = PushRequestFactory.fromMessageData(versioned);
      expect(request, isA<PushDefaultRequest>());
      expect(request.verifySignature(token), isTrue);
      expect(
        request.signedData,
        PushRequestFactory.fromMessageData(data).signedData,
      );
    });

    test(
      'presence options are detected by require_presence, not by version',
      () {
        final request = PushRequestFactory.fromMessageData(
          server.createChallenge(requirePresence: ['A', 'B']),
        );

        expect(request, isA<PushChoiceRequest>());
        expect((request as PushChoiceRequest).possibleAnswers, ['A', 'B']);
      },
    );
  });

  group('the positional sign strings the server rebuilds', () {
    // "{nonce}|{url}|{serial}|... with conditional |segment appends for
    //  require_presence, decline, decline_reason, presence_answer"
    test('challenge: nonce|url|serial|question|title|sslverify', () {
      final data = server.createChallenge();

      expect(
        PushRequestFactory.fromMessageData(data).signedData,
        '${data['nonce']}|${FakePushServer.url}|${server.serial}'
        '|${data['question']}|${data['title']}|1',
      );
    });

    test('challenge with require_presence appended', () {
      final data = server.createChallenge(requirePresence: ['A', 'B']);

      expect(
        PushRequestFactory.fromMessageData(data).signedData,
        endsWith('|1|A,B'),
      );
    });

    test(
      'answer: nonce|serial then decline, decline_reason, presence_answer',
      () {
        final data = server.createChallenge(requirePresence: ['A', 'B']);
        final request =
            PushRequestFactory.fromMessageData(data) as PushChoiceRequest;

        expect(
          request.copyWith(accepted: () => true).getResponseSignMsg(token),
          '${data['nonce']}|${token.serial}',
        );
        expect(
          request
              .copyWith(accepted: () => true, selectedAnswer: 'A')
              .getResponseSignMsg(token),
          '${data['nonce']}|${token.serial}|A',
        );
        expect(
          request
              .copyWith(
                accepted: () => false,
                declineReason: () => DeclineReason.cancelled,
              )
              .getResponseSignMsg(token),
          '${data['nonce']}|${token.serial}|decline|cancelled',
        );
        expect(
          request
              .copyWith(
                accepted: () => false,
                declineReason: () => DeclineReason.cancelled,
                selectedAnswer: 'A',
              )
              .getResponseSignMsg(token),
          '${data['nonce']}|${token.serial}|decline|cancelled|A',
        );
      },
    );
  });

  group('5583 verification rules', () {
    test(
      'the signed input is the canonical form of capabilities and nonce',
      () {
        expect(
          canonicalizeJson({
            'capabilities': {'decline_reason': true},
            'nonce': 'ABC123',
          }),
          '{"capabilities":{"decline_reason":true},"nonce":"ABC123"}',
        );
      },
    );

    test('a nonce mismatch rejects the challenge', () {
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(capabilitiesNonce: 'a_different_nonce'),
      );

      expect(request.verifySignature(token), isFalse);
    });

    test('a feature is used only when advertised and implemented', () {
      final advertised = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      ).capabilitiesOf(token);

      expect(advertised.negotiate(appPushCapabilities).names, [
        'decline_reason',
      ]);
      expect(
        advertised.negotiate(Capabilities.declared({'something_else': true})),
        Capabilities.none,
      );
      expect(
        Capabilities.declared({
          'something_else': true,
        }).negotiate(appPushCapabilities),
        Capabilities.none,
      );
    });

    test('the decline reasons are unknown_trigger and cancelled', () {
      expect(DeclineReason.values.map((r) => r.value), [
        'unknown_trigger',
        'cancelled',
      ]);
    });
  });

  group('downgrade is tamper-evident, not prevented', () {
    // "an active man-in-the-middle can simply strip capabilities/
    //  capabilities_signature to force a capable app back to legacy, with no
    //  signature failure"
    test(
      'a stripped advertisement falls back to legacy, it does not fail',
      () async {
        final data = server.createChallenge()
          ..remove(SignedCapabilities.CAPABILITIES)
          ..remove(SignedCapabilities.SIGNATURE);

        final request = PushRequestFactory.fromMessageData(data);
        expect(request.verifySignature(token), isTrue);
        expect(request.capabilitiesOf(token), Capabilities.none);

        final result = await answerWith(
          server,
          token,
          request.dynamicCopyWith(
            accepted: () => false,
            declineReason: () => DeclineReason.cancelled,
          ),
        );
        expect(result.result, isTrue);
        expect(result.session, ChallengeSession.declined);
      },
    );

    test('a tampered advertisement does fail', () {
      final data = server.createChallenge();
      data[SignedCapabilities.CAPABILITIES] =
          '{"decline_reason": true, "sneaked_in": true}';

      expect(
        PushRequestFactory.fromMessageData(data).verifySignature(token),
        isFalse,
      );
    });
  });

  group('#5618 phase 1', () {
    // "App includes a capabilities JSON array (e.g. ["decline_reason"]) [...]
    //  Vocabulary is the shared PushCapability value set."
    // The request body itself is pinned in token_notifier_test.dart.
    test('the announcement is a json array of the shared vocabulary', () {
      expect(canonicalizeJson(appPushCapabilities.names), '["decline_reason"]');
      expect(appPushCapabilities.names, [PushCapability.declineReason]);
      expect(PushCapability.declineReason, 'decline_reason');
    });

    // "an app that ships early is tolerated by an unaware server"
    test('a server that ignores the announcement still enrolls', () {
      final unaware = FakePushServer.legacy();
      final enrolled = enrollAgainst(unaware);

      expect(unaware.appCapabilities, isNull);
      expect(enrolled.rsaPublicServerKey, isNotNull);
    });

    // "Server parses it defensively and stores it in tokeninfo
    //  (e.g. app_capabilities) but does not branch on it yet"
    test('a phase 1 server stores the names without acting on them', () {
      final server = FakePushServer.storing();
      enrollAgainst(server);

      expect(server.appCapabilities, ['decline_reason']);
      expect(server.advertisedCapabilities, server.serverCapabilities);
    });
  });

  group('#5618 phase 2', () {
    // "read app_capabilities and intersect with SERVER_PUSH_CAPABILITIES,
    //  tailoring the challenge per token"
    test('the challenge carries the intersection of both sides', () {
      final server = FakePushServer.tailoring(
        capabilities: {'decline_reason': true, 'not_reported_by_the_app': true},
      );
      final tailoredToken = enrollAgainst(server);

      final advertised = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      ).capabilitiesOf(tailoredToken);

      expect(advertised.names, ['decline_reason']);
    });
  });
}
