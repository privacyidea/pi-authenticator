/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/model/firebase_config.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

// TODO test the behavior of this class.
class StorageUtil {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _GLOBAL_PREFIX = 'app_v3_';

  // ###########################################################################
  // TOKENS
  // ###########################################################################

  /// Saves [token] securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  static Future<void> saveOrReplaceToken(Token token) async => await _storage.write(
      key: _GLOBAL_PREFIX + token.id, value: jsonEncode(token));

  static Future<Token> loadToken(String id) async => (await loadAllTokens())
      .firstWhere((t) => _GLOBAL_PREFIX + t.id == id, orElse: () => null);

  /// Returns a list of all Tokens that are saved in the secure storage of
  /// this device.
  static Future<List<Token>> loadAllTokens({bool loadLegacy = false}) async {
    Map<String, String> keyValueMap = await _storage.readAll();

    if (keyValueMap.keys.isEmpty && loadLegacy) {
      // No Token is availabel, attempt to load legacy tokens:

      print('Loading legacy tokens');

      List<Token> legacyTokens = await StorageUtil.loadAllTokensLegacy();

      if (legacyTokens.isNotEmpty) {
        for (Token t in legacyTokens) {
          await StorageUtil.saveOrReplaceToken(t);
        }

        keyValueMap = await _storage.readAll();
      }
    }

    List<Token> tokenList = [];
    for (String value in keyValueMap.values) {
      Map<String, dynamic> serializedToken = jsonDecode(value);

      if (!serializedToken.containsKey('type')) continue;

      // TODO when the token version (token.version) changed handle this here.

      if (serializedToken['type'] == enumAsString(TokenTypes.HOTP)) {
        tokenList.add(HOTPToken.fromJson(serializedToken));
      } else if (serializedToken['type'] == enumAsString(TokenTypes.TOTP)) {
        tokenList.add(TOTPToken.fromJson(serializedToken));
      } else if (serializedToken['type'] == enumAsString(TokenTypes.PIPUSH)) {
        tokenList.add(PushToken.fromJson(serializedToken));
      } else {
        log(
          'Type ${serializedToken['type']} is unknown.',
          name: 'storage_utils.dart',
        );
      }
    }

    return tokenList;
  }

  /// Deletes the saved json of [token] from the secure storage.
  /// If the token is a PushToken, its firebase config is deleted too.
  static Future<void> deleteToken(Token token) async {
    _storage.delete(key: _GLOBAL_PREFIX + token.id);
    if (token is PushToken) deleteFirebaseConfig(token);
  }

  // ###########################################################################
  // GLOBAL FIREBASE CONFIG
  // ###########################################################################

  static const _GLOBAL_FIREBASE_CONFIG_KEY =
      _GLOBAL_PREFIX + "cc0d13b2-9ce1-11ea-bb37-0242ac130002";

  static void saveOrReplaceGlobalFirebaseConfig(FirebaseConfig config) async =>
      await _storage.write(
          key: _GLOBAL_FIREBASE_CONFIG_KEY, value: jsonEncode(config));

  static void deleteGlobalFirebaseConfig() async =>
      await _storage.delete(key: _GLOBAL_FIREBASE_CONFIG_KEY);

  static Future<bool> globalFirebaseConfigExists() async =>
      await loadGlobalFirebaseConfig() != null;

  static Future<FirebaseConfig> loadGlobalFirebaseConfig() async {
    String serializedConfig =
        await _storage.read(key: _GLOBAL_FIREBASE_CONFIG_KEY);

    return serializedConfig == null
        ? null
        : FirebaseConfig.fromJson(jsonDecode(serializedConfig));
  }

  // ###########################################################################
  // FIREBASE PER TOKEN
  // ###########################################################################

  static const _KEY_POSTFIX = "_firebase_config";

  static Future<void> saveOrReplaceFirebaseConfig(
      Token token, FirebaseConfig config) async {
    await _storage.write(
        key: _GLOBAL_PREFIX + token.id + _KEY_POSTFIX,
        value: jsonEncode(config));
  }

  static Future<FirebaseConfig> loadFirebaseConfig(Token token) async {
    String serializedConfig =
        await _storage.read(key: _GLOBAL_PREFIX + token.id + _KEY_POSTFIX);

    return serializedConfig == null
        ? null
        : FirebaseConfig.fromJson(jsonDecode(serializedConfig));
  }

  static void deleteFirebaseConfig(Token token) async =>
      _storage.delete(key: _GLOBAL_PREFIX +token.id + _KEY_POSTFIX);

  // ###########################################################################
  // LEGACY
  // ###########################################################################

  static Future<List<Token>> loadAllTokensLegacy() async {
    List<Token> tokenList = [];

    for (var tokenMap in jsonDecode(await Legacy.loadAllTokens())) {
      Token token;
      if (tokenMap['type'] != null && tokenMap['type'] == 'hotp') {
        token = HOTPToken(
          issuer: tokenMap['label'],
          id: tokenMap['serial'],
          label: tokenMap['label'],
          counter: tokenMap['counter'],
          digits: tokenMap['digits'],
          secret: tokenMap['secret'],
          algorithm: mapStringToAlgorithm(
              tokenMap['algorithm'].toString().substring(4)),
        );
      } else if (tokenMap['type'] != null && tokenMap['type'] == 'totp') {
        token = TOTPToken(
          issuer: tokenMap['label'],
          id: tokenMap['serial'],
          label: tokenMap['label'],
          period: tokenMap['period'],
          digits: tokenMap['digits'],
          secret: tokenMap['secret'],
          algorithm: mapStringToAlgorithm(
              tokenMap['algorithm'].toString().substring(4)),
        );
      } else if (tokenMap['type'] != null && tokenMap['type'] == 'pipush') {
        token = PushToken(
          issuer: tokenMap['label'],
          label: tokenMap['label'],
          id: tokenMap['serial'],
          serial: tokenMap['serial'],
          expirationDate: DateTime.now().subtract(Duration(minutes: 60)),
          enrollmentCredentials: null,
          sslVerify: null,
          url: null,
        );
        (token as PushToken).isRolledOut = true;

        var configMap = jsonDecode(await Legacy.loadFirebaseConfig());

        FirebaseConfig config = FirebaseConfig(
          appID: configMap['appid'],
          apiKey: configMap['apikey'],
          projectID: configMap['projectid'],
          projectNumber: configMap['projectnumber'],
        );

        StorageUtil.saveOrReplaceFirebaseConfig(token, config);
        StorageUtil.saveOrReplaceGlobalFirebaseConfig(config);
      } else {
        log(
          "Unknown token type encountered",
          name: 'storage_utils.dart#loadAllTokensLegacy',
          error: tokenMap,
        );
        continue;
      }

      tokenList.add(token);
    }

    for (Token t in tokenList) {
      await StorageUtil.saveOrReplaceToken(t);
    }

    return tokenList;
  }
}
