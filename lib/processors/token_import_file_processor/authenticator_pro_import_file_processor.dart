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
// ignore_for_file: constant_identifier_names, empty_catches

import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:file_selector/file_selector.dart';

import '../../l10n/app_localizations.dart';
import '../../model/encryption/uint_8_buffer.dart';
import '../../model/enums/algorithms.dart';
import '../../model/enums/token_origin_source_type.dart';
import '../../model/enums/token_types.dart';
import '../../model/extensions/enums/token_origin_source_type.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import '../../processors/token_import_file_processor/two_fas_import_file_processor.dart';
import '../../utils/encryption/aes_encrypted.dart';
import '../../utils/errors.dart';
import '../../utils/globals.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../../utils/object_validator.dart';
import '../../utils/token_import_origins.dart';
import 'token_import_file_processor_interface.dart';

class AuthenticatorProImportFileProcessor extends TokenImportFileProcessor {
  static get resultHandlerType => TokenImportFileProcessor.resultHandlerType;
  static const String header = "AUTHENTICATORPRO";
  static const String headerLegacy = "AuthenticatorPro";

  static const String _AUTHENTICATOR_PRO_TYPE = 'Type';
  static const String _AUTHENTICATOR_PRO_ISSUER = 'Issuer';
  static const String _AUTHENTICATOR_PRO_LABEL = 'Username';
  static const String _AUTHENTICATOR_PRO_SECRET = "Secret";
  static const String _AUTHENTICATOR_PRO_DIGITS = "Digits";
  static const String _AUTHENTICATOR_PRO_PERIOD = "Period";
  static const String _AUTHENTICATOR_PRO_COUNTER = "Counter";
  static const String _AUTHENTICATOR_PRO_ALGORITHM = "Algorithm";

  static final typeMap = {
    1: TokenTypes.HOTP.name,
    2: TokenTypes.TOTP.name,
    //  3: 'mOTP', // Not supported
    4: TokenTypes.STEAM.name,
    //   5: 'Yandex', // Not supported
  };

  static final algorithmMap = {
    0: Algorithms.SHA1.name,
    1: Algorithms.SHA256.name,
    2: Algorithms.SHA512.name,
  };

  const AuthenticatorProImportFileProcessor();

  @override
  Future<bool> fileIsValid(XFile file) async {
    final contentBytes = await file.readAsBytes();
    try {
      final contentString = utf8.decode(contentBytes);
      try {
        // Check if it's a JSON with plain tokens
        if (json.decode(contentString)['Authenticators'] != null) return true;
      } catch (e) {}
      try {
        // Check if it's the HTML export
        if (contentString.startsWith('<!doctype html>')) return true;
      } catch (e) {}
      try {
        // Check if it's a list of URIs
        List<String> lines = contentString.split('\n')..removeWhere((element) => element.isEmpty);
        if (lines.every((line) => line.isEmpty || line.startsWith('otpauth://'))) return true;
      } catch (e) {}
      // Its utf8 encoded, but not a JSON, HTML or URI list, so it's not valid -> return false
      Logger.warning(
        'File is not a valid Authenticator Pro backup file',
        error: 'Invalid content: $contentString',
      );
      return false;
    } catch (e) {
      // When utf8 decoding fails, it's may be encrypted
      try {
        final headerByteLength = utf8.encode(header).length;
        final importedHeader = contentBytes.sublist(0, headerByteLength);
        final fileHeader = utf8.decode(importedHeader);
        if (fileHeader == header || fileHeader == headerLegacy) {
          return true;
        }
      } catch (e) {}
      Logger.warning(
        'File is not a valid Authenticator Pro backup file',
        error: 'Content Bytes: $contentBytes',
      );
    }
    // It's not utf8 encoded and not encrypted, so it's not valid -> return false
    return false;
  }

