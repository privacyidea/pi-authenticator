import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:privacyidea_authenticator/processors/token_import_processor/token_file_import_processor_interface.dart';

import '../../model/encryption/aes_encrypted.dart';
import '../../model/tokens/token.dart';

class FreeOtpFileImportProcessor implements TokenFileImportProcessor {
  static const String mMasterKey = "masterKey";
  static const String mEncryptedKey = "mEncryptedKey";
  static const String mCipher = "mCipher";
  static const String mCipherText = "mCipherText";
  static const String mParameters = "mParameters";
  static const String mIterations = "mIterations";
  static const String mSalt = "mSalt";

  const FreeOtpFileImportProcessor();

  @override
  Future<List<Token>> process({required XFile file, String? password}) async {
    final fileContent = (await const MethodChannel('readValueFromFile').invokeMethod('json', {'path': file.path}) as Map).cast<String, dynamic>();
    final masterKey = jsonDecode(fileContent.remove(mMasterKey) as String) as Map<String, dynamic>;
    final mCipherTextInt = (masterKey['mEncryptedKey']['mCipherText'] as List).cast<int>();
    final mIvAsn1 = (masterKey['mEncryptedKey']['mParameters'] as List).cast<int>(); // IV as ASN.1
    // print(mIvAsn1);
    final asn1Parser = ASN1Parser(Uint8List.fromList(mIvAsn1));
    final ivAsn1 = asn1Parser.nextObject() as ASN1Sequence;
    // for (var i = 0; i < ivAsn1.elements!.length; i++) {
    //   print("$i: ${ivAsn1.elements![i].runtimeType}");
    // }
    // final tempIV = ivAsn1.valueBytes;
    final asn1OctetString = ivAsn1.elements![0] as ASN1OctetString;
    final ivBytes = asn1OctetString.valueBytes!;
    // final ivStringUtf8 = utf8.decode(ivBytes);
    // print(ivStringUtf8);
    // final asn1Integer = ivAsn1.elements![1] as ASN1Integer;

    final iv = IV(ivBytes);
    final mIterations = masterKey['mIterations'] as int;
    final mSaltInt = (masterKey['mSalt'] as List).cast<int>();

    final saltBytes = Uint8List.fromList(mSaltInt);
    final cipherTextBytes = Uint8List.fromList(mCipherTextInt);

    final keyGenerator = Pbkdf2(macAlgorithm: Hmac.sha512(), iterations: mIterations, bits: saltBytes.length * 8);

    final SecretKey secretKey = await keyGenerator.deriveKeyFromPassword(password: password!, nonce: saltBytes);
    final Uint8List keyBytes = Uint8List.fromList(await secretKey.extractBytes());
    final Key key = Key(keyBytes);

    final encrypter = Encrypter(AES(key, mode: AESMode.gcm, padding: 'NoPadding'));
    final String decryptedString;

    final decrypted = encrypter.decryptBytes(Encrypted(cipherTextBytes), iv: iv);
    decryptedString = utf8.decode(decrypted);

    print(decryptedString);

    // } catch (e) {
    //   throw WrongDecryptionPasswordException('Wrong password or corrupted data');
    // }

    // final tokens = <Token>[];
    // fileContent.forEach((key, value) {
    //   if (key.endsWith("-token")) {
    //     log('token: $value');
    //     // Do stuff with master key and token
    //   }
    // });

    return [];
  }

  @override
  Future<bool> fileIsValid({required XFile file}) async {
    try {
      final fileContent = (await const MethodChannel('readValueFromFile').invokeMethod('json', {'path': file.path}) as Map).cast<String, dynamic>();
      return fileContent.containsKey("masterKey") && fileContent.length >= 3;
    } catch (e) {
      return false;
    }
  }

  /// FreeOTP Tokens are always encrypted
  @override
  Future<bool> fileNeedsPassword({required XFile file}) => Future(() => true);
}

final masterKey = {
  "mAlgorithm": "PBKDF2withHmacSHA512",
  "mEncryptedKey": {
    "mCipher": "AES/GCM/NoPadding",
    "mCipherText": [/* ... */],
    "mParameters": [48, 17, 4, 12, 122, -53, -107, 28, 30, 7, 72, -112, -74, -91, -29, -65, 2, 1, 16],
    "mToken": "AES"
  },
  "mIterations": 100.000,
  "mSalt": [74, 64, 37, -90, -37, 3, -94, 65, -11, 8, 77, 12, 65, -98, 89, 50, 9, 70, -113, 109, -97, 113, 4, 106, -23, 97, 80, 67, -32, 103, -39, -102]
};
final _35902690_b031_41c3_bdc7_ca7edeb3b4e7 = {
  "key": {
    "mCipher": "AES\/GCM\/NoPadding",
    "mCipherText": [18, -100, -77, -120, -37, -128, 31, -98, -23, 62, 31, 103, 2, 72, -14, 58, -120],
    "mParameters": [48, 17, 4, 12, -90, -88, 21, 4, -108, 51, -122, -109, 9, -59, 45, -99, 2, 1, 16],
    "mToken": "HmacSHA256",
  }
};
final _35902690_b031_41c3_bdc7_ca7edeb3b4e7_token = {
  "algo": "SHA256",
  "counter": 0,
  "digits": 6,
  "issuerExt": "",
  "label": "loooool",
  "period": 30,
  "type": "HOTP"
};
final _2134ec38_1d21_4754_9c4a_d359d5fc9e6c = {
  "key": {
    "mCipher": "AES\/GCM\/NoPadding",
    "mCipherText": [
      -61,
      92,
      108,
      -81,
      -5,
      -2,
      1,
      -92,
      111,
      45,
      -13,
      50,
      118,
      92,
      101,
      -82,
      -51,
      -4,
      68,
      -107,
      -68,
      -108,
      79,
      83,
      -64,
      49,
      69,
      -109,
      -16,
      -11,
      93,
      -33,
      -10,
      72,
      -113,
      40
    ],
    "mParameters": [48, 17, 4, 12, -22, 33, -123, -102, 4, -26, 97, 40, -61, -52, -50, -54, 2, 1, 16],
    "mToken": "HmacSHA1",
  }
};
final _5d9f2634_c65e_4e79_9469_346f3f247d1f = {
  "key": {
    "mCipher": "AES\/GCM\/NoPadding",
    "mCipherText": [-33, -52, -73, 76, -29, -27, -75, 79, 42, 24, -36, -12, -15, 83, -40, -84, -25, -44, 55],
    "mParameters": [48, 17, 4, 12, -108, -91, -124, 27, 41, -1, -53, -96, 14, 74, -16, -117, 2, 1, 16],
    "mToken": "HmacSHA512",
  }
};
final _5d9f2634_c65e_4e79_9469_346f3f247d1f_token = {
  "algo": "SHA512",
  "digits": 8,
  "issuerExt": "",
  "label": "aaa",
  "period": 60,
  "type": "TOTP",
};
final _2134ec38_1d21_4754_9c4a_d359d5fc9e6c_token = {
  "counter": 1,
  "digits": 6,
  "issuerInt": "privacyIDEA",
  "label": "OATH00039821",
  "type": "HOTP",
};
