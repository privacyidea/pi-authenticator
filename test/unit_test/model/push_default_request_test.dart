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
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';

import 'fake_push_server.dart';
import 'legacy_token_url_fixture.dart';

void main() {
  group('PushMessageRequest Tests', () {
    final testDate = DateTime(2025);

    test('Constructor and basic fields', () {
      final request = PushDefaultRequest(
        title: 'Message Title',
        question: 'Confirm?',
        nonce: 'nonce123',
        serial: 'PIPU123',
        signature: 'sig123',
        expirationDate: testDate,
        uri: Uri.parse('https://example.com'),
        sslVerify: true,
      );

      expect(request.title, 'Message Title');
      expect(request.uri.toString(), 'https://example.com');
      expect(request.sslVerify, true);
    });

    test('signedData string generation (with answers)', () {
      final request = PushDefaultRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: 'serial',
        signature: 'sig',
        expirationDate: testDate,
        uri: Uri.parse('https://pi.com'),
        sslVerify: true,
      );

      // Format: nonce|uri|serial|question|title|sslVerify
      expect(
        request.signedData,
        'nonce|https://pi.com|serial|Question|Title|1',
      );
    });

    test('signedData string generation (without answers)', () {
      final request = PushDefaultRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: 'serial',
        signature: 'sig',
        expirationDate: testDate,
        uri: Uri.parse('https://pi.com'),
        sslVerify: false,
      );

      expect(
        request.signedData,
        'nonce|https://pi.com|serial|Question|Title|0',
      );
    });

    test('JSON serialization', () {
      final request = PushDefaultRequest(
        title: 'T',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: Uri.parse('https://test.de'),
        sslVerify: true,
        accepted: false,
      );

      final json = request.toJson();
      expect(json['title'], 'T');
      expect(json['question'], 'Q');
      expect(json['nonce'], 'N');
      expect(json['serial'], 'S');
      expect(json['signature'], 'Sig');
      expect(json['expirationDate'], testDate.toIso8601String());
      expect(json['uri'], 'https://test.de');
      expect(json['sslVerify'], true);
      expect(json['type'], PushDefaultRequest.TYPE);
      expect(json['accepted'], false);
    });

    test('Polymorphic fromJson', () {
      final json = {
        'title': 'T',
        'question': 'Q',
        'nonce': 'N',
        'serial': 'S',
        'signature': 'Sig',
        'expirationDate': testDate.toIso8601String(),
        'uri': 'http://example.com',
        'sslVerify': false,
        'type': PushDefaultRequest.TYPE,
        'accepted': true,
      };

      final result = PushRequest.fromJson(json);
      expect(result, isA<PushDefaultRequest>());
      expect(result.title, 'T');
      expect(result.question, 'Q');
      expect(result.nonce, 'N');
      expect(result.serial, 'S');
      expect(result.signature, 'Sig');
      expect(result.uri, Uri.parse('http://example.com'));
      expect(result.sslVerify, false);
      expect(result.expirationDate, testDate);
      expect(result.accepted, true);
      expect(result.type, PushDefaultRequest.TYPE);
      expect(result.id, 'N'.hashCode);
    });
  });

  // Security tests for the "re-add url and sslverify to android legacy tokens"
  // step of `PushDefaultRequest.verifySignature`. The url and sslVerify of a
  // request may only be written into the token after a successful signature
  // check and never for a request that is rejected. See
  // legacy_token_url_fixture.dart. The same step is inherited by
  // PushChoiceRequest (push_choice_test.dart).
  group('PushDefaultRequest for a token without url', () {
    final fx = useLegacyTokenUrlFixture();

    Map<String, dynamic> challenge(
      FakePushServer s, {
      String? capabilitiesNonce,
    }) => s.createChallenge(capabilitiesNonce: capabilitiesNonce);
    PushRequest parse(Map<String, dynamic> data) =>
        PushDefaultRequest.fromMessageData(data);

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
