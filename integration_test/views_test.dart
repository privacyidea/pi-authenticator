import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/custom_int_buffer.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';

import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/settings_group.dart';

import '../test/tests_app_wrapper.dart';
import '../test/tests_app_wrapper.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final MockSettingsRepository mockSettingsRepository;
  late final MockTokenRepository mockTokenRepository;
  late final MockTokenFolderRepository mockTokenFolderRepository;
  late final MockRsaUtils mockRsaUtils;
  late final MockFirebaseUtils mockFirebaseUtils;
  late final MockPrivacyideaIOClient mockIOClient;
  late final MockIntroductionRepository mockIntroductionRepository;
  late final MockPushRequestRepository mockPushRequestRepository;
  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async =>
        SettingsState(isFirstRun: false, useSystemLocale: false, localePreference: const Locale('en'), latestStartedVersion: Version.parse('999.999.999')));
    when(mockSettingsRepository.saveSettings(any)).thenAnswer((_) async => true);

    mockTokenRepository = MockTokenRepository();
    var tokens = <Token>[];
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async => tokens);
    when(mockTokenRepository.saveOrReplaceToken(any)).thenAnswer((invocation) async {
      final arguments = invocation.positionalArguments;
      tokens.removeWhere((element) => element.id == (arguments[0] as Token).id);
      tokens.add(arguments[0] as Token);
      return true;
    });
    when(mockTokenRepository.deleteToken(any)).thenAnswer((invocation) async {
      final arguments = invocation.positionalArguments;
      tokens.removeWhere((element) => element.id == (arguments[0] as Token).id);
      return true;
    });

    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadState()).thenAnswer((_) async => const TokenFolderState(folders: []));
    when(mockTokenFolderRepository.saveState(any)).thenAnswer((_) async => true);
    mockRsaUtils = MockRsaUtils();
    when(mockRsaUtils.serializeRSAPublicKeyPKCS8(any)).thenAnswer((_) => 'publicKey');
    when(mockRsaUtils.generateRSAKeyPair()).thenAnswer((_) => const RsaUtils()
        .generateRSAKeyPair()); // We get here a random result anyway and is it more likely to make errors by mocking it than by using the real method
    mockFirebaseUtils = MockFirebaseUtils();
    when(mockFirebaseUtils.getFBToken()).thenAnswer((_) => Future.value('fbToken'));
    when(mockRsaUtils.deserializeRSAPublicKeyPKCS1('publicKey')).thenAnswer((_) => RSAPublicKey(BigInt.one, BigInt.one));

    mockIOClient = MockPrivacyideaIOClient();
    when(mockIOClient.doPost(
      url: anyNamed('url'),
      body: anyNamed('body'),
      sslVerify: anyNamed('sslVerify'),
    )).thenAnswer((_) => Future.value(Response('{"detail": {"public_key": "publicKey"}}', 200)));
    mockIntroductionRepository = MockIntroductionRepository();
    when(mockIntroductionRepository.loadCompletedIntroductions())
        .thenAnswer((_) async => const IntroductionState(completedIntroductions: {...Introduction.values}));

    mockPushRequestRepository = MockPushRequestRepository();
    var state = PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: []));
    when(mockPushRequestRepository.saveState(any)).thenAnswer((invocation) async {
      final arguments = invocation.positionalArguments;
      state = arguments[0] as PushRequestState;
    });
    when(mockPushRequestRepository.loadState()).thenAnswer((_) async => state);
    when(mockPushRequestRepository.addRequest(any)).thenAnswer((invocation) async {
      final arguments = invocation.positionalArguments;
      state = state.withRequest(arguments[0] as PushRequest);
      return state;
    });
    when(mockPushRequestRepository.removeRequest(any)).thenAnswer((invocation) async {
      final arguments = invocation.positionalArguments;
      state = state.withoutRequest(arguments[0] as PushRequest);
      return state;
    });
    when(mockPushRequestRepository.clearState()).thenAnswer((_) async {
      state = PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: []));
    });
  });

  testWidgets('Views Test', (tester) async {
    await tester.pumpWidget(TestsAppWrapper(
      overrides: [
        settingsProvider.overrideWith(() => SettingsNotifier(repoOverride: mockSettingsRepository)),
        tokenProvider.overrideWith(() => TokenNotifier(
              repoOverride: mockTokenRepository,
              rsaUtilsOverride: mockRsaUtils,
              firebaseUtilsOverride: mockFirebaseUtils,
              ioClientOverride: mockIOClient,
            )),
        pushRequestProvider.overrideWith(
          () => PushRequestNotifier(
            rsaUtilsOverride: mockRsaUtils,
            ioClientOverride: mockIOClient,
            pushRepoOverride: mockPushRequestRepository,
            pushProviderOverride: PushProvider(
              rsaUtils: mockRsaUtils,
              ioClient: mockIOClient,
              firebaseUtils: mockFirebaseUtils,
            ),
          ),
        ),
        tokenFolderProvider.overrideWith(() => TokenFolderNotifier(repoOverride: mockTokenFolderRepository)),
        introductionNotifierProvider.overrideWith(() => IntroductionNotifier(repoOverride: mockIntroductionRepository)),
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
  expect(find.text(AppLocalizationsEn().themeMode), findsOneWidget);
  expect(find.text(AppLocalizationsEn().language), findsOneWidget);
  expect(find.text(AppLocalizationsEn().errorLogTitle), findsOneWidget);
  expect(find.byType(SettingsGroup), findsNWidgets(6));
  const qrCode =
      'otpauth://pipush/label?url=http%3A%2F%2Fwww.example.com&ttl=10&issuer=issuer&enrollment_container=enrollmentCredentials&v=1&serial=serial&serial=serial&sslverify=0';
  final notifier = globalRef!.read(tokenProvider.notifier);
  await scanQrCode([notifier], qrCode);

  await pumpUntilFindNWidgets(tester, find.text(AppLocalizationsEn().pushToken), 1, const Duration(minutes: 5));
  expect(find.text(AppLocalizationsEn().pushToken), findsOneWidget);
  expect(find.byType(SettingsGroup), findsNWidgets(6));
}
