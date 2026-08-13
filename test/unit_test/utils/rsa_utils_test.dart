import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/model/enums/biometric_push_key_status.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/biometric_push_key_manager.dart';
import 'package:privacyidea_authenticator/utils/helpers/base32_helper.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

void main() {
  _testSerializingRSAKeys();
  _testBiometricPushKeyProtection();
}

void _testBiometricPushKeyProtection() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test_biometric_push_key');
  const manager = BiometricPushKeyManager(
    channel: channel,
    supportedPlatformOverride: true,
  );
  const rsaUtils = RsaUtils(biometricPushKeyManager: manager);

  PushToken token() => PushToken(
    serial: 'PIPU0001',
    id: 'push-1',
    forceBiometricOption: ForceBiometricOption.biometric,
    privateTokenKey: 'legacy-private-key',
  );

  group('biometric Push key protection', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'passes the legacy private key to native biometric protection',
      () async {
        MethodCall? received;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              received = call;
              return null;
            });

        await rsaUtils.protectBiometricPushKey(token());

        expect(received?.method, 'protect');
        expect(received?.arguments['privateKey'], 'legacy-private-key');
        expect(received?.arguments['invalidateOnBiometricChange'], isTrue);
      },
    );

    test('persists migration before returning a biometric signature', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'sign');
            expect(call.arguments['invalidateOnBiometricChange'], isTrue);
            return {
              'signature': base64.encode([1, 2, 3, 4]),
              'protectedNow': true,
            };
          });
      PushToken? persisted;

      final signature = await rsaUtils.trySignWithToken(
        token(),
        'message',
        onTokenChanged: (updated) async {
          persisted = updated;
          return true;
        },
      );

      expect(signature, base32Encode(Uint8List.fromList([1, 2, 3, 4])));
      expect(persisted?.privateTokenKey, isNull);
      expect(persisted?.biometricKeyStatus, BiometricPushKeyStatus.protected);
    });

    test('marks the token invalid when Android invalidates the key', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(
              code: BiometricPushKeyManager.invalidatedCode,
            );
          });
      final protectedToken = token().copyWith(
        privateTokenKey: () => null,
        biometricKeyStatus: BiometricPushKeyStatus.protected,
      );
      PushToken? persisted;

      await expectLater(
        rsaUtils.trySignWithToken(
          protectedToken,
          'message',
          onTokenChanged: (updated) async {
            persisted = updated;
            return true;
          },
        ),
        throwsA(
          isA<BiometricPushKeyException>().having(
            (error) => error.isInvalidated,
            'isInvalidated',
            isTrue,
          ),
        ),
      );

      expect(persisted?.privateTokenKey, isNull);
      expect(persisted?.biometricKeyStatus, BiometricPushKeyStatus.invalidated);
    });

    test(
      'repairs Dart state when native protection survived an interrupted migration',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              expect(call.method, 'sign');
              return {
                'signature': base64.encode([5, 6, 7, 8]),
                'protectedNow': false,
              };
            });
        PushToken? persisted;

        final signature = await rsaUtils.trySignWithToken(
          token(),
          'message',
          onTokenChanged: (updated) async {
            persisted = updated;
            return true;
          },
        );

        expect(signature, base32Encode(Uint8List.fromList([5, 6, 7, 8])));
        expect(persisted?.privateTokenKey, isNull);
        expect(persisted?.biometricKeyStatus, BiometricPushKeyStatus.protected);
      },
    );

    test(
      'does not return a signature until migration state is durable',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              channel,
              (call) async => {
                'signature': base64.encode([1, 2, 3, 4]),
                'protectedNow': true,
              },
            );

        await expectLater(
          rsaUtils.trySignWithToken(
            token(),
            'message',
            onTokenChanged: (_) async => false,
          ),
          throwsA(
            isA<BiometricPushKeyException>().having(
              (error) => error.isStateNotPersisted,
              'isStateNotPersisted',
              isTrue,
            ),
          ),
        );
      },
    );

    test(
      'fails closed when native strong-biometric protection is unavailable',
      () async {
        const unsupported = RsaUtils(
          biometricPushKeyManager: BiometricPushKeyManager(
            supportedPlatformOverride: false,
          ),
        );

        await expectLater(
          unsupported.trySignWithToken(token(), 'message'),
          throwsA(
            isA<BiometricPushKeyException>().having(
              (error) => error.code,
              'code',
              BiometricPushKeyManager.unsupportedCode,
            ),
          ),
        );
        await expectLater(
          unsupported.protectBiometricPushKey(token()),
          throwsA(isA<BiometricPushKeyException>()),
        );
      },
    );
  });
}

