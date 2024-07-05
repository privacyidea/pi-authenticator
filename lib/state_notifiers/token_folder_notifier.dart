import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutex/mutex.dart';

import '../interfaces/repo/token_folder_repository.dart';
import '../model/states/token_folder_state.dart';
import '../model/token_folder.dart';
import '../utils/logger.dart';

class TokenFolderNotifier extends StateNotifier<TokenFolderState> {
  late final Future<TokenFolderState> initState;
  final Mutex _loadingRepoMutex = Mutex();
  final Mutex _updateFolderMutex = Mutex();
  final TokenFolderRepository _repo;

  TokenFolderNotifier({required TokenFolderRepository repository, TokenFolderState? initialState})
      : _repo = repository,
        super(initialState ?? const TokenFolderState(folders: [])) {
    _init();
  }

  void _init() async {
    _loadingRepoMutex.acquire();
    initState = Future(() async => state = TokenFolderState(folders: await _repo.loadFolders()));
    await initState;
    _loadingRepoMutex.release();
  }

  Future<bool> _addOrReplaceFolders(List<TokenFolder> folders) async {
    await _loadingRepoMutex.acquire();
    final success = await _repo.saveReplaceList(folders);
    if (!success) {
      Logger.warning(
        'Failed to save folders',
        name: 'TokenFolderNotifier#_addOrReplaceFolders',
      );
      return false;
    }
    state = state.addOrReplaceFolders(folders);
    _loadingRepoMutex.release();
    return true;
  }

  Future<bool> _addOrReplaceFolder(TokenFolder folder) async {
    await _loadingRepoMutex.acquire();
    final newState = state.addOrReplaceFolder(folder);
    final success = await _repo.saveReplaceList(newState.folders);
    if (!success) {
      Logger.warning(
        'Failed to add or replace folder',
        name: 'TokenFolderNotifier#_addOrReplaceFolder',
      );
      return false;
    }
    state = newState;
    _loadingRepoMutex.release();
    return true;
  }

  Future<bool> _addNewFolder(String name) async {
    await _loadingRepoMutex.acquire();
    final newState = state.addNewFolder(name);
    final success = await _repo.saveReplaceList(newState.folders);
    if (!success) {
      Logger.warning(
        'Failed to add new folder',
        name: 'TokenFolderNotifier#_addNewFolder',
      );
      return false;
    }
    state = newState;
    _loadingRepoMutex.release();
    return true;
  }

  Future<bool> _removeFolder(TokenFolder folder) async {
    await _loadingRepoMutex.acquire();
    final newState = state.removeFolder(folder);
    final success = await _repo.saveReplaceList(newState.folders);
    if (!success) {
      Logger.warning(
        'Failed to remove folder',
        name: 'TokenFolderNotifier#_removeFolder',
      );
      return false;
    }
    state = newState;
    _loadingRepoMutex.release();
    return true;
  }

  Future<bool> addNewFolder(String name) => _addNewFolder(name);

  Future<bool> removeFolder(TokenFolder folder) => _removeFolder(folder);

  /// Search for the current version of the given folder and update it with the updater function.
  /// If the folder is not found, nothing will happen.
  /// Returns true if the operation is successful, false otherwise.
  Future<bool> updateFolder(TokenFolder folder, Function(TokenFolder) updater) async {
    await _updateFolderMutex.acquire();
    final curent = state.currentOf(folder);
    if (curent == null) return false;
    final newFolder = updater(curent);
    final success = await _addOrReplaceFolder(newFolder);
    _updateFolderMutex.release();
    return success;
  }

  Future<bool> addOrReplaceFolders(List<TokenFolder> folders) => _addOrReplaceFolders(folders);

  Future<bool> expandFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isExpanded: true));
  Future<bool> expandFolderById(int folderId) => updateFolder(state.currentById(folderId)!, (p0) => p0.copyWith(isExpanded: true));
  Future<bool> collapseFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isExpanded: false));
  Future<bool> lockFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isLocked: true));
  Future<bool> unlockFolder(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isLocked: false));
  Future<bool> toggleFolderLock(TokenFolder folder) => updateFolder(folder, (p0) => p0.copyWith(isLocked: !folder.isLocked));
  Future<bool> updateLabel(TokenFolder folder, String label) => updateFolder(folder, (p0) => p0.copyWith(label: label));

  Future<bool> collapseLockedFolders() async {
    await _updateFolderMutex.acquire();
    final lockedFolders = state.folders.where((element) => element.isLocked).toList();
    for (var i = 0; i < lockedFolders.length; i++) {
      lockedFolders[i] = lockedFolders[i].copyWith(isExpanded: false);
    }
    final newState = state.addOrReplaceFolders(lockedFolders);
    final success = _addOrReplaceFolders(newState.folders);
    _updateFolderMutex.release();
    return success;
  }
}
