import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';

void main() {
  _testTokenFolderState();
}

void _testTokenFolderState() {
  group('TokenFolderState', () {
    const state = TokenFolderState(folders: [TokenFolder(label: 'label', folderId: 1)]);
    test('constructor', () {
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
    });
    test('copyWith', () {
      final newState = state.copyWith(folders: [const TokenFolder(label: 'labelCopy', folderId: 2)]);
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
      expect(newState.folders.first.label, 'labelCopy');
      expect(newState.folders.first.folderId, 2);
    });
    test('withFolder', () {
      final newState = state.withFolder('newFolder');
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
      expect(newState.folders.length, 2);
      expect(newState.folders.first.label, 'label');
      expect(newState.folders.first.folderId, 1);
      expect(newState.folders.last.label, 'newFolder');
      expect(newState.folders.last.folderId, 2);
    });
    test('withUpdated', () {
      final newState = state.withUpdated(folders: [const TokenFolder(label: 'labelUpdated', folderId: 1)]);
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
      expect(newState.folders.length, 1);
      expect(newState.folders.first.label, 'labelUpdated');
      expect(newState.folders.first.folderId, 1);
    });
    test('withoutFolder', () {
      final newState = state.withoutFolder(const TokenFolder(label: 'label', folderId: 1));
      expect(state.folders.first.label, 'label');
      expect(state.folders.first.folderId, 1);
      expect(newState.folders.length, 0);
    });
  });
}
