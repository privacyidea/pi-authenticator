import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/states/token_folder_state.dart';
import '../model/token_folder.dart';
import '../repo/token_folder_repository.dart';

class TokenFolderNotifier extends StateNotifier<TokenFolderState> {
  final TokenFolderRepositoy _repo;

  TokenFolderNotifier({required TokenFolderRepositoy repositoy})
      : _repo = repositoy,
        super(const TokenFolderState(folders: [])) {
    _loadFromStorage();
  }

  void _loadFromStorage() async => _repo.loadFolders().then((value) => state = TokenFolderState(folders: value));

  void _saveToStorage() async => _repo.saveFolders(state.folders);

  void addFolder(String name) {
    state = state.withFolder(name);
    _saveToStorage();
  }

  void removeFolder(TokenFolder folder) {
    state = state.withoutFolder(folder);
    _saveToStorage();
  }

  void updateFolder(TokenFolder folder) {
    state = state.withUpdated(folders: [folder]);
    _saveToStorage();
  }

  void updateFolders(List<TokenFolder> folders) {
    state = state.withUpdated(folders: folders);
    _saveToStorage();
  }
}
