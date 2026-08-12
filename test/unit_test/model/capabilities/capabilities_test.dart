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
import 'package:privacyidea_authenticator/model/capabilities/capabilities.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/helpers/json_canonicalizer.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

void main() {
  _testCapabilities();
  _testSignedCapabilities();
}

void _testCapabilities() {
  group('Capabilities', () {
    test('supports only what is advertised', () {
      final capabilities = Capabilities.declared({
        'flag': true,
        'descriptor': Capabilities.accepting(['a', 'b']),
        'disabled': false,
      });

      expect(capabilities.supports('flag'), isTrue);
      expect(capabilities.supports('descriptor'), isTrue);
      expect(capabilities.supports('disabled'), isFalse);
      expect(capabilities.supports('never_heard_of_it'), isFalse);
      expect(Capabilities.none.supports('flag'), isFalse);
      expect(Capabilities.none.isEmpty, isTrue);
    });

    test('a flag does not restrict its values, a descriptor does', () {
      final capabilities = Capabilities.declared({
        'flag': true,
        'descriptor': Capabilities.accepting(['a', 'b']),
      });

      expect(capabilities.allowedValues('flag'), isNull);
      expect(capabilities.allowedValues('descriptor'), {'a', 'b'});
      expect(capabilities.allowedValues('never_heard_of_it'), isNull);
    });

    test('negotiate keeps what both sides advertise', () {
      final server = Capabilities.declared({'a': true, 'b': true});
      final app = Capabilities.declared({'b': true, 'c': true});

      final negotiated = server.negotiate(app);

      expect(negotiated.supports('a'), isFalse);
      expect(negotiated.supports('b'), isTrue);
      expect(negotiated.supports('c'), isFalse);
    });

    test('negotiate intersects the values both sides accept', () {
      final server = Capabilities.declared({
        'reason': Capabilities.accepting(['cancelled', 'timeout']),
      });
      final app = Capabilities.declared({
        'reason': Capabilities.accepting(['unknown_trigger', 'cancelled']),
      });

      expect(server.negotiate(app).allowedValues('reason'), {'cancelled'});
    });

    test('negotiate drops a feature whose values do not overlap', () {
      final server = Capabilities.declared({
        'reason': Capabilities.accepting(['timeout']),
      });
      final app = Capabilities.declared({
        'reason': Capabilities.accepting(['cancelled']),
      });

      expect(server.negotiate(app).supports('reason'), isFalse);
    });

    test('negotiate takes the values of the side that names them', () {
      final server = Capabilities.declared({'reason': true});
      final app = Capabilities.declared({
        'reason': Capabilities.accepting(['cancelled']),
      });

      expect(server.negotiate(app).allowedValues('reason'), {'cancelled'});
      expect(app.negotiate(server).allowedValues('reason'), {'cancelled'});
    });

    test('negotiating against nothing advertised leaves nothing usable', () {
      final app = Capabilities.declared({'reason': true});

      expect(Capabilities.none.negotiate(app).isEmpty, isTrue);
      expect(app.negotiate(Capabilities.none).isEmpty, isTrue);
    });

    test('rejects values the canonical form cannot represent', () {
      expect(() => Capabilities.declared({'a': 1}), throwsFormatException);
      expect(
        () => Capabilities.declared({
          'a': {'values': 1},
        }),
        throwsFormatException,
      );
    });

    test('names lists what is advertised, without the descriptors', () {
      final capabilities = Capabilities.declared({
        'flag': true,
        'descriptor': Capabilities.accepting(['a']),
        'disabled': false,
      });

      expect(capabilities.names, ['flag', 'descriptor']);
      expect(canonicalizeJson(capabilities.names), '["flag","descriptor"]');
      expect(Capabilities.none.names, isEmpty);
    });

    test('canonical json is the form that gets signed', () {
      expect(
        Capabilities.declared({'decline_reason': true}).toCanonicalJson(),
        '{"decline_reason":true}',
      );
      expect(
        Capabilities.declared({
          'decline_reason': Capabilities.accepting([
            'cancelled',
            'unknown_trigger',
          ]),
        }).toCanonicalJson(),
        '{"decline_reason":{"values":["cancelled","unknown_trigger"]}}',
      );
    });

    test('equality does not depend on the order of the entries', () {
      expect(
        Capabilities.declared({'a': true, 'b': false}),
        Capabilities.declared({'b': false, 'a': true}),
      );
      expect(
        Capabilities.declared({'a': true}),
        isNot(Capabilities.declared({'a': false})),
      );
    });
  });
}

