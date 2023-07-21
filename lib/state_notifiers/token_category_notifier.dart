import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/states/token_category_state.dart';

class TokenCategoryNotifier extends StateNotifier<TokenCategoryState> {
  TokenCategoryNotifier() : super(TokenCategoryState(categorys: [])) {
    _loadFromStorage();
  }

  void _saveToStorage() {
    //TODO: Save categories to storage
  }

  void _loadFromStorage() {
    //TODO: Load categories from storage
  }

  void addCategory(String name) {
    state = state.withCategory(name);
    _saveToStorage();
  }
}
