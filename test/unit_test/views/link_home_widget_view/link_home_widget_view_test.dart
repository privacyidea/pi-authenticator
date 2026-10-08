import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/introduction_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/app_dimensions.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/extended_text_theme.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/status_colors.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/battery_optimization_provider.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/link_home_widget_view/link_home_widget_view.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/battery_optimization_dialog.dart';

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
  _FakeFolderNotifier(this.folders);

  @override
  TokenFolderState build({required TokenFolderRepository repo}) =>
      TokenFolderState(folders: folders);
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

HOTPToken _token({
  required String id,
  required String label,
  bool isLocked = false,
  int? folderId,
  int digits = 6,
}) => HOTPToken(
  id: id,
  label: label,
  algorithm: Algorithms.SHA1,
  digits: digits,
  secret: 'JBSWY3DPEHPK3PXP',
  isLocked: isLocked,
  folderId: folderId,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l = AppLocalizationsEn();
  late List<String> events;

  setUp(() {
    events = [];
  });

  /// Pumps an app with a first route and pushes the [LinkHomeWidgetView] on top.
  Future<void> pumpView(
    WidgetTester tester, {
    List<Token> tokens = const [],
    List<TokenFolder> folders = const [],
    bool batteryOptimizationsDisabled = true,
    String? veilingCharacter,
    Object? errorOnComplete,
    String widgetId = '32',
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenProvider.overrideWith(() => _FakeTokenNotifier(tokens)),
          tokenFolderProvider.overrideWith(() => _FakeFolderNotifier(folders)),
          introductionNotifierProvider.overrideWith(
            () => _FakeIntroductionNotifier(
              events,
              errorOnComplete: errorOnComplete,
            ),
          ),
          batteryOptimizationsIsDisabledProvider.overrideWith(
            (ref) async => batteryOptimizationsDisabled,
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
              if (veilingCharacter != null)
                ExtendedTextTheme(veilingCharacter: veilingCharacter),
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
    await tester.pumpAndSettle();
  }

  /// The subtitle text of the list tile whose title is [label].
  String subtitleOf(WidgetTester tester, String label) {
    final tile = tester.widget<ListTile>(find.widgetWithText(ListTile, label));
    return (tile.subtitle! as Text).data!;
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
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('shows one tile per OTP token with label as title', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [
          _token(id: 'a', label: 'Alpha'),
          _token(id: 'b', label: 'Beta'),
        ],
      );

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('unlocked token shows its real OTP split in the middle', (
      tester,
    ) async {
      final token = _token(id: 'a', label: 'Alpha');
      await pumpView(tester, tokens: [token]);

      final otp = token.otpValue;
      expect(otp, hasLength(6));
      expect(
        subtitleOf(tester, 'Alpha'),
        '${otp.substring(0, 3)} ${otp.substring(3)}',
      );
    });
  });

  group('locked tokens and folders are masked', () {
    testWidgets('locked token shows veiling characters instead of the OTP', (
      tester,
    ) async {
      final token = _token(id: 'a', label: 'Locked', isLocked: true);
      await pumpView(tester, tokens: [token]);

      expect(subtitleOf(tester, 'Locked'), '●●● ●●●');
      expect(find.textContaining(token.otpValue.substring(0, 3)), findsNothing);
    });

    testWidgets(
      'token in a locked folder is masked even if it is not locked itself',
      (tester) async {
        final token = _token(id: 'a', label: 'InFolder', folderId: 1);
        await pumpView(
          tester,
          tokens: [token],
          folders: const [
            TokenFolder(label: 'Secret', folderId: 1, isLocked: true),
          ],
        );

        expect(token.isLocked, isFalse);
        expect(subtitleOf(tester, 'InFolder'), '●●● ●●●');
      },
    );

    testWidgets('token in an unlocked folder shows the OTP', (tester) async {
      final token = _token(id: 'a', label: 'InFolder', folderId: 1);
      await pumpView(
        tester,
        tokens: [token],
        folders: const [TokenFolder(label: 'Open', folderId: 1)],
      );

      expect(subtitleOf(tester, 'InFolder'), isNot(contains('●')));
    });

    testWidgets('token with unknown folderId is not masked', (tester) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Orphan', folderId: 99)],
        folders: const [
          TokenFolder(label: 'Secret', folderId: 1, isLocked: true),
        ],
      );

      expect(subtitleOf(tester, 'Orphan'), isNot(contains('●')));
    });

    testWidgets('only the locked token of several is masked', (tester) async {
      await pumpView(
        tester,
        tokens: [
          _token(id: 'a', label: 'Open'),
          _token(id: 'b', label: 'Locked', isLocked: true),
        ],
      );

      expect(subtitleOf(tester, 'Open'), isNot(contains('●')));
      expect(subtitleOf(tester, 'Locked'), '●●● ●●●');
    });

    testWidgets('mask length follows the number of digits (8 digits)', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Long', isLocked: true, digits: 8)],
      );

      expect(subtitleOf(tester, 'Long'), '●●●● ●●●●');
    });

    testWidgets('uses the veilingCharacter of the ExtendedTextTheme', (
      tester,
    ) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Locked', isLocked: true)],
        veilingCharacter: '*',
      );

      expect(subtitleOf(tester, 'Locked'), '*** ***');
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
      'BUG (skipped): an error while linking must not leave the tiles dead (alreadyTapped stays true)',
      (tester) async {
        // The link/complete chain has no try/finally, so after an exception the
        // flag is never reset and every further tap is ignored. HomeWidgetUtils
        // cannot be made to throw on a non-Android host, so the failing step is
        // the introduction completion which lives in the very same onTap chain.
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
      // BUG: lib/views/link_home_widget_view/link_home_widget_view.dart:99-114 alreadyTapped is set to true but never reset when link/complete throws, tiles stay dead
      skip: true,
    );
  });

  group('help icon', () {
    testWidgets('has the battery optimization title as tooltip', (
      tester,
    ) async {
      await pumpView(tester);

      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.help_outline),
      );
      expect(button.tooltip, l.batteryOptimizationTitle);
    });

    testWidgets(
      'battery optimization already disabled: shows the "already disabled" dialog',
      (tester) async {
        await pumpView(tester);

        await tester.tap(find.byIcon(Icons.help_outline));
        await tester.pumpAndSettle();

        expect(
          find.byType(BatteryOptimizationAlreadyDisabledDialog),
          findsOneWidget,
        );
        expect(find.byType(BatteryOptimizationDialog), findsNothing);
        expect(
          find.text(l.batteryOptimizationAlreadyDisabledBody),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'battery optimization still active: shows the explaining dialog',
      (tester) async {
        await pumpView(tester, batteryOptimizationsDisabled: false);

        await tester.tap(find.byIcon(Icons.help_outline));
        await tester.pumpAndSettle();

        expect(find.byType(BatteryOptimizationDialog), findsOneWidget);
        expect(
          find.byType(BatteryOptimizationAlreadyDisabledDialog),
          findsNothing,
        );
        expect(find.text(l.batteryOptimizationDialogBody), findsOneWidget);
      },
    );

    testWidgets('help icon does not trigger the link flow', (tester) async {
      await pumpView(
        tester,
        tokens: [_token(id: 'a', label: 'Alpha')],
      );

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      expect(events, isEmpty);
    });
  });
}
