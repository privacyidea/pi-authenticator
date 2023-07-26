import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repo/token_category_repository.dart';
import '../model/token_category.dart';

import '../model/states/token_category_state.dart';

class TokenCategoryNotifier extends StateNotifier<TokenCategoryState> {
  final TokenCategoryRepositoy _repo;

  TokenCategoryNotifier({required TokenCategoryRepositoy repositoy})
      : _repo = repositoy,
        super(const TokenCategoryState(categorys: [])) {
    _loadFromStorage();
  }

  void _loadFromStorage() async => _repo.loadCategories().then((value) => state = TokenCategoryState(categorys: value));

  void _saveToStorage() async => _repo.saveCategorys(state.categorys);

  void addCategory(String name) {
    state = state.withCategory(name);
    _saveToStorage();
  }

  void removeCategory(TokenCategory category) {
    state = state.withoutCategory(category);
    _saveToStorage();
  }

  void updateCategory(TokenCategory category) {
    state = state.withUpdated(categorys: [category]);
    _saveToStorage();
  }

  void updateCategorys(List<TokenCategory> categorys) {
    state = state.withUpdated(categorys: categorys);
    _saveToStorage();
  }
}
