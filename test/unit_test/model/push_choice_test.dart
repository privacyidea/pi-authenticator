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
import 'package:privacyidea_authenticator/model/push_request/push_choice_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';

import 'fake_push_server.dart';
import 'legacy_token_url_fixture.dart';

void main() {
  group('PushChoiceRequest Tests with Short Answers', () {
    final testDate = DateTime(2026, 2, 20);
    final baseUri = Uri.parse('https://example.com');

    final testToken = PushToken(serial: 'PIPU123', id: "123456");

    test('signedData with numeric possibleAnswers', () {
      final request = PushChoiceRequest(
        title: 'Selection',
        question: 'Choose a number',
        nonce: 'N1',
        serial: 'S1',
        signature: 'Sig1',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: true,
        possibleAnswers: ['1', '2', '3'],
      );

      // Verifies that numbers are joined correctly: nonce|uri|serial|question|title|ssl|1,2,3
      expect(
        request.signedData,
        'N1|https://example.com|S1|Choose a number|Selection|1|1,2,3',
      );
    });

    test('signedData with letter possibleAnswers', () {
      final request = PushChoiceRequest(
        title: 'Poll',
        question: 'Select A or B',
        nonce: 'N2',
        serial: 'S2',
        signature: 'Sig2',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: false,
        possibleAnswers: ['A', 'B'],
      );

      expect(
        request.signedData,
        'N2|https://example.com|S2|Select A or B|Poll|0|A,B',
      );
    });

    test('getResponseSignMsg appends numeric selectedAnswer', () {
      final request = PushChoiceRequest(
        title: 'T',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: true,
        possibleAnswers: ['1', '2'],
        selectedAnswer: '2',
        accepted: true,
      );

      final responseMsg = request.getResponseSignMsg(testToken);

      expect(responseMsg, endsWith('|2'));
      expect(request.accepted, isTrue);
    });

    test('fromMessageData handles comma separated numbers', () {
      final data = {
        'title': 'Numbers',
        'question': 'Pick?',
        'url': 'https://pi.com',
        'nonce': 'nonce123',
        'sslverify': '1',
        'serial': 'S123',
        'signature': 'SIG',
        'require_presence':
            '1,2,3,4', // The server sends choices as a comma-separated string
      };

      final request = PushChoiceRequest.fromMessageData(data);

      expect(request.possibleAnswers, ['1', '2', '3', '4']);
      expect(request.possibleAnswers.length, 4);
      expect(request.possibleAnswers.first, '1');
    });

    test('equality and hashing with numeric IDs', () {
      final req1 = PushChoiceRequest(
        title: 'T',
        question: 'Q',
        nonce: '100',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: true,
        possibleAnswers: ['1'],
      );
      final req2 = PushChoiceRequest(
        title: 'Other',
        question: 'Other',
        nonce: '100',
        serial: 'Other',
        signature: 'Other',
        expirationDate: testDate,
        uri: baseUri,
        sslVerify: false,
        possibleAnswers: ['2'],
      );

      // Both have the same nonce '100', so their id (nonce.hashCode) is identical
      expect(req1, req2);
      expect(req1.hashCode, req2.hashCode);
    });
  });

  // PushChoiceRequest inherits `verifySignature` from PushDefaultRequest, so it
  // has the same "re-add url and sslverify to android legacy tokens" step. The
  // url and sslVerify of a request may only be written into the token after a
  // successful signature check and never for a request that is rejected. See
  // legacy_token_url_fixture.dart and push_default_request_test.dart.
  group('PushChoiceRequest for a token without url', () {
    final fx = useLegacyTokenUrlFixture();

    Map<String, dynamic> challenge(
      FakePushServer s, {
      String? capabilitiesNonce,
    }) => s.createChallenge(
      requirePresence: ['1', '2', '3'],
      capabilitiesNonce: capabilitiesNonce,
    );
    PushRequest parse(Map<String, dynamic> data) =>
        PushChoiceRequest.fromMessageData(data);

    testWidgets(
      'control: a valid request is accepted and the url and sslVerify of the request are re-added',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final data = challenge(fx.server);
        final request = parse(data);

        expect(request.verifySignature(fx.legacyToken()), isTrue);

        expect(notifier.updates, hasLength(1));
        expect(notifier.updates.single.before.url, isNull);
        expect(
          notifier.updates.single.after.url,
          Uri.parse(FakePushServer.url),
        );
        expect(notifier.updates.single.after.url, request.uri);
        expect(notifier.updates.single.after.sslVerify, isTrue);
      },
    );

    testWidgets(
      'control: the url of a token that has one is never touched, valid or forged',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final tokenWithUrl = fx.legacyToken().copyWith(
          url: Uri.parse(FakePushServer.url),
          sslVerify: true,
        );
        final valid = parse(challenge(fx.server));
        final forged = parse({...challenge(fx.server), 'url': evilUrl});

        expect(valid.verifySignature(tokenWithUrl), isTrue);
        expect(forged.verifySignature(tokenWithUrl), isFalse);

        expect(notifier.updates, isEmpty);
      },
    );

    test(
      'control: verification works without a globalRef (background isolate)',
      () {
        // globalRef stays null: nothing is mounted.
        final request = parse(challenge(fx.server));

        expect(globalRef, isNull);
        expect(request.verifySignature(fx.legacyToken()), isTrue);
      },
    );

    bugTestWidgets(
      'a request with a swapped url but the original signature is rejected and does not redirect the token',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final forged = parse({...challenge(fx.server), 'url': evilUrl});

        expect(forged.uri, Uri.parse(evilUrl));
        expect(forged.verifySignature(fx.legacyToken()), isFalse);

        expect(
          notifier.updates.where((u) => u.after.url == Uri.parse(evilUrl)),
          isEmpty,
          reason: 'The url of a rejected request was written into the token',
        );
        expect(notifier.updates, isEmpty);
      },
      bug:
          'BUG: push_default_request.dart:88-95 writes url and sslVerify of the unverified request into the token before super.verifySignature runs',
    );

    bugTestWidgets(
      'a request signed with the key of an attacker (matching serial) is rejected and does not redirect the token',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final data = challenge(fx.attacker);
        data['url'] = evilUrl;
        data['sslverify'] = '0';
        // The attacker signs the exact message it sends, only the key is wrong.
        data['signature'] = fx.attackerSignature(parse(data).signedData);
        final forged = parse(data);

        expect(forged.serial, fx.legacyToken().serial);
        expect(forged.verifySignature(fx.legacyToken()), isFalse);

        expect(notifier.updates, isEmpty);
      },
      bug:
          'BUG: push_default_request.dart:88-95 writes url and sslVerify of the unverified request into the token before super.verifySignature runs',
    );

    bugTestWidgets(
      'a request with a malformed signature is rejected and does not touch the token',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final forged = parse({
          ...challenge(fx.server),
          'url': evilUrl,
          'signature': '!not base32!',
        });

        expect(forged.verifySignature(fx.legacyToken()), isFalse);

        expect(notifier.updates, isEmpty);
      },
      bug:
          'BUG: push_default_request.dart:88-95 writes url and sslVerify of the unverified request into the token before super.verifySignature runs',
    );

    bugTestWidgets(
      'a request whose capabilities signature is invalid is rejected as a whole and does not touch the token',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        // The main signature is valid, the detached capabilities signature is
        // bound to another nonce.
        final request = parse(
          challenge(fx.server, capabilitiesNonce: 'another-nonce'),
        );

        expect(request.verifySignature(fx.legacyToken()), isFalse);

        expect(notifier.updates, isEmpty);
      },
      bug:
          'BUG: push_default_request.dart:88-95 writes url and sslVerify into the token even when verifySignature then returns false',
    );

    bugTestWidgets(
      'a request for a token that has no server key (not rolled out) is rejected and does not touch the token',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final notRolledOut = PushToken(
          serial: fx.server.serial,
          id: 'not-rolled-out',
        );
        final forged = parse({...challenge(fx.server), 'url': evilUrl});

        expect(notRolledOut.url, isNull);
        expect(forged.verifySignature(notRolledOut), isFalse);

        expect(notifier.updates, isEmpty);
      },
      bug:
          'BUG: push_default_request.dart:88-95 writes url and sslVerify into a token that has no server key to verify against',
    );
  });
}