void _testSerializingRSAKeys() {
  group('PKCS#1 format', () {
    const rsaUtils = RsaUtils();
    test('Converting key', () async {
      RSAPublicKey publicKey = RSAPublicKey(
        BigInt.from(431254),
        BigInt.from(32545),
      );

      String base64String = rsaUtils.serializeRSAPublicKeyPKCS1(publicKey);
      RSAPublicKey convertedKey = rsaUtils.deserializeRSAPublicKeyPKCS1(
        base64String,
      );

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Converting generated key', () async {
      var asymmetricKeyPair = await rsaUtils.generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;

      String base64String = rsaUtils.serializeRSAPublicKeyPKCS1(publicKey);
      RSAPublicKey convertedKey = rsaUtils.deserializeRSAPublicKeyPKCS1(
        base64String,
      );

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Parsing existing key', () async {
      String serializedPublicKey =
          'MIICCgKCAgEAtOE6hDrwB+9Quk5Ibp9DduUMAmQ'
          'i3KSn4pSZPrj4vhx9COenh+K6NtWFDwSPZcEOMk/s7GXsgAzdQvUVp4KpmBSAL3C'
          'XgwZrhG4DZWRvXhB4P0Toxz1McVnPvabriWqU1L3Jorca1bnlvaaYh9rywbBrxes'
          'IA4VUmfFoWHpn+HMdYp4g2UG1UeBIqBsgI4syPiwlEDW6sWTeSDcvQWTYGBsHMXf'
          'zqNGT6ONo5mTSGqI7F75+KtJdtWfNxOKC9pKXXDG8UlgkkhWu0N6sCu/1PEsDxrc'
          'pW7sKKrrB37J8jbEIOHzg67LgCWqFQMoBmIVRHlzQb5HKIswP10AmjJ7Mks0H1db'
          'jK0/ONnU4A9QzjM0ZQt3mvCe8gE0FwQa7CYv8o1OKItQaxPhqBvcLJqjjXc8iFwJ'
          'Qx5XsFU9jMJskQo+2pBBdW7oGRNqdyX0Zx36OQ48OaqbTciNT7oVQrIPd0oIiHjD'
          'LnwBvwn3y5HmvmczdFAs2gQSryJ2/tS/zxrT/OjcGK4JQGDzbjog4fz7kox0PnGg'
          'ssLfoonhflfpM5Om3vGePeqNnISTbA/yCH7X07dZf2BT5/41/OKzNjGzShFNwifb'
          'WBf1mlwUNh1Vuu+ZGdTQKisxI4G8k2dZrlTWkQqOmLebCE3L38jnh0Oek+Jl9fNm'
          'TcMl8sPWxB8lgGpUCAwEAAQ==';

      expect(
        rsaUtils.serializeRSAPublicKeyPKCS1(
          rsaUtils.deserializeRSAPublicKeyPKCS1(serializedPublicKey),
        ),
        serializedPublicKey,
      );
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  group('PKCS#8 format', () {
    const rsaUtils = RsaUtils();
    test('Converting key', () async {
      RSAPublicKey publicKey = RSAPublicKey(
        BigInt.from(431254),
        BigInt.from(32545),
      );

      String base64String = rsaUtils.serializeRSAPublicKeyPKCS8(publicKey);
      RSAPublicKey convertedKey = rsaUtils.deserializeRSAPublicKeyPKCS8(
        base64String,
      );

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Converting generated key', () async {
      var asymmetricKeyPair = await rsaUtils.generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;

      String base64String = rsaUtils.serializeRSAPublicKeyPKCS8(publicKey);
      RSAPublicKey convertedKey = rsaUtils.deserializeRSAPublicKeyPKCS8(
        base64String,
      );

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Parse existing key', () async {
      String serializedPublicKey =
          'MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCA'
          'gEAwdxugfnlsrd3rwZsEvI8GzEF4BtGEK3+vXRWVv43Z0Itn9NAtN5TWYgUkI/1RdI'
          'ahWSZ8xM8vqza3Vb6SzI/vzw4O22TvFwNGDQcwIpxf/I0Iow+U/0uA0VFH2nPdyeJw'
          'eNjEFaPkIZEHSyJ0CUtNS2umXpx4IyUN2R9Xve4OddbUpfTFPDYdcOiqPn1IkVLan/'
          't1fyEggabsk0Mdig+lK6JEd3keU1o9cOyHeiplOrmS5mNLV2Alz6Es+gvbvsMkXKvJ'
          'rZ3+f8eVvRMNUgS/UfgIgPflUvUgxhlDCmCs/brZeZMhrUbWN00URdrfRT3xdSmNUV'
          '10LPryk/l9quG8Phn8MKE1cKEEGWcBkuvF0v/f9DqMh6hsXea86oA//bYZM8Nb+mut'
          'EjXSAi5AJxfryci0MGbL5jZaO8a2yfx41f84forxMReBCATDQIzSagMK9Ixln/h/U2'
          'KZarenD6rB1rAd0pQLjXa9GMdfBJdImW3LYNpDaPuV/MPQOGRa851gCTf9Ha7rZl67'
          'ekTgwlEAskZOp6NQz8ZdCl4oc7gaTGjFttBmH1TZtKtkpuvhqXv3Ige6XCzBH40+HC'
          'nuwUCqJvPlKJHd/ikm2OfQS+BsPH8HDvrQGQyHyzBzV20oRfNGPIXVOXc9AEIJAPxB'
          'QYQE2aoTR+l7N4On4x59z8qU1UCAwEAAQ==';

      expect(
        rsaUtils.serializeRSAPublicKeyPKCS8(
          rsaUtils.deserializeRSAPublicKeyPKCS8(serializedPublicKey),
        ),
        serializedPublicKey,
      );
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  group('Serialize RSA private keys', () {
    const rsaUtils = RsaUtils();
    test(
      'writes standard PKCS#1 and reads the legacy duplicate exponent shape',
      () async {
        RSAPrivateKey privateKey =
            (await rsaUtils.generateRSAKeyPair()).privateKey;
        String base64String = rsaUtils.serializeRSAPrivateKeyPKCS1(privateKey);
        final standardSequence =
            ASN1Parser(base64.decode(base64String)).nextObject()
                as ASN1Sequence;

        expect(
          (standardSequence.elements[2] as ASN1Integer).valueAsBigInteger,
          privateKey.publicExponent,
        );
        expect(
          (standardSequence.elements[3] as ASN1Integer).valueAsBigInteger,
          privateKey.privateExponent,
        );

        final convertedKey = rsaUtils.deserializeRSAPrivateKeyPKCS1(
          base64String,
        );
        expect(privateKey.modulus, convertedKey.modulus);
        expect(privateKey.privateExponent, convertedKey.privateExponent);
        expect(privateKey.publicExponent, convertedKey.publicExponent);
        expect(privateKey.p, convertedKey.p);
        expect(privateKey.q, convertedKey.q);

        final legacySequence = ASN1Sequence()
          ..add(ASN1Integer.fromInt(0))
          ..add(ASN1Integer(privateKey.modulus!))
          ..add(ASN1Integer(privateKey.privateExponent!))
          ..add(ASN1Integer(privateKey.privateExponent!))
          ..add(ASN1Integer(privateKey.p!))
          ..add(ASN1Integer(privateKey.q!))
          ..add(
            ASN1Integer(
              privateKey.privateExponent! % (privateKey.p! - BigInt.one),
            ),
          )
          ..add(
            ASN1Integer(
              privateKey.privateExponent! % (privateKey.q! - BigInt.one),
            ),
          )
          ..add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));
        final recovered = rsaUtils.deserializeRSAPrivateKeyPKCS1(
          base64.encode(legacySequence.encodedBytes),
        );

        expect(recovered.privateExponent, privateKey.privateExponent);
        expect(recovered.publicExponent, privateKey.publicExponent);
        final message = utf8.encode('legacy compatibility');
        expect(
          rsaUtils.verifyRSASignature(
            RSAPublicKey(privateKey.modulus!, privateKey.publicExponent!),
            message,
            rsaUtils.createRSASignature(recovered, message),
          ),
          isTrue,
        );
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );
  });

  group('RSA signing and verifying', () {
    const rsaUtils = RsaUtils();
    test('Signature is valid', () async {
      var asymmetricKeyPair = await rsaUtils.generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;
      RSAPrivateKey privateKey = asymmetricKeyPair.privateKey;

      String message = 'I am a signature.';

      var signature = rsaUtils.createRSASignature(
        privateKey,
        utf8.encode(message),
      );

      expect(
        true,
        rsaUtils.verifyRSASignature(publicKey, utf8.encode(message), signature),
      );
    }, timeout: const Timeout(Duration(minutes: 5)));

    test('Signature is invalid', () async {
      var asymmetricKeyPair = await rsaUtils.generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;
      RSAPrivateKey privateKey = asymmetricKeyPair.privateKey;

      String message = 'I am a signature.';

      var signature = rsaUtils.createRSASignature(
        privateKey,
        utf8.encode(message),
      );

      expect(
        false,
        rsaUtils.verifyRSASignature(
          publicKey,
          utf8.encode('I am not the signature you are looking for.'),
          signature,
        ),
      );
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}
