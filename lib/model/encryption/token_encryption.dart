import 'dart:convert';
import 'dart:developer';

import '../tokens/token.dart';
import 'aes_encrypted.dart';

class TokenEncryption {
  static Future<String> encrypt({required Iterable<Token> tokens, required String password}) async {
    final jsonsList = tokens.map((e) => e.toJson()).toList();
    final encoded = json.encode(jsonsList);
    final encrypted = (await AesEncrypted.encrypt(data: encoded, password: password)).toJsonString();
    return encrypted;
  }

  static Future<List<Token>> decrypt({required String encryptedTokens, required String password}) async {
    final jsonString = await AesEncrypted.fromJsonString(encryptedTokens).decryptToString(password);
    final jsonsList = json.decode(jsonString) as List;
    return jsonsList.map<Token>((e) => Token.fromJson(e)).toList();
  }

  static Uri generateQrCodeUri({required Token token}) {
    final tokenJson = token.toJson();
    final encoded = json.encode(tokenJson);
    final uri = Uri.parse('pia://json?json=$encoded');
    log('${uri.toString()}');
    return uri;
  }
}
