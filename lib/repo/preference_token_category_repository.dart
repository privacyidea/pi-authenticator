import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/token_category.dart';
import '../utils/logger.dart';
import 'token_category_repository.dart';

class PreferenceTokenCategoryRepotisory extends TokenCategoryRepositoy {
  static const String _tokenCategorysKey = 'TOKEN_CATEGORYS';
  final Future<SharedPreferences> _prefs;
  PreferenceTokenCategoryRepotisory() : _prefs = SharedPreferences.getInstance();

  @override
  Future<List<TokenCategory>> loadCategories() async {
    try {
      final categorysStrig = await _prefs.then((prefs) => prefs.getString(_tokenCategorysKey));
      if (categorysStrig == null) return [];
      final jsons = jsonDecode(categorysStrig) as List<dynamic>;
      final categories = jsons.map((e) => TokenCategory.fromJson(e)).toList();
      return categories;
    } catch (e, s) {
      Logger.error('Failed to load categories', name: 'PreferenceTokenCategoryRepotisory#loadCategories', error: e, stackTrace: s);
      return [];
    }
  }

  @override
  Future<bool> saveCategorys(List<TokenCategory> categories) async {
    try {
      final jsons = categories.map((e) => e.toJson()).toList();
      final json = jsonEncode(jsons);
      await _prefs.then((prefs) => prefs.setString(_tokenCategorysKey, json));
      return true;
    } catch (e, s) {
      Logger.error('Failed to save categories', name: 'PreferenceTokenCategoryRepotisory#saveCategorys', error: e, stackTrace: s);
      return false;
    }
  }
}
