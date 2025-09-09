import 'dart:convert';


import 'package:privacyidea_authenticator/utils/identifiers.dart';

import '../interfaces/repo/token_container_repository.dart';
import '../model/riverpod_states/token_container_state.dart';
import '../model/token_container.dart';
import '../utils/logger.dart';
import 'secure_storage_mutexed.dart';

class SecureTokenContainerRepository extends TokenContainerRepository {
  static const String _TOKEN_CONTAINER_PREFIX_LEGACY = 'containerCredentials';
  static const String _TOKEN_CONTAINER_PREFIX = '${GLOBAL_SECURE_REPO_PREFIX}_token_container';

  static final _storageLegacy = SecureStorageMutexed.legacy(storagePrefix: _TOKEN_CONTAINER_PREFIX_LEGACY);
  static final _storage = SecureStorageMutexed.create(storagePrefix: _TOKEN_CONTAINER_PREFIX);

  /// Takes all containers from the legacy storage and saves them to the new storage.
  /// Afterwards, the containers are deleted from the legacy storage.
  Future<void> _migrate() async {
    final containerJsonStrings = await _storageLegacy.readAll();
    if (containerJsonStrings.isEmpty) return;
    Logger.info('Migrating ${containerJsonStrings.length} containers from legacy secure storage');
    for (var entry in containerJsonStrings.entries) {
      await _storage.write(key: entry.key, value: entry.value);
      await _storageLegacy.delete(key: entry.key);
      Logger.info('Migrated container ${entry.key} to new secure storage');
    }
    Logger.info('Migration of legacy containers to new secure storage completed');
  }

  @override
  Future<TokenContainerState> loadContainerState() async {
    try {
      await _migrate();
    } catch (e) {
      Logger.warning('Could not migrate legacy containers', error: e, verbose: true);
    }
    final containerJsonStrings = await _storage.readAll();
    Logger.info('Loaded container: $containerJsonStrings');
    return TokenContainerState.fromJsonStringList(containerJsonStrings.values.toList());
  }

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async {
    Logger.info('Saving container: $containerState');
    final futures = <Future>[];
    for (var container in containerState.containerList) {
      futures.add(saveContainer(container));
    }
    await Future.wait(futures);
    return await loadContainerState();
  }

  @override
  Future<TokenContainerState> saveContainerList(List<TokenContainer> containerList) async {
    Logger.info('Saving container: $containerList');
    final futures = <Future>[];
    for (var container in containerList) {
      futures.add(saveContainer(container));
    }
    await Future.wait(futures);
    return await loadContainerState();
  }

  @override
  Future<TokenContainerState> deleteContainer(String serial) async {
    await _storage.delete(key: serial);
    return await loadContainerState();
  }

  @override
  Future<TokenContainerState> deleteAllContainer() async {
    await _storage.deleteAll();

    return await loadContainerState();
  }

  @override
  Future<TokenContainer?> loadContainer(String serial) async {
    final containerJsonString = await _storage.read(key: serial);
    if (containerJsonString == null) return null;
    return TokenContainer.fromJson(jsonDecode(containerJsonString));
  }

  @override
  Future<TokenContainerState> saveContainer(TokenContainer container) async {
    final containerJsonString = jsonEncode(container.toJson());
    await _storage.write(key: container.serial, value: containerJsonString);
    return await loadContainerState();
  }
}
