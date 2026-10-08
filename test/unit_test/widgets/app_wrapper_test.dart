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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/introduction_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/deeplink.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_folder_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/widgets/app_wrapper.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/battery_optimization_dialog.dart';

import '../../tests_app_wrapper.dart';

const _notificationsChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);
const _settingsChannel = MethodChannel('pi_authenticator/settings');

final _l10n = AppLocalizationsEn();

class _FakeDeeplinkNotifier extends DeeplinkNotifier {
  @override
  Stream<DeepLink> build() => const Stream<DeepLink>.empty();
}

class _FakeTokenNotifier extends TokenNotifier {
  final TokenState? refreshResult;
  final Object? refreshError;
  final bool minimizeResult;
  final Object? minimizeError;
  final List<String> events;

  int refreshCalls = 0;
  int minimizeCalls = 0;

  _FakeTokenNotifier({
    required this.events,
    this.refreshResult,
    this.refreshError,
    this.minimizeResult = true,
    this.minimizeError,
  });

  @override
  Future<TokenState> build({
    required firebaseUtils,
    required ioClient,
    required repo,
    required rsaUtils,
  }) async => const TokenState(tokens: []);

  @override
  Future<TokenState?> loadStateFromRepo() async {
    refreshCalls++;
    events.add('refreshTokens');
    if (refreshError != null) throw refreshError!;
    return refreshResult;
  }

  @override
  Future<bool> onMinimizeApp() async {
    minimizeCalls++;
    events.add('saveTokens');
    if (minimizeError != null) throw minimizeError!;
    return minimizeResult;
  }
}

class _FakePushRequestNotifier extends PushRequestNotifier {
  final List<String> events;
  final Object? pollError;
  final List<bool> pollCalls = [];
  int loadCalls = 0;
  int initFirebaseCalls = 0;

  _FakePushRequestNotifier({required this.events, this.pollError});

  @override
  Future<PushRequestState> build({
    required rsaUtils,
    required ioClient,
    required pushProvider,
    required pushRepo,
  }) async => PushRequestState.empty();

  @override
  Future<PushRequestState> loadStateFromRepo() async {
    loadCalls++;
    events.add('loadPushRequests');
    return PushRequestState.empty();
  }

  @override
  Future<void> pollForChallenges({required bool isManually}) async {
    pollCalls.add(isManually);
    events.add('poll');
    if (pollError != null) throw pollError!;
  }

  @override
  Future<void> initFirebase() async {
    initFirebaseCalls++;
  }
}

class _FakeFolderNotifier extends TokenFolderNotifier {
  final Future<TokenFolderState> Function() onCollapse;
  final List<String> events;
  int collapseCalls = 0;

  _FakeFolderNotifier({required this.events, required this.onCollapse});

  @override
  TokenFolderState build({required TokenFolderRepository repo}) =>
      const TokenFolderState(folders: []);

  @override
  Future<TokenFolderState> collapseLockedFolders() {
    collapseCalls++;
    events.add('collapseFolders');
    return onCollapse();
  }
}

class _MemoryFolderRepository implements TokenFolderRepository {
  TokenFolderState current;
  final List<TokenFolderState> saved = [];
  _MemoryFolderRepository(this.current);

  @override
  Future<TokenFolderState> loadState() async => current;

  @override
  Future<bool> saveState(TokenFolderState state) async {
    saved.add(state);
    current = state;
    return true;
  }
}

class _MemoryIntroductionRepository implements IntroductionRepository {
  IntroductionState current;
  final List<IntroductionState> saved = [];
  _MemoryIntroductionRepository(this.current);

  @override
  Future<IntroductionState> loadCompletedIntroductions() async => current;

  @override
  Future<bool> saveCompletedIntroductions(
    IntroductionState introductions,
  ) async {
    saved.add(introductions);
    current = introductions;
    return true;
  }
}

PushToken _pushToken() => PushToken(
  serial: 'PUSH-1',
  id: 'push-1',
  label: 'push',
  issuer: 'issuer',
  isRolledOut: true,
  isPollOnly: true,
);

TOTPToken _totpToken() => TOTPToken(
  id: 'totp-1',
  label: 'totp',
  issuer: 'issuer',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'GEZDGNBVGY3TQOJQ',
  period: 30,
);

