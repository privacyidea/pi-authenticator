import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:privacyidea_authenticator/model/states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_folder_notifier.dart';

import 'token_folder_notifier_test.mocks.dart';

@GenerateMocks([TokenFolderRepository])
void main() {
  _testTokenFolderNotifier();
}

void _testTokenFolderNotifier() {
  group('TokenFolderNotifier', () {
    test('addFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = <TokenFolder>[];
      const after = [TokenFolder(label: 'test', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null)];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceFolders(after)).thenAnswer((_) async => []);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      await notifier.isLoading;
      notifier.addFolder('test');
      await notifier.isLoading;
      final state = container.read(testProvider);
      expect(state.folders, after);
      verify(mockRepo.saveOrReplaceFolders(after)).called(1);
    });

    test('removeFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = [TokenFolder(label: 'test', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null)];
      const after = <TokenFolder>[];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceFolders(after)).thenAnswer((_) async => []);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      await notifier.isLoading;
      notifier.removeFolder(const TokenFolder(label: 'test', folderId: 1));
      await notifier.isLoading;
      final state = container.read(testProvider);
      expect(state.folders, after);
      verify(mockRepo.saveOrReplaceFolders(after)).called(1);
    });
    test('updateFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = [TokenFolder(label: 'test', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null)];
      const after = [TokenFolder(label: 'testUpdated', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null)];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceFolders(after)).thenAnswer((_) async => []);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      await notifier.isLoading;
      notifier.updateFolder(after.first);
      await notifier.isLoading;
      final state = container.read(testProvider);
      expect(state.folders, after);
      verify(mockRepo.saveOrReplaceFolders(after)).called(1);
    });
    test('updateFolders', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = [
        TokenFolder(label: 'test1', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null),
        TokenFolder(label: 'test2', folderId: 2, isExpanded: true, isLocked: false, sortIndex: null),
      ];
      const after = [
        TokenFolder(label: 'test1Updated', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null),
        TokenFolder(label: 'test2Updated', folderId: 2, isExpanded: true, isLocked: false, sortIndex: null),
      ];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveOrReplaceFolders(after)).thenAnswer((_) async => []);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      await notifier.isLoading;
      notifier.updateFolders(after);
      await notifier.isLoading;
      final state = container.read(testProvider);
      expect(state.folders, after);
      verify(mockRepo.saveOrReplaceFolders(after)).called(1);
    });
  });
}
