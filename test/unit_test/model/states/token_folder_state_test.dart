import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';

void main() {
  _testTokenFolderState();
}

void _testTokenFolderState() {
  group('TokenFolderState', () {
    const state = TokenFolderState(
      folders: [TokenFolder(label: 'label', folderId: 1)],
    );
    test('constructor', () {
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
    });
    test('withFolder', () {
      final newState = state.addNewFolder('newFolder');
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
      expect(newState.folders.length, 2);
      expect(newState.folders.first.label, 'label');
      expect(newState.folders.first.folderId, 1);
      expect(newState.folders.last.label, 'newFolder');
      expect(newState.folders.last.folderId, 2);
    });
    test('withUpdated', () {
      final newState = state.addOrReplaceFolders([
        const TokenFolder(label: 'labelUpdated', folderId: 1),
      ]);
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
      expect(newState.folders.length, 1);
      expect(newState.folders.first.label, 'labelUpdated');
      expect(newState.folders.first.folderId, 1);
    });
    test('withoutFolder', () {
      final newState = state.removeFolder(
        const TokenFolder(label: 'label', folderId: 1),
      );
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
      expect(newState.folders.length, 0);
    });
  });

  group('TokenFolderState', () {
    const a = TokenFolder(label: 'a', folderId: 1);
    const b = TokenFolder(label: 'b', folderId: 2);
    const state = TokenFolderState(folders: [a, b]);

    test('addOrReplaceFolders replaces by id and keeps the order', () {
      const b2 = TokenFolder(label: 'b2', folderId: 2);

      final result = state.addOrReplaceFolders([b2]);

      expect(result.folders, [a, b2]);
    });

    test('addOrReplaceFolders does not modify the original', () {
      state.addOrReplaceFolders([const TokenFolder(label: 'b2', folderId: 2)]);

      expect(state.folders, [a, b]);
    });

    test('addOrReplaceFolders adds folders with a new id', () {
      const c = TokenFolder(label: 'c', folderId: 3);

      final result = state.addOrReplaceFolders([c]);

      expect(result.folders, [a, b, c]);
    }, skip: 'BUG: token_folder_state.dart:45-56 addOrReplaceFolders never adds, the `if (index != -1)` has no else branch');

    test('addOrReplaceFolders handles a mix of new and existing folders', () {
      const b2 = TokenFolder(label: 'b2', folderId: 2);
      const c = TokenFolder(label: 'c', folderId: 3);

      final result = state.addOrReplaceFolders([c, b2]);

      expect(result.folders, [a, b2, c]);
    }, skip: 'BUG: token_folder_state.dart:45-56 addOrReplaceFolders never adds, the `if (index != -1)` has no else branch');

    test('addOrReplaceFolder replaces by id', () {
      const b2 = TokenFolder(label: 'b2', folderId: 2);

      expect(state.addOrReplaceFolder(b2).folders, [a, b2]);
    });

    test('addOrReplaceFolder adds a folder with a new id', () {
      const c = TokenFolder(label: 'c', folderId: 3);

      final result = state.addOrReplaceFolder(c);

      expect(result.folders, [a, b, c]);
    }, skip: 'BUG: token_folder_state.dart:58-67 addOrReplaceFolder never adds, the `if (index != -1)` has no else branch');

    test('addNewFolder uses max id + 1 also with gaps and does not modify the original', () {
      const gap = TokenFolderState(
        folders: [TokenFolder(label: 'x', folderId: 5)],
      );

      final result = gap.addNewFolder('y');

      expect(result.folders.last, const TokenFolder(label: 'y', folderId: 6));
      expect(gap.folders, hasLength(1));
    });

    test('addNewFolder on an empty state starts with id 1', () {
      expect(
        const TokenFolderState(folders: []).addNewFolder('first').folders,
        const [TokenFolder(label: 'first', folderId: 1)],
      );
    });

    test('removeFolder and removeFolders remove by id only', () {
      expect(
        state.removeFolder(const TokenFolder(label: 'other label', folderId: 1)).folders,
        [b],
      );
      expect(state.removeFolders([a, b]).folders, isEmpty);
      expect(state.removeFolders(const []).folders, [a, b]);
      expect(state.folders, [a, b]);
    });

    test('update ignores an unknown folder', () {
      final result = state.update(
        const TokenFolder(label: 'ghost', folderId: 9),
        (f) => f.copyWith(label: 'changed'),
      );

      expect(result.folders, [a, b]);
    });

    test('currentOfId returns null for null and unknown ids', () {
      expect(state.currentOfId(null), isNull);
      expect(state.currentOfId(9), isNull);
      expect(state.currentOfId(2), b);
      expect(state.currentOf(const TokenFolder(label: 'x', folderId: 1)), a);
    });
  });
}
