/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/introduction_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/model/enums/app_feature.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/allow_screenshot_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/views/splash_screen/splash_screen.dart';

import '../../../tests_app_wrapper.dart';

class _FakeTokenNotifier extends TokenNotifier {
  final Future<TokenState> Function() _builder;
  _FakeTokenNotifier(this._builder);

  @override
  Future<TokenState> build({
    required firebaseUtils,
    required ioClient,
    required repo,
    required rsaUtils,
  }) => _builder();
}

class _FakeAllowScreenshotNotifier extends AllowScreenshotNotifier {
  final Future<bool> Function() _builder;
  _FakeAllowScreenshotNotifier(this._builder);

  @override
  Future<bool> build({required screenshotUtils}) => _builder();
}

class _FakeFolderRepository implements TokenFolderRepository {
  final Future<TokenFolderState> Function() _load;
  _FakeFolderRepository([Future<TokenFolderState> Function()? load])
    : _load = load ?? (() async => const TokenFolderState(folders: []));

  @override
  Future<TokenFolderState> loadState() => _load();

  @override
  Future<bool> saveState(TokenFolderState state) async => true;
}

class _FakeContainerNotifier extends TokenContainerNotifier {
  final Future<Map<int, TokenContainerFinalized>> Function(
    TokenState tokenState,
    bool isManually,
  )
  _onSync;
  final List<({TokenState tokenState, bool isManually})> syncCalls = [];

  _FakeContainerNotifier(this._onSync);

  @override
  Future<TokenContainerState> build({
    required repo,
    required containerApi,
    required eccUtils,
  }) async => const TokenContainerState(containerList: []);

  @override
  Future<Map<int, TokenContainerFinalized>> syncContainers({
    required TokenState tokenState,
    required bool isManually,
    List<TokenContainerFinalized>? containersToSync,
    bool? isInitSync,
  }) {
    syncCalls.add((tokenState: tokenState, isManually: isManually));
    return _onSync(tokenState, isManually);
  }
}

class _RecordingIntroductionRepository implements IntroductionRepository {
  final List<IntroductionState> saved = [];

  @override
  Future<IntroductionState> loadCompletedIntroductions() async =>
      const IntroductionState();

  @override
  Future<bool> saveCompletedIntroductions(
    IntroductionState introductions,
  ) async {
    saved.add(introductions);
    return true;
  }
}

class _RecordingObserver extends NavigatorObserver {
  final List<String> events = [];

