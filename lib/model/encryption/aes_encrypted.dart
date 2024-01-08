import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

class AESEncrypted {
  final String data;
  final Uint8List dataBytes;
  final String salt;
  final Uint8List saltBytes;
  final String iv;
  final Hmac macAlgorithm;
  final int iterations;
  final int keyBitLengh;
  final AESMode aesMode;

  String? decryptedString;

  AESEncrypted(this.data, this.salt, this.iv, {Hmac? macAlgorithm, int? iterations, int? keyBitLengh, AESMode? aesMode})
      : dataBytes = base64Decode(data),
        saltBytes = base64Decode(salt),
        macAlgorithm = macAlgorithm ?? Hmac.sha256(),
        iterations = iterations ?? 10000,
        keyBitLengh = keyBitLengh ?? 256,
        aesMode = aesMode ?? AESMode.gcm;

  /// The [encrypted] string should be in the format of [data:salt:iv]
  /// When using another separator, you can pass it as [separator]
  /// Default [macAlgorithm] is [Hmac.sha256()]
  /// Default [iterations] is [10000]
  /// Default [keyBitLengh] is [256]
  /// Default [aesMode] is [AESMode.gcm]
  factory AESEncrypted.fromSingleEncryptedString(String encrypted,
      {String separator = ':', Hmac? macAlgorithm, int? iterations, int? keyBitLengh, AESMode? aesMode}) {
    final splitedServices = encrypted.split(separator);
    return AESEncrypted(
      splitedServices[0],
      splitedServices[1],
      splitedServices[2],
      macAlgorithm: macAlgorithm,
      iterations: iterations,
      keyBitLengh: keyBitLengh,
      aesMode: aesMode,
    );
  }

  Future<String?> decrypt(String password) async {
    final keyGenerator = Pbkdf2(macAlgorithm: macAlgorithm, iterations: iterations, bits: keyBitLengh);

    final SecretKey secretKey = await keyGenerator.deriveKeyFromPassword(password: password, nonce: saltBytes);
    final Uint8List keyRaw = Uint8List.fromList(await secretKey.extractBytes());
    final Key key = Key(keyRaw);
    final iv = IV.fromBase64(this.iv);

    final encrypter = Encrypter(AES(key, mode: aesMode));
    final String decryptedString;
    // try {
    final decrypted = encrypter.decryptBytes(Encrypted(dataBytes), iv: iv);
    decryptedString = utf8.decode(decrypted);
    // } catch (e) {
    //   Logger.info('decryption failed');
    //   return null;
    // }

    return decryptedString;
  }
}
