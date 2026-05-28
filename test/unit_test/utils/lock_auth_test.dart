import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication mockLocalAuth;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    localAuthInstance = mockLocalAuth; // override Local instance for testing
    resetAuthMutex();
  });

  group('lockAuth - Basic Flow', () {
    test('should return true when authentication succeeds', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(
        mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).thenAnswer((_) async => true);

      final result = await lockAuth(
        reason: (loc) => 'reason',
        localization: AppLocalizationsEn(),
      );

      expect(result, isTrue);
    });

    test(
      'should return false when authentication is canceled by user',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => false);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
        );

        expect(result, isFalse);
      },
    );
  });

  group('lockAuth - Hardware & Support', () {
    test(
      'should skip support checks and attempt auth when autoAuthIfUnsupported is true',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => true);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          autoAuthIfUnsupported: true,
        );

        expect(result, isTrue);
        verify(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      },
    );

    test(
      'should return false if biometric is forced but sensor is missing',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          forceBiometricOption: ForceBiometricOption.biometric,
        );

        expect(result, isFalse);
      },
    );

    test(
      'should return false if biometric is forced but none are enrolled',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          mockLocalAuth.getAvailableBiometrics(),
        ).thenAnswer((_) async => []);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          forceBiometricOption: ForceBiometricOption.biometric,
        );

        expect(result, isFalse);
      },
    );

    test(
      'should succeed when biometric is forced and biometrics are enrolled',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          mockLocalAuth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.fingerprint]);
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => true);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          forceBiometricOption: ForceBiometricOption.biometric,
        );

        expect(result, isTrue);
        verify(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: true,
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      },
    );

    test(
      'should skip support checks when autoAuth is true, even if device unsupported',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => false);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          autoAuthIfUnsupported: true,
        );

        // autoAuth=true skips _checkSupport, so authenticate is called
        // but authenticate returns false, so result is false
        expect(result, isFalse);
        verify(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      },
    );

    test(
      'should return false when device unsupported and autoAuth is false',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
        );

        expect(result, isFalse);
      },
    );
  });

  group('lockAuth - Concurrency & Exceptions', () {
    test('should handle LocalAuthException userCanceled gracefully', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(
        mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).thenThrow(
        LocalAuthException(
          code: LocalAuthExceptionCode.userCanceled,
          description: 'User canceled authentication',
        ),
      );

      final result = await lockAuth(
        reason: (loc) => 'reason',
        localization: AppLocalizationsEn(),
      );

      expect(result, isFalse);
    });

    test('should handle non-userCanceled exceptions gracefully', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(
        mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).thenThrow(Exception('Unknown auth error'));

      final result = await lockAuth(
        reason: (loc) => 'reason',
        localization: AppLocalizationsEn(),
      );

      expect(result, isFalse);
    });

    test(
      'lockAuthWithSettingsRef merges app setting and forces biometricOnly when app setting is biometric',
      () async {
        final ref = await _refWithAppAuthMethod(ForceBiometricOption.biometric);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          mockLocalAuth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.fingerprint]);
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => true);

        final result = await lockAuthWithSettingsRef(
          ref: ref,
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          // Token says "any"; app setting (biometric) should win.
        );

        expect(result, isTrue);
        verify(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: true,
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      },
    );

    test(
      'lockAuthWithSettingsRef does not force biometric when app setting is any and token is none',
      () async {
        final ref = await _refWithAppAuthMethod(ForceBiometricOption.any);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => true);

        final result = await lockAuthWithSettingsRef(
          ref: ref,
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
        );

        expect(result, isTrue);
        verify(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      },
    );

    test(
      'lockAuthWithSettingsRef uses token-level biometric even when app setting is any',
      () async {
        final ref = await _refWithAppAuthMethod(ForceBiometricOption.any);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          mockLocalAuth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.fingerprint]);
        when(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => true);

        final result = await lockAuthWithSettingsRef(
          ref: ref,
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          forceBiometricOption: ForceBiometricOption.biometric,
        );

        expect(result, isTrue);
        verify(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: true,
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      },
    );

    test('should prevent concurrent calls using the mutex', () async {
      when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(
        mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      });

      final firstCall = lockAuth(
        reason: (loc) => 'first',
        localization: AppLocalizationsEn(),
      );
      final secondCall = lockAuth(
        reason: (loc) => 'second',
        localization: AppLocalizationsEn(),
      );

      final results = await Future.wait([firstCall, secondCall]);

      expect(results[0], isTrue);
      expect(results[1], isFalse); // Second call should be blocked by mutex
      verify(
        mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).called(1);
    });
  });
}

/// Builds a Riverpod container with [settingsProvider] overridden so that
/// [appAuthMethodProvider] resolves to [appAuthMethod], and returns a real
/// `Ref` captured from a probe provider so [lockAuthWithSettingsRef] can be
/// exercised end-to-end.
Future<Ref> _refWithAppAuthMethod(ForceBiometricOption appAuthMethod) async {
  final mockRepo = MockSettingsRepository();
  when(
    mockRepo.loadSettings(),
  ).thenAnswer((_) async => SettingsState(appAuthMethod: appAuthMethod));
  when(mockRepo.saveSettings(any)).thenAnswer((_) async => true);

  late Ref captured;
  final probe = Provider<int>((ref) {
    captured = ref;
    return 0;
  });

  final container = ProviderContainer(
    overrides: [
      settingsProvider.overrideWith(
        () => SettingsNotifier(repoOverride: mockRepo),
      ),
    ],
  );
  container.read(probe);
  // Ensure settingsProvider is materialized so the .select read returns the
  // overridden value rather than the default.
  await container.read(settingsProvider.future);
  return captured;
}
