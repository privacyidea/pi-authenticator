import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_groups/settings_group_auth_method/settings_group_auth_method.dart';

import '../../../tests_app_wrapper.mocks.dart';

/// Records every `setAppAuthMethod` call, then behaves like the real notifier.
class _RecordingSettingsNotifier extends SettingsNotifier {
  final calls = <ForceBiometricOption>[];

  _RecordingSettingsNotifier(MockSettingsRepository repo)
    : super(repoOverride: repo);

  @override
  Future<SettingsState> setAppAuthMethod(ForceBiometricOption value) {
    calls.add(value);
    return super.setAppAuthMethod(value);
  }
}

void main() {
  final l10n = AppLocalizationsEn();

  late MockLocalAuthentication localAuth;
  late MockSettingsRepository settingsRepo;
  late _RecordingSettingsNotifier settingsNotifier;

  setUp(() {
    localAuth = MockLocalAuthentication();
    localAuthInstance = localAuth;
    resetAuthMutex();
    settingsRepo = MockSettingsRepository();
    when(settingsRepo.saveSettings(any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    localAuthInstance = LocalAuthentication();
    resetAuthMutex();
  });

  void deviceSupportsBiometrics() {
    when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
    when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
    when(
      localAuth.getAvailableBiometrics(),
    ).thenAnswer((_) async => [BiometricType.fingerprint]);
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

  void verifyNoPrompt() {
    verifyNever(
      localAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        biometricOnly: anyNamed('biometricOnly'),
        authMessages: anyNamed('authMessages'),
      ),
    );
  }

  Future<ProviderContainer> pumpGroup(
    WidgetTester tester, {
    required ForceBiometricOption stored,
  }) async {
    when(
      settingsRepo.loadSettings(),
    ).thenAnswer((_) async => SettingsState(appAuthMethod: stored));
    settingsNotifier = _RecordingSettingsNotifier(settingsRepo);
    final container = ProviderContainer(
      overrides: [settingsProvider.overrideWith(() => settingsNotifier)],
    );
    addTearDown(container.dispose);
    await container.read(settingsProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SettingsGroupAuthMethod()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(find.text(l10n.authMethodTitle));
    await tester.pumpAndSettle();
    expect(find.text(l10n.authMethodAny), findsOneWidget);
    expect(find.text(l10n.authMethodBiometric), findsOneWidget);
  }

  Future<void> select(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// Tapping the already selected radio does not report a new value, the
  /// dialog simply stays open. Close it again via cancel.
  Future<void> expectDialogStaysOpenThenCancel(WidgetTester tester) async {
    expect(find.text(l10n.authMethodBiometric), findsOneWidget);
    await select(tester, l10n.cancel);
    expect(find.text(l10n.authMethodBiometric), findsNothing);
  }

  IconData? trailingIcon(WidgetTester tester) {
    final icons = tester
        .widgetList<Icon>(
          find.descendant(
            of: find.byType(SettingsGroupAuthMethod),
            matching: find.byType(Icon),
          ),
        )
        .map((i) => i.icon)
        .toList();
    return icons.firstWhere(
      (i) => i == Icons.fingerprint || i == Icons.lock_outline,
      orElse: () => null,
    );
  }

  ForceBiometricOption currentOption(ProviderContainer c) =>
      c.read(appAuthMethodProvider);

  group('rendering', () {
    testWidgets('app method any shows the lock icon and the title', (
      tester,
    ) async {
      await pumpGroup(tester, stored: ForceBiometricOption.any);

      expect(find.text(l10n.authMethodTitle), findsOneWidget);
      expect(trailingIcon(tester), Icons.lock_outline);
    });

    testWidgets('app method biometric shows the fingerprint icon', (
      tester,
    ) async {
      await pumpGroup(tester, stored: ForceBiometricOption.biometric);

      expect(trailingIcon(tester), Icons.fingerprint);
    });

    testWidgets('legacy stored values (none, pin) are shown like any', (
      tester,
    ) async {
      for (final stored in [ForceBiometricOption.none, ForceBiometricOption.pin]) {
        await pumpGroup(tester, stored: stored);
        expect(trailingIcon(tester), Icons.lock_outline, reason: '$stored');
      }
    });

    testWidgets('opening the dialog marks the current method as selected', (
      tester,
    ) async {
      await pumpGroup(tester, stored: ForceBiometricOption.biometric);

      await openDialog(tester);

      final group = tester.widget<RadioGroup<ForceBiometricOption>>(
        find.byType(RadioGroup<ForceBiometricOption>),
      );
      expect(group.groupValue, ForceBiometricOption.biometric);
      verifyNoPrompt();
    });
  });

  group('any -> biometric', () {
    testWidgets('auth granted: setAppAuthMethod(biometric) is called and saved', (
      tester,
    ) async {
      deviceSupportsBiometrics();
      authResult(true);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.any,
      );
      await openDialog(tester);

      await select(tester, l10n.authMethodBiometric);

      expect(settingsNotifier.calls, [ForceBiometricOption.biometric]);
      expect(currentOption(container), ForceBiometricOption.biometric);
      expect(trailingIcon(tester), Icons.fingerprint);
      final saved = verify(settingsRepo.saveSettings(captureAny)).captured;
      expect(
        (saved.single as SettingsState).appAuthMethod,
        ForceBiometricOption.biometric,
      );
    });

    testWidgets('the prompt is biometric-only and uses the change reason', (
      tester,
    ) async {
      deviceSupportsBiometrics();
      authResult(true);
      await pumpGroup(tester, stored: ForceBiometricOption.any);
      await openDialog(tester);

      await select(tester, l10n.authMethodBiometric);

      final captured = verify(
        localAuth.authenticate(
          localizedReason: captureAnyNamed('localizedReason'),
          biometricOnly: captureAnyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).captured;
      expect(captured, [l10n.authMethodChangeReason, true]);
    });

    testWidgets('auth denied: setAppAuthMethod is NOT called, nothing is saved', (
      tester,
    ) async {
      deviceSupportsBiometrics();
      authResult(false);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.any,
      );
      await openDialog(tester);

      await select(tester, l10n.authMethodBiometric);

      verify(
        localAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: true,
          authMessages: anyNamed('authMessages'),
        ),
      ).called(1);
      expect(settingsNotifier.calls, isEmpty);
      verifyNever(settingsRepo.saveSettings(any));
      expect(currentOption(container), ForceBiometricOption.any);
      expect(trailingIcon(tester), Icons.lock_outline);
    });

    testWidgets('no biometrics enrolled: no prompt and no change', (
      tester,
    ) async {
      when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(localAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
      authResult(true);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.any,
      );
      await openDialog(tester);

      await select(tester, l10n.authMethodBiometric);

      verifyNoPrompt();
      expect(settingsNotifier.calls, isEmpty);
      expect(currentOption(container), ForceBiometricOption.any);
    });

    testWidgets('no biometric hardware: no prompt and no change', (
      tester,
    ) async {
      when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(localAuth.canCheckBiometrics).thenAnswer((_) async => false);
      authResult(true);
      await pumpGroup(tester, stored: ForceBiometricOption.any);
      await openDialog(tester);

      await select(tester, l10n.authMethodBiometric);

      verifyNoPrompt();
      expect(settingsNotifier.calls, isEmpty);
    });

    testWidgets('authentication throws: no change', (tester) async {
      deviceSupportsBiometrics();
      when(
        localAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).thenAnswer(
        (_) async => throw LocalAuthException(
          code: LocalAuthExceptionCode.userCanceled,
          description: 'cancelled',
        ),
      );
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.any,
      );
      await openDialog(tester);

      await select(tester, l10n.authMethodBiometric);

      expect(settingsNotifier.calls, isEmpty);
      expect(currentOption(container), ForceBiometricOption.any);
    });
  });

  group('biometric -> any', () {
    testWidgets('auth granted: setAppAuthMethod(any) is called', (tester) async {
      deviceSupportsBiometrics();
      authResult(true);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.biometric,
      );
      await openDialog(tester);

      await select(tester, l10n.authMethodAny);

      expect(settingsNotifier.calls, [ForceBiometricOption.any]);
      expect(currentOption(container), ForceBiometricOption.any);
      expect(trailingIcon(tester), Icons.lock_outline);
    });

    testWidgets(
      'relaxing the setting also requires biometric-only authentication',
      (tester) async {
        deviceSupportsBiometrics();
        authResult(true);
        await pumpGroup(tester, stored: ForceBiometricOption.biometric);
        await openDialog(tester);

        await select(tester, l10n.authMethodAny);

        final captured = verify(
          localAuth.authenticate(
            localizedReason: captureAnyNamed('localizedReason'),
            biometricOnly: captureAnyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).captured;
        expect(captured, [l10n.authMethodChangeReason, true]);
      },
    );

    testWidgets('auth denied: setAppAuthMethod is NOT called', (tester) async {
      deviceSupportsBiometrics();
      authResult(false);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.biometric,
      );
      await openDialog(tester);

      await select(tester, l10n.authMethodAny);

      verify(
        localAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: true,
          authMessages: anyNamed('authMessages'),
        ),
      ).called(1);
      expect(settingsNotifier.calls, isEmpty);
      verifyNever(settingsRepo.saveSettings(any));
      expect(currentOption(container), ForceBiometricOption.biometric);
      expect(trailingIcon(tester), Icons.fingerprint);
    });

    testWidgets(
      'biometrics were removed from the device: the setting can not be relaxed '
      '(characterization, the user is locked into biometric)',
      (tester) async {
        when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(localAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
        authResult(true);
        final container = await pumpGroup(
          tester,
          stored: ForceBiometricOption.biometric,
        );
        await openDialog(tester);

        await select(tester, l10n.authMethodAny);

        verifyNoPrompt();
        expect(settingsNotifier.calls, isEmpty);
        expect(currentOption(container), ForceBiometricOption.biometric);
      },
    );
  });

  group('no-op and cancel', () {
    testWidgets('selecting the current method does nothing', (tester) async {
      deviceSupportsBiometrics();
      authResult(true);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.biometric,
      );
      await openDialog(tester);

      await select(tester, l10n.authMethodBiometric);
      await expectDialogStaysOpenThenCancel(tester);

      verifyNoPrompt();
      expect(settingsNotifier.calls, isEmpty);
      verifyNever(settingsRepo.saveSettings(any));
      expect(currentOption(container), ForceBiometricOption.biometric);
    });

    testWidgets('selecting any while any is current does nothing', (
      tester,
    ) async {
      deviceSupportsBiometrics();
      authResult(true);
      await pumpGroup(tester, stored: ForceBiometricOption.any);
      await openDialog(tester);

      await select(tester, l10n.authMethodAny);
      await expectDialogStaysOpenThenCancel(tester);

      verifyNoPrompt();
      expect(settingsNotifier.calls, isEmpty);
    });

    testWidgets(
      'stored legacy pin is normalized to any: selecting any is a no-op',
      (tester) async {
        deviceSupportsBiometrics();
        authResult(true);
        await pumpGroup(tester, stored: ForceBiometricOption.pin);
        await openDialog(tester);

        await select(tester, l10n.authMethodAny);
        await expectDialogStaysOpenThenCancel(tester);

        verifyNoPrompt();
        expect(settingsNotifier.calls, isEmpty);
        verifyNever(settingsRepo.saveSettings(any));
      },
    );

    testWidgets(
      'stored legacy pin: switching to biometric asks for biometric authentication',
      (tester) async {
        deviceSupportsBiometrics();
        authResult(true);
        await pumpGroup(tester, stored: ForceBiometricOption.pin);
        await openDialog(tester);

        await select(tester, l10n.authMethodBiometric);

        expect(settingsNotifier.calls, [ForceBiometricOption.biometric]);
        verify(
          localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: true,
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      },
    );

    testWidgets('cancel button closes the dialog without any effect', (
      tester,
    ) async {
      deviceSupportsBiometrics();
      authResult(true);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.any,
      );
      await openDialog(tester);

      await select(tester, l10n.cancel);

      expect(find.text(l10n.authMethodBiometric), findsNothing);
      verifyNoPrompt();
      verifyNever(localAuth.isDeviceSupported());
      expect(settingsNotifier.calls, isEmpty);
      verifyNever(settingsRepo.saveSettings(any));
      expect(currentOption(container), ForceBiometricOption.any);
    });

    testWidgets('dismissing the dialog by tapping the barrier does nothing', (
      tester,
    ) async {
      deviceSupportsBiometrics();
      authResult(true);
      await pumpGroup(tester, stored: ForceBiometricOption.biometric);
      await openDialog(tester);

      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();

      expect(find.text(l10n.authMethodAny), findsNothing);
      verifyNoPrompt();
      expect(settingsNotifier.calls, isEmpty);
    });
  });

  group('lifecycle', () {
    testWidgets(
      'view disposed while the authentication is pending: result is ignored, no change',
      (tester) async {
        deviceSupportsBiometrics();
        final authCompleter = Completer<bool>();
        when(
          localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) => authCompleter.future);
        final container = await pumpGroup(
          tester,
          stored: ForceBiometricOption.any,
        );
        await openDialog(tester);

        await tester.tap(find.text(l10n.authMethodBiometric));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        // The settings page is closed while the OS prompt is still open.
        await tester.pumpWidget(const SizedBox.shrink());
        authCompleter.complete(true);
        await tester.pump();
        await tester.pump();

        expect(settingsNotifier.calls, isEmpty);
        expect(currentOption(container), ForceBiometricOption.any);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('a second change works after a denied one', (tester) async {
      deviceSupportsBiometrics();
      authResult(false);
      final container = await pumpGroup(
        tester,
        stored: ForceBiometricOption.any,
      );
      await openDialog(tester);
      await select(tester, l10n.authMethodBiometric);
      expect(settingsNotifier.calls, isEmpty);

      authResult(true);
      await openDialog(tester);
      await select(tester, l10n.authMethodBiometric);

      expect(settingsNotifier.calls, [ForceBiometricOption.biometric]);
      expect(currentOption(container), ForceBiometricOption.biometric);
    });
  });
}
