import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/token_folder_repository.dart';
import '../model/token_folder.dart';
import '../utils/logger.dart';

class PreferenceTokenFolderRepository extends TokenFolderRepository {
  static const String _tokenFoldersKey = 'TOKEN_CATEGORIES';
  final Future<SharedPreferences> _prefs;
  PreferenceTokenFolderRepository() : _prefs = SharedPreferences.getInstance();

  @override
  Future<List<TokenFolder>> loadFolders() async {
    try {
      final foldersString = await _prefs.then((prefs) => prefs.getString(_tokenFoldersKey));
      if (foldersString == null) return [];
      final jsons = jsonDecode(foldersString) as List<dynamic>;
      final folders = jsons.map((e) => TokenFolder.fromJson(e)).toList();
      return folders;
    } catch (e, s) {
      Logger.error('Failed to load folders', name: 'PreferenceTokenFolderRepository#loadFolders', error: e, stackTrace: s);
      return [];
    }
  }

  @override
  Future<bool> saveReplaceList(List<TokenFolder> folders) async {
    try {
      final jsons = folders.map((e) => e.toJson()).toList();
      final json = jsonEncode(jsons);
      await _prefs.then((prefs) => prefs.setString(_tokenFoldersKey, json));
      return true;
    } catch (e, s) {
      Logger.error('Failed to save folders', name: 'PreferenceTokenFolderRepository#saveFolders', error: e, stackTrace: s);
      return false;
    }
  }
}
