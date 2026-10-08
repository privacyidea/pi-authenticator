import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_detail.dart';
import 'package:privacyidea_authenticator/model/api_results/pi_server_results/pi_server_result_value.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/pi_server_response.dart';
import 'package:privacyidea_authenticator/model/push_request/push_choice_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_code_to_phone_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/push_request/push_request.dart';
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

import '../../../../../tests_app_wrapper.mocks.dart';

/// Hand-written fake: records calls, never talks to a server.
class _FakeNotifier extends PushRequestNotifier {
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
class _Host extends ConsumerWidget with PushDialogMixin {
  @override
  final PushRequest pushRequest;
  @override
  final PushToken token;

  const _Host({required this.pushRequest, required this.token});

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

void main() {
  final l10n = AppLocalizationsEn();

  late PushDefaultRequest defaultRequest;
  late PushChoiceRequest choiceRequest;
  late PushCodeToPhoneRequest codeRequest;
  late _FakeNotifier notifier;
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
    notifier = _FakeNotifier();
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
          _Host(pushRequest: defaultRequest, token: hidden()),
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
        _Host(pushRequest: defaultRequest, token: hidden()),
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
        _Host(pushRequest: codeRequest, token: hidden()),
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
        _Host(pushRequest: codeRequest, token: hidden()),
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
        _Host(
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
        _Host(
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
          _Host(pushRequest: defaultRequest, token: hidden()),
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
        _Host(
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
          _Host(pushRequest: defaultRequest, token: lockedToken()),
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
          _Host(pushRequest: codeRequest, token: lockedToken()),
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
          _Host(pushRequest: defaultRequest, token: lockedToken()),
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
