import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
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
        reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
        reason: (localization) => 'reason',
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
        reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
          reason: (localization) => 'reason',
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
        reason: (localization) => 'first',
        localization: AppLocalizationsEn(),
      );
      final secondCall = lockAuth(
        reason: (localization) => 'second',
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

  _testLockAuthMore();
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

/// Additional tests for `lockAuth`, complementing the tests in `main`.
void _testLockAuthMore() {
  group('lockAuth additional tests', () {
    late MockLocalAuthentication localAuth;
    final l10n = AppLocalizationsEn();

    setUp(() {
      localAuth = MockLocalAuthentication();
      localAuthInstance = localAuth;
      resetAuthMutex();
    });

    tearDown(() {
      localAuthInstance = LocalAuthentication();
      resetAuthMutex();
    });

    void stubAuth(bool result) {
      when(
        localAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      ).thenAnswer((_) async => result);
    }

    void stubSupported({bool biometrics = false}) {
      when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      if (biometrics) {
        when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          localAuth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.fingerprint]);
      }
    }

    void verifyAuthenticateNeverCalled() {
      verifyNever(
        localAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          biometricOnly: anyNamed('biometricOnly'),
          authMessages: anyNamed('authMessages'),
        ),
      );
    }

    Future<bool> callLockAuth({
      ForceBiometricOption? option,
      bool autoAuth = false,
    }) => lockAuth(
      reason: (l) => 'reason',
      localization: l10n,
      forceBiometricOption: option,
      autoAuthIfUnsupported: autoAuth,
    );

    group('lockAuth - support check throws (suspected bug)', () {
      // lockAuth's own doc: "Returns true if authentication succeeds". The
      // authenticate call is wrapped in try/catch (_executeAuth) and returns
      // false on any exception, but _checkSupport is not, so a platform
      // exception while querying the capabilities escapes lockAuth.
      test(
        'isDeviceSupported throws -> lockAuth returns false instead of throwing',
        () async {
          when(
            localAuth.isDeviceSupported(),
          ).thenAnswer((_) async => throw Exception('platform channel error'));

          final result = await callLockAuth();

          expect(result, isFalse);
          verifyAuthenticateNeverCalled();
        },
        skip:
            'BUG: lock_auth.dart:72 _checkSupport runs outside try/catch, so an exception from isDeviceSupported escapes lockAuth',
      );

      test(
        'canCheckBiometrics throws (biometric forced) -> returns false instead of throwing',
        () async {
          when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
          when(
            localAuth.canCheckBiometrics,
          ).thenAnswer((_) async => throw Exception('platform channel error'));

          final result = await callLockAuth(option: ForceBiometricOption.biometric);

          expect(result, isFalse);
          verifyAuthenticateNeverCalled();
        },
        skip:
            'BUG: lock_auth.dart:72 _checkSupport runs outside try/catch, so an exception from canCheckBiometrics escapes lockAuth',
      );

      test(
        'getAvailableBiometrics throws (biometric forced) -> returns false instead of throwing',
        () async {
          when(localAuth.isDeviceSupported()).thenAnswer((_) async => true);
          when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
          when(
            localAuth.getAvailableBiometrics(),
          ).thenAnswer((_) async => throw Exception('platform channel error'));

          final result = await callLockAuth(option: ForceBiometricOption.biometric);

          expect(result, isFalse);
          verifyAuthenticateNeverCalled();
        },
        skip:
            'BUG: lock_auth.dart:72 _checkSupport runs outside try/catch, so an exception from getAvailableBiometrics escapes lockAuth',
      );

      test(
        'the mutex is released after a support check exception, the next call works',
        () async {
          when(
            localAuth.isDeviceSupported(),
          ).thenAnswer((_) async => throw Exception('platform channel error'));
          // Whether lockAuth throws or returns false is covered by the tests
          // above, here only the lock handling matters.
          try {
            await callLockAuth();
          } catch (_) {}

          stubSupported();
          stubAuth(true);
          final second = await callLockAuth();

          expect(second, isTrue);
        },
      );
    });

    group('lockAuth - biometric forced, requirements not met', () {
      test(
        'only a PIN/pattern is enrolled (no biometrics): false and authenticate is never called',
        () async {
          stubSupported();
          when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
          when(localAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
          stubAuth(true);

          final result = await callLockAuth(option: ForceBiometricOption.biometric);

          expect(result, isFalse);
          verify(localAuth.getAvailableBiometrics()).called(1);
          verifyAuthenticateNeverCalled();
        },
      );

      test(
        'no biometric hardware: false, enrolled biometrics are not queried, authenticate is never called',
        () async {
          stubSupported();
          when(localAuth.canCheckBiometrics).thenAnswer((_) async => false);
          stubAuth(true);

          final result = await callLockAuth(option: ForceBiometricOption.biometric);

          expect(result, isFalse);
          verifyNever(localAuth.getAvailableBiometrics());
          verifyAuthenticateNeverCalled();
        },
      );

      test(
        'isDeviceSupported false although biometrics are enrolled: false and authenticate is never called',
        () async {
          when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
          when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
          when(
            localAuth.getAvailableBiometrics(),
          ).thenAnswer((_) async => [BiometricType.face]);
          stubAuth(true);

          final result = await callLockAuth(option: ForceBiometricOption.biometric);

          expect(result, isFalse);
          verifyAuthenticateNeverCalled();
        },
      );

      test(
        'isDeviceSupported false and no biometric hardware: false and authenticate is never called',
        () async {
          when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
          when(localAuth.canCheckBiometrics).thenAnswer((_) async => false);
          stubAuth(true);

          final result = await callLockAuth(option: ForceBiometricOption.biometric);

          expect(result, isFalse);
          verifyAuthenticateNeverCalled();
        },
      );

      test('a failed requirement does not leave the mutex locked', () async {
        stubSupported();
        when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(localAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
        stubAuth(true);
        expect(
          await callLockAuth(option: ForceBiometricOption.biometric),
          isFalse,
        );

        // Biometrics get enrolled afterwards.
        when(
          localAuth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.fingerprint]);

        expect(
          await callLockAuth(option: ForceBiometricOption.biometric),
          isTrue,
        );
      });
    });

    group('lockAuth - ForceBiometricOption mapping', () {
      for (final option in <ForceBiometricOption?>[
        null,
        ForceBiometricOption.none,
        ForceBiometricOption.any,
        ForceBiometricOption.pin,
      ]) {
        test(
          'option $option is not biometric-only and does not query biometrics',
          () async {
            stubSupported();
            stubAuth(true);

            final result = await callLockAuth(option: option);

            expect(result, isTrue);
            verify(
              localAuth.authenticate(
                localizedReason: anyNamed('localizedReason'),
                authMessages: anyNamed('authMessages'),
              ),
            ).called(1);
            verifyNever(localAuth.canCheckBiometrics);
            verifyNever(localAuth.getAvailableBiometrics());
          },
        );
      }

      test(
        'ForceBiometricOption.pin is treated like any: device credentials, biometrics both allowed '
        '(local_auth has no PIN-only mode)',
        () async {
          stubSupported();
          stubAuth(true);
          await callLockAuth(option: ForceBiometricOption.pin);
          final pinCall = verify(
            localAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              biometricOnly: captureAnyNamed('biometricOnly'),
              authMessages: anyNamed('authMessages'),
            ),
          ).captured.single;

          resetAuthMutex();
          await callLockAuth(option: ForceBiometricOption.any);
          final anyCall = verify(
            localAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              biometricOnly: captureAnyNamed('biometricOnly'),
              authMessages: anyNamed('authMessages'),
            ),
          ).captured.single;

          expect(pinCall, anyCall);
          expect(pinCall, isFalse);
        },
      );

      test(
        'unsupported device with option pin: false, nothing is authenticated',
        () async {
          when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
          stubAuth(true);

          final result = await callLockAuth(option: ForceBiometricOption.pin);

          expect(result, isFalse);
          verifyAuthenticateNeverCalled();
        },
      );

      test('biometric option passes biometricOnly: true', () async {
        stubSupported(biometrics: true);
        stubAuth(true);

        expect(await callLockAuth(option: ForceBiometricOption.biometric), isTrue);

        verify(
          localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: true,
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      });
    });

    group('lockAuth - autoAuthIfUnsupported semantics', () {
      test(
        'doc: unsupported device + autoAuthIfUnsupported returns true without prompting',
        () async {
          // Real device without a screen lock: the OS refuses to authenticate.
          when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
          when(localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          )).thenAnswer(
            (_) async => throw LocalAuthException(
              code: LocalAuthExceptionCode.noCredentialsSet,
              description: 'No credentials set',
            ),
          );

          final result = await callLockAuth(autoAuth: true);

          expect(result, isTrue);
          verifyAuthenticateNeverCalled();
        },
        skip:
            'BUG: lock_auth.dart:72-73,117 autoAuthIfUnsupported skips the support check instead of using it, so an unsupported device is still prompted and denied (doc says returns true)',
      );

      test(
        'supported device + autoAuthIfUnsupported still requires a successful authentication',
        () async {
          stubSupported();
          stubAuth(false);

          final result = await callLockAuth(autoAuth: true);

          expect(result, isFalse);
          verify(
            localAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              biometricOnly: anyNamed('biometricOnly'),
              authMessages: anyNamed('authMessages'),
            ),
          ).called(1);
        },
      );

      test(
        'supported device + autoAuthIfUnsupported + successful authentication returns true',
        () async {
          stubSupported();
          stubAuth(true);

          expect(await callLockAuth(autoAuth: true), isTrue);
        },
      );

      test(
        'autoAuthIfUnsupported never reaches the "unsupported" branch (return autoAuth is dead code): '
        'a failing authenticate yields false',
        () async {
          // Characterization: with autoAuth=true _checkSupport always returns
          // true, so `return autoAuthIfUnsupported` at line 73 can only ever
          // return false.
          when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
          stubAuth(false);

          expect(await callLockAuth(autoAuth: true), isFalse);
        },
      );

      test('autoAuthIfUnsupported does not query device support at all', () async {
        // Characterization of the current behaviour. It is the root of the
        // suspected autoAuthIfUnsupported bug above.
        stubAuth(true);

        await callLockAuth(autoAuth: true);

        verifyNever(localAuth.isDeviceSupported());
        verifyNever(localAuth.canCheckBiometrics);
      });
    });

    group('lockAuth - mutex is released', () {
      test('after the user cancelled (LocalAuthException userCanceled)', () async {
        stubSupported();
        when(
          localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer(
          (_) async => throw LocalAuthException(
            code: LocalAuthExceptionCode.userCanceled,
            description: 'canceled',
          ),
        );
        expect(await callLockAuth(), isFalse);

        stubAuth(true);
        expect(await callLockAuth(), isTrue);
      });

      test('after an unexpected authenticate exception', () async {
        stubSupported();
        when(
          localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: anyNamed('authMessages'),
          ),
        ).thenAnswer((_) async => throw StateError('boom'));
        expect(await callLockAuth(), isFalse);

        stubAuth(true);
        expect(await callLockAuth(), isTrue);
      });

      test('after authenticate returned false', () async {
        stubSupported();
        stubAuth(false);
        expect(await callLockAuth(), isFalse);

        stubAuth(true);
        expect(await callLockAuth(), isTrue);
      });

      test('after an unsupported device', () async {
        when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
        expect(await callLockAuth(), isFalse);

        stubSupported();
        stubAuth(true);
        expect(await callLockAuth(), isTrue);
      });

      test(
        'a rejected concurrent call neither runs the support check nor frees the lock early',
        () async {
          stubSupported();
          when(
            localAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              biometricOnly: anyNamed('biometricOnly'),
              authMessages: anyNamed('authMessages'),
            ),
          ).thenAnswer((_) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return true;
          });

          final first = callLockAuth();
          final second = callLockAuth();
          final third = callLockAuth();
          final results = await Future.wait([first, second, third]);

          expect(results, [true, false, false]);
          verify(localAuth.isDeviceSupported()).called(1);

          // The lock is free again after the first call finished.
          expect(await callLockAuth(), isTrue);
        },
      );
    });

    group('lockAuth - reason and messages', () {
      test('the localized reason and localized messages reach authenticate', () async {
        stubSupported();
        stubAuth(true);

        await lockAuth(
          reason: (l) => 'Please: ${l.cancel}',
          localization: l10n,
        );

        final captured = verify(
          localAuth.authenticate(
            localizedReason: captureAnyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
            authMessages: captureAnyNamed('authMessages'),
          ),
        ).captured;
        expect(captured[0], 'Please: ${l10n.cancel}');
        final messages = (captured[1] as Iterable).toList();
        final android = messages.whereType<AndroidAuthMessages>().single;
        final ios = messages.whereType<IOSAuthMessages>().single;
        expect(android.signInTitle, l10n.signInTitle);
        expect(android.cancelButton, l10n.cancel);
        expect(ios.cancelButton, l10n.cancel);
      });

      test('the reason is not evaluated when the support check fails', () async {
        when(localAuth.isDeviceSupported()).thenAnswer((_) async => false);
        var evaluated = false;

        await lockAuth(
          reason: (l) {
            evaluated = true;
            return 'r';
          },
          localization: l10n,
        );

        expect(evaluated, isFalse);
      });
    });

    group('lockAuthWithSettingsRef - merging', () {
      Future<Ref> refWith(ForceBiometricOption appAuthMethod) async {
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
        addTearDown(container.dispose);
        container.read(probe);
        await container.read(settingsProvider.future);
        return captured;
      }

      test(
        'token biometric + app biometric: biometric-only, support is checked',
        () async {
          final ref = await refWith(ForceBiometricOption.biometric);
          stubSupported(biometrics: true);
          stubAuth(true);

          final result = await lockAuthWithSettingsRef(
            ref: ref,
            reason: (l) => 'r',
            localization: l10n,
            forceBiometricOption: ForceBiometricOption.biometric,
          );

          expect(result, isTrue);
          verify(
            localAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              biometricOnly: true,
              authMessages: anyNamed('authMessages'),
            ),
          ).called(1);
        },
      );

      test(
        'token pin + app biometric: conflict resolves to biometric-only',
        () async {
          final ref = await refWith(ForceBiometricOption.biometric);
          stubSupported(biometrics: true);
          stubAuth(true);

          final result = await lockAuthWithSettingsRef(
            ref: ref,
            reason: (l) => 'r',
            localization: l10n,
            forceBiometricOption: ForceBiometricOption.pin,
          );

          expect(result, isTrue);
          verify(
            localAuth.authenticate(
              localizedReason: anyNamed('localizedReason'),
              biometricOnly: true,
              authMessages: anyNamed('authMessages'),
            ),
          ).called(1);
        },
      );

      test('token pin + app any: not biometric-only', () async {
        final ref = await refWith(ForceBiometricOption.any);
        stubSupported();
        stubAuth(true);

        await lockAuthWithSettingsRef(
          ref: ref,
          reason: (l) => 'r',
          localization: l10n,
          forceBiometricOption: ForceBiometricOption.pin,
        );

        verify(
          localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
        verifyNever(localAuth.getAvailableBiometrics());
      });

      test(
        'app biometric but no biometric enrolled: false, authenticate never called',
        () async {
          final ref = await refWith(ForceBiometricOption.biometric);
          stubSupported();
          when(localAuth.canCheckBiometrics).thenAnswer((_) async => true);
          when(localAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
          stubAuth(true);

          final result = await lockAuthWithSettingsRef(
            ref: ref,
            reason: (l) => 'r',
            localization: l10n,
          );

          expect(result, isFalse);
          verifyAuthenticateNeverCalled();
        },
      );

      test('autoAuthIfUnsupported is forwarded', () async {
        final ref = await refWith(ForceBiometricOption.any);
        stubAuth(true);

        final result = await lockAuthWithSettingsRef(
          ref: ref,
          reason: (l) => 'r',
          localization: l10n,
          autoAuthIfUnsupported: true,
        );

        expect(result, isTrue);
        // autoAuthIfUnsupported skips the support check, so it was not queried.
        verifyNever(localAuth.isDeviceSupported());
      });
    });

    group('lockAuthWithSettings (WidgetRef)', () {
      testWidgets('merges the app-wide biometric setting into the request', (
        tester,
      ) async {
        final mockRepo = MockSettingsRepository();
        when(mockRepo.loadSettings()).thenAnswer(
          (_) async =>
              SettingsState(appAuthMethod: ForceBiometricOption.biometric),
        );
        when(mockRepo.saveSettings(any)).thenAnswer((_) async => true);
        stubSupported(biometrics: true);
        stubAuth(true);

        late WidgetRef widgetRef;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsProvider.overrideWith(
                () => SettingsNotifier(repoOverride: mockRepo),
              ),
            ],
            child: MaterialApp(
              home: Consumer(
                builder: (context, ref, _) {
                  widgetRef = ref;
                  // Watching materializes the settings.
                  ref.watch(appAuthMethodProvider);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        final result = await lockAuthWithSettings(
          ref: widgetRef,
          reason: (l) => 'r',
          localization: l10n,
        );

        expect(result, isTrue);
        verify(
          localAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: true,
            authMessages: anyNamed('authMessages'),
          ),
        ).called(1);
      });
    });
  });
}
