import 'dart:convert';

import 'package:privacyidea_authenticator/model/processor_result.dart';

import 'package:privacyidea_authenticator/model/tokens/token.dart';

import 'token_import_scheme_processor_interface.dart';

class PrivacyIDEAAuthenticatorQrProcessor extends TokenImportSchemeProcessor {
  const PrivacyIDEAAuthenticatorQrProcessor();

  @override
  Set<String> get supportedSchemes => {'pia'};

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) async {
    if (supportedSchemes.contains(uri.scheme) || uri.host != 'jsonBackup') {
      return [];
    }
    final jsonString = uri.queryParameters['data'];
    Map<String, dynamic> tokenJson;
    try {
      tokenJson = json.decode(jsonString!) as Map<String, dynamic>;
    } catch (e) {
      return [ProcessorResult.error('Invalid URI')];
    }
    final token = Token.fromJson(tokenJson);
    return [ProcessorResult.success(token)];
  }
}
