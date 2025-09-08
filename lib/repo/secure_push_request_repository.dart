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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

import '../interfaces/repo/push_request_repository.dart';
import '../model/push_request.dart';
import '../model/riverpod_states/push_request_state.dart';
import '../utils/custom_int_buffer.dart';
import '../utils/logger.dart';
import 'secure_storage_mutexed.dart';

class SecurePushRequestRepository implements PushRequestRepository {
  SecurePushRequestRepository();

  static const String _PUSH_REQUEST_PREFIX_LEGACY = GLOBAL_SECURE_REPO_PREFIX_LEGACY;
  static const String _KEY_LEGACY = 'pr_state';
  static const String _PUSH_REQUEST_PREFIX = '${GLOBAL_SECURE_REPO_PREFIX}_push_request';
  static const String _KEY = 'state';

  // Use this to lock critical sections of code.
  static final _storageLegacy = SecureStorageMutexed(
    storagePrefix: _PUSH_REQUEST_PREFIX_LEGACY,
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static final _storage = SecureStorageMutexed(
    storagePrefix: _PUSH_REQUEST_PREFIX,
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  /// Save the state to the secure storage.
  /// This is a critical section, so it is protected by Mutex.
  @override
  Future<void> saveState(PushRequestState pushRequestState) async {
    final stateJson = jsonEncode(pushRequestState.toJson());
    Logger.debug('Saving state: $stateJson');
    await _storage.write(key: _KEY, value: stateJson);
  }

  Future<String?> _migrate() async {
    final stateJson = await _storageLegacy.read(key: _KEY_LEGACY);
    if (stateJson == null) return null;
    Logger.info('Loaded legacy push request state from secure storage');
    await _storage.write(key: _KEY, value: stateJson);
    await _storageLegacy.delete(key: _KEY_LEGACY);
    Logger.info('Migrated legacy push request state to new secure storage');
    return stateJson;
  }

  /// Load the state from the secure storage.
  /// If no state is found, an empty state is returned.
  /// This is a critical section, so it is protected by Mutex.
  @override
  Future<PushRequestState> loadState() async {
    String? stateJson = await _storage.read(key: _KEY);
    if (stateJson == null) {
      // Try to load legacy state if no state is found.
      stateJson = await _migrate();
      if (stateJson == null) {
        Logger.info('No push request state found in secure storage, returning empty state');
        return PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: []));
      }
      Logger.info('Loaded migrated push request state from secure storage');
    }
    return PushRequestState.fromJson(jsonDecode(stateJson));
  }

  /// Adds a push request in the given state if it is not already known.
  /// If no state is given, the current state is loaded from the secure storage.
  /// This is a critical section, so it is protected by Mutex.
  @override
  Future<PushRequestState> addRequest(PushRequest pushRequest, {PushRequestState? state}) async {
    state ??= await loadState();
    if (state.knowsRequest(pushRequest)) {
      return state;
    }
    final newState = state.withRequest(pushRequest);
    await saveState(newState);
    return newState;
  }

  /// Remove a push request from the state.
  /// If no state is given, the current state is loaded from the secure storage.
  /// This is a critical section, so it is protected by Mutex.
  @override
  Future<PushRequestState> removeRequest(PushRequest pushRequest, {PushRequestState? state}) async {
    state ??= await loadState();
    final newState = state.withoutRequest(pushRequest);
    await saveState(newState);
    return newState;
  }

  /// Removes all push requests from the repository.
  /// If no state is saved, nothing will happen.
  /// This is a critical section, so it is protected by Mutex.
  @override
  Future<void> clearState() => _storage.delete(key: _KEY);
}
