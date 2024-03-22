// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:file_selector/file_selector.dart';
import 'package:privacyidea_authenticator/utils/token_import_origins.dart';

import '../../l10n/app_localizations.dart';
import '../../model/encryption/aes_encrypted.dart';
import '../../model/enums/algorithms.dart';
import '../../model/enums/encodings.dart';
import '../../model/enums/token_origin_source_type.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/globals.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import 'token_import_file_processor_interface.dart';

class TwoFasFileImportProcessor extends TokenImportFileProcessor {
  const TwoFasFileImportProcessor();
  static const String TWOFAS_TYPE = 'tokenType';
  static const String TWOFAS_ISSUER = 'name';
  static const String TWOFAS_SECRET = 'secret';
  static const String TWOFAS_LABEL = 'label';
  static const String TWOFAS_DIGITS = 'digits';
  static const String TWOFAS_COUNTER = 'counter';

  @override
  Future<List<ProcessorResult<Token>>> processFile({required XFile file, String? password}) async {
    final String fileContent = await file.readAsString();
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      throw InvalidFileContentException('No valid 2FAS import file');
    }
    if (password == null) return _processPlainFile(jsonString: fileContent, json: json);
    return processEncryptedFile(jsonString: fileContent, json: json, password: password);
  }

  @override
  Future<bool> fileNeedsPassword({required XFile file}) async {
    try {
      final Map<String, dynamic> json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json['servicesEncrypted'] != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> fileIsValid({required XFile file}) async {
    try {
      final Map<String, dynamic> json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json['servicesEncrypted'] != null || json['services'] != null;
    } catch (e) {
      return false;
    }
  }

  Future<List<ProcessorResult<Token>>> processEncryptedFile({String? jsonString, Map<String, dynamic>? json, required String password}) async {
    json ??= jsonDecode(jsonString!) as Map<String, dynamic>;
    if (json['servicesEncrypted'] == null) {
      if (json['services'] == null) {
        throw InvalidFileContentException('No valid 2FAS import file');
      } else {
        return _processPlainFile(json: json);
      }
    }
    final String decryptedTokens;
    final List<dynamic> decryptedTokensJsonList;
    try {
      final servicesEncrypted = json['servicesEncrypted'] as String;
      final splitted = servicesEncrypted.split(':');
      final dataWithMac = base64Decode(splitted[0]);

      final cypther = AesGcm.with256bits();
      final salt = base64Decode(splitted[1]);
      final iv = base64Decode(splitted[2]);

      decryptedTokens = await AesEncrypted(
        cypher: cypther,
        kdf: Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 10000, bits: salt.length),
        data: dataWithMac,
        salt: salt,
        iv: iv,
      ).decryptToString(password);
    } catch (e) {
      Logger.warning('Failed to decrypt 2FAS import file', error: e, name: 'two_fas_import_file_processor.dart#processEncryptedFile');
      throw BadDecryptionPasswordException('Wrong decryption password');
    }
    try {
      decryptedTokensJsonList = jsonDecode(decryptedTokens);
    } catch (e) {
      throw InvalidFileContentException('No valid 2FAS import file');
    }
    return await _processPlainTokens(decryptedTokensJsonList.cast<Map<String, dynamic>>());
  }

  Future<List<ProcessorResult<Token>>> _processPlainFile({String? jsonString, Map<String, dynamic>? json}) async {
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
        throw BadDecryptionPasswordException('2FAS import file is encrypted');
      }
    }
    Logger.info('2FAS import file contains ${tokensJsonList.length} tokens', name: 'two_fas_import_file_processor.dart#processPlainFile');
    return _processPlainTokens(tokensJsonList.cast<Map<String, dynamic>>());
  }

  Future<List<ProcessorResult<Token>>> _processPlainTokens(List<Map<String, dynamic>> tokensJsonList) async {
    final results = <ProcessorResult<Token>>[];
    for (Map<String, dynamic> twoFasToken in tokensJsonList) {
      try {
        results.add(ProcessorResult<Token>(success: true, resultData: Token.fromUriMap(_twoFasToUriMap(twoFasToken))));
      } on LocalizedException catch (e) {
        results.add(ProcessorResult<Token>(
          success: false,
          error: e.localizedMessage(AppLocalizations.of(await globalContext)!),
        ));
      } catch (e) {
        results.add(ProcessorResult<Token>(success: false, error: e.toString()));
      }
    }
    Logger.info('successfully imported ${results.length} tokens', name: 'two_fas_import_file_processor.dart#processPlainTokens');
    return results;
  }

  Map<String, dynamic> _twoFasToUriMap(Map<String, dynamic> twoFasToken) {
    final twoFasOTP = twoFasToken['otp'];
    return {
      URI_TYPE: twoFasOTP[TWOFAS_TYPE],
      URI_ISSUER: twoFasToken[TWOFAS_ISSUER],
      URI_SECRET: Encodings.none.decode(twoFasToken[TWOFAS_SECRET]),
      URI_LABEL: twoFasOTP[TWOFAS_LABEL],
      URI_DIGITS: twoFasOTP[TWOFAS_DIGITS],
      URI_COUNTER: twoFasOTP[TWOFAS_COUNTER],
      URI_ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
        appName: TokenImportOrigins.twoFasAuthenticator.appName,
        isPrivacyIdeaToken: false,
        data: jsonEncode(twoFasToken),
      ),
    };
  }
}

class BadDecryptionPasswordException implements Exception {
  final String message;
  BadDecryptionPasswordException(this.message);
  @override
  String toString() {
    return 'BadDecryptionPasswordException: $message';
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
