import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/encryption/aes_encrypted.dart';

void main() {
  _testAesEncrypted();
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
      final jsonEncoded = jsonEncode(aesEncrypted.toJson());
      print(jsonEncoded);
      expect(decrypted, "test");
    });
    test('toJson', () {
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
    });

    test('toJson 2', () {
// TODO: implement test
    });
    test('toJson 3', () {
// TODO: implement test
    });
    test('toJson 4', () {
// TODO: implement test
    });

    test('fromJson', () async {
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
      final decrypted = await aesEncrypted.decryptToString("password");
      expect(decrypted, "test");
    });
  });
  test('fromJson 2', () {
    // TODO: implement test
  });
  test('fromJson 3', () {
    // TODO: implement test
  });
  test('fromJson 4', () {
    // TODO: implement test
  });
}
