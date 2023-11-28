import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/main_netknights.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view_widgets/labeled_dropdown_button.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/app_bar_item.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/drag_target_divider.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/folder_widgets/token_folder_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/day_password_token_widgets/day_password_token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_base.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/totp_token_widgets/totp_token_widget.dart';

import '../test/tests_app_wrapper.dart';
import '../test/tests_app_wrapper.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final MockSettingsRepository mockSettingsRepository;
  late final MockTokenRepository mockTokenRepository;
  late final MockTokenFolderRepository mockTokenFolderRepository;
  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => SettingsState(useSystemLocale: false, localePreference: const Locale('en')));
    when(mockSettingsRepository.saveSettings(any)).thenAnswer((_) async => true);
    mockTokenRepository = MockTokenRepository();
    when(mockTokenRepository.loadTokens()).thenAnswer((_) async => []);
    when(mockTokenRepository.saveOrReplaceTokens(any)).thenAnswer((_) async => []);
    when(mockTokenRepository.deleteTokens(any)).thenAnswer((_) async => []);
    mockTokenFolderRepository = MockTokenFolderRepository();
    when(mockTokenFolderRepository.loadFolders()).thenAnswer((_) async => []);
    when(mockTokenFolderRepository.saveOrReplaceFolders(any)).thenAnswer((_) async => []);
  });
  testWidgets(
    'Add Tokens Test',
    (tester) async {
      await tester.pumpWidget(TestsAppWrapper(
        overrides: [
          settingsProvider.overrideWith((ref) => SettingsNotifier(repository: mockSettingsRepository)),
          tokenProvider.overrideWith((ref) => TokenNotifier(repository: mockTokenRepository)),
          tokenFolderProvider.overrideWith((ref) => TokenFolderNotifier(repository: mockTokenFolderRepository)),
        ],
        child: PrivacyIDEAAuthenticator(customization: ApplicationCustomization.defaultCustomization),
      ));

      await _introToMainView(tester);
      expectMainViewIsEmptyAndCorrect();
      await _addHotpToken(tester);
      expect(find.byType(HOTPTokenWidget), findsOneWidget);
      await _addTotpToken(tester);
      expect(find.byType(TOTPTokenWidget), findsOneWidget);
      await _addDaypasswordToken(tester);
      expect(find.byType(DayPasswordTokenWidget), findsOneWidget);
      await _createFolder(tester);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(TokenFolderWidget), findsOneWidget);
      expect(find.text(AppLocalizationsEn().folderName), findsOneWidget);
      expect(find.byType(TokenWidgetBase).hitTestable(), findsNWidgets(3));
      await _moveFolderToTopPosition(tester);
      await _moveHotpTokenWidgetIntoFolder(tester);
      await _moveDayPasswordTokenWidgetIntoFolder(tester);
      expect(find.byType(TOTPTokenWidget).hitTestable(), findsOneWidget);
      expect(find.byType(TokenWidgetBase).hitTestable(), findsOneWidget);
      await _openFolder(tester);
      await pumpUntilFindNWidgets(tester, find.byType(TokenWidgetBase).hitTestable(), 3, const Duration(seconds: 5));
      expect(find.byType(TokenWidgetBase).hitTestable(), findsNWidgets(3));
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}

Future<void> _introToMainView(WidgetTester tester) async {
  final Finder finder = find.byType(FloatingActionButton);
  await pumpUntilFindNWidgets(tester, finder, 1, const Duration(seconds: 10));
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pump(const Duration(milliseconds: 1000));
}

Future<void> _addHotpToken(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.byIcon(Icons.add_moderator));
  await tester.pump(const Duration(milliseconds: 1000));
  expect(find.byType(AddTokenManuallyView), findsOneWidget);
  expect(find.byType(TextField), findsNWidgets(2));
  expect(find.byType(LabeledDropdownButton<Encodings>), findsOneWidget);
  expect(find.byType(LabeledDropdownButton<Algorithms>), findsOneWidget);
  expect(find.byType(LabeledDropdownButton<int>), findsOneWidget);
  expect(find.byType(LabeledDropdownButton<TokenTypes>), findsOneWidget);
  expect(find.text(AppLocalizationsEn().addToken), findsOneWidget);
  await tester.tap(find.text(AppLocalizationsEn().name));
  await tester.pump();
  await tester.enterText(find.byType(TextField).first, 'test');
  await tester.pump();
  await tester.tap(find.text(AppLocalizationsEn().secretKey));
  await tester.pump();
  await tester.enterText(find.byType(TextField).last, 'test');
  await tester.pump();
  await tester.tap(find.text(AppLocalizationsEn().addToken));
  await tester.pump(const Duration(milliseconds: 1000));
}

