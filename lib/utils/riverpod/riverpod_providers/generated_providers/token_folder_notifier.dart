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
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/repo/preference_token_folder_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../interfaces/repo/token_folder_repository.dart';
import '../../../../model/riverpod_states/token_folder_state.dart';
import '../../../../model/token_folder.dart';
import '../../../logger.dart';

part 'token_folder_notifier.g.dart';

final tokenFolderProvider = tokenFolderNotifierProviderOf(repo: PreferenceTokenFolderRepository());

@Riverpod(keepAlive: true)
class TokenFolderNotifier extends _$TokenFolderNotifier {
  late final Future<TokenFolderState> initState;
  final Mutex _repoMutex = Mutex();
  final Mutex _stateMutex = Mutex();

  @override
  TokenFolderRepository get repo => _repo;
  final TokenFolderRepository? _repoOverride;
  late final TokenFolderRepository _repo;

  TokenFolderNotifier({TokenFolderRepository? repoOverride})
      : _repoOverride = repoOverride,
        super();

  @override
  TokenFolderState build({required TokenFolderRepository repo}) {
    _repo = _repoOverride ?? repo;
    _stateMutex.acquire();
    Logger.info('Initializing token folder state', name: 'TokenFolderNotifier#initTokenFolder');
    initState = _loadFromRepo().then((newState) {
      _stateMutex.release();
      return state = newState;
    });
    return const TokenFolderState(folders: []);
  }

  Future<TokenFolderState> _loadFromRepo() async {
    await _repoMutex.acquire();
    final newState = await _repo.loadState();
    _repoMutex.release();
    return newState;
  }

  Future<bool> _saveToRepo(TokenFolderState state) async {
    await _repoMutex.acquire();
    final success = await _repo.saveState(state);
    if (!success) {
      Logger.warning(
        'Failed to save folders',
        name: 'TokenFolderNotifier#_saveToRepo',
      );
      _repoMutex.release();
      return false;
    }
    _repoMutex.release();
    return true;
  }

  Future<TokenFolderState> addNewFolder(String name) async {
    await _stateMutex.acquire();
    final oldState = state;
    final newState = oldState.addNewFolder(name);
    final success = await _saveToRepo(newState);
    if (!success) {
      Logger.warning(
        'Failed to add new folder',
        name: 'TokenFolderNotifier#_addNewFolder',
      );
      _stateMutex.release();
      return oldState;
    }
    state = newState;
    _stateMutex.release();
    return newState;
  }

  Future<TokenFolderState> removeFolder(TokenFolder folder) async {
    await _stateMutex.acquire();
    final oldState = state;
    final newState = oldState.removeFolder(folder);
    final success = await _saveToRepo(newState);
    if (!success) {
      Logger.warning(
        'Failed to remove folder',
        name: 'TokenFolderNotifier#_removeFolder',
      );
      _stateMutex.release();
      return oldState;
    }
    state = newState;
    _stateMutex.release();
    return newState;
  }

  /// Search for the current version of the given folder and update it with the updater function.
  /// If the folder is not found, nothing will happen.
  /// Returns true if the operation is successful, false otherwise.
  Future<TokenFolderState> updateFolder(TokenFolder folder, TokenFolder Function(TokenFolder) updater) async {
    await _stateMutex.acquire();
    final oldState = state;
    final newState = oldState.update(folder, updater);
    final success = await _saveToRepo(newState);
    if (!success) {
      Logger.warning(
        'Failed to add or replace folders',
        name: 'TokenFolderNotifier#addOrReplaceFolders',
      );
      _stateMutex.release();
      return oldState;
    }
    state = newState;
    _stateMutex.release();
    return newState;
  }

  /// Search for the current version of the given folder and update it with the updater function.
  /// If the folder is not found, nothing will happen.
  /// Returns true if the operation is successful, false otherwise.
  Future<TokenFolderState> updateFolderById(int folderId, TokenFolder Function(TokenFolder) updater) async {
    await _stateMutex.acquire();
    final oldState = state;
    final folder = oldState.currentOfId(folderId)!;
    final newState = oldState.update(folder, updater);
    final success = await _saveToRepo(newState);
    if (!success) {
      Logger.warning(
        'Failed to add or replace folders',
        name: 'TokenFolderNotifier#addOrReplaceFolders',
      );
      _stateMutex.release();
      return oldState;
    }
    state = newState;
    _stateMutex.release();
    return newState;
  }

  Future<TokenFolderState> addOrReplaceFolders(List<TokenFolder> folders) async {
    await _stateMutex.acquire();
    final oldState = state;
    final newState = oldState.addOrReplaceFolders(folders);
    final success = await _saveToRepo(newState);
    if (!success) {
      Logger.warning(
        'Failed to add or replace folders',
        name: 'TokenFolderNotifier#addOrReplaceFolders',
      );
      _stateMutex.release();
      return oldState;
    }
    state = newState;
    _stateMutex.release();
    return newState;
  }

  // Future<TokenFolderState> expandFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isExpanded: true));
  // Future<TokenFolderState> collapseFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isExpanded: false));
  // Future<TokenFolderState> lockFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isLocked: true));
  // Future<TokenFolderState> unlockFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isLocked: false));
  Future<TokenFolderState> toggleFolderLock(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isLocked: !folder.isLocked));
  Future<TokenFolderState> updateLabel(TokenFolder folder, String label) => updateFolder(folder, (p0) => p0.copyWith(label: label));
  Future<TokenFolderState> expandFolderById(int folderId) => updateFolderById(folderId, (p0) => p0.copyWith(isExpanded: true));

  Future<TokenFolderState> collapseLockedFolders() async {
    await _stateMutex.acquire();
    final lockedFolders = (state).folders.where((element) => element.isLocked).toList();
    for (var i = 0; i < lockedFolders.length; i++) {
      lockedFolders[i] = lockedFolders[i].copyWith(isExpanded: false);
    }
    final oldState = state;
    final newState = oldState.addOrReplaceFolders(lockedFolders);
    final success = await _saveToRepo(newState);
    if (!success) {
      Logger.warning(
        'Failed to add or replace folders',
        name: 'TokenFolderNotifier#addOrReplaceFolders',
      );
      _stateMutex.release();
      return oldState;
    }
    _stateMutex.release();
    return newState;
  }
}
