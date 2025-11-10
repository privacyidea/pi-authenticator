import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gms_check/gms_check.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testTokenFolderNotifier();
}

void _testTokenFolderNotifier() {
  group('TokenFolderNotifier', () {
    test('addFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const TokenFolderState before = TokenFolderState(folders: []);
      const TokenFolderState after = TokenFolderState(folders: [TokenFolder(label: 'test', folderId: 1, isExpanded: false, isLocked: false, sortIndex: null)]);
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderNotifierProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.addNewFolder('test');
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });

    test('removeFolder', () async {
      await GmsCheck().checkGmsAvailability();
      final mockRepo = MockTokenFolderRepository();
      final mockTokenRepo = MockTokenRepository();
      when(mockTokenRepo.loadTokens()).thenAnswer((_) async => const []);
      final container = ProviderContainer(
        overrides: [
          tokenProvider.overrideWith(() => TokenNotifier(repoOverride: mockTokenRepo)),
        ],
      );
      const before = TokenFolderState(folders: [TokenFolder(label: 'test', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null)]);
      const after = TokenFolderState(folders: []);
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderNotifierProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.removeFolder(const TokenFolder(label: 'test', folderId: 1));
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });
    test('updateFolder', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = TokenFolderState(folders: [TokenFolder(label: 'test', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null)]);
      const after = TokenFolderState(folders: [TokenFolder(label: 'testUpdated', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null)]);
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderNotifierProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.updateFolder(before.folders.first, (p0) => after.folders.first);
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });
    test('updateFolders', () async {
      final mockRepo = MockTokenFolderRepository();
      final container = ProviderContainer();
      const before = TokenFolderState(folders: [
        TokenFolder(label: 'test1', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null),
        TokenFolder(label: 'test2', folderId: 2, isExpanded: true, isLocked: false, sortIndex: null),
      ]);
      const after = TokenFolderState(folders: [
        TokenFolder(label: 'test1Updated', folderId: 1, isExpanded: true, isLocked: false, sortIndex: null),
        TokenFolder(label: 'test2Updated', folderId: 2, isExpanded: true, isLocked: false, sortIndex: null),
      ]);
      when(mockRepo.loadState()).thenAnswer((_) async => before);
      when(mockRepo.saveState(after)).thenAnswer((_) async => true);
      final testProvider = tokenFolderNotifierProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      await notifier.initState;
      await notifier.addOrReplaceFolders(after.folders);
      final state = container.read(testProvider);
      expect(state, after);
      verify(mockRepo.saveState(after)).called(1);
    });
  });
}
