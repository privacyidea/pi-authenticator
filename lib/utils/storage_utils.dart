// ignore_for_file: constant_identifier_names

/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

// TODO How to test the behavior of this class?
class StorageUtil {
  // Use this to lock critical sections of code.
  static final Mutex _m = Mutex();

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  static protect(Function f) => _m.protect(f as Future<dynamic> Function());

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _GLOBAL_PREFIX = 'app_v3_';

  // ###########################################################################
  // TOKENS
  // ###########################################################################

  /// Saves [token] securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  static Future<void> saveOrReplaceToken(Token token) async {
    await _storage.write(key: _GLOBAL_PREFIX + token.id, value: jsonEncode(token));
    Logger.info('Token saved to secure storage');
  }

  static Future<Token?> loadToken(String id) async => (await loadAllTokens()).firstWhereOrNull((t) => t.id == id);

  /// Returns a list of all tokens that are saved in the secure storage of
  /// this device.
  /// If [loadLegacy] is set to true, will attempt to load old android and ios tokens.
  static Future<List<Token>> loadAllTokens() async {
    Map<String, String> keyValueMap = await _storage.readAll();

    List<Token> tokenList = [];

    for (var i = 0; i < keyValueMap.length; i++) {
      final value = keyValueMap.values.elementAt(i);
      final key = keyValueMap.keys.elementAt(i);
      // for (String value in keyValueMap.values) {

      Map<String, dynamic>? serializedToken;

      try {
        serializedToken = jsonDecode(value);
      } on FormatException catch (e, s) {
        if (key == _CURRENT_APP_TOKEN_KEY || key == _NEW_APP_TOKEN_KEY) {
          continue;
        }
        Logger.warning(
          'Could not deserialize token from secure storage. Value: $value, key: $key',
          name: 'storage_utils.dart#loadAllTokens',
          error: e,
          stackTrace: s,
        );
        // Skip everything that does not fit a serialized token
        continue;
      }

      if (serializedToken == null || !serializedToken.containsKey('type')) {
        Logger.warning(
            'Could not deserialize token from secure storage. Value: $value\nserializedToken = $serializedToken\ncontainsKey(type) = ${serializedToken?.containsKey('type')} ',
            name: 'storage_utils.dart#loadAllTokens');
        // Skip everything that fits for deserialization but is not a token
        continue;
      }

      // TODO token.version might be deprecated, is there a reason to use it?
      // TODO when the token version (token.version) changed handle this here.

      // TODO Is this still needed? Can a json annotation be used instead to
      //  define default values?
      // Handle new fields here
      serializedToken['issuer'] ??= '';
      serializedToken['label'] ??= '';

      tokenList.add(Token.fromJson(serializedToken));
    }

    Logger.info('Loaded ${tokenList.length} tokens from secure storage');
    return tokenList;
  }

  /// Deletes the saved json of [token] from the secure storage.
  static Future<void> deleteToken(Token token) async {
    _storage.delete(key: _GLOBAL_PREFIX + token.id);
    Logger.info('Token deleted from secure storage');
  }

  // ###########################################################################
  // FIREBASE CONFIG
  // ###########################################################################

  static const _CURRENT_APP_TOKEN_KEY = '${_GLOBAL_PREFIX}CURRENT_APP_TOKEN';

  static Future<void> setCurrentFirebaseToken(String str) async => _storage.write(key: _CURRENT_APP_TOKEN_KEY, value: str);

  static Future<String?> getCurrentFirebaseToken() async => _storage.read(key: _CURRENT_APP_TOKEN_KEY);

  static const _NEW_APP_TOKEN_KEY = '${_GLOBAL_PREFIX}NEW_APP_TOKEN';

  // This is used for checking if the token was updated.
  static Future<void> setNewFirebaseToken(String str) async => _storage.write(key: _NEW_APP_TOKEN_KEY, value: str);

  static Future<String?> getNewFirebaseToken() async => _storage.read(key: _NEW_APP_TOKEN_KEY);

// ###########################################################################
// Update information
// ###########################################################################

  static const _KEY_VERSION = '${_GLOBAL_PREFIX}_app_version';

  static Future<String?> getCurrentVersion() async {
    return await _storage.read(key: _KEY_VERSION);
  }

  static Future<void> setCurrentVersion(String version) async {
    await _storage.write(key: _KEY_VERSION, value: version);
  }

  // #########################################################################
  // Misc
  // #########################################################################

  static Future<void> deleteEverything() async => _storage.deleteAll();
}
