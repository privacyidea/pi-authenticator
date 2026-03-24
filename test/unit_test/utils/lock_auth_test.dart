import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';

import 'lock_auth_test.mocks.dart';

@GenerateMocks([LocalAuthentication])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication mockLocalAuth;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    localAuthInstance = mockLocalAuth; // override Local instance for testing
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
      'should return autoAuthIfUnsupported value if hardware is missing',
      () async {
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        final result = await lockAuth(
          reason: (loc) => 'reason',
          localization: AppLocalizationsEn(),
          autoAuthIfUnsupported: true,
        );

        expect(result, isTrue);
        verifyNever(
          mockLocalAuth.authenticate(
            localizedReason: anyNamed('localizedReason'),
            biometricOnly: anyNamed('biometricOnly'),
          ),
        );
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
