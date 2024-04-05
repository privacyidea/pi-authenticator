import 'dart:convert';
import 'dart:io';

import '../../processors/scheme_processors/token_import_scheme_processors/privacyidea_authenticator_qr_processor.dart';
import '../tokens/token.dart';
import 'aes_encrypted.dart';

class TokenEncryption {
  static Future<String> encrypt({required Iterable<Token> tokens, required String password}) async {
    final jsonsList = tokens.map((e) => e.toJson()).toList();
    final encoded = json.encode(jsonsList);
    final encrypted = (await AesEncrypted.encrypt(data: encoded, password: password)).toJson();
    return jsonEncode(encrypted);
  }

  static Future<List<Token>> decrypt({required String encryptedTokens, required String password}) async {
    final json = jsonDecode(encryptedTokens);
    final tokenJsonString = await AesEncrypted.fromJson(json).decryptToString(password);
    final tokenJsonsList = jsonDecode(tokenJsonString) as List;
    return tokenJsonsList.map<Token>((e) => Token.fromJson(e)).toList();
  }

  static Uri generateQrCodeUri({required Token token}) {
    final tokenJson = token.toJson();
    final encoded = json.encode(tokenJson);
    final zip = gzip.encode(utf8.encode(encoded));
    final base64 = base64Url.encode(zip);
    final uri = Uri.parse('${PrivacyIDEAAuthenticatorQrProcessor.scheme}://${PrivacyIDEAAuthenticatorQrProcessor.host}?data=$base64');
    return uri;
  }

  static Token fromQrCodeUri(Uri uri) {
    final base64String = uri.queryParameters['data'];
    final zip = base64Url.decode(base64String!);
    final jsonString = utf8.decode(gzip.decode(zip));
    final tokenJson = json.decode(jsonString) as Map<String, dynamic>;
    return Token.fromJson(tokenJson);
  }
}
