import '../model/token_category.dart';

abstract class TokenCategoryRepositoy {
  Future<bool> saveCategorys(List<TokenCategory> categories);
  Future<List<TokenCategory>> loadCategories();
}
