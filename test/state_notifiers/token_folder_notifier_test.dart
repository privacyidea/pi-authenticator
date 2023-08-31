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
      final before = <TokenFolder>[];
      final after = <TokenFolder>[const TokenFolder(label: 'test', folderId: 1)];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveFolders(after)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.addFolder('test'), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.folders, after);
      verify(mockRepo.saveFolders(after)).called(1);
    });

    test('removeFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      final before = <TokenFolder>[const TokenFolder(label: 'test', folderId: 1)];
      final after = <TokenFolder>[];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveFolders(after)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.removeFolder(const TokenFolder(label: 'test', folderId: 1)), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.folders, after);
      verify(mockRepo.saveFolders(after)).called(1);
    });
    test('updateFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      final before = <TokenFolder>[const TokenFolder(label: 'test', folderId: 1)];
      final after = <TokenFolder>[const TokenFolder(label: 'testUpdated', folderId: 1)];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveFolders(after)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.updateFolder(after.first), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.folders, after);
      verify(mockRepo.saveFolders(after)).called(1);
    });
    test('updateFolders', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      final before = <TokenFolder>[const TokenFolder(label: 'test1', folderId: 1), const TokenFolder(label: 'test2', folderId: 2)];
      final after = <TokenFolder>[const TokenFolder(label: 'test1Updated', folderId: 1), const TokenFolder(label: 'test2Updated', folderId: 2)];
      when(mockRepo.loadFolders()).thenAnswer((_) async => before);
      when(mockRepo.saveFolders(after)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>((ref) => TokenFolderNotifier(
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      expect(await notifier.updateFolders(after), true);
      final state = container.read(testProvider);
      expect(state, isNotNull);
      expect(state.folders, after);
      verify(mockRepo.saveFolders(after)).called(1);
    });
  });
}
