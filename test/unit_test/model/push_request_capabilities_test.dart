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
import 'package:privacyidea_authenticator/model/push_request/decline_reason.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/helpers/json_canonicalizer.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

void main() {
  const rsaUtils = RsaUtils();
  final serverKeyPair = _generateKeyPair();
  final token = PushToken(
    serial: 'PIPU0001',
    id: 'id',
  ).withPublicServerKey(serverKeyPair.publicKey);

  String sign(String message) => rsaUtils.createBase32Signature(
    serverKeyPair.privateKey,
    utf8.encode(message),
  );

  String signCapabilities(Object capabilities, String nonce) =>
      sign(canonicalizeJson({'capabilities': capabilities, 'nonce': nonce}));

  /// The message data of a challenge as it arrives from firebase.
  Map<String, dynamic> messageData({
    Map<String, Object>? capabilities,
    String? capabilitiesSignature,
  }) {
    final data = <String, dynamic>{
      PushRequest.TITLE: 'Login',
      PushRequest.QUESTION: 'Do you want to login?',
      PushRequest.URL: 'https://example.com/ttype/push',
      PushRequest.NONCE: 'nonce123',
      PushRequest.SSL_VERIFY: '1',
      PushRequest.SERIAL: token.serial,
      PushRequest.SIGNATURE: '',
    };
    if (capabilities != null) {
      data['capabilities'] = jsonEncode(capabilities);
      data['capabilities_signature'] =
          capabilitiesSignature ?? signCapabilities(capabilities, 'nonce123');
    }
    final request = PushRequestFactory.fromMessageData(data);
    return {...data, PushRequest.SIGNATURE: sign(request.signedData)};
  }

  PushRequest declined(Map<String, dynamic> data) =>
      PushRequestFactory.fromMessageData(data).dynamicCopyWith(
        accepted: () => false,
        declineReason: () => DeclineReason.cancelled,
      );

  group('Push request without advertised capabilities', () {
    test('is accepted and behaves the legacy way', () {
      final data = messageData();
      final request = PushRequestFactory.fromMessageData(data);

      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token).isEmpty, isTrue);
    });

    test('declines without a reason', () {
      final request = declined(messageData());

      expect(request.getResponseData(token), {
        'serial': token.serial,
        'nonce': 'nonce123',
        'decline': '1',
      });
      expect(
        request.getResponseSignMsg(token),
        'nonce123|${token.serial}|decline',
      );
    });
  });

  group('Push request with advertised capabilities', () {
    test('is accepted when the capabilities signature matches', () {
      final data = messageData(capabilities: {'decline_reason': true});
      final request = PushRequestFactory.fromMessageData(data);

      expect(request.verifySignature(token), isTrue);
      expect(request.capabilitiesOf(token).supports('decline_reason'), isTrue);
    });

    test('is rejected when the capabilities signature does not match', () {
      final data = messageData(
        capabilities: {'decline_reason': true},
        capabilitiesSignature: signCapabilities({
          'decline_reason': true,
        }, 'another_nonce'),
      );
      final request = PushRequestFactory.fromMessageData(data);

      expect(request.verifySignature(token), isFalse);
      expect(request.capabilitiesOf(token).isEmpty, isTrue);
    });

    test('declines with a reason when the server advertised the flag', () {
      final request = declined(
        messageData(capabilities: {'decline_reason': true}),
      );

      expect(request.getResponseData(token), {
        'serial': token.serial,
        'nonce': 'nonce123',
        'decline': '1',
        'decline_reason': 'cancelled',
      });
      expect(
        request.getResponseSignMsg(token),
        'nonce123|${token.serial}|decline|cancelled',
      );
    });

    test('declines with a reason the server accepts', () {
      final request = declined(
        messageData(
          capabilities: {
            'decline_reason': {
              'values': ['cancelled', 'unknown_trigger'],
            },
          },
        ),
      );

      expect(request.getResponseData(token)['decline_reason'], 'cancelled');
    });

    test('declines without a reason the server does not accept', () {
      final request = declined(
        messageData(
          capabilities: {
            'decline_reason': {
              'values': ['unknown_trigger'],
            },
          },
        ),
      );

      expect(
        request.getResponseData(token).containsKey('decline_reason'),
        isFalse,
      );
      expect(
        request.getResponseSignMsg(token),
        'nonce123|${token.serial}|decline',
      );
    });

    test('declines without a reason when another feature was advertised', () {
      final request = declined(
        messageData(capabilities: {'something_else': true}),
      );

      expect(
        request.getResponseData(token).containsKey('decline_reason'),
        isFalse,
      );
    });

    test('does not use capabilities whose signature does not verify', () {
      final request = declined(
        messageData(
          capabilities: {'decline_reason': true},
          capabilitiesSignature: signCapabilities({
            'decline_reason': true,
          }, 'another_nonce'),
        ),
      );

      expect(
        request.getResponseData(token).containsKey('decline_reason'),
        isFalse,
      );
    });

    test('survives being stored and restored', () {
      final request = declined(
        messageData(capabilities: {'decline_reason': true}),
      );

      final restored = PushRequest.fromJson(
        jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>,
      );

      expect(restored.getResponseData(token)['decline_reason'], 'cancelled');
    });
  });

  group('Capabilities the app cannot verify', () {
    test('do not invalidate the message data', () {
      // PushProvider validates every entry of a poll response with
      // verifyMessageData and drops the whole response if one throws.
      for (final unusable in [
        '["decline_reason"]',
        '{"decline_reason": 1}',
        'not json',
      ]) {
        expect(
          () => PushRequest.verifyMessageData({
            ...messageData(),
            'capabilities': unusable,
            'capabilities_signature': 'AAAA',
          }),
          returnsNormally,
          reason: unusable,
        );
      }
    });

    test('leave the challenge intact and fall back to legacy', () {
      final data = messageData();
      for (final unusable in [
        '{"decline_reason": true}', // signature stripped below
        '["decline_reason"]',
        '{"decline_reason": 1}',
        'not json',
      ]) {
        final request = PushRequestFactory.fromMessageData({
          ...data,
          'capabilities': unusable,
        });

        expect(request.verifySignature(token), isTrue);
        expect(request.capabilitiesOf(token).isEmpty, isTrue);
      }
    });

    test('a declined request is still answerable', () {
      final request = declined({
        ...messageData(),
        'capabilities': '{"decline_reason": 1}',
        'capabilities_signature': 'AAAA',
      });

      expect(
        request.getResponseData(token).containsKey('decline_reason'),
        isFalse,
      );
      expect(
        request.getResponseSignMsg(token),
        'nonce123|${token.serial}|decline',
      );
    });
  });
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateKeyPair() {
  final generator = RSAKeyGenerator()
    ..init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 1024, 64),
        secureRandom(),
      ),
    );
  final pair = generator.generateKeyPair();
  return AsymmetricKeyPair(pair.publicKey, pair.privateKey);
}
