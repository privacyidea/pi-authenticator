import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/mains/main_netknights.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_notifiers/completed_introduction_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_notifiers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/settings_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/token_folder_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/default_token_actions/default_delete_action.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/actions/edit_hotp_token_action.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget.dart';

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
    var tokens = <Token>[
      HOTPToken(label: 'test', issuer: 'test', id: 'id', algorithm: Algorithms.SHA256, digits: 6, secret: 'secret', counter: 0),
    ];
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async {
      return tokens;
    });
    when(mockTokenRepository.saveOrReplaceToken(any)).thenAnswer((invocation) async {
      final arguments = invocation.positionalArguments;
      tokens.removeWhere((element) => element.id == (arguments[0] as Token).id);
      tokens.add(arguments[0] as Token);
      return true;
    });
    when(mockTokenRepository.deleteToken(tokens.first)).thenAnswer((_) async {
      tokens.remove(tokens.first);
      return true;
    });
    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadFolders()).thenAnswer((_) async => []);
    when(mockTokenFolderRepository.saveReplaceList(any)).thenAnswer((_) async => true);
    mockIntroductionRepository = MockIntroductionRepository();
    when(mockIntroductionRepository.loadCompletedIntroductions())
        .thenAnswer((_) async => const IntroductionState(completedIntroductions: {...Introduction.values}));
  });
  testWidgets('Rename and Delete Token', (tester) async {
    await tester.pumpWidget(TestsAppWrapper(
      overrides: [
        settingsProvider.overrideWith((ref) => SettingsNotifier(repository: mockSettingsRepository)),
        tokenProvider.overrideWith((ref) => TokenNotifier(repository: mockTokenRepository, ref: ref)),
        tokenFolderProvider.overrideWith((ref) => TokenFolderNotifier(repository: mockTokenFolderRepository)),
        introductionProvider.overrideWith((ref) => IntroductionNotifier(repository: mockIntroductionRepository)),
      ],
      child: PrivacyIDEAAuthenticator(ApplicationCustomization.defaultCustomization),
    ));
    await _renameToken(tester, 'Renamed Token');
    await _renameToken(tester, 'Renamed Token Again');
    await _deleteToken(tester);
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> _renameToken(WidgetTester tester, String newName) async {
  // Rename Token
  await tester.pumpAndSettle();
  await pumpUntilFindNWidgets(tester, find.byType(HOTPTokenWidget), 1, const Duration(seconds: 10));
  expect(find.byType(HOTPTokenWidget), findsOneWidget);
  await tester.drag(find.byType(HOTPTokenWidget), const Offset(-300, 0));
  await tester.pumpAndSettle();
  await pumpUntilFindNWidgets(tester, find.byType(EditHOTPTokenAction), 1, const Duration(seconds: 2));
  await tester.tap(find.byType(EditHOTPTokenAction));
  await tester.pumpAndSettle();
  expect(find.text(AppLocalizationsEn().editToken), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(4));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, '');
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, newName);
  await pumpUntilFindNWidgets(tester, find.widgetWithText(TextFormField, newName), 1, const Duration(seconds: 2));
  await tester.tap(find.text(AppLocalizationsEn().save));
  await pumpUntilFindNWidgets(tester, find.text(newName), 1, const Duration(seconds: 2));
  expect(find.text(newName), findsOneWidget);
}

Future<void> _deleteToken(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await pumpUntilFindNWidgets(tester, find.byType(HOTPTokenWidget), 1, const Duration(seconds: 10));
  expect(find.byType(HOTPTokenWidget), findsOneWidget);
  await tester.drag(find.byType(HOTPTokenWidget), const Offset(-300, 0));
  await tester.pumpAndSettle();
  await pumpUntilFindNWidgets(tester, find.byType(EditHOTPTokenAction), 1, const Duration(seconds: 2));
  await tester.tap(find.byType(DefaultDeleteAction));
  await tester.pumpAndSettle();
  expect(find.text(AppLocalizationsEn().confirmDeletion), findsOneWidget);
  expect(find.text(AppLocalizationsEn().delete), findsOneWidget);
  await tester.tap(find.text(AppLocalizationsEn().delete));
  await pumpUntilFindNWidgets(tester, find.byType(HOTPTokenWidget), 0, const Duration(seconds: 2));
  expect(find.byType(HOTPTokenWidget), findsNothing);
}
