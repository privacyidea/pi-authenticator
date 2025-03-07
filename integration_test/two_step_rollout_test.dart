import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget_tile.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/totp_token_widgets/totp_token_widget_tile.dart';
import 'package:privacyidea_authenticator/widgets/widget_keys.dart';

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
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async => []);
    when(mockTokenRepository.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
    when(mockTokenRepository.deleteTokens(any)).thenAnswer((_) async => []);
    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadState()).thenAnswer((_) async => const TokenFolderState(folders: []));
    when(mockTokenFolderRepository.saveState(any)).thenAnswer((_) async => true);
    mockIntroductionRepository = MockIntroductionRepository();
    when(mockIntroductionRepository.loadCompletedIntroductions())
        .thenAnswer((_) async => const IntroductionState(completedIntroductions: {...Introduction.values}));
  });
  testWidgets(
    '2step rollout test',
    (tester) async {
      await tester.pumpWidget(TestsAppWrapper(
        overrides: [
          settingsProvider.overrideWith(() => SettingsNotifier(repoOverride: mockSettingsRepository)),
          tokenProvider.overrideWith(() => TokenNotifier(repoOverride: mockTokenRepository)),
          tokenFolderProvider.overrideWith(() => TokenFolderNotifier(repoOverride: mockTokenFolderRepository)),
          introductionNotifierProvider.overrideWith(() => IntroductionNotifier(repoOverride: mockIntroductionRepository)),
        ],
        child: PrivacyIDEAAuthenticator(ApplicationCustomization.defaultCustomization),
      ));
      await _addTwoStepHotpTokenTest(tester);
      await _addTwoStepTotpTokenTest(tester);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<void> _addTwoStepHotpTokenTest(WidgetTester tester) async {
  await pumpUntilFindNWidgets(tester, find.byType(MainView), 1, const Duration(seconds: 10));
  const qrCode =
      'otpauth://hotp/OATH0001DBD0?secret=AALIBQJMOGEE7SAVEZ5D3K2ADO7MVFQD&counter=1&digits=6&issuer=privacyIDEA&2step_salt=8&2step_output=20&2step_difficulty=10000';
  final notifier = globalRef!.read(tokenProvider.notifier);
  await scanQrCode(resultHandlerList: [notifier], qrCode: qrCode);
  Logger.info('Finding phone part dialog');
  await pumpUntilFindNWidgets(tester, find.text(AppLocalizationsEn().phonePart), 1, const Duration(seconds: 20));
  expect(find.text(AppLocalizationsEn().phonePart), findsOneWidget);
  final finder = find.byKey(twoStepDialogContent);
  expect(finder, findsOneWidget);
  final text = finder.evaluate().single.widget as Text;
  final phonePart = text.data;
  Logger.info('Checking phone part exists and has correct length');
  expect(phonePart, isNotNull);
  expect(phonePart, isNotEmpty);
  // step_output=20
  expect(phonePart!.replaceAll(' ', '').length, 20);
  expect(find.text(AppLocalizationsEn().dismiss), findsOneWidget);
  Logger.info('Dismissing dialog');
  await tester.tap(find.text(AppLocalizationsEn().dismiss));
  await pumpUntilFindNWidgets(tester, find.byType(HOTPTokenWidgetTile), 1, const Duration(seconds: 10));
}

Future<void> _addTwoStepTotpTokenTest(WidgetTester tester) async {
  await pumpUntilFindNWidgets(tester, find.byType(MainView), 1, const Duration(seconds: 10));
  const qrCode =
      'otpauth://totp/TOTP00009D5F?secret=NZ4OPONKAAGDFN2QHV26ZWYVTLFER4C6&period=30&digits=6&issuer=privacyIDEA&2step_salt=8&2step_output=20&2step_difficulty=10000';
  final notifier = globalRef!.read(tokenProvider.notifier);
  await scanQrCode(resultHandlerList: [notifier], qrCode: qrCode);
  Logger.info('Finding phone part dialog');
  await pumpUntilFindNWidgets(tester, find.text(AppLocalizationsEn().phonePart), 1, const Duration(seconds: 20));
  expect(find.text(AppLocalizationsEn().phonePart), findsOneWidget);
  final finder = find.byKey(twoStepDialogContent);
  expect(finder, findsOneWidget);
  final text = finder.evaluate().single.widget as Text;
  final phonePart = text.data;
  Logger.info('Checking phone part exists and has correct length');
  expect(phonePart, isNotNull);
  expect(phonePart, isNotEmpty);
  // step_output=20
  expect(phonePart!.replaceAll(' ', '').length, 20);
  expect(find.text(AppLocalizationsEn().dismiss), findsOneWidget);
  Logger.info('Dismissing dialog');
  await tester.tap(find.text(AppLocalizationsEn().dismiss));
  await pumpUntilFindNWidgets(tester, find.byType(TOTPTokenWidgetTile), 1, const Duration(seconds: 10));
  //cannot "await tester.pumpAndSettle();" because of the infinite TOTP animation.
}