  String _name(Route<dynamic>? route) => route?.settings.name ?? '<null>';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('push ${_name(route)}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    events.add('replace ${_name(oldRoute)} -> ${_name(newRoute)}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('remove ${_name(route)}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('pop ${_name(route)}');
  }

  int count(String event) => events.where((e) => e == event).length;

  int get mainViewNavigations =>
      events.where((e) => e.endsWith('-> ${MainView.routeName}')).length +
      count('push ${MainView.routeName}');
}

Duration? _noRetry(int retryCount, Object error) => null;

const _mainKey = Key('main-view-stub');
const _deepKey = Key('deep-link-stub');

void main() {
  setUpAll(() async {
    await setupMocks();
  });

  late _RecordingObserver observer;
  late _FakeContainerNotifier containerNotifier;
  late _RecordingIntroductionRepository introductionRepo;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    observer = _RecordingObserver();
    navigatorKey = GlobalKey<NavigatorState>();
    introductionRepo = _RecordingIntroductionRepository();
    containerNotifier = _FakeContainerNotifier((_, _) async => {});
  });

  Future<void> pumpSplash(
    WidgetTester tester, {
    Future<TokenState> Function()? tokens,
    Future<bool> Function()? allowScreenshot,
    TokenFolderRepository? folderRepo,
    ApplicationCustomization? customization,
    bool defaultRetry = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: defaultRetry ? null : _noRetry,
        overrides: [
          tokenProvider.overrideWith(
            () => _FakeTokenNotifier(
              tokens ?? () async => const TokenState(tokens: []),
            ),
          ),
          allowScreenshotProvider.overrideWith(
            () => _FakeAllowScreenshotNotifier(
              allowScreenshot ?? () async => false,
            ),
          ),
          tokenFolderProvider.overrideWith(
            () => TokenFolderNotifier(
              repoOverride: folderRepo ?? _FakeFolderRepository(),
            ),
          ),
          tokenContainerProvider.overrideWith(() => containerNotifier),
          introductionNotifierProvider.overrideWith(
            () => IntroductionNotifier(repoOverride: introductionRepo),
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            ref.listen(tokenProvider, (_, _) {});
            return child!;
          },
          child: MaterialApp(
            navigatorKey: navigatorKey,
            navigatorObservers: [observer],
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (_) => SplashScreen(
                customization:
                    customization ??
                    ApplicationCustomization.defaultCustomization,
              ),
              MainView.routeName: (_) =>
                  const Scaffold(body: Text('MAIN', key: _mainKey)),
              '/deep': (_) => const Scaffold(body: Text('DEEP', key: _deepKey)),
              '/other': (_) => const Scaffold(body: Text('OTHER')),
            },
          ),
        ),
      ),
    );
  }

  Future<void> finishSplash(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Replaces the splash route by a route without transition, so the
  /// splash screen is disposed right away (a page transition would keep it alive).
  Future<void> removeSplashRoute(WidgetTester tester) async {
    unawaited(
      navigatorKey.currentState!.pushReplacement(
        PageRouteBuilder<void>(
          settings: const RouteSettings(name: '/other'),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => const Scaffold(body: Text('OTHER')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  }

  /// Removes the widget tree and lets the polling timer of a splash screen
  /// that is still waiting for the top route fire once.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 150));
  }

  Future<void> pushDeepRoute(WidgetTester tester) async {
    unawaited(navigatorKey.currentState!.pushNamed('/deep'));
    await tester.pumpAndSettle();
  }

  group('SplashScreen navigation', () {
    testWidgets('shows the splash screen first and no main view yet', (
      tester,
    ) async {
      await pumpSplash(tester);

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byKey(_mainKey), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(_mainKey), findsNothing);

      await finishSplash(tester);
    });

    testWidgets('navigates to the main view exactly once when loading works', (
      tester,
    ) async {
      await pumpSplash(tester);
      await finishSplash(tester);

      expect(find.byKey(_mainKey), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(observer.mainViewNavigations, 1);
      expect(
        observer.count(
          'replace ${SplashScreen.routeName} -> ${MainView.routeName}',
        ),
        1,
      );
      expect(navigatorKey.currentState!.canPop(), isFalse);

      await tester.pump(const Duration(seconds: 5));
      expect(observer.mainViewNavigations, 1);
    });

    testWidgets('syncs the containers in the background once, not manually', (
      tester,
    ) async {
      const tokenState = TokenState(tokens: []);
      await pumpSplash(tester, tokens: () async => tokenState);
      await finishSplash(tester);

      expect(containerNotifier.syncCalls, hasLength(1));
      expect(containerNotifier.syncCalls.single.isManually, isFalse);
      expect(containerNotifier.syncCalls.single.tokenState, tokenState);
    });

    testWidgets('does not wait for a container sync that never finishes', (
      tester,
    ) async {
      final neverCompletes = Completer<Map<int, TokenContainerFinalized>>();
      containerNotifier = _FakeContainerNotifier(
        (_, _) => neverCompletes.future,
      );
      await pumpSplash(tester);
      await finishSplash(tester);

      expect(containerNotifier.syncCalls, hasLength(1));
      expect(find.byKey(_mainKey), findsOneWidget);
      expect(observer.mainViewNavigations, 1);
    });

    testWidgets('navigates once when the token provider throws', (
      tester,
    ) async {
      await pumpSplash(tester, tokens: () async => throw Exception('tokens'));
      await finishSplash(tester);

      expect(find.byKey(_mainKey), findsOneWidget);
      expect(observer.mainViewNavigations, 1);
      expect(containerNotifier.syncCalls, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'BUG: splash waits about 38 s (10 provider retries) before navigating when the token provider throws an Exception',
      (tester) async {
        await pumpSplash(
          tester,
          tokens: () async => throw Exception('tokens'),
          defaultRetry: true,
        );
        var waited = Duration.zero;
        while (find.byKey(_mainKey).evaluate().isEmpty &&
            waited < const Duration(seconds: 60)) {
          await tester.pump(const Duration(milliseconds: 100));
          waited += const Duration(milliseconds: 100);
        }
        await tester.pumpAndSettle();

        expect(find.byKey(_mainKey), findsOneWidget);
        expect(waited, lessThanOrEqualTo(const Duration(seconds: 5)));
        expect(observer.mainViewNavigations, 1);
        await disposeTree(tester);
      },
      skip: true,
    );
    testWidgets('navigates once when the allow screenshot provider throws', (
      tester,
    ) async {
      await pumpSplash(
        tester,
        allowScreenshot: () async => throw Exception('screenshot'),
      );
      await finishSplash(tester);

      expect(find.byKey(_mainKey), findsOneWidget);
      expect(observer.mainViewNavigations, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigates once when loading the folders throws', (
      tester,
    ) async {
      await pumpSplash(
        tester,
        folderRepo: _FakeFolderRepository(
          () async => throw Exception('folders'),
        ),
      );
      await finishSplash(tester);

      expect(find.byKey(_mainKey), findsOneWidget);
      expect(observer.mainViewNavigations, 1);
    });

    testWidgets('navigates once when the container sync throws', (
      tester,
    ) async {
      containerNotifier = _FakeContainerNotifier(
        (_, _) async => throw Exception('sync'),
      );
      await pumpSplash(tester);
      await finishSplash(tester);

      expect(containerNotifier.syncCalls, hasLength(1));
      expect(find.byKey(_mainKey), findsOneWidget);
      expect(observer.mainViewNavigations, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('waits for slow providers before navigating', (tester) async {
      final tokensCompleter = Completer<TokenState>();
      await pumpSplash(tester, tokens: () => tokensCompleter.future);

      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(observer.mainViewNavigations, 0);

      tokensCompleter.complete(const TokenState(tokens: []));
      await finishSplash(tester);

      expect(find.byKey(_mainKey), findsOneWidget);
      expect(observer.mainViewNavigations, 1);
    });

    testWidgets('completes all introductions when the feature is disabled', (
      tester,
    ) async {
      await pumpSplash(
        tester,
        customization: ApplicationCustomization(
          disabledFeatures: const {AppFeature.introductions},
        ),
      );
      await finishSplash(tester);

      expect(introductionRepo.saved, isNotEmpty);
      expect(
        introductionRepo.saved.last.completedIntroductions,
        containsAll(Introduction.values),
      );
      expect(observer.mainViewNavigations, 1);
    });

    testWidgets('keeps the introductions untouched when nothing is disabled', (
      tester,
    ) async {
      await pumpSplash(tester);
      await finishSplash(tester);

      expect(introductionRepo.saved, isEmpty);
    });
  });

  group('SplashScreen disposed while loading', () {
    testWidgets(
      'does not navigate nor sync when removed before the icon shows',
      (tester) async {
        await pumpSplash(tester);
        await tester.pump(const Duration(milliseconds: 100));

        await removeSplashRoute(tester);
        expect(find.byType(SplashScreen), findsNothing);
        expect(find.text('OTHER'), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        expect(find.byKey(_mainKey), findsNothing);
        expect(find.text('OTHER'), findsOneWidget);
        expect(observer.mainViewNavigations, 0);
        expect(containerNotifier.syncCalls, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('does not navigate nor sync when removed while loading', (
      tester,
    ) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 300));

      await removeSplashRoute(tester);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.byKey(_mainKey), findsNothing);
      expect(observer.mainViewNavigations, 0);
      expect(containerNotifier.syncCalls, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'does not navigate when removed while waiting for the top route',
      (tester) async {
        await pumpSplash(tester);
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 10));

        await removeSplashRoute(tester);
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.byKey(_mainKey), findsNothing);
        expect(find.text('OTHER'), findsOneWidget);
        expect(observer.mainViewNavigations, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('does not throw when the whole tree is removed', (
      tester,
    ) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));

      expect(tester.takeException(), isNull);
      expect(containerNotifier.syncCalls, isEmpty);
      expect(observer.mainViewNavigations, 0);
    });
  });

  group('SplashScreen with a route pushed on top (deep link)', () {
    testWidgets('does not show the main view while the pushed route is open', (
      tester,
    ) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 100));

      await pushDeepRoute(tester);
      await tester.pump(const Duration(seconds: 3));

      expect(find.byKey(_deepKey), findsOneWidget);
      expect(find.byKey(_mainKey), findsNothing);
      expect(observer.mainViewNavigations, 0);
      expect(observer.count('remove ${SplashScreen.routeName}'), 0);

      await disposeTree(tester);
    });

    testWidgets('shows the main view once the pushed route is closed', (
      tester,
    ) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 100));

      await pushDeepRoute(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(_mainKey), findsNothing);

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.byKey(_mainKey), findsOneWidget);
      expect(find.byKey(_deepKey), findsNothing);
      expect(find.byType(SplashScreen), findsNothing);
      expect(observer.mainViewNavigations, 1);
      expect(
        navigatorKey.currentState!.canPop(),
        isFalse,
        reason: 'the main view has to be the only route left',
      );
    });

    testWidgets(
      'replaces the splash by the main view and never removes it after the pushed route closes',
      (tester) async {
        await pumpSplash(tester);
        await tester.pump(const Duration(milliseconds: 100));

        await pushDeepRoute(tester);
        await tester.pump(const Duration(seconds: 3));
        navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('MAIN'), findsOneWidget);
        expect(observer.count('remove ${SplashScreen.routeName}'), 0);
        expect(
          observer.count(
            'replace ${SplashScreen.routeName} -> ${MainView.routeName}',
          ),
          1,
        );
      },
    );

    testWidgets(
      'navigates when the pushed route is closed before loading ends',
      (tester) async {
        await pumpSplash(tester);
        await tester.pump(const Duration(milliseconds: 50));

        await pushDeepRoute(tester);
        navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        await finishSplash(tester);

        expect(find.byKey(_mainKey), findsOneWidget);
        expect(observer.mainViewNavigations, 1);
      },
    );

    testWidgets(
      'does not navigate when the splash route is removed below the pushed route',
      (tester) async {
        await pumpSplash(tester);
        await tester.pump(const Duration(milliseconds: 100));

        final splashRoute = ModalRoute.of(
          tester.element(find.byType(SplashScreen)),
        )!;
        await pushDeepRoute(tester);
        navigatorKey.currentState!.removeRoute(splashRoute);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 5));

        expect(find.byKey(_deepKey), findsOneWidget);
        expect(find.byKey(_mainKey), findsNothing);
        expect(observer.mainViewNavigations, 0);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
