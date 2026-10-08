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
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/model/push_request/push_code_to_phone_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_request.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

import 'fake_push_server.dart';
import 'legacy_token_url_fixture.dart';

const _rsaUtils = RsaUtils();

void main() {
  group('PushCodeToPhoneRequest Tests', () {
    final testDate = DateTime(2025);

    test('Constructor and displayCode', () {
      final request = PushCodeToPhoneRequest(
        title: 'Code Title',
        question: 'Enter Code',
        nonce: 'nonce456',
        serial: 'PIPU456',
        signature: 'sig456',
        expirationDate: testDate,
        displayCode: '123456',
        uri: Uri.parse("http://example.com"),
        sslVerify: false,
      );

      expect(request.displayCode, '123456');
      expect(request.id, 'nonce456'.hashCode);
    });

    test('signedData string generation', () {
      final request = PushCodeToPhoneRequest(
        title: 'Title',
        question: 'Question',
        nonce: 'nonce',
        serial: 'serial',
        signature: 'sig',
        expirationDate: testDate,
        displayCode: '654321',
        uri: Uri.parse("http://example.com"),
        sslVerify: false,
      );

      expect(
        request.signedData,
        'nonce|http://example.com|serial|Question|Title|0|654321',
      );
    });

    test('JSON serialization/deserialization', () {
      final request = PushCodeToPhoneRequest(
        title: 'T',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        displayCode: '111222',
        uri: Uri.parse('http://example.com'),
        sslVerify: false,
      );

      final json = request.toJson();
      expect(json['displayCode'], '111222');

      final fromJson = PushCodeToPhoneRequest.fromJson(json);
      expect(fromJson.displayCode, '111222');
      expect(fromJson.type, 'code_to_phone');
    });

    test('Polymorphic detection via displayCode field', () {
      final json = {
        'title': 'T',
        'question': 'Q',
        'nonce': 'N',
        'serial': 'S',
        'signature': 'Sig',
        'expirationDate': testDate.toIso8601String(),
        'displayCode': '888777',
        'uri': 'http://example.com',
        'sslVerify': false,
        'type': PushCodeToPhoneRequest.TYPE,
        'accepted': true,
      };

      final result = PushRequest.fromJson(json);
      expect(result, isA<PushCodeToPhoneRequest>());
      expect((result as PushCodeToPhoneRequest).displayCode, '888777');
      expect(result.id, 'N'.hashCode);
      expect(result.signedData, 'N|http://example.com|S|Q|T|0|888777');
      expect(result.title, 'T');
      expect(result.question, 'Q');
      expect(result.nonce, 'N');
      expect(result.serial, 'S');
      expect(result.signature, 'Sig');
      expect(result.expirationDate, testDate);
      expect(result.uri, Uri.parse('http://example.com'));
      expect(result.sslVerify, false);
      expect(result.type, PushCodeToPhoneRequest.TYPE);
      expect(result.accepted, true);
    });
  });

  // PushCodeToPhoneRequest has no override of `verifySignature`, unlike
  // PushDefaultRequest and PushChoiceRequest, which re-add the url and
  // sslverify of a request to an android legacy token. See
  // legacy_token_url_fixture.dart.
  group('PushCodeToPhoneRequest for a token without url', () {
    final fx = useLegacyTokenUrlFixture();
    const code = '123456';

    /// A code to phone challenge, signed by [keys] over the documented sign
    /// string `nonce|url|serial|question|title|sslverify|display_code`.
    Map<String, dynamic> codeToPhoneData({
      required AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keys,
      String url = FakePushServer.url,
    }) {
      final data = fx.server.createChallenge();
      data['url'] = url;
      data['display_code'] = code;
      data['signature'] = _rsaUtils.createBase32Signature(
        keys.privateKey,
        utf8.encode(
          '${data['nonce']}|$url|${data['serial']}|${data['question']}|${data['title']}|1|$code',
        ),
      );
      return data;
    }

    testWidgets(
      'a valid request is accepted but, unlike default and choice requests, does not re-add the url (INCONSISTENCY)',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final request = PushCodeToPhoneRequest.fromMessageData(
          codeToPhoneData(keys: fx.serverKeys),
        );

        expect(request.verifySignature(fx.legacyToken()), isTrue);

        // There is no override of verifySignature in PushCodeToPhoneRequest, so
        // a legacy token only gets its url back from a default or choice request.
        expect(notifier.updates, isEmpty);
      },
    );

    testWidgets(
      'a forged request is rejected and does not touch the token (safe because there is no override)',
      (tester) async {
        final notifier = await fx.mountApp(tester);
        final redirected = PushCodeToPhoneRequest.fromMessageData(
          codeToPhoneData(keys: fx.attackerKeys, url: evilUrl),
        );

        expect(redirected.uri, Uri.parse(evilUrl));
        expect(redirected.verifySignature(fx.legacyToken()), isFalse);

        expect(notifier.updates, isEmpty);
      },
    );
  });
}
