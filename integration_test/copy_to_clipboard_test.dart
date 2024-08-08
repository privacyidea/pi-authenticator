import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/token_notifier.dart';

import '../test/tests_app_wrapper.dart';
import '../test/tests_app_wrapper.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final MockSettingsRepository mockSettingsRepository;
  late final MockTokenRepository mockTokenRepository;
  late final MockTokenFolderRepository mockTokenFolderRepository;
  late final MockIntroductionRepository mockIntroductionRepository;
  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async =>
        SettingsState(isFirstRun: false, useSystemLocale: false, localePreference: const Locale('en'), latestStartedVersion: Version.parse('999.999.999')));
    when(mockSettingsRepository.saveSettings(any)).thenAnswer((_) async => true);
    mockTokenRepository = MockTokenRepository();
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async => [
          HOTPToken(label: 'test', issuer: 'test', id: 'id', algorithm: Algorithms.SHA256, digits: 6, secret: 'secret', counter: 0),
        ]);
    when(mockTokenRepository.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
    when(mockTokenRepository.deleteTokens(any)).thenAnswer((_) async => []);
    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadState()).thenAnswer((_) async => const TokenFolderState(folders: []));
    when(mockTokenFolderRepository.saveState(any)).thenAnswer((_) async => true);
    mockIntroductionRepository = MockIntroductionRepository();
    when(mockIntroductionRepository.loadCompletedIntroductions())
        .thenAnswer((_) async => const IntroductionState(completedIntroductions: {...Introduction.values}));
  });
  testWidgets('Copy to Clipboard Test', (tester) async {
    await tester.pumpWidget(TestsAppWrapper(
      overrides: [
        settingsProvider.overrideWith(() => SettingsNotifier(repoOverride: mockSettingsRepository)),
        tokenProvider.overrideWith(() => TokenNotifier(repoOverride: mockTokenRepository)),
        tokenFolderProvider.overrideWith(() => TokenFolderNotifier(repoOverride: mockTokenFolderRepository)),
        introductionNotifierProvider.overrideWith(() => IntroductionNotifier(repoOverride: mockIntroductionRepository)),
      ],
      child: PrivacyIDEAAuthenticator(ApplicationCustomization.defaultCustomization),
    ));
    await tester.pumpAndSettle();
    await pumpUntilFindNWidgets(tester, find.text('356 306'), 1, const Duration(seconds: 10));
    expect(find.text('356 306'), findsOneWidget);
    await tester.tap(find.text('356 306'));
    await tester.pumpAndSettle();
    expect(find.text('Password "356306" copied to clipboard.'), findsOneWidget);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
