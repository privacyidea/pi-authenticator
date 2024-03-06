import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

class AesEncrypted {
  // Key derivation
  final KdfAlgorithm _kdf;
  final Uint8List _salt;

  // Encryption
  final Uint8List _data;
  final Uint8List _iv;
  final Mac? _mac;
  // final String? padding;

  final Cipher _cypher;

  const AesEncrypted._({
    required Mac? mac,
    required KdfAlgorithm kdf,
    required Cipher cypher,
    required Uint8List salt,
    required Uint8List iv,
    required Uint8List data,
  })  : _cypher = cypher,
        _mac = mac,
        _data = data,
        _iv = iv,
        _salt = salt,
        _kdf = kdf;

  /// If mac is not provided, it will be extracted from the last 16 bytes of the data
  /// This is the default of AES encryption.
  factory AesEncrypted({
    required Uint8List data,
    required Uint8List salt,
    required Uint8List iv,
    Mac? mac,
    required KdfAlgorithm kdf,
    required Cipher cypher,
  }) {
    if (mac == null) {
      mac = Mac(data.sublist(data.length - 16, data.length));
      data = data.sublist(0, data.length - 16);
    }
    return AesEncrypted._(mac: mac, kdf: kdf, cypher: cypher, salt: salt, iv: iv, data: data);
  }

  // AesEncrypted withMacFromData(int macLengh) {
  //   assert(_mac != null || _mac != Mac.empty, 'Mac is already set');
  //   final mac = Mac(_data.sublist(_data.length - macLengh, _data.length));
  //   final data = _data.sublist(0, _data.length - macLengh);
  //   return AesEncrypted._(mac: mac, kdf: _kdf, cypher: _cypher, salt: _salt, iv: _iv, data: data);
  // }

  Future<Uint8List> decrypt(String password) async {
    final SecretKey secretKey = await _deriveKey(password);
    final SecretBox secretBox = SecretBox(_data, nonce: _iv, mac: _mac ?? Mac.empty);
    final decrypted = await _cypher.decrypt(secretBox, secretKey: secretKey);
    return Uint8List.fromList(decrypted);
  }

  Future<String> decryptToString(String password) async {
    final decrypted = await decrypt(password);
    return utf8.decode(decrypted);
  }

  Future<SecretKey> _deriveKey(String password) async {
    return await _kdf.deriveKeyFromPassword(password: password, nonce: _salt);
  }
}

// class AESEncrypted {
//   final Uint8List data;
//   final Uint8List salt;
//   final Uint8List iv;
//   final String ivBase64;
//   final String padding;
//   final Hmac macAlgorithm;
//   final int iterations;
//   // final int keyBitLengh;
//   final AESMode aesMode;

//   String? decryptedString;

//   AESEncrypted(
//       {required this.data, required this.salt, required this.iv, String? padding, Hmac? macAlgorithm, int? iterations, int? keyBitLengh, AESMode? aesMode})
//       : //dataBytes = base64Decode(data),
//         // saltBytes = base64Decode(salt),
//         // ivBytes = base64Decode(iv),
//         padding = padding ?? 'PKCS7',
//         ivBase64 = base64Encode(iv),
//         macAlgorithm = macAlgorithm ?? Hmac.sha256(),
//         iterations = iterations ?? 10000,
//         // keyBitLengh = keyBitLengh ?? 128,//
//         aesMode = aesMode ?? AESMode.gcm;

//   Future<String> decrypt(String password) async {
//     final keyGenerator = Pbkdf2(macAlgorithm: macAlgorithm, iterations: iterations, bits: salt.length * 8);

//     final SecretKey secretKey = await keyGenerator.deriveKeyFromPassword(password: password, nonce: salt);
//     final Uint8List keyBytes = Uint8List.fromList(await secretKey.extractBytes());
//     final Key key = Key(keyBytes);

//     final encrypter = Encrypter(AES(key, mode: aesMode, padding: padding));
//     final iv = IV.fromBase64(ivBase64);
//     final String decryptedString;
//     try {
//       final decrypted = encrypter.decryptBytes(Encrypted(data), iv: iv);
//       decryptedString = utf8.decode(decrypted);
//     } catch (e) {
//       throw Exception('Wrong password or corrupted data');
//     }
//     return decryptedString;
//   }
// }
