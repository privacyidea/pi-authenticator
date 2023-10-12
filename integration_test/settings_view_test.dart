import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/main_netknights.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view_widgets/settings_groups.dart';

import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import '../test/tests_app_wrapper.dart';
import '../test/tests_app_wrapper.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final MockSettingsRepository mockSettingsRepository;
  late final MockTokenRepository mockTokenRepository;
  late final MockTokenFolderRepository mockTokenFolderRepository;
  late final MockQrParser mockQrParser;
  late final MockRsaUtils mockRsaUtils;
  late final MockFirebaseUtils mockFirebaseUtils;
  late final MockCustomIOClient mockIOClient;
  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => SettingsState(
        isFirstRun: false,
        localePreference: AppLocalizations.supportedLocales.firstWhere((language) => language.toLanguageTag().substring(0, 2) == 'en'),
        useSystemLocale: false));
    when(mockSettingsRepository.saveSettings(any)).thenAnswer((_) async => true);
    mockTokenRepository = MockTokenRepository();
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async => []);
    when(mockTokenRepository.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
    when(mockTokenRepository.deleteTokens(any)).thenAnswer((_) async => []);
    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadFolders()).thenAnswer((_) async => []);
    when(mockTokenFolderRepository.saveOrReplaceFolders(any)).thenAnswer((_) async => []);
    mockQrParser = MockQrParser();
    when(mockQrParser.parseQRCodeToMap(any)).thenReturn(<String, dynamic>{
      'URI_TYPE': 'PIPUSH',
      'URI_LABEL': 'label',
      'URI_ISSUER': 'issuer',
      'URI_SERIAL': 'serial',
      'URI_SSL_VERIFY': false,
      'URI_ENROLLMENT_CREDENTIAL': 'enrollmentCredentials',
      'URI_ROLLOUT_URL': Uri.parse('http://www.example.com'),
      'URI_TTL': 10,
    });
    mockRsaUtils = MockRsaUtils();
    when(mockRsaUtils.serializeRSAPublicKeyPKCS8(any)).thenAnswer((_) => 'publicKey');
    when(mockRsaUtils.generateRSAKeyPair()).thenAnswer((_) => const RsaUtils()
        .generateRSAKeyPair()); // We get here a random result anyway and is it more likely to make errors by mocking it than by using the real method
    mockFirebaseUtils = MockFirebaseUtils();
    when(mockFirebaseUtils.getFBToken()).thenAnswer((_) => Future.value('fbToken'));
    when(mockRsaUtils.deserializeRSAPublicKeyPKCS1('publicKey')).thenAnswer((_) => RSAPublicKey(BigInt.one, BigInt.one));
    mockIOClient = MockCustomIOClient();
    when(mockIOClient.doPost(
      url: anyNamed('url'),
      body: anyNamed('body'),
      sslVerify: anyNamed('sslVerify'),
    )).thenAnswer((_) => Future.value(Response('{"detail": {"public_key": "publicKey"}}', 200)));
  });
  testWidgets('Licenses View', (tester) async {
    runApp(TestsAppWrapper(
      overrides: [
        settingsProvider.overrideWith((ref) => SettingsNotifier(repository: mockSettingsRepository)),
        tokenProvider.overrideWith((ref) => TokenNotifier(
            repository: mockTokenRepository, qrParser: mockQrParser, firebaseUtils: mockFirebaseUtils, rsaUtils: mockRsaUtils, ioClient: mockIOClient)),
        tokenFolderProvider.overrideWith((ref) => TokenFolderNotifier(repository: mockTokenFolderRepository)),
      ],
      child: PrivacyIDEAAuthenticator(customization: ApplicationCustomization.defaultCustomization),
    ));

    await waitFor(const Duration(seconds: 3), tester);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Error logs'), findsOneWidget);
    expect(find.byType(SettingsGroup), findsNWidgets(3));
    globalRef!.read(tokenProvider.notifier).addTokenFromOtpAuth(otpAuth: 'otpauth://totp/issuer:label?secret=secret&issuer=issuer');
    await waitFor(const Duration(seconds: 10), tester);
    expect(find.text('Push Token'), findsOneWidget);
    expect(find.byType(SettingsGroup), findsNWidgets(4));
  });
}