  @override
  Future<bool> fileNeedsPassword(XFile file) async {
    final contentBytes = await file.readAsBytes();

    try {
      utf8.decode(contentBytes);

      return false;
    } catch (e) {
      final headerByteLength = utf8.encode(header).length;
      final fileHeaderBytes = contentBytes.sublist(0, headerByteLength);
      final fileHeader = utf8.decode(fileHeaderBytes);

      if (fileHeader == header || fileHeader == headerLegacy) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password}) async {
    var results = <ProcessorResult<Token>>[];
    final bytes = await file.readAsBytes();
    Uint8Buffer uint8buffer = Uint8Buffer(data: bytes);
    final headerByteLength = utf8.encode(header).length;
    final fileHeader = utf8.decode(uint8buffer.readBytes(headerByteLength));
    Logger.info('File header: $fileHeader');
    final plainText = switch (fileHeader) {
      header => await _processEncrypted(uint8buffer: uint8buffer, password: password ?? ''),
      headerLegacy => await _processEncryptedLegacy(uint8buffer: uint8buffer, password: password ?? ''),
      _ => utf8.decode(bytes),
    };
    results = await _processPlain(fileContent: plainText);

    return results.map((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.backupFile.addOriginToToken(
          appName: TokenImportOrigins.authenticatorPro.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: t.resultData.origin!.data,
        ),
        resultHandlerType: resultHandlerType,
      );
    }).toList();
  }

  Future<String> _processEncrypted({required Uint8Buffer uint8buffer, required String password}) async {
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

    try {
      return await aesEncrypted.decryptToString(password);
    } catch (e) {
      throw BadDecryptionPasswordException('Invalid password');
    }
  }

  Future<String> _processEncryptedLegacy({required Uint8Buffer uint8buffer, required String password}) async {
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

    try {
      return await aesEncrypted.decryptToString(password);
    } catch (e) {
      throw BadDecryptionPasswordException('Invalid password');
    }
  }

  Future<List<ProcessorResult<Token>>> _processPlain({required String fileContent}) async {
    try {
      final tokensMap = (json.decode(fileContent)['Authenticators'].cast<Map<String, dynamic>>()) as List<Map<String, dynamic>>;
      return _processJson(tokensMap: tokensMap);
    } catch (e) {
      try {
        final lines = fileContent.split('\n').where((e) => e.isNotEmpty).map((e) => Uri.parse(e)).toList();
        return _processUriList(lines: lines);
      } catch (e) {
        if (fileContent.startsWith('<!doctype html>')) {
          return _processHtml(fileContent: fileContent);
        }
      }
    }
    return [];
  }

  Future<List<ProcessorResult<Token>>> _processUriList({required List<Uri> lines}) async {
    final results = <ProcessorResult<Token>>[];
    for (var uri in lines) {
      try {
        final newResults = await const OtpAuthProcessor().processUri(uri);
        results.addAll(newResults);
      } on LocalizedException catch (e) {
        results.add(ProcessorResultFailed(
          e.localizedMessage(AppLocalizations.of(await globalContext)!),
          resultHandlerType: resultHandlerType,
        ));
      } catch (e) {
        Logger.error('Failed to parse token.', error: e, stackTrace: StackTrace.current);
        results.add(ProcessorResultFailed(
          e.toString(),
          resultHandlerType: resultHandlerType,
        ));
      }
    }
    return results;
  }

  Future<List<ProcessorResult<Token>>> _processHtml({required String fileContent}) async {
    RegExp exp = RegExp(r'(?<=(\<code\>)).*(?=(\<\/code\>))');
    final results = <ProcessorResult<Token>>[];
    try {
      final matches = exp.allMatches(fileContent);
      for (var match in matches) {
        final uri = Uri.parse(match.group(0)!);
        final newResults = await const OtpAuthProcessor().processUri(uri);
        for (final newResult in newResults) {
          if (newResult is! ProcessorResultSuccess<Token>) {
            results.add(newResult);
            continue;
          }
          results.add(
            ProcessorResultSuccess(
              TokenOriginSourceType.backupFile.addOriginToToken(
                appName: TokenImportOrigins.authenticatorPro.appName,
                isPrivacyIdeaToken: false,
                token: newResult.resultData,
                data: uri.toString(),
              ),
              resultHandlerType: resultHandlerType,
            ),
          );
        }
      }
    } on LocalizedException catch (e) {
      results.add(ProcessorResultFailed(
        e.localizedMessage(AppLocalizations.of(await globalContext)!),
        resultHandlerType: resultHandlerType,
      ));
    } catch (e) {
      Logger.error('Failed to parse token.', error: e, stackTrace: StackTrace.current);
      results.add(ProcessorResultFailed(
        e.toString(),
        resultHandlerType: resultHandlerType,
      ));
    }
    return results;
  }

  Future<List<ProcessorResult<Token>>> _processJson({required List<Map<String, dynamic>> tokensMap}) async {
    Logger.info('Processing plain file');
    final result = <ProcessorResult<Token>>[];
    for (var tokenMap in tokensMap) {
      try {
        final typeInt = tokenMap[_AUTHENTICATOR_PRO_TYPE] as int;
        final tokenType = typeMap[typeInt];
        if (tokenType == null) {
          Logger.warning('Unsupported token type: $typeInt');
          continue;
        }

        final otpAuthMap = validateMap<String>(
          map: {
            OTP_AUTH_TYPE: tokenType,
            OTP_AUTH_ISSUER: tokenMap[_AUTHENTICATOR_PRO_ISSUER],
            OTP_AUTH_LABEL: tokenMap[_AUTHENTICATOR_PRO_LABEL],
            OTP_AUTH_SECRET_BASE32: tokenMap[_AUTHENTICATOR_PRO_SECRET],
            OTP_AUTH_DIGITS: tokenMap[_AUTHENTICATOR_PRO_DIGITS],
            OTP_AUTH_PERIOD_SECONDS: tokenMap[_AUTHENTICATOR_PRO_PERIOD],
            OTP_AUTH_ALGORITHM: tokenMap[_AUTHENTICATOR_PRO_ALGORITHM],
            OTP_AUTH_COUNTER: tokenMap[_AUTHENTICATOR_PRO_COUNTER],
          },
          validators: {
            OTP_AUTH_TYPE: const ObjectValidator<String>(),
            OTP_AUTH_ISSUER: const ObjectValidator<String>(),
            OTP_AUTH_LABEL: const ObjectValidator<String>(),
            OTP_AUTH_SECRET_BASE32: const ObjectValidator<String>(),
            OTP_AUTH_DIGITS: intToStringValidator,
            OTP_AUTH_PERIOD_SECONDS: intToStringValidator,
            OTP_AUTH_ALGORITHM: ObjectValidator<String>(transformer: (value) => algorithmMap[value]!),
            OTP_AUTH_COUNTER: intToStringValidator,
          },
          name: 'AuthenticatorProToken',
        );

        final token = Token.fromOtpAuthMap(
          otpAuthMap,
          additionalData: {
            Token.ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
              originName: TokenImportOrigins.authenticatorPro.appName,
              isPrivacyIdeaToken: false,
              data: jsonEncode(tokenMap),
            ),
          },
        );
        result.add(ProcessorResultSuccess(
          token,
          resultHandlerType: resultHandlerType,
        ));
      } on LocalizedException catch (e) {
        result.add(ProcessorResultFailed(
          e.localizedMessage(AppLocalizations.of(await globalContext)!),
          resultHandlerType: resultHandlerType,
        ));
      } catch (e) {
        Logger.error('Failed to parse token.', error: e, stackTrace: StackTrace.current);
        result.add(ProcessorResultFailed(
          e.toString(),
          resultHandlerType: resultHandlerType,
        ));
      }
    }
    return result;
  }
}
