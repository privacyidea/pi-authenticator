/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:convert';

import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/token_folder_repository.dart';
import '../model/riverpod_states/token_folder_state.dart';
import '../model/token_folder.dart';
import '../utils/logger.dart';

class PreferenceTokenFolderRepository extends TokenFolderRepository {
  static const String _tokenFoldersKey = 'TOKEN_CATEGORIES';
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  static final Mutex _m = Mutex();
  static Future<T> _protect<T>(Future<T> Function() f) => _m.protect<T>(f);

  @override
  Future<TokenFolderState> loadState() async => _protect(_loadFolders);
  Future<TokenFolderState> _loadFolders() async {
    try {
      final foldersString = await _prefs.then((prefs) => prefs.getString(_tokenFoldersKey));
      if (foldersString == null) return const TokenFolderState(folders: []);
      final jsons = jsonDecode(foldersString) as List<dynamic>;
      final folders = jsons.map((e) => TokenFolder.fromJson(e)).toList();
      Logger.info('Loaded ${folders.length} folders from preferences');

      return TokenFolderState(folders: folders);
    } catch (e, s) {
      Logger.error('Failed to load folders', error: e, stackTrace: s);
      return const TokenFolderState(folders: []);
    }
  }

  @override
  Future<bool> saveState(TokenFolderState state) => _protect(() => _saveReplaceList(state));
  Future<bool> _saveReplaceList(TokenFolderState state) async {
    final folders = state.folders;
    Logger.info('Saving ${folders.length} folders to preferences...');
    try {
      final jsons = folders.map((e) => e.toJson()).toList();
      final json = jsonEncode(jsons);
      await _prefs.then((prefs) => prefs.setString(_tokenFoldersKey, json));
      Logger.info('Saved ${folders.length} folders to preferences');

      return true;
    } catch (e, s) {
      Logger.error('Failed to save folders', error: e, stackTrace: s);

      return false;
    }
  }
}
