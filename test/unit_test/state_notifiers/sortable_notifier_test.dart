import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/sortable_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testSortableNotifier();
}

void _testSortableNotifier() {
  group('SortableNotifier test', () {
    test('handleNewList', () async {
      final mockSettingsRepo = MockSettingsRepository();
      when(mockSettingsRepo.loadSettings()).thenAnswer((_) async => SettingsState());
      final MockTokenFolderRepository mockTokenFolderRepository = MockTokenFolderRepository();
      final MockTokenRepository mockTokenRepository = MockTokenRepository();
      List<TokenFolder> tokenFolderState = [
        const TokenFolder(label: 'Folder 1', folderId: 1, sortIndex: null),
        const TokenFolder(label: 'Folder 2', folderId: 2, sortIndex: 2),
      ];
      when(mockTokenFolderRepository.loadFolders()).thenAnswer((_) async => tokenFolderState);
      when(mockTokenFolderRepository.saveReplaceList(any)).thenAnswer((newState) async {
        tokenFolderState = newState.positionalArguments.first as List<TokenFolder>;
        return true;
      });
      List<Token> tokenState = [
        HOTPToken(id: 'Token 1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1', folderId: 1, sortIndex: null),
        TOTPToken(period: 30, id: 'Token 2', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret2', folderId: 2, sortIndex: null),
        HOTPToken(id: 'Token 3', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret3', folderId: null, sortIndex: 1),
      ];
      when(mockTokenRepository.loadTokens()).thenAnswer((_) async => tokenState);
      when(mockTokenRepository.saveOrReplaceTokens(any)).thenAnswer((newState) async {
        final newTokenState = newState.positionalArguments.first as List<Token>;
        for (final token in newTokenState) {
          final index = tokenState.indexWhere((element) => element.id == token.id);
          if (index != -1) {
            tokenState[index] = token;
          } else {
            tokenState.add(token);
          }
        }
        return [];
      });

      final container = ProviderContainer(overrides: [
        settingsProvider.overrideWith((ref) => SettingsNotifier(repository: mockSettingsRepo)),
        tokenFolderProvider.overrideWith((ref) => TokenFolderNotifier(repository: mockTokenFolderRepository)),
        tokenProvider.overrideWith((ref) => TokenNotifier(repository: mockTokenRepository, ref: ref)),
      ]);

      final SortableNotifier sortableNotifier = container.read(sortableProvider.notifier);

      final newToken = TOTPToken(period: 30, id: 'Token 4', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret4', folderId: 1, sortIndex: 1);

      final newTokenState = tokenState.toList()..add(newToken);
      final newState = await sortableNotifier.handleNewStateList(newTokenState);

      final newSortableState = container.read(sortableProvider);
      expect(newState.length, 6);
      expect(newSortableState.length, 6);
      expect(newSortableState[0], isA<Token>());
      expect((newSortableState[0] as Token).id, 'Token 3');
      expect(newSortableState[1], isA<Token>());
      expect((newSortableState[1] as Token).id, 'Token 4');
      expect(newSortableState[2], isA<TokenFolder>());
      expect((newSortableState[2] as TokenFolder).label, 'Folder 2');
    });
  });
}
