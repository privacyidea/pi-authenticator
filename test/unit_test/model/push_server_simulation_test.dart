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
import 'package:privacyidea_authenticator/model/capabilities/capabilities.dart';
import 'package:privacyidea_authenticator/model/push_request/decline_reason.dart';
import 'package:privacyidea_authenticator/model/push_request/push_capabilities.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/helpers/json_canonicalizer.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

import 'fake_push_server.dart';

void main() {
  const rsaUtils = RsaUtils();
  final enroll = enrollAgainst;
  final answer = answerWith;

  group('Server without capabilities', () {
    late FakePushServer server;
    late PushToken token;

    setUp(() {
      server = FakePushServer.legacy();
      token = enroll(server);
    });

    test('ignores the capabilities the app announces at enrollment', () {
      expect(server.smartphonePublicKey, isNotNull);
      expect(server.appCapabilities, isNull);
    });

    test('sends a challenge the app accepts', () {
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      );

      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token).isEmpty, isTrue);
    });

    test('accepts a confirmed challenge', () async {
      final data = server.createChallenge();
      final request = PushRequestFactory.fromMessageData(
        data,
      ).dynamicCopyWith(accepted: () => true);

      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(
        server.sessionOf(data['nonce'] as String),
        ChallengeSession.answered,
      );
    });

    test('accepts a decline without a reason', () async {
      final data = server.createChallenge();
      final request = PushRequestFactory.fromMessageData(data).dynamicCopyWith(
        accepted: () => false,
        declineReason: () => DeclineReason.cancelled,
      );

      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.declined);
    });

    test('rejects an answer that signs the decline reason', () async {
      // What the app did before the capability negotiation: it always appended
      // the reason, which this server version does not expect.
      final data = server.createChallenge();
      final nonce = data['nonce'] as String;
      final signature = await rsaUtils.trySignWithToken(
        token,
        '$nonce|${token.serial}|decline|cancelled',
      );

      final result = server.handleAnswer({
        'serial': token.serial,
        'nonce': nonce,
        'decline': '1',
        'decline_reason': 'cancelled',
        'signature': signature!,
      });

      expect(result.result, isFalse);
      expect(server.sessionOf(nonce), isNull);
    });

    test('accepts the presence answer of a choice challenge', () async {
      final data = server.createChallenge(requirePresence: ['A', 'B', 'C']);
      final request = PushRequestFactory.fromMessageData(
        data,
      ).dynamicCopyWith(accepted: () => true, selectedAnswer: 'A');

      expect(request, isA<PushChoiceRequest>());
      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(result.presenceAnswer, 'A');
    });

    test('rejects a wrong presence answer', () async {
      final data = server.createChallenge(requirePresence: ['A', 'B', 'C']);
      final request = PushRequestFactory.fromMessageData(
        data,
      ).dynamicCopyWith(accepted: () => true, selectedAnswer: 'B');

      expect((await answer(server, token, request)).result, isFalse);
    });
  });

  group('Server advertising decline_reason', () {
    late FakePushServer server;
    late PushToken token;

    setUp(() {
      server = FakePushServer.advertising();
      token = enroll(server);
    });

    test('does not store the announcement yet, phase 1 is not there', () {
      expect(server.appCapabilities, isNull);
    });

    test('sends a challenge whose capabilities the app trusts', () {
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      );

      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token).supports('decline_reason'), isTrue);
    });

    test('accepts a decline that carries the reason', () async {
      final data = server.createChallenge();
      final request = PushRequestFactory.fromMessageData(data).dynamicCopyWith(
        accepted: () => false,
        declineReason: () => DeclineReason.cancelled,
      );

      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.cancelled);
    });

    test('distinguishes an unknown trigger from a cancelled request', () async {
      final data = server.createChallenge();
      final request = PushRequestFactory.fromMessageData(data).dynamicCopyWith(
        accepted: () => false,
        declineReason: () => DeclineReason.unknownTrigger,
      );

      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.declined);
    });

    test('accepts a confirmed challenge', () async {
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      ).dynamicCopyWith(accepted: () => true);

      expect((await answer(server, token, request)).result, isTrue);
    });
  });

  group('Server storing the announcement (#5618 phase 1)', () {
    test('stores the reported names', () {
      final server = FakePushServer.storing();
      enroll(server);

      expect(server.appCapabilities, ['decline_reason']);
    });

    test('stores and ignores: the advertisement does not change', () {
      final server = FakePushServer.storing();
      final token = enroll(server);

      expect(server.advertisedCapabilities, {'decline_reason': true});
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      );
      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token).supports('decline_reason'), isTrue);
    });

    test('parses defensively, a broken announcement does not fail', () {
      for (final announced in ['not json', '{"decline_reason": true}', '3']) {
        final server = FakePushServer.storing();
        final token = enroll(
          server,
          extraRequestData: {'capabilities': announced},
        );

        expect(server.appCapabilities, isNull, reason: announced);
        expect(token.rsaPublicServerKey, isNotNull, reason: announced);
      }
    });

    test('an app that reports nothing is stored as nothing', () {
      final server = FakePushServer.storing();
      enroll(server, extraRequestData: {'capabilities': null});

      expect(server.appCapabilities, isNull);
    });
  });

  group('Server tailoring per token (#5618 phase 2)', () {
    test('advertises what both sides have', () {
      final server = FakePushServer.tailoring();
      final token = enroll(server);

      expect(server.advertisedCapabilities, {'decline_reason': true});
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      );
      expect(request.capabilitiesOf(token).supports('decline_reason'), isTrue);
    });

    test('advertises nothing to an app that reported nothing', () async {
      final server = FakePushServer.tailoring();
      final token = enroll(server, extraRequestData: {'capabilities': null});

      expect(server.advertisedCapabilities, isEmpty);

      final data = server.createChallenge();
      expect(data.containsKey('capabilities'), isFalse);

      final request = PushRequestFactory.fromMessageData(data);
      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token), Capabilities.none);

      final result = await answer(
        server,
        token,
        request.dynamicCopyWith(
          accepted: () => false,
          declineReason: () => DeclineReason.cancelled,
        ),
      );
      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.declined);
    });

    test('drops what only the server has', () {
      final server = FakePushServer.tailoring(
        capabilities: {'decline_reason': true, 'something_else': true},
      );
      enroll(server);

      expect(server.advertisedCapabilities, {'decline_reason': true});
    });
  });

  group('Server advertising a restricted value set', () {
    late FakePushServer server;
    late PushToken token;

    setUp(() {
      server = FakePushServer.advertising(
        capabilities: {
          'decline_reason': Capabilities.accepting(['unknown_trigger']),
        },
      );
      token = enroll(server);
    });

    test('accepts the reason it advertised', () async {
      final data = server.createChallenge();
      final request = PushRequestFactory.fromMessageData(data).dynamicCopyWith(
        accepted: () => false,
        declineReason: () => DeclineReason.unknownTrigger,
      );

      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.declined);
    });

    test('accepts a plain decline for a reason it did not advertise', () async {
      final data = server.createChallenge();
      final request = PushRequestFactory.fromMessageData(data).dynamicCopyWith(
        accepted: () => false,
        declineReason: () => DeclineReason.cancelled,
      );

      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.declined);
    });
  });

  group('Server advertising capabilities the app does not know', () {
    late FakePushServer server;
    late PushToken token;

    setUp(() {
      server = FakePushServer.advertising(
        capabilities: {
          'decline_reason': true,
          'future_flag': true,
          'future_descriptor': Capabilities.accepting(['a', 'b']),
          'future_nested': {
            'values': ['a'],
            'mode': 'strict',
          },
        },
      );
      token = enroll(server);
    });

    test('sends a challenge the app still trusts', () {
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      );

      expect(request.verifySignature(token), isTrue);
    });

    test('the unknown entries are readable but never used', () {
      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(),
      );

      final advertised = request.capabilitiesOf(token);
      expect(advertised.supports('future_flag'), isTrue);
      expect(advertised.supports('future_descriptor'), isTrue);

      final usable = advertised.negotiate(appPushCapabilities);
      expect(usable.supports('future_flag'), isFalse);
      expect(usable.supports('future_descriptor'), isFalse);
      expect(usable.supports('decline_reason'), isTrue);
    });

    test('the known capability keeps working', () async {
      final request =
          PushRequestFactory.fromMessageData(
            server.createChallenge(),
          ).dynamicCopyWith(
            accepted: () => false,
            declineReason: () => DeclineReason.cancelled,
          );

      final result = await answer(server, token, request);

      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.cancelled);
    });

    test(
      'a challenge advertising only unknown entries is answerable',
      () async {
        final other = FakePushServer.advertising(
          capabilities: {'future_flag': true},
        );
        final otherToken = enroll(other);
        final request =
            PushRequestFactory.fromMessageData(
              other.createChallenge(),
            ).dynamicCopyWith(
              accepted: () => false,
              declineReason: () => DeclineReason.cancelled,
            );

        final result = await answer(other, otherToken, request);

        expect(result.result, isTrue);
        expect(result.session, ChallengeSession.declined);
      },
    );

    test('a challenge in a future format stays answerable', () async {
      // The canonical form has no representation for numbers, null or a bare
      // array, so the app cannot check a signature over them and uses none of
      // the advertised features. The challenge itself is signed separately and
      // stays valid.
      const futureFormats = [
        '{"decline_reason": true, "max_retries": 3}',
        '{"decline_reason": null}',
        '["decline_reason"]',
        '{"decline_reason": {"values": ["cancelled"], "since": 5}}',
      ];

      for (final capabilities in futureFormats) {
        final request = PushRequestFactory.fromMessageData({
          ...server.createChallenge(),
          'capabilities': capabilities,
        });

        expect(
          request.verifySignature(token),
          isTrue,
          reason: 'should have accepted the challenge for $capabilities',
        );
        expect(request.capabilitiesOf(token).isEmpty, isTrue);

        final result = await answer(
          server,
          token,
          request.dynamicCopyWith(
            accepted: () => false,
            declineReason: () => DeclineReason.cancelled,
          ),
        );

        expect(
          result.result,
          isTrue,
          reason: 'should have answered $capabilities',
        );
        expect(result.session, ChallengeSession.declined);
      }
    });
  });

  group('The literal payload of the merged server', () {
    // privacyidea/lib/tokens/push_types.py:
    //   SERVER_PUSH_CAPABILITIES = {"decline_reason": True}
    //   SERVER_PUSH_CAPABILITIES_JSON = '{"decline_reason": true}'
    // privacyidea/lib/tokens/pushtoken.py, _build_smartphone_data():
    //   "capabilities": SERVER_PUSH_CAPABILITIES_JSON
    //   "capabilities_signature": b32encode_and_unicode(...)
    //   rfc8785.dumps({"capabilities": SERVER_PUSH_CAPABILITIES,
    //                  "nonce": challenge})
    const serverCapabilitiesJson = '{"decline_reason": true}';

    late FakePushServer server;
    late PushToken token;

    setUp(() {
      server = FakePushServer.advertising();
      token = enroll(server);
    });

    test('the signed input matches rfc8785.dumps of the server', () {
      expect(
        canonicalizeJson({
          'capabilities': {'decline_reason': true},
          'nonce': 'ABC123',
        }),
        '{"capabilities":{"decline_reason":true},"nonce":"ABC123"}',
      );
    });

    test('the app verifies and uses the literal advertisement', () async {
      final data = server.createChallenge();
      // The server sends its pre-computed json string, which carries a space
      // the canonical form does not have.
      final request = PushRequestFactory.fromMessageData({
        ...data,
        'capabilities': serverCapabilitiesJson,
      });

      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token).supports('decline_reason'), isTrue);

      final result = await answer(
        server,
        token,
        request.dynamicCopyWith(
          accepted: () => false,
          declineReason: () => DeclineReason.cancelled,
        ),
      );

      expect(result.result, isTrue);
      expect(result.session, ChallengeSession.cancelled);
    });
  });

  group('Untrustworthy capabilities', () {
    test('a challenge whose capabilities signature is stale is rejected', () {
      final server = FakePushServer.advertising();
      final token = enroll(server);

      final request = PushRequestFactory.fromMessageData(
        server.createChallenge(capabilitiesNonce: 'some_other_nonce'),
      );

      expect(request.verifySignature(token), isFalse);
    });

    test('capabilities of another server are rejected', () {
      final server = FakePushServer.advertising();
      final token = enroll(server);
      final attacker = FakePushServer.advertising();

      final data = server.createChallenge();
      final forged = attacker.createChallenge(
        advertise: {'decline_reason': true},
      );
      data['capabilities_signature'] = forged['capabilities_signature'];

      expect(
        PushRequestFactory.fromMessageData(data).verifySignature(token),
        isFalse,
      );
    });
  });
}
