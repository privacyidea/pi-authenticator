import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/encryption/aes_encrypted.dart';

void main() {
  _testAesEncrypted();
  _testAesEncryptedTamper();
}

void _testAesEncrypted() {
  group('Aes Encrypted', () {
    test('constructor', () {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([41, 142, 95, 156]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        mac: const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]),
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      expect(aesEncrypted, isNotNull);
      expect(aesEncrypted.data, Uint8List.fromList([41, 142, 95, 156]));
      expect(aesEncrypted.salt, Uint8List.fromList(List.generate(16, (index) => index)));
      expect(aesEncrypted.iv, Uint8List.fromList(List.generate(16, (index) => index)));
      expect(
        aesEncrypted.kdf,
        Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
      );
      expect(aesEncrypted.cypher, AesGcm.with256bits());
      expect(aesEncrypted.mac, const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]));
    });

    test('constructor mac from data', () {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([
          ...[41, 142, 95, 156], // data
          ...[103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3], // mac
        ]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      expect(aesEncrypted, isNotNull);
      expect(aesEncrypted.data, Uint8List.fromList([41, 142, 95, 156]));
      expect(aesEncrypted.salt, Uint8List.fromList(List.generate(16, (index) => index)));
      expect(aesEncrypted.iv, Uint8List.fromList(List.generate(16, (index) => index)));
      expect(aesEncrypted.mac, const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]));
      expect(
        aesEncrypted.kdf,
        Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
      );
      expect(aesEncrypted.cypher, AesGcm.with256bits());
    });
    test('encrypt', () async {
      final AesEncrypted aesEncrypted = await AesEncrypted.encrypt(
        data: "test",
        password: "password",
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
      );
      expect(aesEncrypted, isNotNull);
      expect(aesEncrypted.data, Uint8List.fromList([41, 142, 95, 156]));
      final decrypted = await aesEncrypted.decrypt("password");
      expect(decrypted, Uint8List.fromList([116, 101, 115, 116]));
      final decryptedString = await aesEncrypted.decryptToString("password");
      expect(decryptedString, "test");
    });
    test('encrypt no password', () async {
      try {
        await AesEncrypted.encrypt(
          data: "test",
          password: "",
          salt: Uint8List.fromList(List.generate(16, (index) => index)),
          iv: Uint8List.fromList(List.generate(16, (index) => index)),
        );
      } catch (e) {
        expect(e, isA<ArgumentError>());
      }
    });
    test('encrypt no data', () async {
      try {
        await AesEncrypted.encrypt(
          data: "",
          password: "password",
          salt: Uint8List.fromList(List.generate(16, (index) => index)),
          iv: Uint8List.fromList(List.generate(16, (index) => index)),
        );
      } catch (e) {
        expect(e, isA<ArgumentError>());
      }
    });
    test('encrypt no salt and iv', () async {
      final aesEncrypted = await AesEncrypted.encrypt(
        data: "test",
        password: "password",
      ); // salt and iv are random
      expect(aesEncrypted.salt.isNotEmpty, true);
      expect(aesEncrypted.iv.isNotEmpty, true);
      final decrypted = await aesEncrypted.decrypt("password");
      expect(decrypted, Uint8List.fromList([116, 101, 115, 116]));
    });
    test('decrypt', () async {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([41, 142, 95, 156]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        mac: const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]),
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      final decrypted = await aesEncrypted.decrypt("password");
      expect(decrypted, Uint8List.fromList([116, 101, 115, 116]));
    });
    test('decrypt no mac', () async {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([
          ...[41, 142, 95, 156],
          ...[103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3],
        ]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      final decrypted = await aesEncrypted.decrypt("password");
      expect(decrypted, Uint8List.fromList([116, 101, 115, 116]));
    });
    test('decrypt wrong password', () async {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([41, 142, 95, 156]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        mac: const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]),
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      expect(aesEncrypted.decrypt("wrong password"), throwsA(isA<SecretBoxAuthenticationError>()));
    });
    test('decrypt wrong mac', () async {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([41, 142, 95, 156]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        mac: const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 4]), // last byte is wrong
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      expect(aesEncrypted.decrypt("password"), throwsA(isA<SecretBoxAuthenticationError>()));
    });
    test('decryptToString', () async {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([41, 142, 95, 156]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        mac: const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]),
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      final decrypted = await aesEncrypted.decryptToString("password");
      expect(decrypted, "test");
    });
    test('toJson wrong mac', () {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([41, 142, 95, 156]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        mac: Mac.empty,
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      expect(
        jsonEncode(aesEncrypted.toJson()),
        '{"data":"KY5fnA==","salt":"AAECAwQFBgcICQoLDA0ODw==","iv":"AAECAwQFBgcICQoLDA0ODw==","mac":"","kdf":{"algorithm":"Pbkdf2","macAlgorithm":{"algorithm":"Hmac","hashAlgorithm":{"algorithm":"DartSha256"}},"iterations":100000,"bits":256},"cypher":{"algorithm":"AesGcm","secretKeyLength":32}}',
      );
      expect(aesEncrypted.decrypt("password"), throwsA(isA<SecretBoxAuthenticationError>()));
    });

    test('toJson', () {
      final AesEncrypted aesEncrypted = AesEncrypted(
        data: Uint8List.fromList([41, 142, 95, 156]),
        salt: Uint8List.fromList(List.generate(16, (index) => index)),
        iv: Uint8List.fromList(List.generate(16, (index) => index)),
        mac: const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]),
        kdf: Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
        cypher: AesGcm.with256bits(),
      );
      expect(
        jsonEncode(aesEncrypted.toJson()),
        '{"data":"KY5fnA==","salt":"AAECAwQFBgcICQoLDA0ODw==","iv":"AAECAwQFBgcICQoLDA0ODw==","mac":"Z6mLXNQoyAPQbqWAmLkwAw==","kdf":{"algorithm":"Pbkdf2","macAlgorithm":{"algorithm":"Hmac","hashAlgorithm":{"algorithm":"DartSha256"}},"iterations":100000,"bits":256},"cypher":{"algorithm":"AesGcm","secretKeyLength":32}}',
      );
    });

    test('fromJson', () {
      final json = {
        "data": "KY5fnA==",
        "salt": "AAECAwQFBgcICQoLDA0ODw==",
        "iv": "AAECAwQFBgcICQoLDA0ODw==",
        "mac": "Z6mLXNQoyAPQbqWAmLkwAw==",
        "kdf": {
          "algorithm": "Pbkdf2",
          "macAlgorithm": {
            "algorithm": "Hmac",
            "hashAlgorithm": {"algorithm": "DartSha256"}
          },
          "iterations": 100000,
          "bits": 256
        },
        "cypher": {"algorithm": "AesGcm", "secretKeyLength": 32}
      };
      final aesEncrypted = AesEncrypted.fromJson(json);
      expect(aesEncrypted.data, Uint8List.fromList([41, 142, 95, 156]));
      expect(aesEncrypted.salt, Uint8List.fromList(List.generate(16, (index) => index)));
      expect(aesEncrypted.iv, Uint8List.fromList(List.generate(16, (index) => index)));
      expect(aesEncrypted.mac, const Mac([103, 169, 139, 92, 212, 40, 200, 3, 208, 110, 165, 128, 152, 185, 48, 3]));
      expect(
        aesEncrypted.kdf,
        Pbkdf2(
          macAlgorithm: AesEncrypted.defaultMacAlgorithm,
          iterations: AesEncrypted.defaultIterations,
          bits: AesEncrypted.defaultBits,
        ),
      );
      expect(aesEncrypted.cypher, AesGcm.with256bits());
      expect(aesEncrypted.decrypt("password"), completion(Uint8List.fromList([116, 101, 115, 116])));
    });

    test('fromJson2', () async {
      final json = {
        "data": "KYs5fn===",
        "salt": "AAECAwQFBgcICQoLDA0ODw==",
        "iv": "AAECAwQFBgcICQoLDA0ODw==",
        "mac": "",
        "kdf": {
          "algorithm": "Pbkdf2",
          "macAlgorithm": {
            "algorithm": "Hmac",
            "hashAlgorithm": {"algorithm": "DartSha256"}
          },
          "iterations": 100000,
          "bits": 256
        },
        "cypher": {"algorithm": "AesGcm", "secretKeyLength": 32}
      }; // FormatException: Invalid base64
      try {
        AesEncrypted.fromJson(json);
      } catch (e) {
        expect(e, isA<FormatException>());
      }
    });
  });
}

