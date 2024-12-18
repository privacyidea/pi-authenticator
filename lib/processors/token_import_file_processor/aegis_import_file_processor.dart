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
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import 'package:file_selector/file_selector.dart';
import 'package:pointycastle/export.dart';

import '../../model/enums/encodings.dart';
import '../../model/enums/token_origin_source_type.dart';
import '../../model/exception_errors/localized_argument_error.dart';
import '../../model/exception_errors/localized_exception.dart';
import '../../model/extensions/enums/encodings_extension.dart';
import '../../model/extensions/enums/token_origin_source_type.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/hotp_token.dart';
import '../../model/tokens/otp_token.dart';
import '../../model/tokens/token.dart';
import '../../model/tokens/totp_token.dart';
import '../../utils/logger.dart';
import '../../utils/object_validator.dart';
import '../../utils/token_import_origins.dart';
import 'token_import_file_processor_interface.dart';
import 'two_fas_import_file_processor.dart';

//TODO:Test Again

/// Args: [SendPort] sendPort, [ScryptParameters] scryptParameters, [String] password
void _isolatedKdf(List args) {
  final SendPort sendPort = args[0] as SendPort;
  final scryptParameters = args[1] as ScryptParameters;
  final String? password = args[2] as String?;

  final kdf = Scrypt();
  kdf.init(scryptParameters);
  final Uint8List inp = Uint8List.fromList(utf8.encode(password!));
  final Uint8List keyBytes = Uint8List(32);
  kdf.deriveKey(inp, 0, keyBytes, 0);

  sendPort.send(keyBytes);
}

class AegisImportFileProcessor extends TokenImportFileProcessor {
  static get resultHandlerType => TokenImportFileProcessor.resultHandlerType;

  const AegisImportFileProcessor();
  static const String AEGIS_JSON_HEADER = 'header';
  static const String AEGIS_HEADER_SLOTS = 'slots';
  static const String AEGIS_SLOT_KEYPARAMS = 'key_params';
  static const String AEGIS_KEYPARAMS_NONCE = 'nonce';
  static const String AEGIS_KEYPARAMS_TAG = 'tag';
  static const String AEGIS_SLOT_N = 'n';
  static const String AEGIS_SLOT_R = 'r';
  static const String AEGIS_SLOT_P = 'p';
  static const String AEGIS_SLOT_SALT = 'salt';
  static const String AEGIS_SLOT_KEY = 'key';
  static const String AEGIS_HEADER_HEADERPARAMS = 'params';
  static const String AEGIS_HEADERPARAMS_NONCE = 'nonce';
  static const String AEGIS_HEADERPARAMS_TAG = 'tag';
  static const String AEGIS_JSON_DB = 'db';
  static const String AEGIS_DB_VERSION = 'version';
  static const String AEGIS_DB_ENTRIES = 'entries';
  static const String AEGIS_ENTRY_INFO = 'info';

  static const String AEGIS_ENTRY_TYPE = 'type';
  static const String AEGIS_ENTRY_ID = 'uuid';
  static const String AEGIS_ENTRY_LABEL = 'name';
  static const String AEGIS_ENTRY_ISSUER = 'issuer';
  static const String AEGIS_ENTRY_NOTE = 'note'; // Not used
  static const String AEGIS_ENTRY_ICON = 'icon'; // Not used
  static const String AEGIS_INFO_SECRET = 'secret';
  static const String AEGIS_INFO_ALGORITHM = 'algo';
  static const String AEGIS_INFO_DIGITS = 'digits';
  static const String AEGIS_INFO_PERIOD = 'period';
  static const String AEGIS_INFO_COUNTER = 'counter';
  static const String AEGIS_INFO_PIN = 'pin';
  static const String AEGIS_ENTRY_GROUPS = 'groups'; // Not used

  bool _isValidPlain(Map<String, dynamic> json) {
    try {
      return json[AEGIS_JSON_DB] != null &&
          json[AEGIS_JSON_DB] is Map<String, dynamic> &&
          json[AEGIS_JSON_DB][AEGIS_DB_ENTRIES] != null &&
          json[AEGIS_JSON_DB][AEGIS_DB_ENTRIES].length > 0;
    } catch (e) {
      return false;
    }
  }

  bool _isValidEncrypted(Map<String, dynamic> json) {
    try {
      return json[AEGIS_JSON_HEADER] != null &&
          json[AEGIS_JSON_HEADER][AEGIS_HEADER_SLOTS] != null &&
          (json[AEGIS_JSON_HEADER][AEGIS_HEADER_SLOTS] as List).isNotEmpty &&
          json[AEGIS_JSON_DB] != null &&
          (json[AEGIS_JSON_DB] is String);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> fileIsValid(XFile file) async {
    final Map<String, dynamic> json;
    try {
      final String fileContent = await file.readAsString();
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      return false;
    }
    return _isValidPlain(json) || _isValidEncrypted(json);
  }

  @override
  Future<bool> fileNeedsPassword(XFile file) async {
    Map<String, dynamic> json;
    try {
      final String fileContent = await file.readAsString();
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      return false;
    }
    return _isValidEncrypted(json);
  }

  @override
  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password}) async {
    final String fileContent = await file.readAsString();
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (e) {
      throw InvalidFileContentException('No valid Aegis import file');
    }
    if (_isValidPlain(json)) {
      return _processPlain(json);
    } else if (_isValidEncrypted(json)) {
      return _processEncrypted(json, password);
    } else {
      throw Exception('Invalid file format');
    }
  }

