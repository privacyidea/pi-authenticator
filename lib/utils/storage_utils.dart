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
import 'package:privacyidea_authenticator/model/tokens.dart';

// TODO test the behavior of this class.
class StorageUtil {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Saves [token] securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  static void saveOrReplaceToken(Token token) async {
    String key = token.uuid;

    String value = await _storage.read(key: key);

    if (value != null) {
      await _storage.delete(key: key);
    }

    String serializedToken = jsonEncode(token);
    await _storage.write(key: key, value: serializedToken);
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
      } else if (serializedToken.containsKey("ttl")) {
        tokenList.add(PushToken.fromJson(serializedToken));
      }
    });

    return tokenList;
  }

  /// Deletes the saved json of [token] from the secure storage.
  static void deleteToken(Token token) async {
    String key = token.uuid;

    await _storage.delete(key: key);
  }
}