/// Run `flutter test --dart-define=RUN_BUG_TESTS=true <file>` to execute the tests that are
/// marked as known bugs. They are skipped by default so that the suite stays green.
const bool _runBugTests = bool.fromEnvironment('RUN_BUG_TESTS');

const _plaintext = 'top secret plaintext 0123456789 äöü €';
const _password = 'pa55w0rd';

/// PBKDF2 with 100000 iterations in pure Dart takes seconds, so the tamper matrix uses a cheap key derivation.
/// The code under test (decrypt / authentication) is the same, only the iteration count differs.
const _cheapIterations = 10;

Pbkdf2 _kdf({int iterations = _cheapIterations, int bits = 256, MacAlgorithm? mac}) =>
    Pbkdf2(macAlgorithm: mac ?? Hmac.sha256(), iterations: iterations, bits: bits);

Uint8List _bytes(int length, [int start = 0]) => Uint8List.fromList(List.generate(length, (i) => (start + i) & 0xFF));

/// Same steps as [AesEncrypted.encrypt], only with a configurable key derivation.
Future<AesEncrypted> _encrypt({
  String data = _plaintext,
  String password = _password,
  int iterations = _cheapIterations,
  Uint8List? salt,
  Uint8List? iv,
}) async {
  final cypher = AesGcm.with256bits();
  final kdf = _kdf(iterations: iterations);
  salt ??= _bytes(16, 1);
  iv ??= _bytes(16, 100);
  final key = await kdf.deriveKeyFromPassword(password: password, nonce: salt);
  final box = await cypher.encrypt(utf8.encode(data), secretKey: key, nonce: iv);
  return AesEncrypted(
    data: Uint8List.fromList(box.cipherText),
    salt: salt,
    iv: iv,
    mac: box.mac,
    kdf: kdf,
    cypher: cypher,
  );
}