void _testSignedCapabilities() {
  group('SignedCapabilities', () {
    const rsaUtils = RsaUtils();
    final keyPair = _generateKeyPair();
    final otherKeyPair = _generateKeyPair();

    String signCapabilities(String capabilities, String nonce) =>
        rsaUtils.createBase32Signature(
          keyPair.privateKey,
          utf8.encode(
            canonicalizeJson({
              'capabilities': jsonDecode(capabilities),
              'nonce': nonce,
            }),
          ),
        );

    test('a message without capabilities carries none', () {
      expect(SignedCapabilities.fromMessageData({'nonce': 'N'}), isNull);
    });

    test('reads capabilities sent as a json string', () {
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': '{"decline_reason": true}',
        'capabilities_signature': 'AAAA',
      });

      expect(signed, isNotNull);
      expect(signed!.toJson()['capabilities'], {'decline_reason': true});
    });

    test('reads capabilities sent as a json object', () {
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': <String, dynamic>{'decline_reason': true},
        'capabilities_signature': 'AAAA',
      });

      expect(signed, isNotNull);
      expect(signed!.toJson()['capabilities'], {'decline_reason': true});
    });

    test('drops capabilities without a signature', () {
      expect(
        SignedCapabilities.fromMessageData({
          'capabilities': '{"decline_reason": true}',
        }),
        isNull,
      );
    });

    test('drops capabilities in a shape it cannot represent', () {
      const unusable = [
        'not json',
        '["decline_reason"]',
        '"decline_reason"',
        '3',
        '{"decline_reason": 1}',
        '{"decline_reason": null}',
        '{"decline_reason": {"values": [1]}}',
        '{"decline_reason": {"values": {"a": 1.5}}}',
      ];
      for (final capabilities in unusable) {
        expect(
          SignedCapabilities.fromMessageData({
            'capabilities': capabilities,
            'capabilities_signature': 'AAAA',
          }),
          isNull,
          reason: 'should have dropped $capabilities',
        );
      }
    });

    test('drops capabilities that are neither a string nor an object', () {
      expect(
        SignedCapabilities.fromMessageData({
          'capabilities': ['decline_reason'],
          'capabilities_signature': 'AAAA',
        }),
        isNull,
      );
      expect(
        SignedCapabilities.fromMessageData({
          'capabilities': 3,
          'capabilities_signature': 'AAAA',
        }),
        isNull,
      );
    });

    test('verifies a signature made for these capabilities and nonce', () {
      const capabilities = '{"decline_reason": true}';
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': capabilities,
        'capabilities_signature': signCapabilities(capabilities, 'ABC123'),
      })!;

      final verified = signed.verify(
        publicKey: keyPair.publicKey,
        nonce: 'ABC123',
      );

      expect(verified, isNotNull);
      expect(verified!.supports('decline_reason'), isTrue);
    });

    test('does not verify a signature made for another nonce', () {
      const capabilities = '{"decline_reason": true}';
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': capabilities,
        'capabilities_signature': signCapabilities(capabilities, 'ABC123'),
      })!;

      expect(
        signed.verify(publicKey: keyPair.publicKey, nonce: 'OTHER'),
        isNull,
      );
    });

    test('does not verify tampered capabilities', () {
      final signature = signCapabilities('{"decline_reason": true}', 'ABC123');
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': '{"decline_reason": true, "sneaky": true}',
        'capabilities_signature': signature,
      })!;

      expect(
        signed.verify(publicKey: keyPair.publicKey, nonce: 'ABC123'),
        isNull,
      );
    });

    test('does not verify against another server key', () {
      const capabilities = '{"decline_reason": true}';
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': capabilities,
        'capabilities_signature': signCapabilities(capabilities, 'ABC123'),
      })!;

      expect(
        signed.verify(publicKey: otherKeyPair.publicKey, nonce: 'ABC123'),
        isNull,
      );
    });

    test('does not verify a signature that is not base32', () {
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': '{"decline_reason": true}',
        'capabilities_signature': 'not base32!',
      })!;

      expect(
        signed.verify(publicKey: keyPair.publicKey, nonce: 'ABC123'),
        isNull,
      );
    });

    test('survives being stored and restored', () {
      const capabilities = '{"decline_reason": true}';
      final signature = signCapabilities(capabilities, 'ABC123');
      final signed = SignedCapabilities.fromMessageData({
        'capabilities': capabilities,
        'capabilities_signature': signature,
      })!;

      final restored = SignedCapabilities.fromJson(signed.toJson());

      expect(restored, signed);
      expect(
        restored.verify(publicKey: keyPair.publicKey, nonce: 'ABC123'),
        isNotNull,
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
