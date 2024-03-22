import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

class AesEncrypted {
  static final defaultMacAlgorithm = Hmac.sha256();
  static const defaultIterations = 100000;
  static const defaultBits = 256;
  // Key derivation
  final KdfAlgorithm kdf;
  final Uint8List salt;

  // Encryption
  final Uint8List data;
  final Uint8List iv;
  final Mac? mac;
  // final String? padding;

  final Cipher cypher;

  const AesEncrypted._({
    required this.kdf,
    required this.salt,
    required this.data,
    required this.iv,
    this.mac,
    required this.cypher,
  });

  static Future<AesEncrypted> encrypt({
    required String data,
    required String password,
  }) async {
    final plainBytes = utf8.encode(data);
    final cypher = AesGcm.with256bits();
    final kdf = Pbkdf2(
      macAlgorithm: defaultMacAlgorithm,
      iterations: defaultIterations,
      bits: defaultBits,
    );
    final salt = Uint8List.fromList(List.generate(16, (index) => index));
    final iv = Uint8List.fromList(List.generate(16, (index) => index));
    final secretKey = await kdf.deriveKeyFromPassword(password: password, nonce: salt);
    final secretBox = await cypher.encrypt(plainBytes, secretKey: secretKey, nonce: iv);
    final encryptedData = secretBox.concatenation(nonce: false, mac: false);
    return AesEncrypted._(
      cypher: cypher,
      kdf: kdf,
      salt: salt,
      iv: iv,
      data: encryptedData,
      mac: secretBox.mac,
    );
  }

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

  Future<Uint8List> decrypt(String password) async {
    final SecretKey secretKey = await _deriveKey(password);
    final SecretBox secretBox = SecretBox(data, nonce: iv, mac: mac ?? Mac.empty);
    final decrypted = await cypher.decrypt(secretBox, secretKey: secretKey);
    return Uint8List.fromList(decrypted);
  }

  Future<String> decryptUtf8(String password) async {
    final decrypted = await decrypt(password);
    return utf8.decode(decrypted);
  }

  Future<String> decryptToString(String password) async {
    final decrypted = await decrypt(password);
    return utf8.decode(decrypted);
  }

  Future<SecretKey> _deriveKey(String password) async {
    return await kdf.deriveKeyFromPassword(password: password, nonce: salt);
  }

  static AesEncrypted fromJson(Map<String, dynamic> json) {
    return AesEncrypted(
      data: base64Decode(json['data']),
      salt: base64Decode(json['salt']),
      iv: base64Decode(json['iv']),
      mac: Mac(base64Decode(json['mac'])),
      kdf: Pbkdf2(
        macAlgorithm: defaultMacAlgorithm,
        iterations: defaultIterations,
        bits: defaultBits,
      ),
      cypher: AesGcm.with256bits(),
    );
  }

  static AesEncrypted fromJsonString(String jsonString) => fromJson(jsonDecode(jsonString));

  Map<String, dynamic> toJson() {
    return {
      'data': base64Encode(data),
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'mac': base64Encode(mac?.bytes ?? Uint8List(0)),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
