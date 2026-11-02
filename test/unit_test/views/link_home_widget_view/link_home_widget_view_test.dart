import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/introduction_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/app_dimensions.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/status_colors.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/link_home_widget_view/link_home_widget_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/folder_widgets/token_folder_expandable_widgets/token_folder_expandable_header_icon.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_image.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_tile.dart';

import '../../../tests_app_wrapper.mocks.dart';

class _FakeTokenNotifier extends TokenNotifier {
  final List<Token> tokens;
  _FakeTokenNotifier(this.tokens);

  @override
  Future<TokenState> build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) async => TokenState(tokens: tokens);
}

class _FakeFolderNotifier extends TokenFolderNotifier {
  final List<TokenFolder> folders;
  final List<String> events;
  _FakeFolderNotifier(this.folders, this.events);

  @override
  TokenFolderState build({required TokenFolderRepository repo}) =>
      TokenFolderState(folders: folders);

  @override
  Future<TokenFolderState> updateFolder(
    TokenFolder folder,
    TokenFolder Function(TokenFolder) updater,
  ) async {
    events.add('saveFolder:${folder.folderId}');
    return state;
  }

  @override
  Future<TokenFolderState> updateFolderById(
    int folderId,
    TokenFolder Function(TokenFolder) updater,
  ) async {
    events.add('saveFolder:$folderId');
    return state;
  }
}

class _FakeIntroductionNotifier extends IntroductionNotifier {
  final List<String> events;
  final Object? errorOnComplete;
  _FakeIntroductionNotifier(this.events, {this.errorOnComplete});

  @override
  Future<IntroductionState> build({
    required IntroductionRepository repo,
  }) async => const IntroductionState();

  @override
  Future<void> complete(Introduction introduction) async {
    events.add('complete:${introduction.name}');
    if (errorOnComplete != null) throw errorOnComplete!;
  }
}

class _RouteObserver extends NavigatorObserver {
  final List<String> events;
  _RouteObserver(this.events);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == LinkHomeWidgetView.routeName) {
      events.add('navigatorPop');
    }
  }
}

const _secret = 'JBSWY3DPEHPK3PXP';

HOTPToken _token({
  required String id,
  required String label,
  String issuer = '',
  String? tokenImage,
  bool isLocked = false,
  int? folderId,
  int? sortIndex,
  int digits = 6,
}) => HOTPToken(
  id: id,
  label: label,
  issuer: issuer,
  tokenImage: tokenImage,
  algorithm: Algorithms.SHA1,
  digits: digits,
  secret: _secret,
  isLocked: isLocked,
  folderId: folderId,
  sortIndex: sortIndex,
);

