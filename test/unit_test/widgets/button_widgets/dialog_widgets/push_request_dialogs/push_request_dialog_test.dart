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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_detail.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/pi_server_response.dart';
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';

import '../../../../../tests_app_wrapper.dart';
import '../../../../../tests_app_wrapper.mocks.dart';

/// Hand-written fake: records calls, never talks to a server.
class _DiscardFakeNotifier extends PushRequestNotifier {
  final removed = <PushRequest>[];
  final cancelled = <PushRequest>[];
  int declineCalls = 0;
  int acceptCalls = 0;
  PiSuccessResponse<PiServerResultValue, PiServerResultDetail>? cancelResponse;

  @override
  Future<PushRequestState> build({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  }) async => PushRequestState.empty();

  @override
  Future<bool> remove(PushRequest pushRequest) async {
    removed.add(pushRequest);
    return true;
  }

  @override
  Future<PiSuccessResponse<T, D>?> cancel<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request) async {
    cancelled.add(request);
    return cancelResponse as PiSuccessResponse<T, D>?;
  }

  @override
  Future<PiSuccessResponse<T, D>?> decline<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request) async {
    declineCalls++;
    return null;
  }

  @override
  Future<PiSuccessResponse<T, D>?> accept<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request, {String? selectedAnswer}) async {
    acceptCalls++;
    return null;
  }
}

/// Minimal host exposing [PushDialogMixin.handleDiscard] via a button.
class _DiscardHost extends ConsumerWidget with PushDialogMixin {
  @override
  final PushDefaultRequest pushRequest;
  @override
  final PushToken token;

