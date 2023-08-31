import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/states/token_folder_state.dart';
import '../model/token_folder.dart';
import '../interfaces/repo/token_folder_repository.dart';

class TokenFolderNotifier extends StateNotifier<TokenFolderState> {
  late Future<void> _isInitialized;
  final TokenFolderRepository _repo;

  TokenFolderNotifier({required TokenFolderRepository repository, TokenFolderState? initialState})
      : _repo = repository,
        super(initialState ?? const TokenFolderState(folders: [])) {
    _isInitialized = Future(() => _loadFromRepo());
  }

  void _loadFromRepo() async => _repo.loadFolders().then((value) => state = TokenFolderState(folders: value));

  Future<bool> _saveToRepo(TokenFolderState newState) => _repo.saveFolders(newState.folders);

  Future<bool> addFolder(String name) async {
    await _isInitialized;
    final newState = state.withFolder(name);
    final success = await _saveToRepo(newState);
    if (success) {
      state = newState;
    }
    return success;
  }

  Future<bool> removeFolder(TokenFolder folder) async {
    await _isInitialized;
    final newState = state.withoutFolder(folder);
    final success = await _saveToRepo(newState);
    if (success) {
      state = newState;
    }
    return success;
  }

  Future<bool> updateFolder(TokenFolder folder) async {
    await _isInitialized;
    final newState = state.withUpdated([folder]);
    final success = await _saveToRepo(newState);
    if (success) {
      state = newState;
    }
    return success;
  }

  Future<bool> updateFolders(List<TokenFolder> folders) async {
    await _isInitialized;
    final newState = state.withUpdated(folders);
    final success = await _saveToRepo(newState);
    if (success) {
      state = newState;
    }
    return success;
  }
}
