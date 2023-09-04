import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';

void main() {
  _testTokenFolder();
}

void _testTokenFolder() {
  group('TokenFolder', () {
    test('constructor', () {
      const folder1 = TokenFolder(label: 'test', folderId: 1, isExpanded: true, isLocked: false, sortIndex: 0);
      expect(folder1.label, 'test');
      expect(folder1.folderId, 1);
      expect(folder1.isExpanded, true);
      expect(folder1.isLocked, false);
      expect(folder1.sortIndex, 0);
      const folder2 = TokenFolder(label: 'test2', folderId: 2, isExpanded: false, isLocked: true, sortIndex: 1);
      expect(folder2.label, 'test2');
      expect(folder2.folderId, 2);
      expect(folder2.isExpanded, false);
      expect(folder2.isLocked, true);
      expect(folder2.sortIndex, 1);
    });
    test('copyWith', () {
      const folder = TokenFolder(label: 'test', folderId: 1, isExpanded: true, isLocked: false, sortIndex: 0);
      final folderCopy = folder.copyWith(label: 'test2', folderId: 2, isExpanded: false, isLocked: true, sortIndex: 1);
      expect(folderCopy.label, 'test2');
      expect(folderCopy.folderId, 2);
      expect(folderCopy.isExpanded, false);
      expect(folderCopy.isLocked, true);
      expect(folderCopy.sortIndex, 1);
    });
    test('fromJson', () {
      final folder1 = TokenFolder.fromJson(const {
        'label': 'test',
        'folderId': 1,
        'isExpanded': true,
        'isLocked': true,
        'sortIndex': 0,
      });
      expect(folder1.label, 'test');
      expect(folder1.folderId, 1);
      expect(folder1.isExpanded, false);
      expect(folder1.isLocked, true);
      expect(folder1.sortIndex, 0);
      final folder2 = TokenFolder.fromJson(const {
        'label': 'test2',
        'folderId': 2,
        'isExpanded': true,
        'isLocked': false,
        'sortIndex': 1,
      });
      expect(folder2.label, 'test2');
      expect(folder2.folderId, 2);
      expect(folder2.isExpanded, true);
      expect(folder2.isLocked, false);
      expect(folder2.sortIndex, 1);
    });
  });
}
