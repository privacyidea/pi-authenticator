/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:file_selector/file_selector.dart';

import '../../model/enums/token_origin_source_type.dart';
import '../../model/exception_errors/localized_exception.dart';
import '../../model/extensions/enums/token_origin_source_type.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/hotp_token.dart';
import '../../model/tokens/otp_token.dart';
import '../../model/tokens/token.dart';
import '../../model/tokens/totp_token.dart';
import '../../utils/encryption/aes_encrypted.dart';
import '../../utils/logger.dart';
import '../../utils/object_validator.dart';
import '../../utils/token_import_origins.dart';
import 'token_import_file_processor_interface.dart';

class TwoFasAuthenticatorImportFileProcessor extends TokenImportFileProcessor {
  static get resultHandlerType => TokenImportFileProcessor.resultHandlerType;
  const TwoFasAuthenticatorImportFileProcessor();
  static const String TWOFAS_OTP = 'otp';
  static const String TWOFAS_TYPE = 'tokenType';
  static const String TWOFAS_ISSUER = 'name';
  static const String TWOFAS_SECRET = 'secret';
  static const String TWOFAS_ALGORITHM = 'algorithm';
  static const String TWOFAS_LABEL = 'label';
  static const String TWOFAS_DIGITS = 'digits';
  static const String TWOFAS_PERIOD = 'period';
  static const String TWOFAS_COUNTER = 'counter';

  @override
  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password}) async {
    final String fileContent = await file.readAsString();
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      throw InvalidFileContentException('No valid 2FAS import file');
    }
    if (password == null) return _processPlainFile(json: json);
    return processEncryptedFile(jsonString: fileContent, json: json, password: password);
  }

  @override
  Future<bool> fileIsValid(XFile file) async {
    try {
      final Map<String, dynamic> json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json['servicesEncrypted'] != null || json['services'] != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> fileNeedsPassword(XFile file) async {
    try {
      final Map<String, dynamic> json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return json['servicesEncrypted'] != null;
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
      Logger.warning('Failed to decrypt 2FAS import file');
      throw BadDecryptionPasswordException('Wrong decryption password');
    }
    try {
      decryptedTokensJsonList = jsonDecode(decryptedTokens);
    } catch (e) {
      throw InvalidFileContentException('No valid 2FAS import file');
    }
    return await _processPlainTokens(decryptedTokensJsonList.cast<Map<String, dynamic>>());
  }

  Future<List<ProcessorResult<Token>>> _processPlainFile({required Map<String, dynamic> json}) async {
    final tokensJsonList = json['services'] as List<dynamic>?;
    if (tokensJsonList == null || tokensJsonList.isEmpty) {
      if (json['servicesEncrypted'] == null) {
        throw InvalidFileContentException('No valid 2FAS import file');
      } else {
        Logger.warning('2FAS import file is encrypted');
        throw BadDecryptionPasswordException('2FAS import file is encrypted');
      }
    }
    Logger.info('2FAS import file contains ${tokensJsonList.length} tokens');
    return _processPlainTokens(tokensJsonList.cast<Map<String, dynamic>>());
  }

  Future<List<ProcessorResult<Token>>> _processPlainTokens(List<Map<String, dynamic>> tokensJsonList) async {
    final results = <ProcessorResult<Token>>[];
    for (Map<String, dynamic> twoFasToken in tokensJsonList) {
      try {
        results.add(ProcessorResult.success(
          Token.fromOtpAuthMap(
            _twoFasToOtpAuth(twoFasToken),
            additionalData: {
              Token.ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
                originName: TokenImportOrigins.twoFasAuthenticator.appName,
                isPrivacyIdeaToken: false,
                data: jsonEncode(twoFasToken),
              ),
            },
          ),
          resultHandlerType: resultHandlerType,
        ));
      } on LocalizedException catch (e) {
        results.add(ProcessorResult.failed(
          (localization) => e.localizedMessage(localization),
          resultHandlerType: resultHandlerType,
        ));
      } catch (e) {
        Logger.error('Failed to parse token.', error: e, stackTrace: StackTrace.current);
        results.add(ProcessorResultFailed(
          (_) => e.toString(),
          resultHandlerType: resultHandlerType,
        ));
      }
    }
    Logger.info('successfully imported ${results.length} tokens');
    return results;
  }

  Map<String, String> _twoFasToOtpAuth(Map<String, dynamic> twoFasToken) {
    Map<String, dynamic> twoFasOTP = twoFasToken[TWOFAS_OTP];
    return validateMap(
      map: {
        Token.ISSUER: twoFasToken[TWOFAS_ISSUER],
        Token.TYPE: twoFasOTP[TWOFAS_TYPE],
        Token.LABEL: twoFasOTP[TWOFAS_LABEL],
        OTPToken.SECRET_BASE32: twoFasToken[TWOFAS_SECRET],
        OTPToken.ALGORITHM: twoFasOTP[TWOFAS_ALGORITHM],
        OTPToken.DIGITS: twoFasOTP[TWOFAS_DIGITS],
        TOTPToken.PERIOD_SECONDS: twoFasOTP[TWOFAS_PERIOD],
        HOTPToken.COUNTER: twoFasOTP[TWOFAS_COUNTER],
      },
      validators: {
        Token.TYPE: const ObjectValidator<String>(),
        Token.ISSUER: const ObjectValidatorNullable<String>(),
        Token.LABEL: const ObjectValidatorNullable<String>(),
        OTPToken.SECRET_BASE32: const ObjectValidator<String>(),
        OTPToken.ALGORITHM: const ObjectValidatorNullable<String>(),
        OTPToken.DIGITS: intToStringValidatorNullable,
        TOTPToken.PERIOD_SECONDS: intToStringValidatorNullable,
        HOTPToken.COUNTER: intToStringValidatorNullable,
      },
      name: '2FAS token',
    );
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
