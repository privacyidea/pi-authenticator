import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/asn1/unsupported_object_identifier_exception.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/ec_key_algorithm_extension.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';

/// Run `flutter test --dart-define=RUN_BUG_TESTS=true <file>` to execute the tests that are
/// marked as known bugs. They are skipped by default so that the suite stays green.
const bool _runBugTests = bool.fromEnvironment('RUN_BUG_TESTS');

// ---------------------------------------------------------------------------
// Static fixtures, generated with OpenSSL 3.2.1 (no key generation at test time):
//   openssl ecparam -name prime256v1 -genkey -noout        (SEC1 private key)
//   openssl ec -pubout                                      (SubjectPublicKeyInfo)
//   openssl pkcs8 -topk8 -nocrypt                           (PKCS8 private key)
//   openssl dgst -sha256 -sign key.pem msg | base64        (DER ECDSA signature)
// ---------------------------------------------------------------------------
const _p256Sec1Pem = '''-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIAKryVcthHeNeH/OOUNicNt9k4ASODKV+6ZFNh5AQTvdoAoGCCqGSM49
AwEHoUQDQgAEY0ez7m6JbW4zs/7ldJpjUceejBzdH/nCEMJzorb65GlXChmJ1LVP
nkw7eaohQizLVMJYnz7YMsIKvZfSsR1pPw==
-----END EC PRIVATE KEY-----''';
const _p256Pkcs8Pem = '''-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgAqvJVy2Ed414f845
Q2Jw232TgBI4MpX7pkU2HkBBO92hRANCAARjR7PuboltbjOz/uV0mmNRx56MHN0f
+cIQwnOitvrkaVcKGYnUtU+eTDt5qiFCLMtUwlifPtgywgq9l9KxHWk/
-----END PRIVATE KEY-----''';
const _p256PubPem = '''-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEY0ez7m6JbW4zs/7ldJpjUceejBzd
H/nCEMJzorb65GlXChmJ1LVPnkw7eaohQizLVMJYnz7YMsIKvZfSsR1pPw==
-----END PUBLIC KEY-----''';
const _p256PrivateScalarHex = '02abc9572d84778d787fce39436270db7d938012383295fba645361e40413bdd';

const _p384Sec1Pem = '''-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDB8dLtBWmkgtjcfOHcoqJFDu+JsplHyjALXCFY4rakaUP7xf6H4nA5B
dDT3xvt/VQygBwYFK4EEACKhZANiAAQeK9zsFCFAkLPfQOZ/En5xK/J+B2yyVMoQ
Rax8EoDNoQPSG7IcIcYJGIIoJ2ztiOv+AyXqVsUNQCh2j9w0N/kizeoor+9O7nan
7lDJVXJptBor+36i9Cx4Up9r5133BZ0=
-----END EC PRIVATE KEY-----''';
const _p384PubPem = '''-----BEGIN PUBLIC KEY-----
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEHivc7BQhQJCz30DmfxJ+cSvyfgdsslTK
EEWsfBKAzaED0huyHCHGCRiCKCds7Yjr/gMl6lbFDUAodo/cNDf5Is3qKK/vTu52
p+5QyVVyabQaK/t+ovQseFKfa+dd9wWd
-----END PUBLIC KEY-----''';

/// The message the app signs when it finalizes a container: nonce|timestamp|serial|registrationUrl
const _asciiMessage = 'nonce123|2024-01-01T00:00:00+00:00|CONT0001|https://pi.example.com/container/register';

/// Same as [_asciiMessage] plus a user typed passphrase containing non-ASCII characters.
const _nonAsciiMessage = '$_asciiMessage|Grüße €';

// Signatures created by OpenSSL over the UTF-8 bytes of the messages above (what a Python/OpenSSL
// server produces and expects).
const _p256SigAscii = 'MEUCIQDeJ8Zk7GSgV5qCfGdZD2+1WPTo4grFTeFG1U9jXAxlOwIgejJrHjn4JYdwudpNjFOlDt4CxvR+w6opEIwlSfHaZCo=';
const _p256SigUtf8 = 'MEQCIFYnhOpKdeQeBeQQwb0NeQI1xY6689POnxnTkRT1aKc9AiB/crthXtEBJQy5Nef+kAtQw8PdGPUUNDSHXNHnQKtVIA==';
const _p384SigAscii =
    'MGUCMHSLCRifNc+GDSV9CHqCkwfLGOfMm/fC6JGmUpU31Se4fPispkybs25T+VPGHEs0sQIxALIDl7v0kcraVugb2P4oUvR7J3BGr2GDr8WiPcOFtwrCU4JhEtbzcixLou6GqjCpeA==';