String _split(String otp) {
  final half = (otp.length / 2).ceil();
  return '${otp.substring(0, half)} ${otp.substring(half)}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l = AppLocalizationsEn();
  late List<String> events;
  late MockLocalAuthentication localAuth;

  setUp(() {
    events = [];
    localAuth = MockLocalAuthentication();
    when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
    localAuthInstance = localAuth;
    resetAuthMutex();
  });

  tearDown(() {
    localAuthInstance = LocalAuthentication();
    resetAuthMutex();
  });

  void authResult(bool result) {
    when(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    ).thenAnswer((_) async => result);
  }

  int authPrompts() => verify(
    localAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
      biometricOnly: anyNamed('biometricOnly'),
      authMessages: anyNamed('authMessages'),
    ),
  ).callCount;

  /// Pumps an app with a first route and pushes the [LinkHomeWidgetView] on top.
  ///
  /// [settle] false is needed for TOTP tiles, whose countdown never settles.
  Future<void> pumpView(
    WidgetTester tester, {
    List<Token> tokens = const [],
    List<TokenFolder> folders = const [],
    Object? errorOnComplete,
    String widgetId = '32',
    bool settle = true,
  }) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.pop') events.add('systemPop');
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final settingsRepo = MockSettingsRepository();
    when(
      settingsRepo.loadSettings(),
    ).thenAnswer((_) async => SettingsState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenProvider.overrideWith(() => _FakeTokenNotifier(tokens)),
          tokenFolderProvider.overrideWith(
            () => _FakeFolderNotifier(folders, events),
          ),
          introductionNotifierProvider.overrideWith(
            () => _FakeIntroductionNotifier(
              events,
              errorOnComplete: errorOnComplete,
            ),
          ),
          settingsProvider.overrideWith(
            () => SettingsNotifier(repoOverride: settingsRepo),
          ),
        ],
        child: MaterialApp(
          navigatorKey: globalNavigatorKey,
          navigatorObservers: [_RouteObserver(events)],
          theme: ThemeData(
            extensions: [
              const AppDimensions(),
              StatusColors(
                success: const Color(0xFF4CAF50),
                warning: const Color(0xFFFF9800),
                error: const Color(0xFFF44336),
                neutral: const Color(0xFF9E9E9E),
              ),
            ],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const Scaffold(body: Text('first route')),
        ),
      ),
    );
    final view = LinkHomeWidgetView(homeWidgetId: widgetId);
    globalNavigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => view, settings: view.routeSettings),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> tapAndSettle(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  test('routeName and routeSettings', () {
    expect(LinkHomeWidgetView.routeName, '/link_home_widget');
    expect(
      const LinkHomeWidgetView(homeWidgetId: '1').routeSettings.name,
      '/link_home_widget',
    );
  });

  group('token list', () {
    testWidgets('shows the localized title and no tiles without tokens', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text(l.linkHomeWidgetViewTitle), findsOneWidget);
      expect(find.byType(TokenWidgetTile), findsNothing);
    });

    testWidgets('shows every OTP token as a tile of the main list', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [
          _token(id: 'a', label: 'Alpha'),
          _token(id: 'b', label: 'Beta'),
        ],
      );

      expect(find.byType(TokenWidgetTile), findsNWidgets(2));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('shows the issuer and the token image of a token', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [
          _token(
            id: 'a',
            label: 'Alpha',
            issuer: 'issuer.example.org',
            tokenImage: 'https://img.example.org/logo.png',
          ),
        ],
      );

      expect(find.text('issuer.example.org'), findsOneWidget);
      expect(
        tester.widget<TokenImage>(find.byType(TokenImage)).tokenImage,
        'https://img.example.org/logo.png',
      );
    });

    testWidgets('shows no algorithm, counter or period lines of any OTP type', (
      tester,
    ) async {
      await pumpView(
        tester,
        settle: false,
        tokens: [
          _token(id: 'hotp', label: 'live-check-hotp'),
          TOTPToken(
            id: 'totp',
            label: 'live-check-totp',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: _secret,
            period: 30,
          ),
          DayPasswordToken(
            id: 'day',
            label: 'live-check-day',
            algorithm: Algorithms.SHA1,
            digits: 6,
            secret: _secret,
            period: const Duration(hours: 24),
          ),
          SteamToken(
            id: 'steam',
            label: 'live-check-steam',
            issuer: 'Steam',
            secret: _secret,
          ),
        ],
      );

      expect(find.byType(TokenWidgetTile), findsNWidgets(4));
      expect(find.textContaining('Algorithm:'), findsNothing);
      expect(find.textContaining('Counter:'), findsNothing);
      expect(find.textContaining('Period:'), findsNothing);
    });

    testWidgets('an unlocked token shows its real OTP split in the middle', (
      tester,
    ) async {
      final token = _token(id: 'a', label: 'Alpha');
      await pumpView(tester, tokens: [token]);

      expect(token.otpValue, hasLength(6));
      expect(find.text(_split(token.otpValue)), findsOneWidget);
    });
  });

  group('locked tokens are masked like in the main list', () {
    testWidgets('a locked token shows bullets instead of the OTP', (
      tester,
    ) async {
      final token = _token(id: 'a', label: 'Locked', isLocked: true);
      await pumpView(tester, tokens: [token]);

      expect(find.text('••• •••'), findsOneWidget);
      expect(find.text(_split(token.otpValue)), findsNothing);
    });

    testWidgets('only the locked token of several is masked', (tester) async {
      final open = _token(id: 'a', label: 'Open');
      await pumpView(
        tester,
        tokens: [
          open,
          _token(id: 'b', label: 'Locked', isLocked: true),
        ],
      );

      expect(find.text(_split(open.otpValue)), findsOneWidget);
      expect(find.text('••• •••'), findsOneWidget);
    });

    testWidgets('the mask length follows the number of digits (8 digits)', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Long', isLocked: true, digits: 8)],
      );

      expect(find.text('•••• ••••'), findsOneWidget);
    });

    testWidgets('tapping a locked token links it without an auth prompt', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Locked', isLocked: true)],
      );

      await tester.tap(find.text('Locked'));
      await tester.pump();

      expect(events, ['complete:homeWidgetSetUp', 'systemPop']);
      verifyNever(localAuth.isDeviceSupported());
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    });
  });

  group('folders', () {
    testWidgets('tokens of a collapsed folder show only after expanding it', (
      tester,
    ) async {
      final token = _token(id: 'a', label: 'InFolder', folderId: 1);
      await pumpView(
        tester,
        tokens: [token],
        folders: const [TokenFolder(label: 'Work', folderId: 1)],
      );

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('InFolder'), findsNothing);

      await tapAndSettle(tester, 'Work');

      expect(find.text('InFolder'), findsOneWidget);
      expect(find.text(_split(token.otpValue)), findsOneWidget);
    });

    testWidgets('a folder stored as expanded starts expanded', (tester) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [
          TokenFolder(label: 'Work', folderId: 1, isExpanded: true),
        ],
      );

      expect(find.text('InFolder'), findsOneWidget);
    });

    testWidgets('tapping an expanded folder collapses it', (tester) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [
          TokenFolder(label: 'Work', folderId: 1, isExpanded: true),
        ],
      );

      await tapAndSettle(tester, 'Work');

      expect(find.text('InFolder'), findsNothing);
    });

    testWidgets('the header of an expanded folder stays inside its card', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [
          TokenFolder(label: 'Work', folderId: 1, isExpanded: true),
        ],
      );

      final card = tester.getRect(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                ((widget.decoration as BoxDecoration).boxShadow?.isNotEmpty ??
                    false),
          ),
          matching: find.byType(DecoratedBox),
        ),
      );
      final arrow = tester.getRect(find.byIcon(Icons.arrow_forward_ios_sharp));
      final folderIcon = tester.getRect(
        find.byType(TokenFolderExpandableHeaderIcon),
      );

      expect(arrow.left, greaterThanOrEqualTo(card.left));
      expect(folderIcon.right, lessThanOrEqualTo(card.right));
    });

    testWidgets('folders and tokens keep the order of the main list', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [
          _token(id: 'c', label: 'Third', sortIndex: 2),
          _token(id: 'a', label: 'First', sortIndex: 0),
          _token(id: 'f', label: 'InFolder', folderId: 1, sortIndex: 0),
        ],
        folders: const [
          TokenFolder(label: 'Second', folderId: 1, sortIndex: 1),
        ],
      );

      final first = tester.getTopLeft(find.text('First')).dy;
      final second = tester.getTopLeft(find.text('Second')).dy;
      final third = tester.getTopLeft(find.text('Third')).dy;
      expect(first, lessThan(second));
      expect(second, lessThan(third));
    });

    testWidgets('a folder without OTP tokens is not shown', (tester) async {
      await pumpView(
        tester,
        tokens: [
          _token(id: 'a', label: 'Alpha'),
          PushToken(
            serial: 'live-check-push',
            id: 'push',
            label: 'PushInFolder',
            folderId: 2,
          ),
        ],
        folders: const [
          TokenFolder(label: 'Empty', folderId: 1),
          TokenFolder(label: 'PushOnly', folderId: 2),
        ],
      );

      expect(find.text('Empty'), findsNothing);
      expect(find.text('PushOnly'), findsNothing);
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('a token with an unknown folderId stays in the top list', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Orphan', folderId: 99)],
        folders: const [
          TokenFolder(label: 'Secret', folderId: 1, isLocked: true),
        ],
      );

      expect(find.text('Orphan'), findsOneWidget);
      expect(find.text('Secret'), findsNothing);
    });

    testWidgets('expanding and collapsing saves no folder state', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [TokenFolder(label: 'Work', folderId: 1)],
      );

      await tapAndSettle(tester, 'Work');
      await tapAndSettle(tester, 'Work');

      expect(events.where((e) => e.startsWith('saveFolder')), isEmpty);
    });

    testWidgets('tapping a token inside a folder links it', (tester) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [TokenFolder(label: 'Work', folderId: 1)],
      );

      await tapAndSettle(tester, 'Work');
      await tester.tap(find.text('InFolder'));
      await tester.pump();

      expect(events, ['complete:homeWidgetSetUp', 'systemPop']);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    });
  });

  group('locked folders ask for authentication like in the main list', () {
    const locked = TokenFolder(
      label: 'Secret',
      folderId: 1,
      isLocked: true,
      isExpanded: true,
    );

    testWidgets('a locked folder starts collapsed even if stored expanded', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [locked],
      );

      expect(find.text('Secret'), findsOneWidget);
      expect(find.text('InFolder'), findsNothing);
    });

    testWidgets('expands after a successful authentication', (tester) async {
      authResult(true);
      final token = _token(id: 'a', label: 'InFolder', folderId: 1);
      await pumpView(tester, tokens: [token], folders: const [locked]);

      await tapAndSettle(tester, 'Secret');

      expect(authPrompts(), 1);
      expect(find.text('InFolder'), findsOneWidget);
      expect(find.text(_split(token.otpValue)), findsOneWidget);
    });

    testWidgets('stays collapsed when the authentication fails', (
      tester,
    ) async {
      authResult(false);
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [locked],
      );

      await tapAndSettle(tester, 'Secret');

      expect(authPrompts(), 1);
      expect(find.text('InFolder'), findsNothing);
    });

    testWidgets('collapsing needs no authentication', (tester) async {
      authResult(true);
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [locked],
      );

      await tapAndSettle(tester, 'Secret');
      await tapAndSettle(tester, 'Secret');

      expect(authPrompts(), 1);
      expect(find.text('InFolder'), findsNothing);
    });

    testWidgets('an expanded locked folder collapses when the app is hidden', (
      tester,
    ) async {
      authResult(true);
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [locked],
      );
      await tapAndSettle(tester, 'Secret');
      expect(find.text('InFolder'), findsOneWidget);

      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();

      expect(find.text('InFolder'), findsNothing);
    });

    testWidgets('an unlocked folder stays expanded when the app is hidden', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [
          TokenFolder(label: 'Work', folderId: 1, isExpanded: true),
        ],
      );

      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();

      expect(find.text('InFolder'), findsOneWidget);
    });

    testWidgets('an unlocked folder expands without authentication', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'InFolder', folderId: 1)],
        folders: const [TokenFolder(label: 'Work', folderId: 1)],
      );

      await tapAndSettle(tester, 'Work');

      verifyNever(localAuth.isDeviceSupported());
      expect(find.text('InFolder'), findsOneWidget);
    });
  });

  group('tapping a token', () {
    testWidgets(
      'completes the introduction, closes the app, then pops the route (in this order)',
      (tester) async {
        await pumpView(
          tester,
          tokens: [_token(id: 'a', label: 'Alpha')],
        );

        await tester.tap(find.text('Alpha'));
        await tester.pump();
        // nothing popped before the 500 ms delay after SystemNavigator.pop
        expect(events, ['complete:homeWidgetSetUp', 'systemPop']);
        expect(find.byType(LinkHomeWidgetView), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        expect(events, [
          'complete:homeWidgetSetUp',
          'systemPop',
          'navigatorPop',
        ]);
        expect(find.byType(LinkHomeWidgetView), findsNothing);
        expect(find.text('first route'), findsOneWidget);
      },
    );

    testWidgets('tapping the OTP of a tile links the token too', (
      tester,
    ) async {
      final token = _token(id: 'a', label: 'Alpha');
      await pumpView(tester, tokens: [token]);

      await tester.tap(find.text(_split(token.otpValue)));
      await tester.pump();

      expect(events, ['complete:homeWidgetSetUp', 'systemPop']);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    });

    testWidgets('alreadyTapped: a second tap on the same token does nothing', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Alpha')],
      );

      await tester.tap(find.text('Alpha'));
      await tester.pump();
      await tester.tap(find.text('Alpha'));
      await tester.pump();
      await tester.tap(find.text('Alpha'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(
        events.where((e) => e.startsWith('complete')),
        hasLength(1),
        reason: 'introduction completed once',
      );
      expect(events.where((e) => e == 'systemPop'), hasLength(1));
      expect(events.where((e) => e == 'navigatorPop'), hasLength(1));
    });

    testWidgets(
      'alreadyTapped: tapping a different token afterwards is ignored too',
      (tester) async {
        await pumpView(
          tester,
          tokens: [
            _token(id: 'a', label: 'Alpha'),
            _token(id: 'b', label: 'Beta'),
          ],
        );

        await tester.tap(find.text('Alpha'));
        await tester.pump();
        await tester.tap(find.text('Beta'));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        expect(events.where((e) => e.startsWith('complete')), hasLength(1));
        expect(events.where((e) => e == 'navigatorPop'), hasLength(1));
      },
    );

    testWidgets(
      'does not pop (no crash) if the route is gone before the delay ends',
      (tester) async {
        await pumpView(
          tester,
          tokens: [_token(id: 'a', label: 'Alpha')],
        );

        await tester.tap(find.text('Alpha'));
        await tester.pump();
        // the host removes the whole app while the delay is running
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull);
        expect(events, isNot(contains('navigatorPop')));
      },
    );

    testWidgets(
      'an error while linking does not leave the tiles dead',
      (tester) async {
        // HomeWidgetUtils cannot be made to throw on a non-Android host, so the
        // failing step is the introduction completion in the same onTap chain.
        await pumpView(
          tester,
          tokens: [_token(id: 'a', label: 'Alpha')],
          errorOnComplete: StateError('link failed'),
        );

        await tester.tap(find.text('Alpha'));
        await tester.pump();
        tester.takeException();
        await tester.tap(find.text('Alpha'));
        await tester.pump();
        tester.takeException();

        expect(
          events.where((e) => e.startsWith('complete')),
          hasLength(2),
          reason: 'the user must be able to retry after a failure',
        );
      },
    );
  });

  testWidgets('the app bar has no actions', (tester) async {
    await pumpView(tester);

    expect(tester.widget<AppBar>(find.byType(AppBar)).actions, isNull);
  });
}
