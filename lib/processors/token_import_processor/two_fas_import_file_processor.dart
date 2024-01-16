// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../model/encryption/aes_encrypted.dart';
import '../../model/token_origin.dart';
import '../../model/tokens/token.dart';
import '../../utils/crypto_utils.dart';
import '../../utils/identifiers.dart';
import 'token_import_file_processor_interface.dart';

class TwoFasImportFileProcessor extends TokenImportProcessor {
  const TwoFasImportFileProcessor();
  static const String TWOFAS_TYPE = 'tokenType';
  static const String TWOFAS_ISSUER = 'name';
  static const String TWOFAS_SECRET = 'secret';
  static const String TWOFAS_LABEL = 'label';
  static const String TWOFAS_DIGITS = 'digits';
  static const String TWOFAS_COUNTER = 'counter';

  @override
  Future<List<Token>> process({String? jsonString, Map<String, dynamic>? json, String? password}) async {
    assert(jsonString != null || json != null);
    assert(jsonString == null || json == null);
    if (password == null) return processPlainFile(jsonString: jsonString, json: json);
    return processEncryptedFile(jsonString: jsonString, json: json, password: password);
  }

  @override
  bool fileContentNeedsPassword({String? jsonString, Map<String, dynamic>? json}) {
    assert(jsonString != null || json != null);
    assert(jsonString == null || json == null);
    try {
      json ??= jsonDecode(jsonString!) as Map<String, dynamic>;
    } catch (e) {
      return false;
    }
    return json['servicesEncrypted'] != null;
  }

  @override
  bool fileContentIsValid({String? jsonString, Map<String, dynamic>? json}) {
    assert(jsonString != null || json != null);
    assert(jsonString == null || json == null);
    try {
      json ??= jsonDecode(jsonString!) as Map<String, dynamic>;
    } catch (e) {
      return false;
    }
    if (json['servicesEncrypted'] == null && json['services'] == null) {
      return false;
    }
    return true;
  }

  Future<List<Token>> processEncryptedFile({String? jsonString, Map<String, dynamic>? json, required String password}) async {
    json ??= jsonDecode(jsonString!) as Map<String, dynamic>;
    if (json['servicesEncrypted'] == null) {
      if (json['services'] == null) {
        throw InvalidFileContentException('No valid 2FAS import file');
      } else {
        return processPlainFile(json: json);
      }
    }
    final String decryptedTokens;
    final List<dynamic> decryptedTokensJsonList;
    try {
      decryptedTokens = await AESEncrypted.fromSingleEncryptedString(json['servicesEncrypted']).decrypt(password);
    } catch (e) {
      Logger.warning('Failed to decrypt 2FAS import file', error: e, name: 'two_fas_import_file_processor.dart#processEncryptedFile');
      throw WrongDecryptionPasswordException('Wrong decryption password');
    }
    try {
      decryptedTokensJsonList = jsonDecode(decryptedTokens);
    } catch (e) {
      throw InvalidFileContentException('No valid 2FAS import file');
    }
    final List<Token> tokens = await processPlainTokens(decryptedTokensJsonList.cast<Map<String, dynamic>>());
    return tokens;
  }

  Future<List<Token>> processPlainFile({String? jsonString, Map<String, dynamic>? json}) async {
    try {
      json ??= jsonDecode(jsonString!) as Map<String, dynamic>;
    } catch (e) {
      throw InvalidFileContentException('No valid 2FAS import file');
    }
    final tokensJsonList = json['services'] as List<dynamic>?;
    if (tokensJsonList == null || tokensJsonList.isEmpty) {
      if (json['servicesEncrypted'] == null) {
        throw InvalidFileContentException('No valid 2FAS import file');
      } else {
        Logger.warning('2FAS import file is encrypted', name: 'two_fas_import_file_processor.dart#processPlainFile');
        throw WrongDecryptionPasswordException('2FAS import file is encrypted');
      }
    }
    Logger.info('2FAS import file contains ${tokensJsonList.length} tokens', name: 'two_fas_import_file_processor.dart#processPlainFile');
    return processPlainTokens(tokensJsonList.cast<Map<String, dynamic>>());
  }

  Future<List<Token>> processPlainTokens(List<Map<String, dynamic>> tokensJsonList) async {
    final List<Token> tokens = [];
    for (Map<String, dynamic> twoFasToken in tokensJsonList) {
      tokens.add(Token.fromUriMap(_twoFasToUriMap(twoFasToken)));
    }
    Logger.warning('successfully imported ${tokens.length} tokens', name: 'two_fas_import_file_processor.dart#processPlainTokens');
    return tokens;
  }

  Map<String, dynamic> _twoFasToUriMap(Map<String, dynamic> twoFasToken) {
    final twoFasOTP = twoFasToken['otp'];
    return {
      URI_TYPE: twoFasOTP[TWOFAS_TYPE],
      URI_ISSUER: twoFasToken[TWOFAS_ISSUER],
      URI_SECRET: decodeSecretToUint8(twoFasToken[TWOFAS_SECRET], Encodings.none),
      URI_LABEL: twoFasOTP[TWOFAS_LABEL],
      URI_DIGITS: twoFasOTP[TWOFAS_DIGITS],
      URI_COUNTER: twoFasOTP[TWOFAS_COUNTER],
      URI_ORIGIN: TokenOrigin(
        source: TokenOriginSourceType.import,
        appName: '2FAS Authenticator',
        data: jsonEncode(twoFasToken),
      ),
    };
  }
}

class WrongDecryptionPasswordException implements Exception {
  final String message;
  WrongDecryptionPasswordException(this.message);
  @override
  String toString() {
    return 'WrongDecryptionPasswordException: $message';
  }
}

class InvalidFileContentException implements Exception {
  final String message;
  InvalidFileContentException(this.message);
  @override
  String toString() {
    return 'InvalidFileContentException: $message';
  }
}
