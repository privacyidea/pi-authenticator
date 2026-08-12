/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import '../interfaces/repo/token_container_repository.dart';
import '../model/riverpod_states/token_container_state.dart';
import '../model/token_container.dart';
import '../utils/helpers/log_redaction_helper.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';
import 'secure_storage.dart';

class SecureTokenContainerRepository extends TokenContainerRepository {
  final SecureStorage _storageLegacy;
  final SecureStorage _storage;

  SecureTokenContainerRepository({
    SecureStorage? storage,
    SecureStorage? legacyStorage,
  }) : _storage =
           storage ??
           SecureStorage(
             storagePrefix: SECURE_REPO_PREFIX_TOKEN_CONTAINER,
             storage: SecureStorage.defaultStorage,
           ),
       _storageLegacy =
           legacyStorage ??
           SecureStorage(
             storagePrefix: SECURE_REPO_PREFIX_LEGACY_TOKEN_CONTAINER,
             storage: SecureStorage.legacyStorage,
             separator: '.',
           );

  /// Takes all containers from the legacy storage and saves them to the new storage.
  /// Afterwards, the containers are deleted from the legacy storage.
  Future<void> _migrate() async {
    final containerJsonStrings = await _storageLegacy.readAll();
    if (containerJsonStrings.isEmpty) return;
    Logger.info(
      'Migrating ${containerJsonStrings.length} containers from legacy secure storage',
    );
    for (var entry in containerJsonStrings.entries) {
      try {
        await _storage.write(key: entry.key, value: entry.value);
        await _storageLegacy.delete(key: entry.key);
        Logger.info('Migrated container ${entry.key} to new secure storage');
      } catch (e, s) {
        // Keep going, so one container that cannot be moved does not hold back
        // the others.
        Logger.error(
          'Could not migrate container ${entry.key} to new secure storage',
          error: e,
          stackTrace: s,
        );
      }
    }
    Logger.info(
      'Migration of legacy containers to new secure storage completed',
    );
  }

  @override
  Future<TokenContainerState> loadContainerState() async {
    try {
      await _migrate();
    } catch (e) {
      Logger.warning(
        'Could not migrate legacy containers',
        error: e,
        verbose: true,
      );
    }
    final containerJsonStrings = await _storage.readAll();

    final containerList = <TokenContainer>[];
    for (var entry in containerJsonStrings.entries) {
      final container = _parseContainer(entry.key, entry.value);
      if (container != null) containerList.add(container);
    }

    final message =
        'Loaded ${containerList.length}/${containerJsonStrings.length} '
        'containers from secure storage';
    if (containerList.length == containerJsonStrings.length) {
      Logger.info(message);
    } else {
      Logger.warning(message, verbose: true);
    }
    return TokenContainerState(containerList: containerList);
  }

  /// The container stored under [key], or null if [jsonString] does not hold a
  /// container that can be read back.
  ///
  /// A single unreadable entry is skipped instead of failing the whole load, so
  /// the remaining containers stay usable.
  TokenContainer? _parseContainer(String key, String jsonString) {
    final Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e, s) {
      Logger.warning(
        'Entry $key of the container storage is not valid json. '
        'It holds ${jsonString.length} characters.',
        error: e,
        stackTrace: s,
        verbose: true,
      );
      return null;
    }
    try {
      return TokenContainer.fromJson(decoded as Map<String, dynamic>);
    } catch (e, s) {
      Logger.warning(
        'Could not load container $key from secure storage. '
        'Its stored entries are '
        '${redactedShape(decoded, allowedEntryNames: TokenContainer.loggableEntryNames)}',
        error: e,
        stackTrace: s,
        verbose: true,
      );
      return null;
    }
  }

  @override
  Future<TokenContainerState> saveContainerState(
    TokenContainerState containerState,
  ) async {
    return await saveContainerList(containerState.containerList);
  }

  @override
  Future<TokenContainerState> saveContainerList(
    List<TokenContainer> containerList,
  ) async {
    Logger.info(
      'Saving ${containerList.length} containers to secure storage: '
      '${containerList.map((container) => container.serial).toList()}',
    );
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
    Logger.info('Container $serial deleted from secure storage');
    return await loadContainerState();
  }

  @override
  Future<TokenContainerState> deleteAllContainer() async {
    await _storage.deleteAll();
    Logger.info('All containers deleted from secure storage', verbose: true);
    return await loadContainerState();
  }

  @override
  Future<TokenContainer?> loadContainer(String serial) async {
    final containerJsonString = await _storage.read(key: serial);
    if (containerJsonString == null) {
      Logger.warning(
        'Container $serial not found in secure storage',
        verbose: true,
      );
      return null;
    }
    return _parseContainer(serial, containerJsonString);
  }

  @override
  Future<TokenContainerState> saveContainer(TokenContainer container) async {
    final containerJsonString = jsonEncode(container.toJson());
    await _storage.write(key: container.serial, value: containerJsonString);
    return await loadContainerState();
  }
}