  const _DiscardHost({required this.pushRequest, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: TextButton(
      onPressed: () => handleDiscard(context, ref),
      child: const Text('discard'),
    ),
  );
}

void _testPushDialogDiscard() {
  late PushDefaultRequest defaultRequest;
  late PushCodeToPhoneRequest codeRequest;
  late PushToken token;
  late _DiscardFakeNotifier notifier;
  late MockLocalAuthentication localAuth;

  setUp(() {
    defaultRequest = PushDefaultRequest(
      title: 't',
      question: 'q',
      nonce: 'n',
      serial: 's',
      signature: 'sig',
      expirationDate: DateTime(2099),
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
    );
    codeRequest = PushCodeToPhoneRequest(
      title: 't',
      serial: 's',
      question: 'q',
      nonce: 'n',
      signature: 'sig',
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
      displayCode: '123 456',
      expirationDate: DateTime(2099),
    );
    token = PushToken(serial: 's', id: 'id');
    notifier = _DiscardFakeNotifier();
    localAuth = MockLocalAuthentication();
    localAuthInstance = localAuth;
    resetAuthMutex();
  });

  tearDown(() {
    localAuthInstance = LocalAuthentication();
    resetAuthMutex();
  });

  void verifyNoAuthPrompt() {
    verifyNever(localAuth.isDeviceSupported());
    verifyNever(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    );
  }

  /// Pumps a home page whose button pushes [dialog] as a new route.
  Future<void> openDialog(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pushRequestProvider.overrideWith(() => notifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => Scaffold(body: dialog)),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('handleDone (PushCodeToPhoneDialog)', () {
    testWidgets('Done only removes locally, never cancels or declines', (
      tester,
    ) async {
      await openDialog(
        tester,
        PushCodeToPhoneDialog(pushRequest: codeRequest, token: token),
      );
      expect(find.byType(PushCodeToPhoneDialog), findsOneWidget);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PushCodeToPhoneDialog)),
      )!;

      await tester.tap(find.text(l10n.done));
      await tester.pumpAndSettle();

      expect(notifier.removed, [codeRequest]);
      expect(notifier.cancelled, isEmpty);
      expect(notifier.declineCalls, 0);
      expect(notifier.acceptCalls, 0);
      verifyNoAuthPrompt();
      expect(find.byType(PushCodeToPhoneDialog), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('handleDiscard', () {
    testWidgets('cancel returns null (offline): also removes locally', (
      tester,
    ) async {
      notifier.cancelResponse = null;
      await openDialog(
        tester,
        _DiscardHost(pushRequest: defaultRequest, token: token),
      );

      await tester.tap(find.text('discard'));
      await tester.pumpAndSettle();

      expect(notifier.cancelled, [defaultRequest]);
      expect(notifier.removed, [defaultRequest]);
      verifyNoAuthPrompt();
      expect(find.text('discard'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('cancel succeeds: dialog does not call remove additionally', (
      tester,
    ) async {
      notifier.cancelResponse =
          PiSuccessResponse<PiServerResultValue, PiServerResultDetail>(
            statusCode: 200,
            result: const PiServerResult(
              status: true,
              value: PushResultValue(true),
            ),
          );
      await openDialog(
        tester,
        _DiscardHost(pushRequest: defaultRequest, token: token),
      );

      await tester.tap(find.text('discard'));
      await tester.pumpAndSettle();

      expect(notifier.cancelled, [defaultRequest]);
      expect(notifier.removed, isEmpty);
      verifyNoAuthPrompt();
      expect(find.text('discard'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

/// Hand-written fake: records calls, never talks to a server.
class _AuthFakeNotifier extends PushRequestNotifier {
  final removed = <PushRequest>[];
  final cancelled = <PushRequest>[];
  final declined = <PushRequest>[];
  final accepted = <PushRequest>[];
  final selectedAnswers = <String?>[];

  @override
  Future<PushRequestState> build({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  }) async => PushRequestState.empty();

  @override
  Future<bool> remove(PushRequest pushRequest) async {
    removed.add(pushRequest);
    return true;
  }

  @override
  Future<PiSuccessResponse<T, D>?> cancel<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request) async {
    cancelled.add(request);
    return null;
  }

  @override
  Future<PiSuccessResponse<T, D>?> decline<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request) async {
    declined.add(request);
    return null;
  }

  @override
  Future<PiSuccessResponse<T, D>?> accept<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(PushToken token, PushRequest request, {String? selectedAnswer}) async {
    accepted.add(request);
    selectedAnswers.add(selectedAnswer);
    return null;
  }

  int get serverCalls =>
      cancelled.length + declined.length + accepted.length + removed.length;
}

/// A push token that reports itself as hidden. The real [PushToken] never
/// does (its `isHidden` is hard coded to false), so this is the only way to
/// reach the "hidden token needs authentication to discard" branch.
class _HiddenPushToken extends PushToken {
  _HiddenPushToken({
    required super.serial,
    required super.id,
    super.pin,
    super.forceBiometricOption,
  });

  @override
  bool get isHidden => true;
}

/// Minimal host exposing the [PushDialogMixin] handlers via buttons.
class _AuthHost extends ConsumerWidget with PushDialogMixin {
  @override
  final PushRequest pushRequest;
  @override
  final PushToken token;

  const _AuthHost({required this.pushRequest, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Column(
      children: [
        TextButton(
          onPressed: () => handleAccept(context, ref),
          child: const Text('accept'),
        ),
        TextButton(
          onPressed: () => handleDecline(context, ref),
          child: const Text('decline'),
        ),
        TextButton(
          onPressed: () => handleDiscard(context, ref),
          child: const Text('discard'),
        ),
        TextButton(
          onPressed: () => handleDone(context, ref),
          child: const Text('done'),
        ),
      ],
    ),
  );
}

void _testPushDialogAuth() {
  final l10n = AppLocalizationsEn();

  late PushDefaultRequest defaultRequest;
  late PushChoiceRequest choiceRequest;
  late PushCodeToPhoneRequest codeRequest;
  late _AuthFakeNotifier notifier;
  late MockLocalAuthentication localAuth;

  setUp(() {
    defaultRequest = PushDefaultRequest(
      title: 'Default title',
      question: 'Default question',
      nonce: 'n',
      serial: 's',
      signature: 'sig',
      expirationDate: DateTime(2099),
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
    );
    choiceRequest = PushChoiceRequest(
      title: 'Choice title',
      question: 'Choice question',
      nonce: 'n',
      serial: 's',
      signature: 'sig',
      expirationDate: DateTime(2099),
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
      possibleAnswers: const ['A1', 'B2', 'C3'],
    );
    codeRequest = PushCodeToPhoneRequest(
      title: 'Code title',
      serial: 's',
      question: 'Code question',
      nonce: 'n',
      signature: 'sig',
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
      displayCode: '123 456',
      expirationDate: DateTime(2099),
    );
    notifier = _AuthFakeNotifier();
    localAuth = MockLocalAuthentication();
    localAuthInstance = localAuth;
    resetAuthMutex();
  });

  tearDown(() {
    localAuthInstance = LocalAuthentication();
    resetAuthMutex();
  });

  // --- auth helpers ---------------------------------------------------------

  void deviceWithScreenLock({bool biometricsEnrolled = false}) {
    when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
    if (biometricsEnrolled) {
      when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(
        localAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [BiometricType.fingerprint]);
    }
  }

  void authResult(bool result) {
    when(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    ).thenAnswer((_) async => result);
  }

  List<dynamic> verifyOnePrompt() => verify(
    localAuth.authenticate(
      localizedReason: captureAnyNamed('localizedReason'),
      biometricOnly: captureAnyNamed('biometricOnly'),
      authMessages: anyNamed('authMessages'),
    ),
  ).captured;

  void verifyNoPrompt() {
    verifyNever(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    );
  }

  // --- pumping --------------------------------------------------------------

  Future<ProviderContainer> pumpHome(
    WidgetTester tester,
    Widget home, {
    ForceBiometricOption appAuthMethod = ForceBiometricOption.any,
  }) async {
    final settingsRepo = MockSettingsRepository();
    when(settingsRepo.loadSettings()).thenAnswer(
      (_) async => SettingsState(appAuthMethod: appAuthMethod),
    );
    when(settingsRepo.saveSettings(any)).thenAnswer((_) async => true);
    final container = ProviderContainer(
      overrides: [
        pushRequestProvider.overrideWith(() => notifier),
        settingsProvider.overrideWith(
          () => SettingsNotifier(repoOverride: settingsRepo),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Load the settings up front, the dialogs only read them once.
    await container.read(settingsProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => home),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  PushToken lockedToken({
    ForceBiometricOption option = ForceBiometricOption.none,
  }) => PushToken(
    serial: 's',
    id: 'id',
    isLocked: true,
    forceBiometricOption: option,
  );

  // ==========================================================================

  group('accept (PushDefaultDialog)', () {
    testWidgets('locked token, auth denied: accept is NOT called, dialog stays', (
      tester,
    ) async {
      deviceWithScreenLock();
      authResult(false);
      await pumpHome(
        tester,
        PushDefaultDialog(pushRequest: defaultRequest, token: lockedToken()),
      );

      await tapAndSettle(tester, find.text(l10n.accept));

      final captured = verifyOnePrompt();
      expect(captured[0], l10n.authToAcceptPushRequest);
      expect(notifier.accepted, isEmpty);
      expect(notifier.serverCalls, 0);
      expect(find.byType(PushDefaultDialog), findsOneWidget);
    });

    testWidgets('locked token, auth granted: accept is called exactly once', (
      tester,
    ) async {
      deviceWithScreenLock();
      authResult(true);
      await pumpHome(
        tester,
        PushDefaultDialog(pushRequest: defaultRequest, token: lockedToken()),
      );

      await tapAndSettle(tester, find.text(l10n.accept));

      verifyOnePrompt();
      expect(notifier.accepted, [defaultRequest]);
      expect(notifier.selectedAnswers, [null]);
      expect(notifier.declined, isEmpty);
    });

    testWidgets('unlocked token: accept without any auth prompt', (
      tester,
    ) async {
      await pumpHome(
        tester,
        PushDefaultDialog(
          pushRequest: defaultRequest,
          token: PushToken(serial: 's', id: 'id'),
        ),
      );

      await tapAndSettle(tester, find.text(l10n.accept));

      expect(notifier.accepted, [defaultRequest]);
      verifyNever(localAuth.isDeviceSupported());
      verifyNoPrompt();
    });

    testWidgets(
      'locked token on a device without screen lock: not authenticated, accept is NOT called',
      (tester) async {
        when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
        authResult(true);
        await pumpHome(
          tester,
          PushDefaultDialog(pushRequest: defaultRequest, token: lockedToken()),
        );

        await tapAndSettle(tester, find.text(l10n.accept));

        verifyNoPrompt();
        expect(notifier.accepted, isEmpty);
      },
    );

    testWidgets(
      'token forces biometrics: biometricOnly is forwarded, granted auth accepts',
      (tester) async {
        deviceWithScreenLock(biometricsEnrolled: true);
        authResult(true);
        await pumpHome(
          tester,
          PushDefaultDialog(
            pushRequest: defaultRequest,
            token: lockedToken(option: ForceBiometricOption.biometric),
          ),
        );

        await tapAndSettle(tester, find.text(l10n.accept));

        final captured = verifyOnePrompt();
        expect(captured[1], isTrue);
        expect(notifier.accepted, [defaultRequest]);
      },
    );

    testWidgets(
      'token forces biometrics but none are enrolled: accept is NOT called',
      (tester) async {
        deviceWithScreenLock();
        when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(localAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
        authResult(true);
        await pumpHome(
          tester,
          PushDefaultDialog(
            pushRequest: defaultRequest,
            token: lockedToken(option: ForceBiometricOption.biometric),
          ),
        );

        await tapAndSettle(tester, find.text(l10n.accept));

        verifyNoPrompt();
        expect(notifier.accepted, isEmpty);
      },
    );

    testWidgets(
      'token without own option but app-wide biometric setting: biometricOnly is forwarded',
      (tester) async {
        deviceWithScreenLock(biometricsEnrolled: true);
        authResult(true);
        await pumpHome(
          tester,
          PushDefaultDialog(pushRequest: defaultRequest, token: lockedToken()),
          appAuthMethod: ForceBiometricOption.biometric,
        );

        await tapAndSettle(tester, find.text(l10n.accept));

        final captured = verifyOnePrompt();
        expect(captured[1], isTrue);
        expect(notifier.accepted, [defaultRequest]);
      },
    );

    testWidgets(
      'token without option and app setting any: device credentials are allowed (biometricOnly false)',
      (tester) async {
        deviceWithScreenLock();
        authResult(true);
        await pumpHome(
          tester,
          PushDefaultDialog(pushRequest: defaultRequest, token: lockedToken()),
        );

        await tapAndSettle(tester, find.text(l10n.accept));

        final captured = verifyOnePrompt();
        expect(captured[1], isFalse);
      },
    );
  });

  group('accept (PushChoiceDialog)', () {
    testWidgets('locked token, auth denied: no answer is sent', (tester) async {
      deviceWithScreenLock();
      authResult(false);
      await pumpHome(
        tester,
        PushChoiceDialog(pushRequest: choiceRequest, token: lockedToken()),
      );

      await tapAndSettle(tester, find.text('B2'));

      verifyOnePrompt();
      expect(notifier.accepted, isEmpty);
      expect(notifier.selectedAnswers, isEmpty);
    });

    testWidgets('locked token, auth granted: the tapped answer is sent', (
      tester,
    ) async {
      deviceWithScreenLock();
      authResult(true);
      await pumpHome(
        tester,
        PushChoiceDialog(pushRequest: choiceRequest, token: lockedToken()),
      );

      await tapAndSettle(tester, find.text('C3'));

      expect(notifier.accepted, [choiceRequest]);
      expect(notifier.selectedAnswers, ['C3']);
    });

    testWidgets('unlocked token: answer is sent without auth', (tester) async {
      await pumpHome(
        tester,
        PushChoiceDialog(
          pushRequest: choiceRequest,
          token: PushToken(serial: 's', id: 'id'),
        ),
      );

      await tapAndSettle(tester, find.text('A1'));

      expect(notifier.selectedAnswers, ['A1']);
      verifyNoPrompt();
    });
  });

  group('decline (via the decline confirmation)', () {
    Future<void> openDeclineConfirm(WidgetTester tester) async {
      await tester.tap(find.text(l10n.decline));
      // The decline button shows an endless spinner while the confirmation is
      // open, so pumpAndSettle would never return.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(l10n.declineIt), findsOneWidget);
    }

    testWidgets('locked token, auth denied: decline is NOT called', (
      tester,
    ) async {
      deviceWithScreenLock();
      authResult(false);
      await pumpHome(
        tester,
        PushDefaultDialog(pushRequest: defaultRequest, token: lockedToken()),
      );
      await openDeclineConfirm(tester);

      await tapAndSettle(tester, find.text(l10n.no));

      final captured = verifyOnePrompt();
      expect(captured[0], l10n.authToDeclinePushRequest);
      expect(notifier.declined, isEmpty);
      expect(notifier.serverCalls, 0);
    });

    testWidgets('locked token, auth granted: decline is called', (tester) async {
      deviceWithScreenLock();
      authResult(true);
      await pumpHome(
        tester,
        PushDefaultDialog(pushRequest: defaultRequest, token: lockedToken()),
      );
      await openDeclineConfirm(tester);

      await tapAndSettle(tester, find.text(l10n.no));

      verifyOnePrompt();
      expect(notifier.declined, [defaultRequest]);
      expect(notifier.cancelled, isEmpty);
    });

    testWidgets('unlocked token: decline needs no auth', (tester) async {
      await pumpHome(
        tester,
        PushDefaultDialog(
          pushRequest: defaultRequest,
          token: PushToken(serial: 's', id: 'id'),
        ),
      );
      await openDeclineConfirm(tester);

      await tapAndSettle(tester, find.text(l10n.no));

      expect(notifier.declined, [defaultRequest]);
      verifyNoPrompt();
    });

    testWidgets(
      'locked token with biometric option: biometricOnly is forwarded to the decline auth',
      (tester) async {
        deviceWithScreenLock(biometricsEnrolled: true);
        authResult(true);
        await pumpHome(
          tester,
          PushDefaultDialog(
            pushRequest: defaultRequest,
            token: lockedToken(option: ForceBiometricOption.biometric),
          ),
        );
        await openDeclineConfirm(tester);

        await tapAndSettle(tester, find.text(l10n.no));

        final captured = verifyOnePrompt();
        expect(captured[1], isTrue);
        expect(notifier.declined, [defaultRequest]);
      },
    );

    testWidgets(
      'choice dialog, locked token, auth denied: decline is NOT called',
      (tester) async {
        deviceWithScreenLock();
        authResult(false);
        await pumpHome(
          tester,
          PushChoiceDialog(pushRequest: choiceRequest, token: lockedToken()),
        );
        await openDeclineConfirm(tester);

        await tapAndSettle(tester, find.text(l10n.no));

        verifyOnePrompt();
        expect(notifier.declined, isEmpty);
      },
    );
  });

  group('discard / done with a hidden token', () {
    // `_HiddenPushToken.isHidden` is true, this exercises the auth branch of
    // PushDialogMixin._authToDiscard.
    PushToken hidden({
      ForceBiometricOption option = ForceBiometricOption.none,
    }) => _HiddenPushToken(
      serial: 's',
      id: 'id',
      pin: true,
      forceBiometricOption: option,
    );

    testWidgets(
      'discard with denied auth: neither cancelled nor removed, view stays',
      (tester) async {
        deviceWithScreenLock();
        authResult(false);
        await pumpHome(
          tester,
          _AuthHost(pushRequest: defaultRequest, token: hidden()),
        );

        await tapAndSettle(tester, find.text('discard'));

        final captured = verifyOnePrompt();
        expect(captured[0], l10n.authToDiscardPushRequest);
        expect(notifier.cancelled, isEmpty);
        expect(notifier.removed, isEmpty);
        expect(find.text('discard'), findsOneWidget);
      },
    );

    testWidgets('discard with granted auth: request is cancelled and view closes', (
      tester,
    ) async {
      deviceWithScreenLock();
      authResult(true);
      await pumpHome(
        tester,
        _AuthHost(pushRequest: defaultRequest, token: hidden()),
      );

      await tapAndSettle(tester, find.text('discard'));

      verifyOnePrompt();
      expect(notifier.cancelled, [defaultRequest]);
      // cancel returned null (offline) -> removed locally as well.
      expect(notifier.removed, [defaultRequest]);
      expect(find.text('discard'), findsNothing);
    });

    testWidgets('done with denied auth: request is NOT removed, view stays', (
      tester,
    ) async {
      deviceWithScreenLock();
      authResult(false);
      await pumpHome(
        tester,
        _AuthHost(pushRequest: codeRequest, token: hidden()),
      );

      await tapAndSettle(tester, find.text('done'));

      final captured = verifyOnePrompt();
      expect(captured[0], l10n.authToDiscardPushRequest);
      expect(notifier.removed, isEmpty);
      expect(notifier.cancelled, isEmpty);
      expect(find.text('done'), findsOneWidget);
    });

    testWidgets('done with granted auth: request is removed, never declined', (
      tester,
    ) async {
      deviceWithScreenLock();
      authResult(true);
      await pumpHome(
        tester,
        _AuthHost(pushRequest: codeRequest, token: hidden()),
      );

      await tapAndSettle(tester, find.text('done'));

      verifyOnePrompt();
      expect(notifier.removed, [codeRequest]);
      expect(notifier.cancelled, isEmpty);
      expect(notifier.declined, isEmpty);
      expect(find.text('done'), findsNothing);
    });

    testWidgets('biometric option of the token is forwarded for discard', (
      tester,
    ) async {
      deviceWithScreenLock(biometricsEnrolled: true);
      authResult(false);
      await pumpHome(
        tester,
        _AuthHost(
          pushRequest: defaultRequest,
          token: hidden(option: ForceBiometricOption.biometric),
        ),
      );

      await tapAndSettle(tester, find.text('discard'));

      final captured = verifyOnePrompt();
      expect(captured[1], isTrue);
      expect(notifier.cancelled, isEmpty);
    });

    testWidgets('biometric option of the token is forwarded for done', (
      tester,
    ) async {
      deviceWithScreenLock(biometricsEnrolled: true);
      authResult(true);
      await pumpHome(
        tester,
        _AuthHost(
          pushRequest: codeRequest,
          token: hidden(option: ForceBiometricOption.biometric),
        ),
      );

      await tapAndSettle(tester, find.text('done'));

      final captured = verifyOnePrompt();
      expect(captured[1], isTrue);
      expect(notifier.removed, [codeRequest]);
    });

    testWidgets(
      'hidden token on a device without screen lock: discard is blocked',
      (tester) async {
        when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
        authResult(true);
        await pumpHome(
          tester,
          _AuthHost(pushRequest: defaultRequest, token: hidden()),
        );

        await tapAndSettle(tester, find.text('discard'));

        verifyNoPrompt();
        expect(notifier.cancelled, isEmpty);
        expect(notifier.removed, isEmpty);
      },
    );
  });

  group('discard / done with a visible token', () {
    testWidgets('unlocked token: discard and done need no auth', (
      tester,
    ) async {
      await pumpHome(
        tester,
        _AuthHost(
          pushRequest: defaultRequest,
          token: PushToken(serial: 's', id: 'id'),
        ),
      );

      await tapAndSettle(tester, find.text('discard'));

      expect(notifier.cancelled, [defaultRequest]);
      verifyNever(localAuth.isDeviceSupported());
      verifyNoPrompt();
    });
  });

  group('discard / done with a locked push token', () {
    // A locked PushToken is never "hidden" (PushToken.isHidden is hard coded
    // to false), so PushDialogMixin._authToDiscard returns true without any
    // authentication. Accept and decline of the same token do authenticate.
    testWidgets(
      'BUG: discard with denied auth must not cancel or remove the request',
      (tester) async {
        deviceWithScreenLock();
        authResult(false);
        await pumpHome(
          tester,
          _AuthHost(pushRequest: defaultRequest, token: lockedToken()),
        );

        await tapAndSettle(tester, find.text('discard'));

        verifyOnePrompt();
        expect(notifier.cancelled, isEmpty);
        expect(notifier.removed, isEmpty);
      },
      // BUG: push_request_dialog.dart:187 _authToDiscard checks token.isHidden, which is always false for PushToken, so a locked push token can be discarded without authentication
      skip: true,
    );

    testWidgets(
      'BUG: done with denied auth must not remove the request',
      (tester) async {
        deviceWithScreenLock();
        authResult(false);
        await pumpHome(
          tester,
          _AuthHost(pushRequest: codeRequest, token: lockedToken()),
        );

        await tapAndSettle(tester, find.text('done'));

        verifyOnePrompt();
        expect(notifier.removed, isEmpty);
      },
      // BUG: push_request_dialog.dart:187 _authToDiscard checks token.isHidden, which is always false for PushToken, so Done on a locked push token needs no authentication
      skip: true,
    );

    testWidgets(
      'BUG: discard with granted auth authenticates once, then cancels',
      (tester) async {
        deviceWithScreenLock();
        authResult(true);
        await pumpHome(
          tester,
          _AuthHost(pushRequest: defaultRequest, token: lockedToken()),
        );

        await tapAndSettle(tester, find.text('discard'));

        final captured = verifyOnePrompt();
        expect(captured[0], l10n.authToDiscardPushRequest);
        expect(notifier.cancelled, [defaultRequest]);
      },
      // BUG: push_request_dialog.dart:187 _authToDiscard checks token.isHidden, which is always false for PushToken, so no authentication prompt is shown when discarding a locked push token
      skip: true,
    );
  });
}


void main() {
  late PushToken mockToken;
  late MockPushRequestNotifier mockNotifier;
  final testDate = DateTime(2026, 4, 14);
  final testUri = Uri.parse('https://example.com');

  setUp(() {
    mockToken = PushToken(serial: 'S1', id: 'ID1');
    mockNotifier = MockPushRequestNotifier();
  });

  Widget createWidgetUnderTest(PushRequest request) {
    return TestsAppWrapper(
      overrides: [pushRequestProvider.overrideWith(() => mockNotifier)],
      child: PushRequestDialog(pushRequest: request, token: mockToken),
    );
  }

  group('PushRequestDialog Factory Tests', () {
    testWidgets('mapping PushChoiceRequest', (tester) async {
      final request = PushChoiceRequest(
        title: 'Choice',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: testUri,
        sslVerify: true,
        possibleAnswers: ['A', 'B'],
      );

      await tester.pumpWidget(createWidgetUnderTest(request));

      final dynamic exception = tester.takeException();
      expect(exception, isNull);

      await tester.pump();
      expect(find.byType(PushChoiceDialog), findsOneWidget);
    });

    testWidgets('mapping PushDefaultRequest', (tester) async {
      final request = PushDefaultRequest(
        title: 'Default',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: testUri,
        sslVerify: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(request));
      await tester.pump();

      expect(find.byType(PushDefaultDialog), findsOneWidget);
    });

    testWidgets('mapping PushCodeToPhoneRequest', (tester) async {
      final request = PushCodeToPhoneRequest(
        title: 'Code',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: testUri,
        sslVerify: true,
        displayCode: '123',
      );

      await tester.pumpWidget(createWidgetUnderTest(request));
      await tester.pump();

      expect(find.byType(PushCodeToPhoneDialog), findsOneWidget);
    });
  });

  _testPushDialogDiscard();
  _testPushDialogAuth();
}
