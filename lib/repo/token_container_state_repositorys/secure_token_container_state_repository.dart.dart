import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
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
        Logger.warning('Writing to secure storage: $key, $value', name: 'SecureTokenContainerRepository');
        return _storage.write(key: key, value: value);
      });
  Future<String?> _read(String key) async {
    return await _protect(() async => await _storage.read(key: key));
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
    if (TokenContainer is TokenContainerError) {
      Logger.error('Cannot save error state to repository', name: 'SecureTokenContainerRepository');
      return containerState;
    }
    Logger.warning('Saving container state', name: 'SecureTokenContainerRepository');
    final json = containerState.toJson();
    Logger.warning('Encoded container state: $json', name: 'SecureTokenContainerRepository');
    final jsonString = jsonEncode(json);
    Logger.warning('Encoded container state string: $jsonString', name: 'SecureTokenContainerRepository');
    await _write(_containerStateKey, jsonString);
    Logger.warning('Saved container state: $jsonString', name: 'SecureTokenContainerRepository');
    return containerState;
  }

  @override

  /// Load the container state from the shared preferences
  Future<TokenContainer> loadContainerState() async {
    Logger.warning('Loading container state', name: 'SecureTokenContainerRepository');
    String? containerStateJsonString = await _read(_containerStateKey);
    Logger.warning('Loaded container state: $containerStateJsonString', name: 'SecureTokenContainerRepository');
    if (containerStateJsonString == null) {
      Logger.info('No container state found in secure storage', name: 'SecureTokenContainerRepository');
      return const TokenContainer.uninitialized(serial: '123');
    }
    final json = jsonDecode(containerStateJsonString);
    Logger.warning('Decoded container state: $json', name: 'SecureTokenContainerRepository');
    try {
      final state = TokenContainer.fromJson(json);
      return state;
    } catch (e) {
      Logger.error('Failed to decode container state', name: 'SecureTokenContainerRepository');
      await _delete(_containerStateKey);
      return const TokenContainer.uninitialized(serial: '123');
    }
  }


}
