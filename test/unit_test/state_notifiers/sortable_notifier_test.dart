import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gms_check/gms_check.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/sortable_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testSortableNotifier();
}

void _testSortableNotifier() {
  group('SortableNotifier test', () {
    test('handleNewList', () async {
      final mockSettingsRepo = MockSettingsRepository();
      await GmsCheck().checkGmsAvailability();
      when(mockSettingsRepo.loadSettings()).thenAnswer((_) async => SettingsState());
      final MockTokenFolderRepository mockTokenFolderRepository = MockTokenFolderRepository();
      final MockTokenRepository mockTokenRepository = MockTokenRepository();
      TokenFolderState tokenFolderState = const TokenFolderState(folders: [
        TokenFolder(label: 'Folder 1', folderId: 1, sortIndex: null),
        TokenFolder(label: 'Folder 2', folderId: 2, sortIndex: 2),
      ]);
      when(mockTokenFolderRepository.loadState()).thenAnswer((_) async {
        Logger.debug('Loading token folder state');
        return tokenFolderState;
      });
      when(mockTokenFolderRepository.saveState(any)).thenAnswer((newState) async {
        tokenFolderState = newState.positionalArguments.first as TokenFolderState;
        return true;
      });
      List<Token> tokenState = [
        HOTPToken(id: 'Token 1', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret1', folderId: 1, sortIndex: null),
        TOTPToken(period: 30, id: 'Token 2', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret2', folderId: 2, sortIndex: null),
        HOTPToken(id: 'Token 3', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret3', folderId: null, sortIndex: 1),
      ];
      when(mockTokenRepository.loadTokens()).thenAnswer((_) async => tokenState);
      when(mockTokenRepository.saveOrReplaceToken(any)).thenAnswer((newState) async {
        final token = newState.positionalArguments.first as Token;
        final index = tokenState.indexWhere((element) => element.id == token.id);
        if (index != -1) {
          tokenState[index] = token;
        } else {
          tokenState.add(token);
        }
        return true;
      });

      final container = ProviderContainer(overrides: [
        settingsProvider.overrideWith(() => SettingsNotifier(repoOverride: mockSettingsRepo)),
        tokenFolderProvider.overrideWith(() => TokenFolderNotifier(repoOverride: mockTokenFolderRepository)),
        tokenProvider.overrideWith(() => TokenNotifier(repoOverride: mockTokenRepository)),
      ]);
      WidgetsFlutterBinding.ensureInitialized();
      final newToken = TOTPToken(period: 30, id: 'Token 4', algorithm: Algorithms.SHA1, digits: 6, secret: 'secret4', folderId: 1, sortIndex: 1);
      await container.read(tokenProvider.notifier).addNewToken(newToken);

      await container.read(tokenFolderProvider.notifier).addNewFolder('Folder 3');
      await Future.delayed(const Duration(milliseconds: 1000));
      final newSortableState = container.read(sortablesProvider);

      expect(newSortableState.length, 7);
      expect(newSortableState[0], isA<Token>());
      expect((newSortableState[0] as Token).id, 'Token 3');
      expect(newSortableState[1], isA<Token>());
      expect((newSortableState[1] as Token).id, 'Token 4');
      expect(newSortableState[2], isA<TokenFolder>());
      expect((newSortableState[2] as TokenFolder).label, 'Folder 2');
      expect((newSortableState.last as TokenFolder).label, 'Folder 3');
      expect((newSortableState.last as TokenFolder).sortIndex, 6);
    });
  });
}
