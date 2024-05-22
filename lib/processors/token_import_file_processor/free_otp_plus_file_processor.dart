// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../utils/errors.dart';
import '../../utils/identifiers.dart';
import '../../utils/token_import_origins.dart';
import '../scheme_processors/token_import_scheme_processors/free_otp_plus_qr_processor.dart';
import 'token_import_file_processor_interface.dart';

class FreeOtpPlusFileProcessor extends TokenImportFileProcessor {
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

  const FreeOtpPlusFileProcessor();

  @override
  Future<bool> fileIsValid(XFile file) async {
    String content;
    try {
      content = await file.readAsString();
    } catch (e) {
      return false;
    }
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      return json['tokens'] != null;
      // ignore: empty_catches
    } catch (e) {}
    List<String> lines = content.split('\n')..removeWhere((element) => element.isEmpty);
    for (var line in lines) {
      if (line.startsWith('otpauth://') == false) {
        return false;
      }
    }
    return true;
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
        Logger.error('Failed to process line: $line', name: 'FreeOtpPlusFileProcessor#processFile', error: e, stackTrace: StackTrace.current);
        results.add(ProcessorResultFailed(e.toString()));
      }
    }
    return results.map((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(TokenOriginSourceType.backupFile.addOriginToToken(
        appName: TokenImportOrigins.freeOtpPlus.appName,
        token: t.resultData,
        isPrivacyIdeaToken: false,
        data: t.resultData.origin!.data,
      ));
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
      return ProcessorResultSuccess(Token.fromUriMap(_jsonToUriMap(tokenJson)));
    } on LocalizedException catch (e) {
      return ProcessorResultFailed(e.localizedMessage(AppLocalizations.of(await globalContext)!));
    } catch (e) {
      Logger.error('Failed to parse token.', name: 'FreeOtpPlusFileProcessor#_processJsonToken', error: e, stackTrace: StackTrace.current);
      return ProcessorResultFailed(e.toString());
    }
  }

  Map<String, dynamic> _jsonToUriMap(Map<String, dynamic> tokenJson) {
    return <String, dynamic>{
      /// Steam is a special case, its hardcoded in the original app.
      URI_TYPE: tokenJson[_FREE_OTP_PLUS_ISSUER] == _steamTokenIssuer ? _steamTokenType : tokenJson[_FREE_OTP_PLUS_TYPE].toLowerCase(),
      URI_LABEL: tokenJson[_FREE_OTP_PLUS_LABEL],
      URI_SECRET: Uint8List.fromList((tokenJson[_FREE_OTP_PLUS_SECRET] as List).cast<int>()),
      URI_ISSUER: tokenJson[_FREE_OTP_PLUS_ISSUER],
      URI_ALGORITHM: tokenJson[_FREE_OTP_PLUS_ALGORITHM],
      URI_DIGITS: tokenJson[_FREE_OTP_PLUS_DIGITS],
      URI_COUNTER: tokenJson[_FREE_OTP_PLUS_COUNTER],
      URI_PERIOD: tokenJson[_FREE_OTP_PLUS_PERIOD],
      URI_ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
        appName: TokenImportOrigins.freeOtpPlus.appName,
        isPrivacyIdeaToken: false,
        data: jsonEncode(tokenJson),
      ),
    };
  }
}
