import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/repo/preference_token_folder_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _key = 'TOKEN_CATEGORIES';

/// A store that reports every write as failed.
class _FailingWriteStore extends InMemorySharedPreferencesStore {
  _FailingWriteStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SharedPreferencesStorePlatform originalStore;

  setUpAll(() async {
    // The repository keeps the SharedPreferences instance in a static field.
    // Create the instance once and share it with the repository.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    originalStore = SharedPreferencesStorePlatform.instance;
  });

  setUp(() async {
    SharedPreferencesStorePlatform.instance = originalStore;
    await prefs.clear();
  });

  Future<void> storeJson(Object json) => prefs.setString(_key, jsonEncode(json));

  group('PreferenceTokenFolderRepository load', () {
    test('a missing key yields an empty state', () async {
      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state, const TokenFolderState(folders: []));
      expect(prefs.getKeys(), isEmpty, reason: 'loading must not write');
    });

    test('stored folders are read with all fields', () async {
      await storeJson([
        {
          'label': 'Work',
          'folderId': 3,
          'isExpanded': true,
          'isLocked': false,
          'sortIndex': 7,
        },
        {'label': 'Private', 'folderId': 5},
      ]);

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state.folders, const [
        TokenFolder(
          label: 'Work',
          folderId: 3,
          isExpanded: true,
          sortIndex: 7,
        ),
        TokenFolder(label: 'Private', folderId: 5),
      ]);
    });

    test('an empty list yields an empty state', () async {
      await storeJson([]);

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state.folders, isEmpty);
    });

    test('a locked folder is loaded collapsed even if it was stored expanded', () async {
      await storeJson([
        {'label': 'Secret', 'folderId': 1, 'isExpanded': true, 'isLocked': true},
      ]);

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state.folders.single.isLocked, isTrue);
      expect(state.folders.single.isExpanded, isFalse);
    });

    test('corrupt JSON yields an empty state instead of throwing', () async {
      await prefs.setString(_key, '[{"label": "x", ');

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state, const TokenFolderState(folders: []));
    });

    test('valid JSON of the wrong shape yields an empty state', () async {
      await storeJson({'label': 'not a list'});

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state, const TokenFolderState(folders: []));
    });

    test('a non string value under the key yields an empty state', () async {
      await prefs.setInt(_key, 5);

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state, const TokenFolderState(folders: []));
    });

    test('one bad element does not discard the valid folders', () async {
      await storeJson([
        {'label': 'Good1', 'folderId': 1},
        {'label': 'Bad', 'folderId': 'not a number'},
        {'label': 'Good2', 'folderId': 2},
      ]);

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(
        state.folders,
        const [
          TokenFolder(label: 'Good1', folderId: 1),
          TokenFolder(label: 'Good2', folderId: 2),
        ],
      );
    }, skip: 'BUG: preference_token_folder_repository.dart:48-53 one element that fails TokenFolder.fromJson makes the whole load fall into the catch and return an empty list, all folders are lost');

    test('one element that is not a map does not discard the valid folders', () async {
      await storeJson([
        {'label': 'Good1', 'folderId': 1},
        'garbage',
      ]);

      final state = await PreferenceTokenFolderRepository().loadState();

      expect(state.folders, const [TokenFolder(label: 'Good1', folderId: 1)]);
    }, skip: 'BUG: preference_token_folder_repository.dart:48-53 one element that fails TokenFolder.fromJson makes the whole load fall into the catch and return an empty list, all folders are lost');
  });

  group('PreferenceTokenFolderRepository save', () {
    test('saves under TOKEN_CATEGORIES as a JSON list', () async {
      final saved = await PreferenceTokenFolderRepository().saveState(
        const TokenFolderState(
          folders: [TokenFolder(label: 'Work', folderId: 1, sortIndex: 2)],
        ),
      );

      expect(saved, isTrue);
      expect(prefs.getKeys(), {_key});
      expect(jsonDecode(prefs.getString(_key)!), [
        {
          'label': 'Work',
          'folderId': 1,
          'isExpanded': false,
          'isLocked': false,
          'sortIndex': 2,
        },
      ]);
    });

    test('round trip keeps label, id, sortIndex and isExpanded', () async {
      final repo = PreferenceTokenFolderRepository();
      const state = TokenFolderState(
        folders: [
          TokenFolder(label: 'Open', folderId: 1, isExpanded: true),
          TokenFolder(label: 'Closed', folderId: 2, sortIndex: 4),
        ],
      );

      await repo.saveState(state);

      expect(await PreferenceTokenFolderRepository().loadState(), state);
    });

    test('round trip keeps isLocked (a locked folder comes back collapsed)', () async {
      final repo = PreferenceTokenFolderRepository();
      await repo.saveState(
        const TokenFolderState(
          folders: [
            TokenFolder(label: 'Locked', folderId: 1, isLocked: true),
            TokenFolder(label: 'Free', folderId: 2),
          ],
        ),
      );

      final loaded = await repo.loadState();

      expect(loaded.folders[0].isLocked, isTrue);
      expect(loaded.folders[1].isLocked, isFalse);
    });

    test('a locked and expanded folder is restored collapsed', () async {
      final repo = PreferenceTokenFolderRepository();
      await repo.saveState(
        const TokenFolderState(
          folders: [
            TokenFolder(
              label: 'Locked',
              folderId: 1,
              isLocked: true,
              isExpanded: true,
            ),
          ],
        ),
      );
      expect(
        (jsonDecode(prefs.getString(_key)!) as List).single['isExpanded'],
        isTrue,
        reason: 'the saved data is not modified',
      );

      final loaded = await repo.loadState();

      expect(loaded.folders.single.isExpanded, isFalse);
    });

    test('saving an empty state clears the stored folders', () async {
      final repo = PreferenceTokenFolderRepository();
      await repo.saveState(
        const TokenFolderState(folders: [TokenFolder(label: 'x', folderId: 1)]),
      );

      final saved = await repo.saveState(const TokenFolderState(folders: []));

      expect(saved, isTrue);
      expect((await repo.loadState()).folders, isEmpty);
    });

    test('a later save replaces the earlier one', () async {
      final repo = PreferenceTokenFolderRepository();
      await repo.saveState(
        const TokenFolderState(folders: [TokenFolder(label: 'a', folderId: 1)]),
      );

      await repo.saveState(
        const TokenFolderState(folders: [TokenFolder(label: 'b', folderId: 2)]),
      );

      expect((await repo.loadState()).folders, const [
        TokenFolder(label: 'b', folderId: 2),
      ]);
    });

    test('concurrent saves are serialized, the last call wins', () async {
      final repo = PreferenceTokenFolderRepository();

      final results = await Future.wait([
        repo.saveState(
          const TokenFolderState(folders: [TokenFolder(label: 'a', folderId: 1)]),
        ),
        repo.saveState(
          const TokenFolderState(
            folders: [
              TokenFolder(label: 'a', folderId: 1),
              TokenFolder(label: 'b', folderId: 2),
            ],
          ),
        ),
      ]);

      expect(results, [true, true]);
      expect((await repo.loadState()).folders.map((f) => f.label), ['a', 'b']);
    });

    test('save reports failure when the storage rejects the write', () async {
      SharedPreferencesStorePlatform.instance = _FailingWriteStore();

      final saved = await PreferenceTokenFolderRepository().saveState(
        const TokenFolderState(folders: [TokenFolder(label: 'a', folderId: 1)]),
      );

      expect(saved, isFalse);
    }, skip: 'BUG: preference_token_folder_repository.dart:68 saveState ignores the bool result of setString and returns true even if the write failed');
  });
}