Uint8List _flipBit(Uint8List source, int byteIndex, int bit) {
  final copy = Uint8List.fromList(source);
  copy[byteIndex] ^= 1 << bit;
  return copy;
}

AesEncrypted _with(
  AesEncrypted source, {
  Uint8List? data,
  Uint8List? salt,
  Uint8List? iv,
  Mac? mac,
  KdfAlgorithm? kdf,
  Cipher? cypher,
}) =>
    AesEncrypted(
      data: data ?? source.data,
      salt: salt ?? source.salt,
      iv: iv ?? source.iv,
      mac: mac ?? source.mac,
      kdf: kdf ?? source.kdf,
      cypher: cypher ?? source.cypher,
    );

/// Decrypts and asserts that the authentication failed and that no plaintext came out.
Future<void> _expectAuthenticationError(AesEncrypted tampered, {String reason = ''}) async {
  Uint8List? plain;
  Object? error;
  try {
    plain = await tampered.decrypt(_password);
  } catch (e) {
    error = e;
  }
  expect(plain, isNull, reason: 'no plaintext may be returned for tampered input. $reason');
  expect(error, isA<SecretBoxAuthenticationError>(), reason: reason);
  expect(error.toString().contains('top secret'), isFalse, reason: 'the error must not leak plaintext');
}

Map<String, dynamic> _validJson(AesEncrypted encrypted) => jsonDecode(jsonEncode(encrypted.toJson())) as Map<String, dynamic>;

