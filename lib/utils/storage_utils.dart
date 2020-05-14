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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privacyidea_authenticator/model/firebase_config.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';

// TODO test the behavior of this class.
class StorageUtil {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Saves [token] securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  static void saveOrReplaceToken(Token token) async {
    await _storage.write(key: token.id, value: jsonEncode(token));
  }

  static Future<Token> loadToken(String id) async {
    return (await loadAllTokens())
        .firstWhere((t) => t.id == id, orElse: () => null);
  }

  /// Returns a list of all Tokens that are saved in the secure storage of
  /// this device.
  static Future<List<Token>> loadAllTokens() async {
    Map<String, String> keyValueMap = await _storage.readAll();

    List<Token> tokenList = [];
    keyValueMap.forEach((_, value) {
      Map<String, dynamic> serializedToken = jsonDecode(value);

      // TODO when the token version (token.version) changed handle this here.

      if (serializedToken.containsKey("counter")) {
        tokenList.add(HOTPToken.fromJson(serializedToken));
      } else if (serializedToken.containsKey("period")) {
        tokenList.add(TOTPToken.fromJson(serializedToken));
      } else if (serializedToken.containsKey("serial")) {
        tokenList.add(PushToken.fromJson(serializedToken));
      }
    });

    return tokenList;
  }

  /// Deletes the saved json of [token] from the secure storage.
  static void deleteToken(Token token) async {
    String key = token.id;

    await _storage.delete(key: key);
  }

  static const _FIREBASE_CONFIG_KEY = "sdfkjhfhknvcnell";

  static void saveOrReplaceFirebaseConfig(FirebaseConfig config) async {
    await _storage.write(key: _FIREBASE_CONFIG_KEY, value: jsonEncode(config));
  }

  static void deleteFirebaseConfig()async {
    await _storage.delete(key: _FIREBASE_CONFIG_KEY);
  }

  static Future<bool> firebaseConfigExists() async {
    return await loadFirebaseConfig() != null;
  }

  static Future<FirebaseConfig> loadFirebaseConfig() async {
    String serializedConfig = await _storage.read(key: _FIREBASE_CONFIG_KEY);

    return serializedConfig == null
        ? null
        : FirebaseConfig.fromJson(jsonDecode(serializedConfig));
  }
}
