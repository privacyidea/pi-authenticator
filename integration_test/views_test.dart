import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/settings_groups.dart';

import '../test/tests_app_wrapper.dart';
import '../test/tests_app_wrapper.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final MockSettingsRepository mockSettingsRepository;
  late final MockTokenRepository mockTokenRepository;
  late final MockTokenFolderRepository mockTokenFolderRepository;
  late final MockRsaUtils mockRsaUtils;
  late final MockFirebaseUtils mockFirebaseUtils;
  late final MockPrivacyIdeaIOClient mockIOClient;
  late final MockIntroductionRepository mockIntroductionRepository;
  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async =>
        SettingsState(isFirstRun: false, useSystemLocale: false, localePreference: const Locale('en'), latestStartedVersion: Version.parse('999.999.999')));
    when(mockSettingsRepository.saveSettings(any)).thenAnswer((_) async => true);
    mockTokenRepository = MockTokenRepository();
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async => []);
    when(mockTokenRepository.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
    when(mockTokenRepository.deleteTokens(any)).thenAnswer((_) async => []);
    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadFolders()).thenAnswer((_) async => []);
    when(mockTokenFolderRepository.saveReplaceList(any)).thenAnswer((_) async => true);
    mockRsaUtils = MockRsaUtils();
    when(mockRsaUtils.serializeRSAPublicKeyPKCS8(any)).thenAnswer((_) => 'publicKey');
    when(mockRsaUtils.generateRSAKeyPair()).thenAnswer((_) => const RsaUtils()
        .generateRSAKeyPair()); // We get here a random result anyway and is it more likely to make errors by mocking it than by using the real method
    mockFirebaseUtils = MockFirebaseUtils();
    when(mockFirebaseUtils.getFBToken()).thenAnswer((_) => Future.value('fbToken'));
    when(mockRsaUtils.deserializeRSAPublicKeyPKCS1('publicKey')).thenAnswer((_) => RSAPublicKey(BigInt.one, BigInt.one));
    mockIOClient = MockPrivacyIdeaIOClient();
    when(mockIOClient.doPost(
      url: anyNamed('url'),
      body: anyNamed('body'),
      sslVerify: anyNamed('sslVerify'),
    )).thenAnswer((_) => Future.value(Response('{"detail": {"public_key": "publicKey"}}', 200)));
    mockIntroductionRepository = MockIntroductionRepository();
    final introductions = {...Introduction.values}..remove(Introduction.introductionScreen);
    when(mockIntroductionRepository.loadCompletedIntroductions()).thenAnswer((_) async => IntroductionState(completedIntroductions: introductions));
  });

  testWidgets('Views Test', (tester) async {
    await tester.pumpWidget(TestsAppWrapper(
      overrides: [
        settingsProvider.overrideWith((ref) => SettingsNotifier(repository: mockSettingsRepository)),
        tokenProvider.overrideWith((ref) => TokenNotifier(
              repository: mockTokenRepository,
              rsaUtils: mockRsaUtils,
              firebaseUtils: mockFirebaseUtils,
              ioClient: mockIOClient,
            )),
        tokenFolderProvider.overrideWith((ref) => TokenFolderNotifier(repository: mockTokenFolderRepository)),
      ],
      child: PrivacyIDEAAuthenticator(ApplicationCustomization.defaultCustomization),
    ));

    await _licensesViewTest(tester);
    await _popUntilMainView(tester);
    await _settingsViewTest(tester);
  }, timeout: const Timeout(Duration(minutes: 10)));
}

Future<void> _popUntilMainView(WidgetTester tester) async {
  await pumpUntilFindNWidgets(tester, find.byIcon(Icons.arrow_back), 1, const Duration(seconds: 2));
  while (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await pumpUntilFindNWidgets(tester, find.byIcon(Icons.arrow_back), 1, const Duration(seconds: 2));
  }
  return;
}

Future<void> _licensesViewTest(WidgetTester tester) async {
  await pumpUntilFindNWidgets(tester, find.byIcon(Icons.info_outline), 1, const Duration(seconds: 20));
  await tester.tap(find.byIcon(Icons.info_outline));
  await tester.pumpAndSettle();
  expect(find.text(ApplicationCustomization.defaultCustomization.appName), findsOneWidget);
  expect(find.text(ApplicationCustomization.defaultCustomization.websiteLink), findsOneWidget);
  expect(find.byType(Icon), findsOneWidget);
  expect(find.byType(LicensePage), findsOneWidget);
}

Future<void> _settingsViewTest(WidgetTester tester) async {
  await pumpUntilFindNWidgets(tester, find.byIcon(Icons.settings), 1, const Duration(seconds: 10));
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
  expect(find.text(AppLocalizationsEn().settings), findsOneWidget);
  expect(find.text(AppLocalizationsEn().theme), findsOneWidget);
  expect(find.text(AppLocalizationsEn().language), findsOneWidget);
  expect(find.text(AppLocalizationsEn().errorLogTitle), findsOneWidget);
  expect(find.byType(SettingsGroup), findsNWidgets(5));
  globalRef!.read(tokenProvider.notifier).handleQrCode(
      'otpauth://pipush/label?url=http%3A%2F%2Fwww.example.com&ttl=10&issuer=issuer&enrollment_credential=enrollmentCredentials&v=1&serial=serial&serial=serial&sslverify=0');
  await pumpUntilFindNWidgets(tester, find.text(AppLocalizationsEn().pushToken), 1, const Duration(minutes: 5));
  expect(find.text(AppLocalizationsEn().pushToken), findsOneWidget);
  expect(find.byType(SettingsGroup), findsNWidgets(5));
}
