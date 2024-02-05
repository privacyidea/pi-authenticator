import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interfaces/repo/token_folder_repository.dart';
import '../model/states/token_folder_state.dart';
import '../model/token_folder.dart';
import '../utils/logger.dart';

class TokenFolderNotifier extends StateNotifier<TokenFolderState> {
  Future<void>? isLoading;
  final TokenFolderRepository _repo;

  TokenFolderNotifier({required TokenFolderRepository repository, TokenFolderState? initialState})
      : _repo = repository,
        super(initialState ?? const TokenFolderState(folders: [])) {
    _loadFromRepo();
  }

  void _loadFromRepo() => isLoading = Future(() async => state = TokenFolderState(folders: await _repo.loadFolders()));

  void _saveOrReplaceFolders(List<TokenFolder> folders) {
    isLoading = Future(() async {
      final failedFolders = await _repo.saveOrReplaceFolders(folders);
      if (failedFolders.isNotEmpty) {
        Logger.error('Failed to save or replace folders: $failedFolders', name: 'TokenFolderNotifier#_saveOrReplaceFolders');
        state = state.withoutFolders(failedFolders);
      }
    });
  }

  void addFolder(String name) {
    final newState = state.withFolder(name);
    state = newState;
    _saveOrReplaceFolders(newState.folders);
  }

  void removeFolder(TokenFolder folder) {
    final newState = state.withoutFolder(folder);
    state = newState;
    _saveOrReplaceFolders(newState.folders);
  }

  void updateFolder(TokenFolder folder) {
    final newState = state.withUpdated([folder]);
    state = newState;
    _saveOrReplaceFolders(newState.folders);
  }

  void updateFolders(List<TokenFolder> folders) {
    final newState = state.withUpdated(folders);
    state = newState;
    _saveOrReplaceFolders(newState.folders);
  }

  void expandFolderById(int id) {
    final folder = state.folders.firstWhere((element) => element.folderId == id).copyWith(isExpanded: true);
    updateFolder(folder);
  }

  void collapseLockedFolders() {
    final lockedFolders = state.folders.where((element) => element.isLocked).toList();
    for (var i = 0; i < lockedFolders.length; i++) {
      lockedFolders[i] = lockedFolders[i].copyWith(isExpanded: false);
    }
    final newState = state.withUpdated(lockedFolders);
    state = newState;
    _saveOrReplaceFolders(newState.folders);
  }
}