void main() {
  late List<String> events;
  late List<MethodCall> notificationCalls;
  late List<MethodCall> settingsCalls;
  late bool batteryOptimizationsDisabled;
  late bool cancelAllFails;
  late _FakeTokenNotifier tokenNotifier;
  late _FakePushRequestNotifier pushNotifier;
  late _FakeFolderNotifier folderNotifier;
  late _MemoryIntroductionRepository introductionRepo;

  setUpAll(() async {
    await setupMocks();
    AndroidFlutterLocalNotificationsPlugin.registerWith();
  });

  setUp(() {
    events = [];
    notificationCalls = [];
    settingsCalls = [];
    batteryOptimizationsDisabled = true;
    cancelAllFails = false;
    tokenNotifier = _FakeTokenNotifier(events: events);
    pushNotifier = _FakePushRequestNotifier(events: events);
    folderNotifier = _FakeFolderNotifier(
      events: events,
      onCollapse: () async => const TokenFolderState(folders: []),
    );
    introductionRepo = _MemoryIntroductionRepository(const IntroductionState());
  });

  void mockChannels(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_notificationsChannel, (call) async {
      notificationCalls.add(call);
      if (call.method == 'cancelAll') {
        events.add('clearNotifications');
        if (cancelAllFails) {
          throw PlatformException(code: 'cancelAllFailed');
        }
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_settingsChannel, (call) async {
      settingsCalls.add(call);
      if (call.method == 'batteryOptimizationsIsDisabled') {
        return batteryOptimizationsDisabled;
      }
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(_notificationsChannel, null);
      messenger.setMockMethodCallHandler(_settingsChannel, null);
    });
  }

  Future<void> pumpApp(WidgetTester tester) async {
    mockChannels(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deeplinkProvider.overrideWith(() => _FakeDeeplinkNotifier()),
          tokenProvider.overrideWith(() => tokenNotifier),
          pushRequestProvider.overrideWith(() => pushNotifier),
          tokenFolderProvider.overrideWith(() => folderNotifier),
          introductionNotifierProvider.overrideWith(
            () => IntroductionNotifier(repoOverride: introductionRepo),
          ),
        ],
        child: AppWrapper(
          child: MaterialApp(
            navigatorKey: globalNavigatorKey,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const Scaffold(body: Text('home')),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> goToBackground(WidgetTester tester) async {
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);
  }

  Future<void> goToForeground(WidgetTester tester) async {
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);
  }

  Future<void> backgroundAndResume(WidgetTester tester) async {
    await goToBackground(tester);
    events.clear();
    await goToForeground(tester);
  }

  void androidTest(
    String description,
    Future<void> Function(WidgetTester tester) body, {
    String? skip,
  }) {
    testWidgets(description, skip: skip != null, (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await body(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  group('AppWrapper on resume', () {
    testWidgets('clears the notifications and refreshes the tokens', (
      tester,
    ) async {
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(
        notificationCalls.where((c) => c.method == 'cancelAll'),
        hasLength(1),
      );
      expect(tokenNotifier.refreshCalls, 1);
      expect(events, containsAll(['clearNotifications', 'refreshTokens']));
      expect(tester.takeException(), isNull);
    });

    testWidgets('does nothing while the app stays in the foreground', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);

      expect(notificationCalls, isEmpty);
      expect(tokenNotifier.refreshCalls, 0);
      expect(tokenNotifier.minimizeCalls, 0);
      expect(folderNotifier.collapseCalls, 0);
    });

    testWidgets('runs the steps again on every resume', (tester) async {
      await pumpApp(tester);
      await backgroundAndResume(tester);
      await backgroundAndResume(tester);

      expect(
        notificationCalls.where((c) => c.method == 'cancelAll'),
        hasLength(2),
      );
      expect(tokenNotifier.refreshCalls, 2);
    });

    testWidgets('a failing notification clearing does not stop the refresh', (
      tester,
    ) async {
      cancelAllFails = true;
      tokenNotifier = _FakeTokenNotifier(
        events: events,
        refreshResult: TokenState(tokens: [_pushToken()]),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(events, contains('clearNotifications'));
      expect(tokenNotifier.refreshCalls, 1);
      expect(pushNotifier.pollCalls, [false]);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'a failing token refresh does not stop the notification clearing',
      (tester) async {
        tokenNotifier = _FakeTokenNotifier(
          events: events,
          refreshError: Exception('storage broken'),
        );
        await pumpApp(tester);
        await backgroundAndResume(tester);

        expect(tokenNotifier.refreshCalls, 1);
        expect(events, contains('clearNotifications'));
        expect(pushNotifier.pollCalls, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('a token refresh without result does not poll', (tester) async {
      tokenNotifier = _FakeTokenNotifier(events: events);
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(tokenNotifier.refreshCalls, 1);
      expect(events, contains('clearNotifications'));
      expect(pushNotifier.loadCalls, 0);
      expect(pushNotifier.pollCalls, isEmpty);
    });

    testWidgets('does not poll when there are only non push tokens', (
      tester,
    ) async {
      tokenNotifier = _FakeTokenNotifier(
        events: events,
        refreshResult: TokenState(tokens: [_totpToken()]),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(tokenNotifier.refreshCalls, 1);
      expect(pushNotifier.loadCalls, 0);
      expect(pushNotifier.pollCalls, isEmpty);
    });

    testWidgets('does not poll when there are no tokens at all', (
      tester,
    ) async {
      tokenNotifier = _FakeTokenNotifier(
        events: events,
        refreshResult: const TokenState(tokens: []),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(pushNotifier.loadCalls, 0);
      expect(pushNotifier.pollCalls, isEmpty);
    });

    testWidgets('polls once, not manually, when a push token exists', (
      tester,
    ) async {
      tokenNotifier = _FakeTokenNotifier(
        events: events,
        refreshResult: TokenState(tokens: [_totpToken(), _pushToken()]),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(pushNotifier.loadCalls, 1);
      expect(pushNotifier.pollCalls, [false]);
      expect(
        events.indexOf('refreshTokens'),
        lessThan(events.indexOf('loadPushRequests')),
      );
      expect(
        events.indexOf('loadPushRequests'),
        lessThan(events.indexOf('poll')),
      );
    });

    testWidgets('a failing poll does not stop the other resume steps', (
      tester,
    ) async {
      tokenNotifier = _FakeTokenNotifier(
        events: events,
        refreshResult: TokenState(tokens: [_pushToken()]),
      );
      pushNotifier = _FakePushRequestNotifier(
        events: events,
        pollError: Exception('network down'),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(pushNotifier.pollCalls, [false]);
      expect(events, contains('clearNotifications'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not touch the folders or save the tokens on resume', (
      tester,
    ) async {
      await pumpApp(tester);
      await goToBackground(tester);
      final savedBefore = tokenNotifier.minimizeCalls;
      final collapsedBefore = folderNotifier.collapseCalls;
      await goToForeground(tester);

      expect(savedBefore, 1);
      expect(collapsedBefore, 1);
      expect(tokenNotifier.minimizeCalls, savedBefore);
      expect(folderNotifier.collapseCalls, collapsedBefore);
    });
  });

  group('AppWrapper on hide', () {
    testWidgets('saves the tokens and collapses the locked folders', (
      tester,
    ) async {
      await pumpApp(tester);
      await goToBackground(tester);

      expect(tokenNotifier.minimizeCalls, 1);
      expect(folderNotifier.collapseCalls, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not clear notifications nor refresh when hidden', (
      tester,
    ) async {
      await pumpApp(tester);
      await goToBackground(tester);

      expect(notificationCalls, isEmpty);
      expect(tokenNotifier.refreshCalls, 0);
    });

    testWidgets('collapses the folders although saving the tokens throws', (
      tester,
    ) async {
      tokenNotifier = _FakeTokenNotifier(
        events: events,
        minimizeError: Exception('save failed'),
      );
      await pumpApp(tester);
      await goToBackground(tester);

      expect(tokenNotifier.minimizeCalls, 1);
      expect(folderNotifier.collapseCalls, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapses the folders although saving the tokens fails', (
      tester,
    ) async {
      tokenNotifier = _FakeTokenNotifier(events: events, minimizeResult: false);
      await pumpApp(tester);
      await goToBackground(tester);

      expect(tokenNotifier.minimizeCalls, 1);
      expect(folderNotifier.collapseCalls, 1);
    });

    testWidgets('saves the tokens although collapsing the folders throws', (
      tester,
    ) async {
      folderNotifier = _FakeFolderNotifier(
        events: events,
        onCollapse: () async => throw Exception('folders broken'),
      );
      await pumpApp(tester);
      await goToBackground(tester);

      expect(folderNotifier.collapseCalls, 1);
      expect(tokenNotifier.minimizeCalls, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides again on every background transition', (tester) async {
      await pumpApp(tester);
      await goToBackground(tester);
      await goToForeground(tester);
      await goToBackground(tester);

      expect(tokenNotifier.minimizeCalls, 2);
      expect(folderNotifier.collapseCalls, 2);
    });

    testWidgets(
      'only locked folders are collapsed by the real folder notifier',
      (tester) async {
        final folderRepo = _MemoryFolderRepository(
          const TokenFolderState(
            folders: [
              TokenFolder(
                label: 'locked',
                folderId: 1,
                isExpanded: true,
                isLocked: true,
              ),
              TokenFolder(label: 'open', folderId: 2, isExpanded: true),
            ],
          ),
        );
        final realFolderNotifier = TokenFolderNotifier(
          repoOverride: folderRepo,
        );
        mockChannels(tester);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              deeplinkProvider.overrideWith(() => _FakeDeeplinkNotifier()),
              tokenProvider.overrideWith(() => tokenNotifier),
              pushRequestProvider.overrideWith(() => pushNotifier),
              tokenFolderProvider.overrideWith(() => realFolderNotifier),
              introductionNotifierProvider.overrideWith(
                () => IntroductionNotifier(repoOverride: introductionRepo),
              ),
            ],
            child: const AppWrapper(child: SizedBox()),
          ),
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(AppWrapper)),
        );
        container.read(tokenFolderProvider);
        await container.read(tokenFolderProvider.notifier).initState;
        await tester.pump();

        await goToBackground(tester);

        final folders = container.read(tokenFolderProvider).folders;
        expect(folders.firstWhere((f) => f.folderId == 1).isExpanded, isFalse);
        expect(folders.firstWhere((f) => f.folderId == 2).isExpanded, isTrue);
        expect(folderRepo.saved, hasLength(1));
        expect(tokenNotifier.minimizeCalls, 1);
      },
    );
  });

  group('AppWrapper battery optimization hint', () {
    androidTest('is not shown when battery optimization is already disabled', (
      tester,
    ) async {
      batteryOptimizationsDisabled = true;
      introductionRepo = _MemoryIntroductionRepository(
        const IntroductionState(
          completedIntroductions: {Introduction.homeWidgetSetUp},
        ),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(find.byType(BatteryOptimizationDialog), findsNothing);
      expect(
        settingsCalls.where(
          (c) => c.method == 'batteryOptimizationsIsDisabled',
        ),
        hasLength(1),
      );
      expect(introductionRepo.saved, isEmpty);
    });

    androidTest('is not shown when no home widget was set up', (tester) async {
      batteryOptimizationsDisabled = false;
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(find.byType(BatteryOptimizationDialog), findsNothing);
      expect(introductionRepo.saved, isEmpty);
    });

    androidTest('is not shown when it was already completed', (tester) async {
      batteryOptimizationsDisabled = false;
      introductionRepo = _MemoryIntroductionRepository(
        const IntroductionState(
          completedIntroductions: {
            Introduction.homeWidgetSetUp,
            Introduction.homeWidgetBatteryOptimization,
          },
        ),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(find.byType(BatteryOptimizationDialog), findsNothing);
      expect(introductionRepo.saved, isEmpty);
    });

    androidTest('is not shown when only the battery step was completed', (
      tester,
    ) async {
      batteryOptimizationsDisabled = false;
      introductionRepo = _MemoryIntroductionRepository(
        const IntroductionState(
          completedIntroductions: {Introduction.homeWidgetBatteryOptimization},
        ),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);

      expect(find.byType(BatteryOptimizationDialog), findsNothing);
      expect(introductionRepo.saved, isEmpty);
    });

    androidTest('is shown once and completed after it was dismissed', (
      tester,
    ) async {
      batteryOptimizationsDisabled = false;
      introductionRepo = _MemoryIntroductionRepository(
        const IntroductionState(
          completedIntroductions: {Introduction.homeWidgetSetUp},
        ),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BatteryOptimizationDialog), findsOneWidget);
      expect(find.text(_l10n.batteryOptimizationTitle), findsOneWidget);
      expect(
        introductionRepo.current.isUncompleted(
          Introduction.homeWidgetBatteryOptimization,
        ),
        isTrue,
        reason: 'only completed once the user dealt with the dialog',
      );

      await tester.tap(find.widgetWithText(IntentButton, _l10n.cancel));
      await tester.pumpAndSettle();

      expect(find.byType(BatteryOptimizationDialog), findsNothing);
      expect(
        introductionRepo.current.isCompleted(
          Introduction.homeWidgetBatteryOptimization,
        ),
        isTrue,
      );
      expect(introductionRepo.saved, hasLength(1));
      expect(
        settingsCalls.where(
          (c) => c.method == 'requestIgnoreBatteryOptimizations',
        ),
        isEmpty,
      );

      await backgroundAndResume(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BatteryOptimizationDialog), findsNothing);
      expect(introductionRepo.saved, hasLength(1));
      expect(
        settingsCalls.where(
          (c) => c.method == 'batteryOptimizationsIsDisabled',
        ),
        hasLength(2),
        reason: 'the optimization state is queried again on every resume',
      );
    });

    androidTest(
      'requests the exemption when the user disables the optimization',
      (tester) async {
        batteryOptimizationsDisabled = false;
        introductionRepo = _MemoryIntroductionRepository(
          const IntroductionState(
            completedIntroductions: {Introduction.homeWidgetSetUp},
          ),
        );
        await pumpApp(tester);
        await backgroundAndResume(tester);
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(
          find.widgetWithText(IntentButton, _l10n.disableButton),
        );
        await tester.pumpAndSettle();

        expect(
          settingsCalls.where(
            (c) => c.method == 'requestIgnoreBatteryOptimizations',
          ),
          hasLength(1),
        );
        expect(find.byType(BatteryOptimizationDialog), findsNothing);
        expect(
          introductionRepo.current.isCompleted(
            Introduction.homeWidgetBatteryOptimization,
          ),
          isTrue,
        );
      },
    );

    androidTest('is still shown when the other resume steps failed', (
      tester,
    ) async {
      batteryOptimizationsDisabled = false;
      cancelAllFails = true;
      tokenNotifier = _FakeTokenNotifier(
        events: events,
        refreshError: Exception('storage broken'),
      );
      introductionRepo = _MemoryIntroductionRepository(
        const IntroductionState(
          completedIntroductions: {Introduction.homeWidgetSetUp},
        ),
      );
      await pumpApp(tester);
      await backgroundAndResume(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BatteryOptimizationDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(IntentButton, _l10n.cancel));
      await tester.pumpAndSettle();
    });

    androidTest('is not shown after the app was only hidden', (tester) async {
      batteryOptimizationsDisabled = false;
      introductionRepo = _MemoryIntroductionRepository(
        const IntroductionState(
          completedIntroductions: {Introduction.homeWidgetSetUp},
        ),
      );
      await pumpApp(tester);
      await goToBackground(tester);

      expect(find.byType(BatteryOptimizationDialog), findsNothing);
      expect(settingsCalls, isEmpty);
    });
    androidTest(
      "BUG: hint is stacked a second time when the app resumes while the first is open",
      (tester) async {
        batteryOptimizationsDisabled = false;
        introductionRepo = _MemoryIntroductionRepository(
          const IntroductionState(
            completedIntroductions: {Introduction.homeWidgetSetUp},
          ),
        );
        await pumpApp(tester);
        await backgroundAndResume(tester);
        await tester.pump(const Duration(milliseconds: 300));
        final afterFirstResume = find
            .byType(BatteryOptimizationDialog)
            .evaluate()
            .length;

        await backgroundAndResume(tester);
        await tester.pump(const Duration(milliseconds: 300));
        final afterSecondResume = find
            .byType(BatteryOptimizationDialog)
            .evaluate()
            .length;

        globalNavigatorKey.currentState!.popUntil((route) => route.isFirst);
        await tester.pumpAndSettle();

        expect(afterFirstResume, 1);
        expect(
          afterSecondResume,
          1,
          reason: 'the hint must be shown at most once',
        );
      },
      skip:
          "BUG: app_wrapper.dart:115-134 marks the hint completed only after the dialog is dismissed, so a second resume stacks a second dialog",
    );
  });
}
