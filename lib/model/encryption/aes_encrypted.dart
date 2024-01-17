import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';

class AESEncrypted {
  final Uint8List data;
  final Uint8List salt;
  final Uint8List iv;
  final String ivBase64;
  final String padding;
  final Hmac macAlgorithm;
  final int iterations;
  // final int keyBitLengh;
  final AESMode aesMode;

  String? decryptedString;

  AESEncrypted(
      {required this.data, required this.salt, required this.iv, String? padding, Hmac? macAlgorithm, int? iterations, int? keyBitLengh, AESMode? aesMode})
      : //dataBytes = base64Decode(data),
        // saltBytes = base64Decode(salt),
        // ivBytes = base64Decode(iv),
        padding = padding ?? 'PKCS7',
        ivBase64 = base64Encode(iv),
        macAlgorithm = macAlgorithm ?? Hmac.sha256(),
        iterations = iterations ?? 10000,
        // keyBitLengh = keyBitLengh ?? 128,//
        aesMode = aesMode ?? AESMode.gcm;

  Future<String> decrypt(String password) async {
    final keyGenerator = Pbkdf2(macAlgorithm: macAlgorithm, iterations: iterations, bits: salt.length * 8);

    final SecretKey secretKey = await keyGenerator.deriveKeyFromPassword(password: password, nonce: salt);
    final Uint8List keyBytes = Uint8List.fromList(await secretKey.extractBytes());
    final Key key = Key(keyBytes);

    final encrypter = Encrypter(AES(key, mode: aesMode, padding: padding));
    final iv = IV.fromBase64(ivBase64);
    final String decryptedString;
    // try {
    final decrypted = encrypter.decryptBytes(Encrypted(data), iv: iv);
    // decryptedString = utf8.decode(decrypted);
    // } catch (e) {
    //   throw Exception('Wrong password or corrupted data');
    // }
    return 'decryptedString';
  }
}
