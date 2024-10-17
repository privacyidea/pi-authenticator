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
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';

import '../../l10n/app_localizations.dart';
import '../../model/enums/token_origin_source_type.dart';
import '../../model/exception_errors/localized_exception.dart';
import '../../model/extensions/enums/token_origin_source_type.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/globals.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../../utils/object_validator.dart';
import '../../utils/token_import_origins.dart';
import '../scheme_processors/token_import_scheme_processors/free_otp_plus_qr_processor.dart';
import 'token_import_file_processor_interface.dart';

class FreeOtpPlusImportFileProcessor extends TokenImportFileProcessor {
  static get resultHandlerType => TokenImportFileProcessor.resultHandlerType;
  static const String _FREE_OTP_PLUS_ALGORITHM = 'algo'; // String: "MD5", "SHA1", "SHA256", "SHA512"
  static const String _FREE_OTP_PLUS_COUNTER = 'counter';
  static const String _FREE_OTP_PLUS_DIGITS = 'digits';
  static const String _FREE_OTP_PLUS_ISSUER = 'issuerExt';
  static const String _FREE_OTP_PLUS_LABEL = 'label';
  static const String _FREE_OTP_PLUS_PERIOD = 'period';
  static const String _FREE_OTP_PLUS_SECRET = 'secret'; // Base32 encoded
  static const String _FREE_OTP_PLUS_TYPE = 'type'; // String: "TOTP", "HOTP"
  static const String _steamTokenIssuer = "Steam";
  static const String _steamTokenType = "steam";

  const FreeOtpPlusImportFileProcessor();

  @override
  Future<bool> fileIsValid(XFile file) async {
    String contentString;
    try {
      contentString = await file.readAsString();
    } catch (e) {
      return false;
    }
    try {
      final json = jsonDecode(contentString) as Map<String, dynamic>;
      return json['tokens'] != null;
      // ignore: empty_catches
    } catch (e) {}
    List<String> lines = contentString.split('\n')..removeWhere((element) => element.isEmpty);
    if (lines.every((line) => line.isEmpty || line.startsWith('otpauth://'))) return true;
    return false;
  }

  @override
  Future<bool> fileNeedsPassword(XFile file) async => false;

  @override
  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password}) async {
    String content = await file.readAsString();
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      return _processJson(json);
      // ignore: empty_catches
    } catch (e) {}
    List<String> lines = content.split('\n')..removeWhere((element) => element.isEmpty);
    final results = <ProcessorResult<Token>>[];
    for (final line in lines) {
      try {
        final uri = Uri.parse(line);
        results.addAll(await const FreeOtpPlusQrProcessor().processUri(uri));
      } catch (e) {
        Logger.error('Failed to process line: $line', error: e, stackTrace: StackTrace.current);
        results.add(ProcessorResultFailed(
          e.toString(),
          resultHandlerType: resultHandlerType,
        ));
      }
    }
    return results.map((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.backupFile.addOriginToToken(
          appName: TokenImportOrigins.freeOtpPlus.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: t.resultData.origin!.data,
        ),
        resultHandlerType: resultHandlerType,
      );
    }).toList();
  }

  Future<List<ProcessorResult<Token>>> _processJson(Map<String, dynamic> json) async {
    final tokensJson = (json['tokens'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
    final tokens = <ProcessorResult<Token>>[];
    if (tokensJson == null) {
      return [];
    }
    for (var tokenJson in tokensJson) {
      tokens.add(await _processJsonToken(tokenJson));
    }
    return tokens;
  }

  Future<ProcessorResult<Token>> _processJsonToken(Map<String, dynamic> tokenJson) async {
    try {
      return ProcessorResultSuccess(
        Token.fromOtpAuthMap(
          _jsonToOtpAuth(tokenJson),
          additionalData: {
            Token.ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
              originName: TokenImportOrigins.freeOtpPlus.appName,
              isPrivacyIdeaToken: false,
              data: jsonEncode(tokenJson),
            ),
          },
        ),
        resultHandlerType: resultHandlerType,
      );
    } on LocalizedException catch (e) {
      return ProcessorResultFailed(
        e.localizedMessage(AppLocalizations.of(await globalContext)!),
        resultHandlerType: resultHandlerType,
      );
    } catch (e, s) {
      Logger.warning('Failed to parse token.', error: e, stackTrace: s);
      return ProcessorResultFailed(
        e.toString(),
        resultHandlerType: resultHandlerType,
      );
    }
  }

  Map<String, String> _jsonToOtpAuth(Map<String, dynamic> tokenJson) => validateMap(
        name: 'FreeOtpPlusToken',
        map: {
          /// Steam is a special case, its hardcoded in the original app.
          OTP_AUTH_TYPE: tokenJson[_FREE_OTP_PLUS_ISSUER] == _steamTokenIssuer ? _steamTokenType : tokenJson[_FREE_OTP_PLUS_TYPE],
          OTP_AUTH_LABEL: tokenJson[_FREE_OTP_PLUS_LABEL],
          OTP_AUTH_SECRET_BASE32: tokenJson[_FREE_OTP_PLUS_SECRET],
          OTP_AUTH_ISSUER: tokenJson[_FREE_OTP_PLUS_ISSUER],
          OTP_AUTH_ALGORITHM: tokenJson[_FREE_OTP_PLUS_ALGORITHM],
          OTP_AUTH_DIGITS: tokenJson[_FREE_OTP_PLUS_DIGITS],
          OTP_AUTH_COUNTER: tokenJson[_FREE_OTP_PLUS_COUNTER],
          OTP_AUTH_PERIOD_SECONDS: tokenJson[_FREE_OTP_PLUS_PERIOD],
        },
        validators: {
          OTP_AUTH_TYPE: const ObjectValidator<String>(),
          OTP_AUTH_LABEL: const ObjectValidator<String>(),
          OTP_AUTH_SECRET_BASE32: ObjectValidator<String>(transformer: (value) => Encodings.base32.encode(Uint8List.fromList((value as List).cast<int>()))),
          OTP_AUTH_ISSUER: const ObjectValidator<String>(),
          OTP_AUTH_ALGORITHM: const ObjectValidator<String>(),
          OTP_AUTH_DIGITS: intToStringValidator,
          // FreeOTP+ saves the counter 1 less than the actual value
          OTP_AUTH_COUNTER: ObjectValidatorNullable<String>(transformer: (value) => ((value as int) + 1).toString()),
          OTP_AUTH_PERIOD_SECONDS: intToStringValidatorNullable,
        },
      );
}
