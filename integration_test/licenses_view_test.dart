import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/main_netknights.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';

import '../test/tests_app_wrapper.dart';
import '../test/tests_app_wrapper.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final MockSettingsRepository mockSettingsRepository;
  late final MockTokenRepository mockTokenRepository;
  late final MockTokenFolderRepository mockTokenFolderRepository;
  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings())
        .thenAnswer((_) async => SettingsState(isFirstRun: false, localePreference: const Locale('en', 'US'), useSystemLocale: false));
    when(mockSettingsRepository.saveSettings(any)).thenAnswer((_) async => true);
    mockTokenRepository = MockTokenRepository();
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async => []);
    when(mockTokenRepository.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
    when(mockTokenRepository.deleteTokens(any)).thenAnswer((_) async => []);
    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadFolders()).thenAnswer((_) async => []);
    when(mockTokenFolderRepository.saveOrReplaceFolders(any)).thenAnswer((_) async => []);
  });
  testWidgets('Licenses View', (tester) async {
    await tester.pumpWidget(TestsAppWrapper(
      overrides: [
        settingsProvider.overrideWith((ref) => SettingsNotifier(repository: mockSettingsRepository)),
        tokenProvider.overrideWith((ref) => TokenNotifier(repository: mockTokenRepository)),
        tokenFolderProvider.overrideWith((ref) => TokenFolderNotifier(repository: mockTokenFolderRepository)),
      ],
      child: PrivacyIDEAAuthenticator(customization: ApplicationCustomization.defaultCustomization),
    ));

    await waitFor(const Duration(seconds: 3), tester);
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text(ApplicationCustomization.defaultCustomization.appName), findsOneWidget);
    expect(find.text(ApplicationCustomization.defaultCustomization.websiteLink), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Licenses'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
