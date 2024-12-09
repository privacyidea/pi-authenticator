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

import 'package:zxing2/qrcode.dart';

import '../../model/tokens/token.dart';
import '../../processors/scheme_processors/token_import_scheme_processors/privacyidea_authenticator_qr_processor.dart';
import '../../utils/encryption/aes_encrypted.dart';
import '../../utils/logger.dart';

class TokenEncryption {
  static Future<String> encrypt({required Iterable<Token> tokens, required String password}) async {
    Logger.info('Encrypting tokens');
    final String jsonString;
    try {
      final jsonsList = tokens.map((e) => e.toJson()).toList();
      final encoded = json.encode(jsonsList);
      final encrypted = (await AesEncrypted.encrypt(data: encoded, password: password)).toJson();
      jsonString = jsonEncode(encrypted);
    } catch (e, s) {
      Logger.error('Failed to encrypt tokens', error: e, stackTrace: s);
      rethrow;
    }
    Logger.info('Encrypted ${tokens.length} tokens');
    return jsonString;
  }

  static Future<List<Token>> decrypt({required String encryptedTokens, required String password}) async {
    Logger.info('Decrypting tokens');
    List<Token> tokens = [];
    try {
      final json = jsonDecode(encryptedTokens);
      final tokenJsonString = await AesEncrypted.fromJson(json).decryptToString(password);
      final tokenJsonsList = jsonDecode(tokenJsonString) as List;
      tokens = tokenJsonsList.map<Token>((e) => Token.fromJson(e).copyWith(folderId: () => null)).toList();
    } catch (e, s) {
      // Does not has to be an error, if the password is wrong.
      Logger.warning('Failed to decrypt tokens', error: e, stackTrace: s);
      rethrow;
    }
    Logger.info('Decrypted ${tokens.length} tokens');
    return tokens;
  }

  static Uri generateExportUri({required Token token}) {
    Logger.info('Generating export URI for token ${token.label}');
    Uri uri;
    try {
      final tokenJson = token.toJson();
      final encoded = json.encode(tokenJson);
      final bytes = utf8.encode(encoded);
      final base64 = base64Url.encode(bytes);
      uri = Uri.parse('${PrivacyIDEAAuthenticatorQrProcessor.scheme}://${PrivacyIDEAAuthenticatorQrProcessor.host}?data=$base64');
    } catch (e, s) {
      Logger.error('Failed to generate export URI', error: e, stackTrace: s);
      rethrow;
    }
    Logger.info('Generated export URI for token ${token.label}');
    return uri;
  }

  static QRCode toQrCode(Token token) {
    Logger.info('Generating QR code for token ${token.label}');
    final QRCode qrCode;
    try {
      qrCode = Encoder.encode(
        generateExportUri(token: token).toString(),
        ErrorCorrectionLevel.l,
        hints: EncodeHints()..put<CharacterSetECI>(EncodeHintType.characterSet, CharacterSetECI.ASCII),
      );
    } catch (e, s) {
      Logger.error('Failed to generate QR code', error: e, stackTrace: s);
      rethrow;
    }
    Logger.info('Generated QR code for token ${token.label}');
    return qrCode;
  }

  static Token fromExportUri(Uri uri) {
    final Token token;
    Logger.info('Parsing exportUri (${uri.scheme})');
    try {
      final base64String = uri.queryParameters['data'];
      final bytes = base64Url.decode(base64String!);
      final jsonString = utf8.decode(bytes);
      final tokenJson = json.decode(jsonString) as Map<String, dynamic>;
      token = Token.fromJson(tokenJson);
    } catch (e, s) {
      Logger.error('Failed to parse token from URI', error: e, stackTrace: s);
      rethrow;
    }
    Logger.info('Parsed token ${token.label}');
    return token;
  }
}
