import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:file_selector/file_selector.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_types.dart';
import 'package:privacyidea_authenticator/model/extensions/enum_extension.dart';

import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../model/encryption/aes_encrypted.dart';
import '../../model/encryption/uint_8_buffer.dart';
import 'token_import_file_processor_interface.dart';

class AuthenticatorProImportFileProcessor extends TokenImportFileProcessor {
  static const String header = "AUTHENTICATORPRO";
  static const String headerLegacy = "AuthenticatorPro";

  static final typeMap = {
    1: TokenTypes.HOTP.asString,
    2: TokenTypes.TOTP.asString,
    //  3: 'mOTP', // Not supported
    4: TokenTypes.STEAM.asString,
    //   5: 'Yandex', // Not supported
  };

  static final algorithmMap = {
    0: Algorithms.SHA1.asString,
    1: Algorithms.SHA256.asString,
    2: Algorithms.SHA512.asString,
  };

  const AuthenticatorProImportFileProcessor();

  @override
  Future<bool> fileIsValid({required XFile file}) async {
    try {
      final content = await file.readAsString();
      return json.decode(content)['Authenticators'] != null;
    } catch (e) {
      try {
        final content = await file.readAsBytes();
        final headerByteLength = utf8.encode(header).length;
        final importedHeader = content.sublist(0, headerByteLength);
        final fileHeader = utf8.decode(importedHeader);
        if (fileHeader == header || fileHeader == headerLegacy) {
          return true;
        }
        return false;
      } catch (e) {
        return false;
      }
    }
  }

  @override
  Future<bool> fileNeedsPassword({required XFile file}) async {
    try {
      final content = await file.readAsString();
      json.decode(content);
    } catch (e) {
      final content = await file.readAsBytes();
      final headerByteLength = utf8.encode(header).length;
      content.sublist(0, headerByteLength);
      return true;
    }
    return false;
  }

  @override
  Future<List<Token>> processFile({required XFile file, String? password}) async {
    try {
      final bytes = await file.readAsBytes();
      Uint8Buffer uint8buffer = Uint8Buffer(data: bytes);
      final headerByteLength = utf8.encode(header).length;
      final fileHeader = utf8.decode(uint8buffer.readBytes(headerByteLength));
      Logger.info('File header: $fileHeader', name: 'authenticator_pro_import_file_processor#processFile');
      final plainText = switch (fileHeader) {
        header => await _process(uint8buffer: uint8buffer, password: password ?? ''),
        headerLegacy => await _processLegacy(uint8buffer: uint8buffer, password: password ?? ''),
        _ => utf8.decode(bytes),
      };
      return _processPlain(fileContent: plainText);
    } catch (e) {
      return [];
    }
  }

  Future<String> _process({required Uint8Buffer uint8buffer, required String password}) async {
    // Modern version uses Argon2id
    const int keySize = 32; // 32 bytes = 256 bits
    const int memoryCost = 65536; // 2^16 KiB = 64 MiB
    const int parallelism = 4;
    const int iterations = 3;
    const int saltSize = 16;
    const int ivSize = 12;

    final Argon2id kdf = Argon2id(
      iterations: iterations,
      parallelism: parallelism,
      memory: memoryCost, // number in KiB
      hashLength: keySize,
    );

    final aesEncrypted = AesEncrypted(
      cypher: AesGcm.with256bits(), // AES/GCM/NoPadding
      salt: uint8buffer.readBytes(saltSize),
      iv: uint8buffer.readBytes(ivSize),
      data: uint8buffer.readBytesToEnd(),
      kdf: kdf,
    );

    final decrypted = await aesEncrypted.decryptToString(password);
    return decrypted;
  }

  Future<String> _processLegacy({required Uint8Buffer uint8buffer, required String password}) async {
    // Legacy uses PBKDF2
    const int iterations = 64000;
    // keySize = 256 bits
    const int saltSizeByte = 20; // 20 Bytes = 160 bits

    // // AES/CBC/PKCS5Padding

    final cypher = AesCbc.with256bits(macAlgorithm: Hmac.sha1());
    final ivLength = cypher.nonceLength;
    // final salt = uint8buffer.readBytes(saltSize);
    // final iv = uint8buffer.readBytes(cypher.blockLength);
    final AesEncrypted aesEncrypted = AesEncrypted(
      cypher: cypher,
      kdf: Pbkdf2(
        macAlgorithm: Hmac.sha256(), // KeySize = 256 bits
        iterations: iterations,
        bits: saltSizeByte * 8,
      ),
      salt: uint8buffer.readBytes(saltSizeByte),
      iv: uint8buffer.readBytes(ivLength),
      data: uint8buffer.readBytesToEnd(),
    );

    final decrypted = await aesEncrypted.decryptToString(password);
    return decrypted;
  }

  Future<List<Token>> _processPlain({required String fileContent}) async {
    Logger.info('Processing plain file', name: 'authenticator_pro_import_file_processor#_processPlain');
    final tokensMap = (json.decode(fileContent)['Authenticators'].cast<Map<String, dynamic>>()) as List<Map<String, dynamic>>;
    final result = <Token>[];
    for (var tokenMap in tokensMap) {
      final typeInt = tokenMap['Type'] as int;
      final tokenType = typeMap[typeInt];
      final issuer = tokenMap['Issuer'] as String;
      final username = tokenMap['Username'] as String;
      final secret = tokenMap['Secret'] as String;
      final secretBytes = utf8.encode(secret);
      final digits = tokenMap['Digits'] as int;
      final period = tokenMap['Period'] as int;
      final counter = tokenMap['Counter'] as int;
      // final copyCount = tokenMap['CopyCount'] as int;
      // final ranking = tokenMap['Ranking'] as int;
      final algorithm = tokenMap['Algorithm'] as int;
      //  final pin = tokenMap['Pin'] as String?;
      //  final icon = tokenMap['Icon'] as String?;
      if (tokenType == null) {
        Logger.warning('Unsupported token type: $typeInt');
        continue;
      }
      final uriMap = {
        URI_TYPE: tokenType,
        URI_ISSUER: issuer,
        URI_LABEL: username,
        URI_SECRET: secretBytes,
        URI_DIGITS: digits,
        URI_PERIOD: period,
        URI_ALGORITHM: algorithmMap[algorithm],
        URI_COUNTER: counter,
        // URI_PIN: pin,
      };

      final token = Token.fromUriMap(uriMap);
      result.add(token);
    }
    return result;
  }
}
