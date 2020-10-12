/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privacyidea_authenticator/model/firebase_config.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';

// TODO test the behavior of this class.
class StorageUtil {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // ###########################################################################
  // TOKENS
  // ###########################################################################

  /// Saves [token] securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  static void saveOrReplaceToken(Token token) async =>
      await _storage.write(key: token.id, value: jsonEncode(token));

  static Future<Token> loadToken(String id) async =>
      (await loadAllTokens()).firstWhere((t) => t.id == id, orElse: () => null);

  /// Returns a list of all Tokens that are saved in the secure storage of
  /// this device.
  static Future<List<Token>> loadAllTokens() async {
    Map<String, String> keyValueMap = await _storage.readAll();

    List<Token> tokenList = [];
    for (String value in keyValueMap.values) {
      if (!(jsonDecode(value) is Map)) continue;
      Map<String, dynamic> serializedToken = jsonDecode(value);

      // TODO when the token version (token.version) changed handle this here.

      if (serializedToken.containsKey("counter")) {
        tokenList.add(HOTPToken.fromJson(serializedToken));
      } else if (serializedToken.containsKey("period")) {
        tokenList.add(TOTPToken.fromJson(serializedToken));
      } else if (serializedToken.containsKey("serial")) {
        tokenList.add(PushToken.fromJson(serializedToken));
      }
    }

    return tokenList;
  }

  /// Deletes the saved json of [token] from the secure storage.
  /// If the token is a PushToken, its firebase config is deleted too.
  static Future<void> deleteToken(Token token) async {
    _storage.delete(key: token.id);
    if (token is PushToken) deleteFirebaseConfig(token);
  }

  // ###########################################################################
  // GLOBAL FIREBASE CONFIG
  // ###########################################################################

  static const _GLOBAL_FIREBASE_CONFIG_KEY =
      "cc0d13b2-9ce1-11ea-bb37-0242ac130002";

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
        key: token.id + _KEY_POSTFIX, value: jsonEncode(config));
  }

  static Future<FirebaseConfig> loadFirebaseConfig(Token token) async {
    String serializedConfig = await _storage.read(key: token.id + _KEY_POSTFIX);

    return serializedConfig == null
        ? null
        : FirebaseConfig.fromJson(jsonDecode(serializedConfig));
  }

  static void deleteFirebaseConfig(Token token) async =>
      _storage.delete(key: token.id + _KEY_POSTFIX);

  // ###########################################################################
  // APPLICATION PIN
  // ###########################################################################

  static const _GLOBAL_PIN_KEY = "b1612ff8-2bf7-4e6e-86e7-dc9f170de9fb";

  static Future<bool> isPINSet() async => await getPIN() != null;

  static Future<void> setPIN(String pin) async =>
      _storage.write(key: _GLOBAL_PIN_KEY, value: pin);

  // FIXME This is deactivated until a good solution for this is found!
  static Future<String> getPIN() async => _storage.read(key: _GLOBAL_PIN_KEY);
//  static Future<String> getPIN() async => null;

  static Future<void> deletePIN() async =>
      _storage.delete(key: _GLOBAL_PIN_KEY);
}