  Future<List<ProcessorResult<Token>>> _processPlain(Map<String, dynamic> json) async => switch (json[AEGIS_JSON_DB][AEGIS_DB_VERSION] as int) {
        2 => _processPlainV2(json),
        3 => _processPlainV3(json),
        _ => _processPlainTryLatest(json),
      };

  Future<List<ProcessorResult<Token>>> _processPlainTryLatest(Map<String, dynamic> json) async {
    try {
      return await _processPlainV3(json);
    } catch (_) {
      throw LocalizedArgumentError(
        localizedMessage: (localizations, value, name) => localizations.unsupported(name, value),
        unlocalizedMessage: 'Unsupported backup version: ${json[AEGIS_JSON_DB][AEGIS_DB_VERSION]}.',
        invalidValue: json[AEGIS_JSON_DB][AEGIS_DB_VERSION],
        name: 'aegis backup version',
      );
    }
  }

  Future<List<ProcessorResult<Token>>> _processPlainV2(Map<String, dynamic> json) {
    final results = <ProcessorResult<Token>>[];
    for (Map<String, dynamic> entry in json[AEGIS_JSON_DB][AEGIS_DB_ENTRIES]) {
      try {
        Map<String, dynamic> info = entry[AEGIS_ENTRY_INFO];
        final otpAuthMap = validateMap<String>(
          map: {
            Token.OTPAUTH_TYPE: entry[AEGIS_ENTRY_TYPE],
            Token.LABEL: entry[AEGIS_ENTRY_LABEL],
            Token.ISSUER: entry[AEGIS_ENTRY_ISSUER],
            Token.PIN: info[AEGIS_INFO_PIN],
            OTPToken.SECRET_BASE32: entry[AEGIS_INFO_SECRET],
            OTPToken.ALGORITHM: info[AEGIS_INFO_ALGORITHM],
            OTPToken.DIGITS: info[AEGIS_INFO_DIGITS],
            TOTPToken.PERIOD_SECONDS: info[AEGIS_INFO_PERIOD],
            HOTPToken.COUNTER: info[AEGIS_INFO_COUNTER],
          },
          validators: {
            Token.OTPAUTH_TYPE: const ObjectValidator<String>(),
            Token.LABEL: const ObjectValidator<String>(defaultValue: ''),
            Token.ISSUER: const ObjectValidator<String>(defaultValue: ''),
            Token.PIN: const ObjectValidatorNullable<String>(),
            OTPToken.SECRET_BASE32: ObjectValidator<String>(transformer: (v) => Encodings.none.encodeStringTo(Encodings.base32, info[AEGIS_INFO_SECRET])),
            OTPToken.ALGORITHM: const ObjectValidatorNullable<String>(),
            OTPToken.DIGITS: ObjectValidatorNullable<String>(transformer: (v) => (v as int).toString()),
            TOTPToken.PERIOD_SECONDS: ObjectValidatorNullable<String>(transformer: (v) => (v as int).toString()),
            HOTPToken.COUNTER: ObjectValidatorNullable<String>(transformer: (v) => (v as int).toString()),
          },
          name: 'aegisV2Entry',
        );

        final token = Token.fromOtpAuthMap(otpAuthMap, additionalData: {
          Token.ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
            originName: TokenImportOrigins.aegisAuthenticator.appName,
            isPrivacyIdeaToken: false,
            data: jsonEncode(entry),
          ),
        });
        results.add(ProcessorResult.success(
          token.copyWith(id: entry[AEGIS_ENTRY_ID]),
          resultHandlerType: resultHandlerType,
        ));
      } on LocalizedException catch (e) {
        results.add(ProcessorResult.failed(
          (localization) => e.localizedMessage(localization),
          resultHandlerType: resultHandlerType,
        ));
      } catch (e) {
        Logger.error('Failed to parse token.', error: e, stackTrace: StackTrace.current);
        results.add(ProcessorResult.failed(
          (_) => e.toString(),
          resultHandlerType: resultHandlerType,
        ));
      }
    }
    return Future.value(results);
  }

  Future<List<ProcessorResult<Token>>> _processPlainV3(Map<String, dynamic> json) {
    final results = <ProcessorResult<Token>>[];
    final entries = json[AEGIS_JSON_DB][AEGIS_DB_ENTRIES] as List;
    for (Map<String, dynamic> entry in entries) {
      try {
        Map<String, dynamic> info = entry[AEGIS_ENTRY_INFO];
        final otpAuthMap = validateMap<String>(
          map: {
            Token.OTPAUTH_TYPE: entry[AEGIS_ENTRY_TYPE],
            Token.LABEL: entry[AEGIS_ENTRY_LABEL],
            Token.ISSUER: entry[AEGIS_ENTRY_ISSUER],
            OTPToken.SECRET_BASE32: info[AEGIS_INFO_SECRET],
            OTPToken.ALGORITHM: info[AEGIS_INFO_ALGORITHM],
            OTPToken.DIGITS: info[AEGIS_INFO_DIGITS],
            TOTPToken.PERIOD_SECONDS: info[AEGIS_INFO_PERIOD],
            HOTPToken.COUNTER: info[AEGIS_INFO_COUNTER],
            Token.PIN: info[AEGIS_INFO_PIN],
          },
          validators: {
            Token.OTPAUTH_TYPE: const ObjectValidator<String>(),
            Token.LABEL: const ObjectValidator<String>(defaultValue: ''),
            Token.ISSUER: const ObjectValidator<String>(defaultValue: ''),
            OTPToken.SECRET_BASE32: ObjectValidator<String>(transformer: (v) => Encodings.base32.encodeStringTo(Encodings.base32, v)),
            OTPToken.ALGORITHM: const ObjectValidatorNullable<String>(),
            OTPToken.DIGITS: intToStringValidatorNullable,
            TOTPToken.PERIOD_SECONDS: intToStringValidatorNullable,
            HOTPToken.COUNTER: intToStringValidatorNullable,
            Token.PIN: const ObjectValidatorNullable<String>(),
          },
          name: 'aegisV3Entry',
        );
        results.add(ProcessorResult.success(
          Token.fromOtpAuthMap(
            otpAuthMap,
            additionalData: {
              Token.ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
                originName: TokenImportOrigins.aegisAuthenticator.appName,
                isPrivacyIdeaToken: false,
                data: jsonEncode(entry),
              ),
            },
          ),
          resultHandlerType: resultHandlerType,
        ));
      } on LocalizedException catch (e) {
        results.add(ProcessorResultFailed(
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

    return Future.value(results);
  }

  Future<Uint8List> runIsolatedKdf(ScryptParameters scryptParameters, String password) async {
    final receivePort = ReceivePort();
    try {
      Isolate.spawn(_isolatedKdf, [receivePort.sendPort, scryptParameters, password]);
    } catch (e) {
      receivePort.close();
    }
    final Uint8List keyBytes = await receivePort.first;
    return keyBytes;
  }

  Future<List<ProcessorResult<Token>>> _processEncrypted(Map<String, dynamic> json, String? password) async {
    final String dbEncrypted = json[AEGIS_JSON_DB];
    final Map<String, dynamic> header = json[AEGIS_JSON_HEADER];
    final Map<String, dynamic> headerParams = header[AEGIS_HEADER_HEADERPARAMS];
    final Map<String, dynamic> slot = header[AEGIS_HEADER_SLOTS].first;
    final Map<String, dynamic> keyParams = slot[AEGIS_SLOT_KEYPARAMS];

    final passwordKeyBytes = await runIsolatedKdf(
      ScryptParameters(slot[AEGIS_SLOT_N], slot[AEGIS_SLOT_R], slot[AEGIS_SLOT_P], 32, decodeHexString(slot[AEGIS_SLOT_SALT])),
      password!,
    );
    final slotNonceBytes = decodeHexString(keyParams[AEGIS_KEYPARAMS_NONCE]);
    final cipher = crypto.AesGcm.with256bits(nonceLength: slotNonceBytes.length);
    final List<int> masterKeyBytes;

    try {
      masterKeyBytes = await cipher.decrypt(
        crypto.SecretBox(
          decodeHexString(slot[AEGIS_SLOT_KEY]),
          nonce: slotNonceBytes,
          mac: crypto.Mac(decodeHexString(keyParams[AEGIS_KEYPARAMS_TAG])),
        ),
        secretKey: crypto.SecretKey(passwordKeyBytes),
      );
    } catch (e) {
      throw BadDecryptionPasswordException('Wrong password or corrupted data');
    }
    final dbDecryptedBytes = await cipher.decrypt(
      crypto.SecretBox(
        base64Decode(dbEncrypted),
        nonce: decodeHexString(headerParams[AEGIS_HEADERPARAMS_NONCE]),
        mac: crypto.Mac(decodeHexString(headerParams[AEGIS_HEADERPARAMS_TAG])),
      ),
      secretKey: crypto.SecretKey(masterKeyBytes),
    );
    final dbDecrypted = utf8.decode(dbDecryptedBytes);
    final dbJson = jsonDecode(dbDecrypted) as Map<String, dynamic>;
    return _processPlain({AEGIS_JSON_DB: dbJson});
  }
}