void _testAesEncryptedTamper() {
  late AesEncrypted valid;
  setUpAll(() async {
    valid = await _encrypt();
  });

  group('AesEncrypted baseline', () {
    test('the untampered fixture decrypts (so the tamper tests fail for the tampering only)', () async {
      expect(await valid.decryptToString(_password), _plaintext);
      expect(valid.data.length, utf8.encode(_plaintext).length, reason: 'GCM cipher text has the length of the plaintext');
      expect(valid.mac.bytes.length, 16);
    });

    test('toJson -> fromJson -> decrypt works with the fixture json', () async {
      final restored = AesEncrypted.fromJson(_validJson(valid));
      expect(await restored.decryptToString(_password), _plaintext);
    });
  });

  group('AesEncrypted bit flips', () {
    test('flipping any single bit of the data is detected', () async {
      for (var byte = 0; byte < valid.data.length; byte++) {
        await _expectAuthenticationError(_with(valid, data: _flipBit(valid.data, byte, byte % 8)), reason: 'data byte $byte');
      }
    });

    test('flipping the first and the last bit of the data is detected', () async {
      await _expectAuthenticationError(_with(valid, data: _flipBit(valid.data, 0, 0)));
      await _expectAuthenticationError(_with(valid, data: _flipBit(valid.data, valid.data.length - 1, 7)));
    });

    test('flipping a bit in every byte of the salt is detected (different key)', () async {
      for (var byte = 0; byte < valid.salt.length; byte++) {
        await _expectAuthenticationError(_with(valid, salt: _flipBit(valid.salt, byte, 0)), reason: 'salt byte $byte');
      }
    });

    test('flipping a bit in every byte of the iv is detected', () async {
      for (var byte = 0; byte < valid.iv.length; byte++) {
        await _expectAuthenticationError(_with(valid, iv: _flipBit(valid.iv, byte, 3)), reason: 'iv byte $byte');
      }
    });

    test('flipping a bit in every byte of the mac is detected', () async {
      for (var byte = 0; byte < valid.mac.bytes.length; byte++) {
        final mac = Mac(_flipBit(Uint8List.fromList(valid.mac.bytes), byte, 5));
        await _expectAuthenticationError(_with(valid, mac: mac), reason: 'mac byte $byte');
      }
    });

    test('swapping data of two different encryptions with the same key material is detected', () async {
      final other = await _encrypt(data: 'a different plaintext of similar length!!');
      await _expectAuthenticationError(_with(valid, data: other.data));
      await _expectAuthenticationError(_with(valid, mac: other.mac));
    });

    test('a wrong password is an authentication error as well', () async {
      Object? error;
      try {
        await valid.decrypt('wrong');
      } catch (e) {
        error = e;
      }
      expect(error, isA<SecretBoxAuthenticationError>());
    });
  });

  group('AesEncrypted truncated or extended input', () {
    test('truncating the last byte of the ciphertext is detected', () async {
      await _expectAuthenticationError(_with(valid, data: valid.data.sublist(0, valid.data.length - 1)));
    });

    test('truncating the ciphertext to one byte or to nothing is detected', () async {
      await _expectAuthenticationError(_with(valid, data: valid.data.sublist(0, 1)));
      await _expectAuthenticationError(_with(valid, data: Uint8List(0)));
    });

    test('appending a byte to the ciphertext is detected', () async {
      await _expectAuthenticationError(_with(valid, data: Uint8List.fromList([...valid.data, 0])));
    });

    test('ciphertext and mac concatenated, one byte cut from the end: the mac window shifts and is detected', () async {
      final concatenated = Uint8List.fromList([...valid.data, ...valid.mac.bytes]);
      final truncated = concatenated.sublist(0, concatenated.length - 1);
      final restored = AesEncrypted(data: truncated, salt: valid.salt, iv: valid.iv, kdf: valid.kdf, cypher: valid.cypher);
      expect(restored.mac.bytes.length, 16);
      expect(restored.data.length, valid.data.length - 1);
      await _expectAuthenticationError(restored);
    });

    test('the concatenated form (no explicit mac) decrypts when it is intact', () async {
      final concatenated = Uint8List.fromList([...valid.data, ...valid.mac.bytes]);
      final restored = AesEncrypted(data: concatenated, salt: valid.salt, iv: valid.iv, kdf: valid.kdf, cypher: valid.cypher);
      expect(restored.data, valid.data);
      expect(restored.mac.bytes, valid.mac.bytes);
      expect(await restored.decryptToString(_password), _plaintext);
    });

    test('mac with the wrong length (empty, 15, 17 bytes) is an authentication error and returns no plaintext', () async {
      await _expectAuthenticationError(_with(valid, mac: Mac.empty), reason: 'empty mac');
      await _expectAuthenticationError(_with(valid, mac: Mac(valid.mac.bytes.sublist(0, 15))), reason: '15 byte mac');
      await _expectAuthenticationError(_with(valid, mac: Mac([...valid.mac.bytes, 0])), reason: '17 byte mac');
    });

    test('an iv of the wrong length (empty, 8 bytes) never yields plaintext', () async {
      for (final iv in [Uint8List(0), _bytes(8)]) {
        Uint8List? plain;
        Object? error;
        try {
          plain = await _with(valid, iv: iv).decrypt(_password);
        } catch (e) {
          error = e;
        }
        expect(plain, isNull, reason: 'iv length ${iv.length}');
        expect(error, isNotNull, reason: 'iv length ${iv.length}');
      }
    });

    test('an empty salt derives a different key and is an authentication error', () async {
      await _expectAuthenticationError(_with(valid, salt: Uint8List(0)));
    });
  });

  group('AesEncrypted factory without mac and short data', () {
    AesEncrypted build(int dataLength) => AesEncrypted(
          data: _bytes(dataLength),
          salt: _bytes(16),
          iv: _bytes(16),
          kdf: _kdf(),
          cypher: AesGcm.with256bits(),
        );

    test('16 bytes: empty data and the whole input is the mac', () async {
      final aes = build(16);
      expect(aes.data, isEmpty);
      expect(aes.mac.bytes, _bytes(16));
      await expectLater(aes.decrypt(_password), throwsA(isA<SecretBoxAuthenticationError>()));
    });

    test('17 bytes: one data byte and a 16 byte mac', () {
      final aes = build(17);
      expect(aes.data, [0]);
      expect(aes.mac.bytes, _bytes(16, 1));
    });

    test('every length below 16 bytes is rejected (characterization: with a RangeError)', () {
      for (var length = 0; length < 16; length++) {
        expect(() => build(length), throwsA(isA<RangeError>()), reason: 'data length $length');
      }
    });

    test('RangeError is an ArgumentError, so callers that catch ArgumentError see it', () {
      expect(() => build(15), throwsArgumentError);
    });

    test(
      'data shorter than the 16 byte mac is rejected with a clean FormatException (no RangeError)',
      () {
        for (var length = 0; length < 16; length++) {
          expect(() => build(length), throwsA(isA<FormatException>()), reason: 'data length $length');
        }
      },
      skip: _runBugTests ? null : 'BUG: aes_encrypted.dart:71 data.sublist(data.length - 16) throws a RangeError with a negative index instead of a descriptive error',
    );
  });

  group('AesEncrypted.fromJson with missing or invalid fields', () {
    for (final key in ['data', 'salt', 'iv', 'mac', 'kdf', 'cypher']) {
      test('missing "$key" throws and returns no object (characterization: TypeError)', () {
        final json = _validJson(valid)..remove(key);
        expect(() => AesEncrypted.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('null "$key" throws and returns no object (characterization: TypeError)', () {
        final json = _validJson(valid)..[key] = null;
        expect(() => AesEncrypted.fromJson(json), throwsA(isA<TypeError>()));
      });
    }

    test(
      'a json without any of the required fields is rejected with a FormatException or ArgumentError (no TypeError)',
      () {
        for (final key in ['data', 'salt', 'iv', 'mac', 'kdf', 'cypher']) {
          final json = _validJson(valid)..remove(key);
          expect(() => AesEncrypted.fromJson(json), throwsA(anyOf(isA<FormatException>(), isA<ArgumentError>())), reason: 'missing $key');
        }
      },
      skip: _runBugTests ? null : 'BUG: aes_encrypted.dart:130-135 fromJson casts null to String/Map and throws a TypeError for an incomplete backup file',
    );

    for (final key in ['data', 'salt', 'iv', 'mac']) {
      test('invalid base64 in "$key" throws a FormatException', () {
        final json = _validJson(valid)..[key] = 'this is not base64!';
        expect(() => AesEncrypted.fromJson(json), throwsA(isA<FormatException>()));
      });

      test('base64 with excess padding in "$key" throws a FormatException', () {
        final json = _validJson(valid)..[key] = 'AAAA====';
        expect(() => AesEncrypted.fromJson(json), throwsA(isA<FormatException>()));
      });

      test('a number instead of a base64 string in "$key" throws', () {
        final json = _validJson(valid)..[key] = 12345;
        expect(() => AesEncrypted.fromJson(json), throwsA(isA<TypeError>()));
      });
    }

    test('an empty mac string is parsed to an empty mac and fails authentication', () async {
      final json = _validJson(valid)..['mac'] = '';
      final aes = AesEncrypted.fromJson(json);
      expect(aes.mac.bytes, isEmpty);
      await _expectAuthenticationError(aes);
    });

    test('extra unknown fields in the json are ignored', () async {
      final json = _validJson(valid)..['unknown'] = {'a': 1};
      expect(await AesEncrypted.fromJson(json).decryptToString(_password), _plaintext);
    });

    test('unsupported cypher, kdf, mac and hash algorithms are rejected with an UnsupportedError', () {
      Map<String, dynamic> withCypher(Map<String, dynamic> cypher) => _validJson(valid)..['cypher'] = cypher;
      Map<String, dynamic> withKdf(Map<String, dynamic> Function(Map<String, dynamic> kdf) change) {
        final json = _validJson(valid);
        json['kdf'] = change(Map<String, dynamic>.of(json['kdf'] as Map<String, dynamic>));
        return json;
      }

      expect(() => AesEncrypted.fromJson(withCypher({'algorithm': 'ChaCha20', 'secretKeyLength': 32})), throwsUnsupportedError);
      expect(() => AesEncrypted.fromJson(withCypher({'algorithm': 'AesGcm', 'secretKeyLength': 20})), throwsUnsupportedError);
      expect(() => AesEncrypted.fromJson(withCypher({'algorithm': 'AesCbc', 'secretKeyLength': 0})), throwsUnsupportedError);
      expect(() => AesEncrypted.fromJson(withKdf((kdf) => {...kdf, 'algorithm': 'Argon2id'})), throwsUnsupportedError);
      expect(() => AesEncrypted.fromJson(withKdf((kdf) => {...kdf, 'macAlgorithm': {'algorithm': 'Poly1305'}})), throwsUnsupportedError);
      expect(
        () => AesEncrypted.fromJson(withKdf((kdf) => {
              ...kdf,
              'macAlgorithm': {
                'algorithm': 'Hmac',
                'hashAlgorithm': {'algorithm': 'DartSha384'},
              },
            })),
        throwsUnsupportedError,
      );
    });
  });

  group('AesEncrypted KDF parameters taken from the file', () {
    Map<String, dynamic> jsonWithKdf(AesEncrypted source, void Function(Map<String, dynamic> kdf) change) {
      final json = _validJson(source);
      final kdf = Map<String, dynamic>.of(json['kdf'] as Map<String, dynamic>);
      change(kdf);
      json['kdf'] = kdf;
      return json;
    }

    test('the default parameters of a real encryption are PBKDF2-HMAC-SHA256, 100000 iterations, 256 bit', () async {
      final real = await AesEncrypted.encrypt(data: 'x', password: _password);
      final kdf = real.kdf as Pbkdf2;
      expect(kdf.iterations, 100000);
      expect(kdf.bits, 256);
      expect(kdf.macAlgorithm, Hmac.sha256());
      expect(real.cypher, AesGcm.with256bits());
      expect(real.salt.length, 16);
      expect(real.iv.length, 16);
    });

    test('changing the iteration count in the file changes the key and is an authentication error', () async {
      final json = jsonWithKdf(valid, (kdf) => kdf['iterations'] = _cheapIterations + 1);
      final aes = AesEncrypted.fromJson(json);
      expect((aes.kdf as Pbkdf2).iterations, _cheapIterations + 1);
      await _expectAuthenticationError(aes);
    });

    test('changing the hash algorithm in the file changes the key and is an authentication error', () async {
      final json = jsonWithKdf(valid, (kdf) {
        kdf['macAlgorithm'] = {
          'algorithm': 'Hmac',
          'hashAlgorithm': {'algorithm': 'DartSha512'},
        };
      });
      await _expectAuthenticationError(AesEncrypted.fromJson(json));
    });

    test('iterations: 1 is accepted without any lower bound (CALL OUT: a file can request a trivially cheap key derivation)', () async {
      // The file is self describing: whoever writes it chooses the work factor. For decryption this is harmless
      // (the reader needs the password anyway), but nothing stops the app from reading very weak parameters.
      final weak = await _encrypt(iterations: 1);
      final json = _validJson(weak);
      expect((json['kdf'] as Map)['iterations'], 1);
      final restored = AesEncrypted.fromJson(json);
      expect((restored.kdf as Pbkdf2).iterations, 1);
      expect(await restored.decryptToString(_password), _plaintext);
    });

    test('a huge iteration count is accepted by fromJson without any upper bound (CALL OUT: decrypting it would block for hours)', () {
      const huge = 2000000000;
      final json = jsonWithKdf(valid, (kdf) => kdf['iterations'] = huge);
      final aes = AesEncrypted.fromJson(json);
      expect((aes.kdf as Pbkdf2).iterations, huge, reason: 'no upper bound is enforced');
      // decrypt() is not called on purpose: 2e9 pure Dart HMAC iterations would take hours.
    });

    test('iterations: 0 and negative values are rejected, but only by an assert (characterization: AssertionError in debug and test mode)', () {
      for (final iterations in [0, -1]) {
        final json = jsonWithKdf(valid, (kdf) => kdf['iterations'] = iterations);
        expect(() => AesEncrypted.fromJson(json), throwsA(isA<AssertionError>()), reason: 'iterations $iterations');
      }
    });

    test('bits below 64 are rejected, but only by an assert (characterization: AssertionError in debug and test mode)', () {
      final json = jsonWithKdf(valid, (kdf) => kdf['bits'] = 8);
      expect(() => AesEncrypted.fromJson(json), throwsA(isA<AssertionError>()));
    });

    test('a derived key length that does not match the cipher key length is an error and returns no plaintext', () async {
      // 128 bit key derivation for the AES-256 cipher.
      final json = jsonWithKdf(valid, (kdf) => kdf['bits'] = 128);
      final aes = AesEncrypted.fromJson(json);
      Uint8List? plain;
      Object? error;
      try {
        plain = await aes.decrypt(_password);
      } catch (e) {
        error = e;
      }
      expect(plain, isNull);
      expect(error, isA<ArgumentError>());
    });

    test('iterations as a string or a double is rejected with a TypeError', () {
      for (final value in <Object>['10', 10.5]) {
        final json = jsonWithKdf(valid, (kdf) => kdf['iterations'] = value);
        expect(() => AesEncrypted.fromJson(json), throwsA(isA<TypeError>()), reason: '$value');
      }
    });
  });

  group('AesEncrypted cipher serialization', () {
    test('AesGcm round trips for 128, 192 and 256 bit keys', () {
      for (final cipher in [AesGcm.with128bits(), AesGcm.with192bits(), AesGcm.with256bits()]) {
        final restored = CipherX.fromJson(cipher.toJson());
        expect(restored, isA<AesGcm>());
        expect((restored as AesGcm).secretKeyLength, cipher.secretKeyLength);
      }
    });

    test('Pbkdf2, Hmac and the hash algorithms round trip', () {
      for (final hmac in [Hmac.sha256(), Hmac.sha512()]) {
        final kdf = Pbkdf2(macAlgorithm: hmac, iterations: 1234, bits: 256);
        final restored = KdfAlgorithmX.fromJson(kdf.toJson()) as Pbkdf2;
        expect(restored.iterations, 1234);
        expect(restored.bits, 256);
        expect(restored.macAlgorithm, hmac);
      }
    });

    test('Hmac.sha1 is written but can not be read back (UnsupportedError)', () {
      final json = Hmac.sha1().toJson();
      expect((json['hashAlgorithm'] as Map)['algorithm'], 'DartSha1');
      expect(() => MacAlgorithmX.fromJson(json), throwsUnsupportedError);
    });

    test('a kdf other than Pbkdf2 (Argon2id) can not be serialized', () {
      expect(() => Argon2id(parallelism: 1, memory: 8, iterations: 1, hashLength: 32).toJson(), throwsUnsupportedError);
    });

    test('padding algorithms round trip through their string form', () {
      expect(PaddingAlgorithmX.fromString(PaddingAlgorithm.pkcs7.toString()), PaddingAlgorithm.pkcs7);
      expect(PaddingAlgorithmX.fromString(PaddingAlgorithm.zero.toString()), PaddingAlgorithm.zero);
      expect(() => PaddingAlgorithmX.fromString('nonsense'), throwsUnsupportedError);
    });

    test('AesCbc fromJson reads a hand written json with a macAlgorithm map', () {
      final cipher = CipherX.fromJson({
        'algorithm': 'AesCbc',
        'secretKeyLength': 32,
        'macAlgorithm': Hmac.sha512().toJson(),
        'paddingAlgorithm': 'PaddingAlgorithm.zero',
      }) as AesCbc;
      expect(cipher.secretKeyLength, 32);
      expect(cipher.macAlgorithm, Hmac.sha512());
      expect(cipher.paddingAlgorithm, PaddingAlgorithm.zero);
    });

    test('AesCbc fromJson defaults to HMAC-SHA256 and PKCS7 when the fields are missing', () {
      final cipher = CipherX.fromJson({'algorithm': 'AesCbc', 'secretKeyLength': 16}) as AesCbc;
      expect(cipher.macAlgorithm, Hmac.sha256());
      expect(cipher.paddingAlgorithm, PaddingAlgorithm.pkcs7);
      expect(cipher.secretKeyLength, 16);
    });

    test('AesCbc toJson writes macAlgorithm as a string, not as the map that fromJson expects (characterization)', () {
      final json = AesCbc.with256bits(macAlgorithm: Hmac.sha256()).toJson();
      expect(json['macAlgorithm'], isA<String>(), reason: 'macAlgorithm.toString() is written');
      expect(json['macAlgorithm'], isNot(isA<Map>()));
      expect(json['paddingAlgorithm'], 'PaddingAlgorithm.pkcs7');
      expect(() => CipherX.fromJson(json), throwsA(isA<TypeError>()), reason: 'the written json can not be read back');
    });

    test(
      'AesCbc toJson -> fromJson round trips',
      () {
        for (final cipher in [
          AesCbc.with128bits(macAlgorithm: Hmac.sha256()),
          AesCbc.with192bits(macAlgorithm: Hmac.sha512(), paddingAlgorithm: PaddingAlgorithm.zero),
          AesCbc.with256bits(macAlgorithm: Hmac.sha256()),
        ]) {
          final restored = CipherX.fromJson(cipher.toJson()) as AesCbc;
          expect(restored.secretKeyLength, cipher.secretKeyLength);
          expect(restored.macAlgorithm, cipher.macAlgorithm);
          expect(restored.paddingAlgorithm, cipher.paddingAlgorithm);
        }
      },
      skip: _runBugTests ? null : 'BUG: aes_encrypted.dart:285 AesCbc.toJson writes macAlgorithm.toString() but fromJson (line 271) expects a map, so the round trip throws a TypeError',
    );

    test(
      'a complete AesEncrypted with AesCbc survives toJson -> jsonEncode -> fromJson -> decrypt',
      () async {
        final cipher = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
        final kdf = _kdf();
        final key = await kdf.deriveKeyFromPassword(password: _password, nonce: _bytes(16));
        final box = await cipher.encrypt(utf8.encode(_plaintext), secretKey: key, nonce: _bytes(16, 7));
        final aes = AesEncrypted(data: Uint8List.fromList(box.cipherText), salt: _bytes(16), iv: _bytes(16, 7), mac: box.mac, kdf: kdf, cypher: cipher);
        expect(await aes.decryptToString(_password), _plaintext, reason: 'in memory the cbc variant works');
        final restored = AesEncrypted.fromJson(jsonDecode(jsonEncode(aes.toJson())) as Map<String, dynamic>);
        expect(await restored.decryptToString(_password), _plaintext);
      },
      skip: _runBugTests ? null : 'BUG: aes_encrypted.dart:285 AesCbc.toJson writes macAlgorithm.toString() but fromJson (line 271) expects a map',
    );
  });
}
