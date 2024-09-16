import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';

import '../interfaces/repo/token_container_repository.dart';
import '../model/riverpod_states/token_container_state.dart';
import '../model/token_container.dart';
import '../utils/logger.dart';

class SecureTokenContainerRepository extends TokenContainerRepository {
  String get containerCredentialsKey => 'containerCredentials';
  String _keyOfSerial(String id) => '$containerCredentialsKey.$id';
  final Mutex _m = Mutex();
  Future<T> _protect<T>(Future<T> Function() f) => _m.protect(f);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _write(String key, String value) => _protect(() => _storage.write(key: key, value: value));
  Future<String?> _read(String key) async => await _protect(() async => await _storage.read(key: key));
  Future<Map<String, String>> _readAll() async =>
      await _protect(() async => (await _storage.readAll())..removeWhere((key, value) => !key.startsWith(containerCredentialsKey)));
  Future<void> _delete(String key) => _protect(() => _storage.delete(key: key));

  @override
  Future<TokenContainerState> loadCredentialsState() async {
    final containerJsonString = await _readAll();
    Logger.warning('Loaded container: $containerJsonString', name: 'SecureTokenContainerRepository');
    return TokenContainerState.fromJsonStringList(containerJsonString.values.toList());
  }

  @override
  Future<TokenContainerState> saveCredentialsState(TokenContainerState containerState) async {
    Logger.warning('Saving container: $containerState', name: 'SecureTokenContainerRepository');
    final futures = <Future>[];
    for (var container in containerState.container) {
      futures.add(saveCredential(container));
    }
    await Future.wait(futures);
    return await loadCredentialsState();
  }

  @override
  Future<TokenContainerState> deleteCredential(String serial) async {
    await _delete(_keyOfSerial(serial));
    return await loadCredentialsState();
  }

  @override
  Future<TokenContainerState> deleteAllCredentials() async {
    final containerKeys = (await _readAll()).keys.where((key) => key.startsWith(containerCredentialsKey));
    final futures = <Future>[];
    for (var key in containerKeys) {
      futures.add(_delete(key));
    }
    await Future.wait(futures);
    return await loadCredentialsState();
  }

  @override
  Future<TokenContainer?> loadCredential(String serial) async {
    final containerJsonString = await _read(_keyOfSerial(serial));
    if (containerJsonString == null) return null;
    return TokenContainer.fromJson(jsonDecode(containerJsonString));
  }

  @override
  Future<TokenContainerState> saveCredential(TokenContainer container) async {
    final containerJsonString = jsonEncode(container.toJson());
    await _write(_keyOfSerial(container.serial), containerJsonString);
    return await loadCredentialsState();
  }
}
