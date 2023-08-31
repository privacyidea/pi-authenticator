import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/states/token_folder_state.dart';
import '../model/token_folder.dart';
import '../interfaces/repo/token_folder_repository.dart';

class TokenFolderNotifier extends StateNotifier<TokenFolderState> {
  late Future<void> _loading;
  final TokenFolderRepository _repo;

  TokenFolderNotifier({required TokenFolderRepository repository, TokenFolderState? initialState})
      : _repo = repository,
        super(initialState ?? const TokenFolderState(folders: [])) {
    _loadFromRepo();
  }

  void _loadFromRepo() => _loading = Future(() async => state = TokenFolderState(folders: await _repo.loadFolders()));

  Future<bool> _saveFolders(TokenFolderState newState) async {
    final failedFolders = await _repo.saveOrReplaceFolders(newState.folders);
    if (failedFolders.isEmpty) {
      state = newState;
      return true;
    }
    return false;
  }

  Future<bool> addFolder(String name) async {
    await _loading;
    final newState = state.withFolder(name);
    return _saveFolders(newState);
  }

  Future<bool> removeFolder(TokenFolder folder) async {
    await _loading;
    final newState = state.withoutFolder(folder);
    return _saveFolders(newState);
  }

  Future<bool> updateFolder(TokenFolder folder) async {
    await _loading;
    final newState = state.withUpdated([folder]);
    return _saveFolders(newState);
  }

  Future<bool> updateFolders(List<TokenFolder> folders) async {
    await _loading;
    final newState = state.withUpdated(folders);
    return _saveFolders(newState);
  }
}
