import 'dart:convert';

import '../interfaces/repo/token_container_repository.dart';
import '../model/riverpod_states/token_container_state.dart';
import '../model/token_container.dart';
import '../utils/logger.dart';
import 'secure_storage_mutexed.dart';

class SecureTokenContainerRepository extends TokenContainerRepository {
  String get containerCredentialsKey => 'containerCredentials';
  String _keyOfSerial(String id) => '$containerCredentialsKey.$id';

  final SecureStorageMutexed _storage = const SecureStorageMutexed();

  Future<Map<String, String>> _readAll() async => (await _storage.readAll())..removeWhere((key, value) => !key.startsWith(containerCredentialsKey));
  Future<void> _delete(String key) => _storage.delete(key: key);

  @override
  Future<TokenContainerState> loadContainerState() async {
    final containerJsonString = await _readAll();
    Logger.warning('Loaded container: $containerJsonString');
    return TokenContainerState.fromJsonStringList(containerJsonString.values.toList());
  }

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async {
    Logger.warning('Saving container: $containerState');
    final futures = <Future>[];
    for (var container in containerState.containerList) {
      futures.add(saveContainer(container));
    }
    await Future.wait(futures);
    return await loadContainerState();
  }

  @override
  Future<List<TokenContainer>> loadContainerList() async {
    final containerJsonString = await _readAll();
    Logger.warning('Loaded container: $containerJsonString');
    return containerJsonString.values.map((jsonString) => TokenContainer.fromJson(jsonDecode(jsonString))).toList();
  }

  @override
  Future<TokenContainerState> saveContainerList(List<TokenContainer> containerList) async {
    Logger.warning('Saving container: $containerList');
    final futures = <Future>[];
    for (var container in containerList) {
      futures.add(saveContainer(container));
    }
    await Future.wait(futures);
    return await loadContainerState();
  }

  @override
  Future<TokenContainerState> deleteContainer(String serial) async {
    await _delete(_keyOfSerial(serial));
    return await loadContainerState();
  }

  @override
  Future<TokenContainerState> deleteAllContainer() async {
    final containerKeys = (await _readAll()).keys.where((key) => key.startsWith(containerCredentialsKey));
    final futures = <Future>[];
    for (var key in containerKeys) {
      futures.add(_delete(key));
    }
    await Future.wait(futures);
    return await loadContainerState();
  }

  @override
  Future<TokenContainer?> loadContainer(String serial) async {
    final containerJsonString = await _storage.read(key: _keyOfSerial(serial));
    if (containerJsonString == null) return null;
    return TokenContainer.fromJson(jsonDecode(containerJsonString));
  }

  @override
  Future<TokenContainerState> saveContainer(TokenContainer container) async {
    final containerJsonString = jsonEncode(container.toJson());
    await _storage.write(key: _keyOfSerial(container.serial), value: containerJsonString);
    return await loadContainerState();
  }
}
