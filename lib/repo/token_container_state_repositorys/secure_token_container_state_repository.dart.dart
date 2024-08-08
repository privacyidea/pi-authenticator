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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import '../../utils/logger.dart';
import '../../interfaces/repo/container_repository.dart';
import '../../model/token_container.dart';

class SecureTokenContainerRepository implements TokenContainerRepository {
  static String prefix = 'token_container_state_';
  String get _containerStateKey => '$prefix${containerId}_container_state';
  final Mutex _m = Mutex();
  Future<T> _protect<T>(Future<T> Function() f) => _m.protect(f);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String containerId;

  SecureTokenContainerRepository({
    required this.containerId,
  });

  Future<void> _write(String key, String value) => _protect(() {
        Logger.debug('Writing key: $key, value: $value', name: 'secure_token_container_state_repository.dart.dart#_write');
        return _storage.write(key: key, value: value);
      });
  Future<String?> _read(String key) async {
    final value = await _protect(() async => await _storage.read(key: key));
    Logger.debug('Reading key: $key, value: $value', name: 'secure_token_container_state_repository.dart.dart#_read');
    return value;
  }

  Future<void> _delete(String key) => _protect(() => _storage.delete(key: key));
  Future<Map<String, String>> _readAll() async {
    Map<String, String>? keys;
    await _protect(() async => keys = await _storage.readAll());
    keys!.removeWhere((key, value) => !key.startsWith(prefix + containerId));
    return keys!;
  }

  @override
  Future<TokenContainer> saveContainerState(TokenContainer containerState) async {
    Logger.info('Saving container state', name: 'secure_token_container_state_repository.dart.dart#saveContainerState');
    if (TokenContainer is TokenContainerError) {
      Logger.error('Cannot save error state to repository', name: 'secure_token_container_state_repository.dart.dart#saveContainerState');
      return containerState;
    }
    final json = containerState.toJson();
    final jsonString = jsonEncode(json);
    await _write(_containerStateKey, jsonString);
    Logger.debug('Saved container state: $jsonString', name: 'secure_token_container_state_repository.dart.dart#saveContainerState');
    return containerState;
  }

  @override

  /// Load the container state from the shared preferences
  Future<TokenContainer> loadContainerState() async {
    Logger.info('Loading container state', name: 'secure_token_container_state_repository.dart.dart#loadContainerState');
    String? containerStateJsonString = await _read(_containerStateKey);
    Logger.debug('Loaded jsonString: $containerStateJsonString', name: 'secure_token_container_state_repository.dart.dart#loadContainerState');
    if (containerStateJsonString == null) {
      return const TokenContainer.uninitialized(serial: '123');
    }
    final json = jsonDecode(containerStateJsonString);
    try {
      final state = TokenContainer.fromJson(json);
      Logger.debug('Loaded container state: $containerStateJsonString', name: 'secure_token_container_state_repository.dart.dart#loadContainerState');
      return state;
    } catch (e) {
      Logger.error(
        'Failed to decode container state',
        name: 'secure_token_container_state_repository.dart.dart#loadContainerState',
        error: e,
        stackTrace: StackTrace.current,
      );
      await _delete(_containerStateKey);
      return const TokenContainer.uninitialized(serial: '123');
    }
  }
}