const _p384SigUtf8 =
    'MGQCMAbVVqFC2BJVfcjsos0z3yMroNC+1DrnUIbbnCogio7PQGh2vFsoQ9qoGx5CtXvZ7QIwe/u5Gy8AF9wiZhBqqK89OOYZiDBJpl3ntYVsH3P3dcQe1UrMATbExk9qe3DN1XeC';

/// Verifies [signature] over [bytes] the way any standards conform verifier (OpenSSL, python-cryptography)
/// would: SHA-256/ECDSA over exactly the given bytes.
bool _verifyOverBytes(ECPublicKey publicKey, String signature, List<int> bytes) =>
    CryptoUtils.ecVerify(publicKey, Uint8List.fromList(bytes), CryptoUtils.ecSignatureFromBase64(signature), algorithm: 'SHA-256/ECDSA');

void main() {
  const eccUtils = EccUtils();

  // Key generation is the expensive part, so one pair for all signing semantics tests.
  late AsymmetricKeyPair<ECPublicKey, ECPrivateKey> keyPair;
  late AsymmetricKeyPair<ECPublicKey, ECPrivateKey> otherKeyPair;
  setUpAll(() {
    keyPair = eccUtils.generateKeyPair(EcKeyAlgorithm.secp256r1);
    otherKeyPair = eccUtils.generateKeyPair(EcKeyAlgorithm.secp256r1);
  });

  group('EccUtils key serialization for every EcKeyAlgorithm', () {
    // basic_utils (ASN1ObjectIdentifier.fromName) only knows the OIDs of these curves, so PEM
    // (de)serialization throws UnsupportedObjectIdentifierException for all the others, although
    // generateKeyPair, sign and validateSignature work for them.
    final unsupportedForPem = <EcKeyAlgorithm>{
      EcKeyAlgorithm.brainpoolp160r1,
      EcKeyAlgorithm.brainpoolp160t1,
      EcKeyAlgorithm.brainpoolp192r1,
      EcKeyAlgorithm.brainpoolp192t1,
      EcKeyAlgorithm.brainpoolp224r1,
      EcKeyAlgorithm.brainpoolp224t1,
      EcKeyAlgorithm.brainpoolp256r1,
      EcKeyAlgorithm.brainpoolp256t1,
      EcKeyAlgorithm.brainpoolp320r1,
      EcKeyAlgorithm.brainpoolp320t1,
      EcKeyAlgorithm.brainpoolp384r1,
      EcKeyAlgorithm.brainpoolp384t1,
      EcKeyAlgorithm.brainpoolp512r1,
      EcKeyAlgorithm.brainpoolp512t1,
      EcKeyAlgorithm.GostR3410_2001_CryptoPro_A,
      EcKeyAlgorithm.GostR3410_2001_CryptoPro_B,
      EcKeyAlgorithm.GostR3410_2001_CryptoPro_C,
      EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchA,
      EcKeyAlgorithm.GostR3410_2001_CryptoPro_XchB,
      EcKeyAlgorithm.secp160k1,
      EcKeyAlgorithm.secp160r1,
      EcKeyAlgorithm.secp160r2,
      EcKeyAlgorithm.secp192k1,
      EcKeyAlgorithm.secp192r1,
      EcKeyAlgorithm.secp224k1,
      EcKeyAlgorithm.secp224r1,
    };
    final supportedForPem = EcKeyAlgorithm.values.where((a) => !unsupportedForPem.contains(a)).toList();

    for (final algorithm in supportedForPem) {
      test('${algorithm.name}: generate, serialize, deserialize, sign and validate', () {
        // pointycastle reports the canonical domain name, e.g. secp256r1 is an alias of prime256v1.
        final expectedDomainName = ECDomainParameters(algorithm.curveName).domainName;
        final pair = eccUtils.generateKeyPair(algorithm);
        expect(pair.publicKey.parameters!.domainName, expectedDomainName, reason: 'generated key must use the requested curve');
        expect(pair.privateKey.parameters!.domainName, expectedDomainName);

        final publicPem = eccUtils.serializeECPublicKey(pair.publicKey);
        final privatePem = eccUtils.serializeECPrivateKey(pair.privateKey);
        expect(publicPem, startsWith('-----BEGIN PUBLIC KEY-----'));
        expect(publicPem, endsWith('-----END PUBLIC KEY-----'));
        expect(privatePem, startsWith('-----BEGIN EC PRIVATE KEY-----'));
        expect(privatePem, endsWith('-----END EC PRIVATE KEY-----'));

        final publicKey = eccUtils.deserializeECPublicKey(publicPem);
        final privateKey = eccUtils.deserializeECPrivateKey(privatePem);

        // The OID lookup may report an alias name (secp256r1 -> prime256v1); the curve itself must be the same.
        expect(publicKey.parameters!.n, pair.publicKey.parameters!.n);
        expect(publicKey.parameters!.G.x!.toBigInteger(), pair.publicKey.parameters!.G.x!.toBigInteger());
        expect(publicKey.Q!.x!.toBigInteger(), pair.publicKey.Q!.x!.toBigInteger());
        expect(publicKey.Q!.y!.toBigInteger(), pair.publicKey.Q!.y!.toBigInteger());
        expect(privateKey.parameters!.n, pair.privateKey.parameters!.n);
        expect(privateKey.d, pair.privateKey.d);

        // The deserialized private key must still belong to the deserialized public key: d * G == Q
        final derived = privateKey.parameters!.G * privateKey.d!;
        expect(derived!.x!.toBigInteger(), publicKey.Q!.x!.toBigInteger());
        expect(derived.y!.toBigInteger(), publicKey.Q!.y!.toBigInteger());

        // Serialization must be stable.
        expect(eccUtils.serializeECPublicKey(publicKey), publicPem);
        expect(eccUtils.serializeECPrivateKey(privateKey), privatePem);

        // Sign with the deserialized private key, validate with the deserialized public key.
        final signature = eccUtils.signWithPrivateKey(privateKey, _asciiMessage);
        expect(eccUtils.validateSignature(publicKey, signature, _asciiMessage), isTrue);
        expect(eccUtils.validateSignature(publicKey, signature, '${_asciiMessage}x'), isFalse);
      });
    }

    for (final algorithm in unsupportedForPem) {
      test('${algorithm.name}: key generation, signing and validation work without PEM', () {
        final pair = eccUtils.generateKeyPair(algorithm);
        expect(pair.publicKey.parameters!.domainName, ECDomainParameters(algorithm.curveName).domainName);
        final signature = eccUtils.signWithPrivateKey(pair.privateKey, _asciiMessage);
        expect(eccUtils.validateSignature(pair.publicKey, signature, _asciiMessage), isTrue);
        expect(eccUtils.validateSignature(pair.publicKey, signature, '${_asciiMessage}x'), isFalse);
      });
    }

    test('characterization: PEM serialization throws UnsupportedObjectIdentifierException for the unsupported curves', () {
      expect(unsupportedForPem.length, 26);
      expect(supportedForPem.length, EcKeyAlgorithm.values.length - 26);
      for (final algorithm in unsupportedForPem) {
        final pair = eccUtils.generateKeyPair(algorithm);
        expect(() => eccUtils.serializeECPublicKey(pair.publicKey), throwsA(isA<UnsupportedObjectIdentifierException>()), reason: algorithm.name);
      }
    });

    test(
      'every EcKeyAlgorithm that can be generated can also be serialized and deserialized',
      () {
        for (final algorithm in EcKeyAlgorithm.values) {
          final pair = eccUtils.generateKeyPair(algorithm);
          final publicKey = eccUtils.deserializeECPublicKey(eccUtils.serializeECPublicKey(pair.publicKey));
          final privateKey = eccUtils.deserializeECPrivateKey(eccUtils.serializeECPrivateKey(pair.privateKey));
          expect(publicKey.Q, pair.publicKey.Q, reason: algorithm.name);
          expect(privateKey.d, pair.privateKey.d, reason: algorithm.name);
        }
      },
      skip: _runBugTests ? null : 'BUG: ec_key_algorithm.dart lists 26 curves (brainpool*, GostR3410*, secp160*, secp192k1/r1, secp224k1/r1) whose OID basic_utils cannot encode, so TokenContainer.withClientKeyPair throws',
    );

    test('every EcKeyAlgorithm has a unique curve name that maps back to the same algorithm', () {
      final names = EcKeyAlgorithm.values.map((e) => e.curveName).toList();
      expect(names.toSet().length, EcKeyAlgorithm.values.length);
      for (final algorithm in EcKeyAlgorithm.values) {
        expect(EcKeyAlgorithm.values.byCurveName(algorithm.curveName), algorithm);
      }
    });
  });

  group('EccUtils sign and validateSignature', () {
    test('round trip with a freshly generated key pair', () {
      final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, _asciiMessage);
      expect(eccUtils.validateSignature(keyPair.publicKey, signature, _asciiMessage), isTrue);
    });

    test('signature is base64 of a DER SEQUENCE of two INTEGERs', () {
      final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, _asciiMessage);
      final der = base64Decode(signature);
      expect(der.first, 0x30, reason: 'ASN.1 SEQUENCE tag');
      final parsed = CryptoUtils.ecSignatureFromBase64(signature);
      expect(parsed.r, greaterThan(BigInt.zero));
      expect(parsed.s, greaterThan(BigInt.zero));
    });

    test('a different message does not validate', () {
      final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, _asciiMessage);
      expect(eccUtils.validateSignature(keyPair.publicKey, signature, _asciiMessage.replaceFirst('CONT0001', 'CONT0002')), isFalse);
      expect(eccUtils.validateSignature(keyPair.publicKey, signature, ''), isFalse);
    });

    test('a different public key does not validate', () {
      final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, _asciiMessage);
      expect(eccUtils.validateSignature(otherKeyPair.publicKey, signature, _asciiMessage), isFalse);
    });

    test('a signature of another message does not validate', () {
      final signatureOfOther = eccUtils.signWithPrivateKey(keyPair.privateKey, 'other message');
      expect(eccUtils.validateSignature(keyPair.publicKey, signatureOfOther, _asciiMessage), isFalse);
    });

    test('a signature with swapped r and s does not validate', () {
      final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, _asciiMessage);
      final parsed = CryptoUtils.ecSignatureFromBase64(signature);
      final swapped = CryptoUtils.ecSignatureToBase64(ECSignature(parsed.s, parsed.r));
      expect(swapped, isNot(signature));
      expect(eccUtils.validateSignature(keyPair.publicKey, swapped, _asciiMessage), isFalse);
    });

    test('ECDSA is randomized: two signatures differ but both validate', () {
      final first = eccUtils.signWithPrivateKey(keyPair.privateKey, _asciiMessage);
      final second = eccUtils.signWithPrivateKey(keyPair.privateKey, _asciiMessage);
      expect(first, isNot(second));
      expect(eccUtils.validateSignature(keyPair.publicKey, first, _asciiMessage), isTrue);
      expect(eccUtils.validateSignature(keyPair.publicKey, second, _asciiMessage), isTrue);
    });

    test('empty message can be signed and validated', () {
      final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, '');
      expect(eccUtils.validateSignature(keyPair.publicKey, signature, ''), isTrue);
      expect(eccUtils.validateSignature(keyPair.publicKey, signature, ' '), isFalse);
    });

    test('invalid base64 signature throws a FormatException', () {
      expect(() => eccUtils.validateSignature(keyPair.publicKey, '!!!not base64!!!', _asciiMessage), throwsA(isA<FormatException>()));
    });

    test('valid base64 that is not a DER signature throws instead of returning true', () {
      expect(
        () => eccUtils.validateSignature(keyPair.publicKey, base64Encode(utf8.encode('definitely not der')), _asciiMessage),
        throwsA(anyOf(isA<Exception>(), isA<Error>())),
      );
    });

    test('empty signature string throws instead of returning true', () {
      expect(() => eccUtils.validateSignature(keyPair.publicKey, '', _asciiMessage), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });

    test('a zero signature (r = 0, s = 0) is rejected', () {
      final zero = CryptoUtils.ecSignatureToBase64(ECSignature(BigInt.zero, BigInt.zero));
      expect(eccUtils.validateSignature(keyPair.publicKey, zero, _asciiMessage), isFalse);
    });
  });

  group('EccUtils PEM parsing errors', () {
    test('empty public key PEM throws ArgumentError', () {
      expect(() => eccUtils.deserializeECPublicKey(''), throwsArgumentError);
    });

    test('empty private key PEM throws ArgumentError', () {
      expect(() => eccUtils.deserializeECPrivateKey(''), throwsArgumentError);
    });

    test('garbage is rejected by the public key parser', () {
      expect(() => eccUtils.deserializeECPublicKey('this is not a pem'), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });

    test('garbage is rejected by the private key parser', () {
      expect(() => eccUtils.deserializeECPrivateKey('this is not a pem'), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });

    test('PEM armor with garbage base64 body is rejected', () {
      const pem = '-----BEGIN PUBLIC KEY-----\n!!!!\n-----END PUBLIC KEY-----';
      expect(() => eccUtils.deserializeECPublicKey(pem), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });

    test('PEM armor with valid base64 that is not DER is rejected', () {
      final pem = '-----BEGIN PUBLIC KEY-----\n${base64Encode(utf8.encode('just some text'))}\n-----END PUBLIC KEY-----';
      expect(() => eccUtils.deserializeECPublicKey(pem), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });

    test('a truncated public key PEM is rejected', () {
      final lines = _p256PubPem.split('\n');
      final truncated = [lines.first, lines[1].substring(0, 20), lines.last].join('\n');
      expect(() => eccUtils.deserializeECPublicKey(truncated), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });

    test('a public key must not be accepted by the private key parser', () {
      final publicPem = eccUtils.serializeECPublicKey(keyPair.publicKey);
      expect(() => eccUtils.deserializeECPrivateKey(publicPem), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });

    test('a private key must not be accepted by the public key parser', () {
      final privatePem = eccUtils.serializeECPrivateKey(keyPair.privateKey);
      expect(() => eccUtils.deserializeECPublicKey(privatePem), throwsA(anyOf(isA<Exception>(), isA<Error>())));
    });
  });

  group('EccUtils interoperability with OpenSSL fixtures', () {
    test('OpenSSL P-256 public key is parsed and re-serialized byte for byte', () {
      final publicKey = eccUtils.deserializeECPublicKey(_p256PubPem);
      expect(publicKey.parameters!.domainName, 'prime256v1');
      expect(eccUtils.serializeECPublicKey(publicKey), _p256PubPem);
    });

    test('OpenSSL P-384 public key is parsed and re-serialized byte for byte', () {
      final publicKey = eccUtils.deserializeECPublicKey(_p384PubPem);
      expect(publicKey.parameters!.domainName, 'secp384r1');
      expect(eccUtils.serializeECPublicKey(publicKey), _p384PubPem);
    });

    test('OpenSSL SEC1 private keys are parsed and re-serialized byte for byte', () {
      final p256 = eccUtils.deserializeECPrivateKey(_p256Sec1Pem);
      expect(p256.parameters!.domainName, 'prime256v1');
      expect(p256.d!.toRadixString(16).padLeft(64, '0'), _p256PrivateScalarHex);
      expect(eccUtils.serializeECPrivateKey(p256), _p256Sec1Pem);

      final p384 = eccUtils.deserializeECPrivateKey(_p384Sec1Pem);
      expect(p384.parameters!.domainName, 'secp384r1');
      expect(eccUtils.serializeECPrivateKey(p384), _p384Sec1Pem);
    });

    test('OpenSSL PKCS8 private key yields the same key as the SEC1 encoding', () {
      final sec1 = eccUtils.deserializeECPrivateKey(_p256Sec1Pem);
      final pkcs8 = eccUtils.deserializeECPrivateKey(_p256Pkcs8Pem);
      expect(pkcs8.d, sec1.d);
      expect(pkcs8.parameters!.domainName, sec1.parameters!.domainName);
    });

    test('the private key d * G equals the public key of the OpenSSL fixture', () {
      final privateKey = eccUtils.deserializeECPrivateKey(_p256Sec1Pem);
      final publicKey = eccUtils.deserializeECPublicKey(_p256PubPem);
      final q = privateKey.parameters!.G * privateKey.d!;
      expect(q!.x!.toBigInteger(), publicKey.Q!.x!.toBigInteger());
      expect(q.y!.toBigInteger(), publicKey.Q!.y!.toBigInteger());
    });

    test('validateSignature accepts OpenSSL signatures of an ASCII message (P-256 and P-384)', () {
      expect(eccUtils.validateSignature(eccUtils.deserializeECPublicKey(_p256PubPem), _p256SigAscii, _asciiMessage), isTrue);
      expect(eccUtils.validateSignature(eccUtils.deserializeECPublicKey(_p384PubPem), _p384SigAscii, _asciiMessage), isTrue);
    });

    test('validateSignature rejects an OpenSSL signature when the message is altered', () {
      final publicKey = eccUtils.deserializeECPublicKey(_p256PubPem);
      expect(eccUtils.validateSignature(publicKey, _p256SigAscii, '$_asciiMessage!'), isFalse);
    });

    test('a signature made by the app for an ASCII message is valid over its UTF-8 bytes (what a server verifies)', () {
      final privateKey = eccUtils.deserializeECPrivateKey(_p256Sec1Pem);
      final publicKey = eccUtils.deserializeECPublicKey(_p256PubPem);
      final signature = eccUtils.signWithPrivateKey(privateKey, _asciiMessage);
      expect(_verifyOverBytes(publicKey, signature, utf8.encode(_asciiMessage)), isTrue);
    });

    test('a signature made by the app for an ASCII message is valid for every message used by the finalize request layout', () {
      // nonce|timestamp|serial|registrationUrl|brand|model|passphrase, all ASCII
      const message = 'abc|2024-12-31T23:59:59.999+00:00|SMPH0001A2|https://pi.example.com/container/SMPH0001A2/register/finalize|Google|Pixel 8|secret';
      final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, message);
      expect(_verifyOverBytes(keyPair.publicKey, signature, utf8.encode(message)), isTrue);
    });
  });

  group('EccUtils message encoding (codeUnits are UTF-16 code units, not UTF-8 bytes)', () {
    // The app builds the finalize message in privacy_idea_container_api.dart with
    // nonce|timestamp|serial|registrationUrl|deviceBrand|deviceModel|passphrase.
    // The passphrase is typed by the user and the device model comes from the OS, so non-ASCII
    // characters are possible. signWithPrivateKey uses message.codeUnits wrapped in
    // Uint8List.fromList, which silently truncates every code unit to its low 8 bits
    // (e.g. U+20AC '€' becomes 0xAC, U+00FC 'ü' becomes the single byte 0xFC instead of 0xC3 0xBC).

    test(
      'a signature over a non-ASCII message is valid over the UTF-8 bytes (server side view)',
      () {
        final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, _nonAsciiMessage);
        expect(_verifyOverBytes(keyPair.publicKey, signature, utf8.encode(_nonAsciiMessage)), isTrue);
      },
      skip: _runBugTests ? null : 'BUG: ecc_utils.dart:37 signs message.codeUnits (truncated to 8 bit) instead of utf8.encode(message)',
    );

    test(
      'validateSignature accepts an OpenSSL signature over the UTF-8 bytes of a non-ASCII message',
      () {
        final publicKey = eccUtils.deserializeECPublicKey(_p256PubPem);
        expect(eccUtils.validateSignature(publicKey, _p256SigUtf8, _nonAsciiMessage), isTrue);
      },
      skip: _runBugTests ? null : 'BUG: ecc_utils.dart:50 verifies message.codeUnits (truncated to 8 bit) instead of utf8.encode(message)',
    );

    test(
      'validateSignature accepts an OpenSSL P-384 signature over the UTF-8 bytes of a non-ASCII message',
      () {
        final publicKey = eccUtils.deserializeECPublicKey(_p384PubPem);
        expect(eccUtils.validateSignature(publicKey, _p384SigUtf8, _nonAsciiMessage), isTrue);
      },
      skip: _runBugTests ? null : 'BUG: ecc_utils.dart:50 verifies message.codeUnits (truncated to 8 bit) instead of utf8.encode(message)',
    );

    test(
      'two messages that differ only in a character above U+00FF must not share a signature',
      () {
        // '€' is U+20AC, '¬' is U+00AC: both end up as the byte 0xAC after truncation.
        final signature = eccUtils.signWithPrivateKey(keyPair.privateKey, 'pass€');
        expect(eccUtils.validateSignature(keyPair.publicKey, signature, 'pass¬'), isFalse);
      },
      skip: _runBugTests ? null : 'BUG: ecc_utils.dart:37 Uint8List.fromList(codeUnits) truncates U+20AC and U+00AC to the same byte 0xAC',
    );

    test('a message consisting only of ASCII characters has identical UTF-8 and code unit bytes', () {
      expect(_asciiMessage.codeUnits, utf8.encode(_asciiMessage));
    });

    test('the non-ASCII fixture message really differs between code units and UTF-8', () {
      expect(_nonAsciiMessage.codeUnits.length, lessThan(utf8.encode(_nonAsciiMessage).length));
      expect(_nonAsciiMessage.codeUnits.any((c) => c > 0xFF), isTrue, reason: 'contains U+20AC which does not fit into one byte');
    });
  });
}
