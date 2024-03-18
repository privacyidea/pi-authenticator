// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';

import '../../utils/identifiers.dart';
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

  const FreeOtpPlusFileProcessor();

  @override
  Future<bool> fileIsValid({required XFile file}) async {
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
      log('Checking line: $line');
      if (line.startsWith('otpauth://') == false) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<bool> fileNeedsPassword({required XFile file}) async => false;

  @override
  Future<List<Token>> processFile({required XFile file, String? password}) async {
    String content = await file.readAsString();
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      log('Processing JSON');
      return _processJson(json);
      // ignore: empty_catches
    } catch (e) {}
    List<String> lines = content.split('\n')..removeWhere((element) => element.isEmpty);
    return _processOtpAuth(lines);
  }

  Future<List<Token>> _processJson(Map<String, dynamic> json) async {
    final tokensJson = (json['tokens'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
    final tokens = <Token>[];
    if (tokensJson == null) {
      return [];
    }
    for (var tokenJson in tokensJson) {
      tokens.add(await _processJsonToken(tokenJson));
    }
    return tokens;
  }

  Future<Token> _processJsonToken(Map<String, dynamic> tokenJson) async => Token.fromUriMap(_jsonToUriMap(tokenJson));

  Map<String, dynamic> _jsonToUriMap(Map<String, dynamic> tokenJson) {
    return <String, dynamic>{
      /// Steam is a special case, its hardcoded in the original app.
      URI_TYPE: tokenJson[_FREE_OTP_PLUS_ISSUER] == "Steam" ? 'steam' : tokenJson[_FREE_OTP_PLUS_TYPE].toLowerCase(),
      URI_LABEL: tokenJson[_FREE_OTP_PLUS_LABEL],
      URI_SECRET: Uint8List.fromList((tokenJson[_FREE_OTP_PLUS_SECRET] as List).cast<int>()),
      URI_ISSUER: tokenJson[_FREE_OTP_PLUS_ISSUER],
      URI_ALGORITHM: tokenJson[_FREE_OTP_PLUS_ALGORITHM],
      URI_DIGITS: tokenJson[_FREE_OTP_PLUS_DIGITS],
      URI_COUNTER: tokenJson[_FREE_OTP_PLUS_COUNTER],
      URI_PERIOD: tokenJson[_FREE_OTP_PLUS_PERIOD],
      URI_ORIGIN: TokenOriginSourceType.backupFile.toTokenOrigin(
        appName: 'FreeOTP+',
        data: jsonEncode(tokenJson),
      ),
    };
  }

  Future<List<Token>> _processOtpAuth(List<String> lines) async {
    final tokens = <Token>[];
    const processor = OtpAuthProcessor();
    for (var line in lines) {
      log('Processing line: $line');
      final uri = Uri.parse(line);
      final token = await processor.processUri(uri);
      tokens.addAll(token);
    }
    return tokens;
  }
}