Future<void> _addTotpToken(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.byIcon(Icons.add_moderator));
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.tap(find.text(AppLocalizationsEn().name));
  await tester.pump();
  await tester.enterText(find.byType(TextField).first, 'test');
  await tester.pump();
  await tester.tap(find.text(AppLocalizationsEn().secretKey));
  await tester.pump();
  await tester.enterText(find.byType(TextField).last, 'test');
  await tester.pump();
  await tester.tap(find.byType(DropdownButton<TokenTypes>));
  await tester.pump();
  await tester.tap(find.text('TOTP'));
  await tester.pump();
  expect(find.byType(DropdownButton<int>), findsNWidgets(2));
  await tester.tap(find.text(AppLocalizationsEn().addToken));
  await tester.pump(const Duration(milliseconds: 1000));
}

Future<void> _addDaypasswordToken(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.byIcon(Icons.add_moderator));
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.enterText(find.byType(TextField).first, 'test');
  await tester.pump();
  await tester.tap(find.text(AppLocalizationsEn().secretKey));
  await tester.pump();
  await tester.enterText(find.byType(TextField).last, 'test');
  await tester.pump();
  await tester.tap(find.byType(DropdownButton<TokenTypes>));
  await tester.pump();
  await tester.tap(find.text('DAYPASSWORD'));
  await tester.pump();
  await tester.tap(find.text(AppLocalizationsEn().addToken));
  await tester.pump(const Duration(milliseconds: 1000));
}

Future<void> _createFolder(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.byIcon(Icons.create_new_folder));
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.enterText(find.byType(TextField).first, AppLocalizationsEn().folderName);
  await tester.pump();
  await tester.tap(find.text(AppLocalizationsEn().save));
  await tester.pump();
}

Future<void> _moveFolderToTopPosition(WidgetTester tester) async {
  await tester.pump();
  final tokenFolderPosition = tester.getCenter(find.byType(TokenFolderWidget));
  final gestrue = await tester.startGesture(tokenFolderPosition);
  await tester.pump(const Duration(milliseconds: 1000));
  final dragTargetDividerPosition = tester.getCenter(find.byType(DragTargetDivider).first);
  await gestrue.moveTo(dragTargetDividerPosition);
  await tester.pump();
  await gestrue.up();
  await tester.pump();
}

Future<void> _moveHotpTokenWidgetIntoFolder(WidgetTester tester) async {
  await tester.pump();
  final tokenWidgetPosition = tester.getCenter(find.byType(HOTPTokenWidget).first);
  final gestrue = await tester.startGesture(tokenWidgetPosition);
  await tester.pump(const Duration(milliseconds: 1000));
  final tokenFolderPosition = tester.getCenter(find.byType(TokenFolderWidget));
  await gestrue.moveTo(tokenFolderPosition);
  await tester.pump();
  await gestrue.up();
  await tester.pump();
}

Future<void> _moveDayPasswordTokenWidgetIntoFolder(WidgetTester tester) async {
  await tester.pump();
  final tokenWidgetPosition = tester.getCenter(find.byType(DayPasswordTokenWidget).last);
  final gestrue = await tester.startGesture(tokenWidgetPosition);
  await tester.pump(const Duration(milliseconds: 1000));
  final tokenFolderPosition = tester.getCenter(find.byType(TokenFolderWidget));
  await gestrue.moveTo(tokenFolderPosition);
  await tester.pump();
  await gestrue.up();
  await tester.pump();
}

Future<void> _openFolder(WidgetTester tester) async {
  await pumpUntilFindNWidgets(tester, find.byType(TokenFolderWidget), 1, const Duration(seconds: 5));
  await tester.tap(find.byType(TokenFolderWidget));
  await tester.pump();
}

void expectMainViewIsEmptyAndCorrect() {
  expect(find.byType(FloatingActionButton), findsOneWidget);
  expect(find.byType(AppBarItem), findsNWidgets(4));
  expect(find.byType(TokenWidgetBase), findsNothing);
  expect(find.byType(TokenFolderWidget), findsNothing);
  expect(find.text(ApplicationCustomization.defaultCustomization.appName), findsOneWidget);
  expect(find.byType(Image), findsOneWidget);
}
