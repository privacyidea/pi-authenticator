/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The persistent storage of the device: the keystore backed secure storage
/// and the shared preferences, both in memory.
///
/// The app's real repositories run on top of it, so seeding an entry here
/// means the app reads it exactly like an entry written by an earlier version.
class FakeDeviceStorage {
  /// Every secure storage entry by its full key, live: the app writes into
  /// this map and a test can read or corrupt it at any time.
  final Map<String, String> secure = {};

  FakeDeviceStorage._();

  /// Installs an empty device. The shared preferences are cleared rather than
  /// mocked again, because the repositories keep the instance of their first
  /// `SharedPreferences.getInstance()` call (see AppHarness).
  static Future<FakeDeviceStorage> install() async {
    final storage = FakeDeviceStorage._();
    FlutterSecureStorage.setMockInitialValues(storage.secure);
    await (await SharedPreferences.getInstance()).clear();
    return storage;
  }

  static String tokenKey(String id) => '${SECURE_REPO_PREFIX_TOKEN}_$id';
  static String legacyKey(String id) =>
      '${GLOBAL_SECURE_REPO_PREFIX_LEGACY}_$id';

  void putToken(Token token) =>
      secure[tokenKey(token.id)] = jsonEncode(token.toJson());

  void putRawToken(String id, String rawValue) =>
      secure[tokenKey(id)] = rawValue;

  void putLegacyToken(Token token) =>
      secure[legacyKey(token.id)] = jsonEncode(token.toJson());

  /// The stored tokens as json, keyed by token id.
  Map<String, Map<String, dynamic>> get storedTokens => {
    for (final entry in secure.entries)
      if (entry.key.startsWith('${SECURE_REPO_PREFIX_TOKEN}_') &&
          !entry.key.startsWith('${SECURE_REPO_PREFIX_TOKEN_CONTAINER}_'))
        entry.key.substring(SECURE_REPO_PREFIX_TOKEN.length + 1):
            jsonDecode(entry.value) as Map<String, dynamic>,
  };

  Iterable<String> get legacyKeys => secure.keys.where(
    (key) => key.startsWith('${GLOBAL_SECURE_REPO_PREFIX_LEGACY}_'),
  );

  /// The persisted push request state, null while nothing was saved.
  PushRequestState? get storedPushRequestState {
    final raw = secure['${SECURE_REPO_PREFIX_PUSH_REQUEST}_state'];
    return raw == null
        ? null
        : PushRequestState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// A device on which the app already ran: introductions done and no patch
  /// notes pending, so nothing covers the main view.
  Future<void> seedReturningUser({required String appVersion}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'COMPLETED_INTRODUCTIONS',
      jsonEncode(IntroductionState.withAllCompleted().toJson()),
    );
    await prefs.setString('KEY_LATEST_VERSION', appVersion);
    await prefs.setBool('KEY_IS_FIRST_RUN', false);
  }

  Future<void> setPreference(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (value) {
      case bool v:
        await prefs.setBool(key, v);
      case String v:
        await prefs.setString(key, v);
      case int v:
        await prefs.setInt(key, v);
      case List<String> v:
        await prefs.setStringList(key, v);
      default:
        throw ArgumentError('Unsupported preference type ${value.runtimeType}');
    }
  }
}
