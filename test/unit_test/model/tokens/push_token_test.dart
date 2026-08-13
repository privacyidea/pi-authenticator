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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/push_token_rollout_state.dart';
import 'package:privacyidea_authenticator/model/enums/biometric_push_key_status.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/push_app_biometric_level.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_argument_error.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

void main() {
  group('PushToken - Every Corner Suite', () {
    const String testSerial = 'PUSH123456';
    const String testId = 'push-id-999';
    final Uri testUrl = Uri.parse('https://example.com/rollout');

    PushToken createPush({
      PushTokenRollOutState? rolloutState,
      bool? isRolledOut,
      bool? sslVerify,
    }) => PushToken(
      serial: testSerial,
      id: testId,
      url: testUrl,
      rolloutState: rolloutState,
      isRolledOut: isRolledOut,
      sslVerify: sslVerify,
      label: 'Push',
      issuer: 'PI',
    );

    test('Rollout State mapping in fromJson factory', () {
      final statesToTest = {
        'generatingRSAKeyPair':
            PushTokenRollOutState.generatingRSAKeyPairFailed,
        'receivingFirebaseToken':
            PushTokenRollOutState.receivingFirebaseTokenFailed,
        'sendRSAPublicKey': PushTokenRollOutState.sendRSAPublicKeyFailed,
        'parsingResponse': PushTokenRollOutState.parsingResponseFailed,
        'rolloutComplete': PushTokenRollOutState.rolloutComplete,
      };

      for (var entry in statesToTest.entries) {
        final json = {
          'id': testId,
          'type': 'PIPUSH',
          'serial': testSerial,
          'rolloutState': entry.key,
        };
        final token = PushToken.fromJson(json);
        expect(
          token.rolloutState,
          entry.value,
          reason: 'Failed for ${entry.key}',
        );
      }
    });

    test('fromOtpAuthMap enforces piauth version 1', () {
      final map = {
        PushToken.VERSION: '2',
        Token.SERIAL: testSerial,
        PushToken.ROLLOUT_URL: testUrl.toString(),
        Token.LABEL: 'L',
        Token.ISSUER: 'I',
      };
      expect(
        () => PushToken.fromOtpAuthMap(map),
        throwsA(isA<LocalizedArgumentError>()),
      );
    });

    test('RSA Public/Private key getter null safety', () {
      final token = createPush();
      expect(token.rsaPublicServerKey, isNull);
      expect(token.rsaPublicTokenKey, isNull);
      expect(token.rsaPrivateTokenKey, isNull);
    });

    test('Identity check (isSameTokenAs) corner cases', () {
      final t1 = createPush().copyWith(publicServerKey: 'KEY_A');
      final t2 = createPush().copyWith(publicServerKey: 'KEY_A');
      final t3 = createPush().copyWith(publicServerKey: 'KEY_B');

      expect(t1.isSameTokenAs(t2), isTrue);
      expect(t1.isSameTokenAs(t3), isFalse);
    });

    test('toOtpAuthMap transforms booleans to 1/0 and True/False strings', () {
      final token = createPush(
        sslVerify: true,
      ).copyWith(isPollOnly: () => true);
      final map = token.toOtpAuthMap();
      expect(map[PushToken.SSL_VERIFY], '1');
      expect(map[PushToken.IS_POLL_ONLY], 'True');
      expect(map[PushToken.VERSION], '1');
    });

    test('isHidden is constant false for PushToken', () {
      final token = createPush().copyWith(isHidden: true);
      expect(token.isHidden, isFalse);
    });

    test('biometric key status survives JSON persistence', () {
      final protected = createPush().copyWith(
        privateTokenKey: () => null,
        biometricKeyStatus: BiometricPushKeyStatus.protected,
      );

      final restored = PushToken.fromJson(protected.toJson());

      expect(restored.privateTokenKey, isNull);
      expect(restored.biometricKeyStatus, BiometricPushKeyStatus.protected);
    });

    test('old JSON defaults biometric key status to unprotected', () {
      final restored = PushToken.fromJson({
        'id': testId,
        'type': 'PIPUSH',
        'serial': testSerial,
      });

      expect(restored.biometricKeyStatus, BiometricPushKeyStatus.unprotected);
    });

    test('missing biometric policy fields fail closed for biometric Push', () {
      final restored = PushToken.fromJson({
        'id': testId,
        'type': 'PIPUSH',
        'serial': testSerial,
        'forceBiometricOption': 'biometric',
      });

      expect(restored.biometricLevel, PushAppBiometricLevel.strong);
      expect(restored.invalidateOnBiometricChange, isTrue);
      expect(restored.requiresBiometricKeyProtection, isTrue);
    });

    test('accepts future server policy aliases from a Push enrollment URL', () {
      final enrollmentMap =
          createPush()
              .copyWith(forceBiometricOption: ForceBiometricOption.biometric)
              .toOtpAuthMap()
            ..remove(PushToken.APP_BIOMETRIC_LEVEL)
            ..remove(PushToken.APP_INVALIDATE_ON_BIOMETRIC_CHANGE)
            ..[PushToken.PUSH_APP_BIOMETRIC_LEVEL] = 'any'
            ..[PushToken.PUSH_APP_INVALIDATE_ON_BIOMETRIC_CHANGE] = 'false';

      final restored = PushToken.fromOtpAuthMap(enrollmentMap);

      expect(restored.biometricLevel, PushAppBiometricLevel.any);
      expect(restored.invalidateOnBiometricChange, isFalse);
      expect(restored.requiresBiometricKeyProtection, isFalse);
    });

    test('server policy aliases override stale app policy aliases', () {
      final enrollmentMap =
          createPush()
              .copyWith(forceBiometricOption: ForceBiometricOption.biometric)
              .toOtpAuthMap()
            ..[PushToken.APP_BIOMETRIC_LEVEL] = 'any'
            ..[PushToken.APP_INVALIDATE_ON_BIOMETRIC_CHANGE] = 'false'
            ..[PushToken.PUSH_APP_BIOMETRIC_LEVEL] = 'strong'
            ..[PushToken.PUSH_APP_INVALIDATE_ON_BIOMETRIC_CHANGE] = 'true';

      final restored = PushToken.fromOtpAuthMap(enrollmentMap);

      expect(restored.biometricLevel, PushAppBiometricLevel.strong);
      expect(restored.invalidateOnBiometricChange, isTrue);
    });

    test('invalidation binding upgrades Android any to strong', () {
      final token = PushToken(
        serial: testSerial,
        id: testId,
        forceBiometricOption: ForceBiometricOption.biometric,
        biometricLevel: PushAppBiometricLevel.any,
        invalidateOnBiometricChange: true,
      );

      expect(token.requiresStrongBiometric, isTrue);
      expect(token.requiresBiometricKeyProtection, isTrue);
    });

    test('a protected key remains native after policy relaxation', () {
      final protected = createPush().copyWith(
        forceBiometricOption: ForceBiometricOption.biometric,
        biometricLevel: PushAppBiometricLevel.strong,
        invalidateOnBiometricChange: false,
        biometricKeyStatus: BiometricPushKeyStatus.protected,
      );
      final policy = protected.toOtpAuthMap()
        ..[PushToken.APP_BIOMETRIC_LEVEL] = 'any'
        ..[PushToken.APP_INVALIDATE_ON_BIOMETRIC_CHANGE] = 'false';

      final updated =
          protected.copyUpdateByTemplate(
                TokenTemplate.withSerial(
                  otpAuthMap: policy,
                  serial: testSerial,
                ),
              )
              as PushToken;

      expect(updated.biometricLevel, PushAppBiometricLevel.any);
      expect(updated.invalidateOnBiometricChange, isFalse);
      expect(updated.biometricKeyStatus, BiometricPushKeyStatus.protected);
      expect(updated.requiresStrongBiometric, isFalse);
      expect(updated.requiresBiometricKeyProtection, isTrue);
    });

    test(
      'tightening enrollment binding invalidates an existing native key',
      () {
        final protectedWithoutBinding = createPush().copyWith(
          forceBiometricOption: ForceBiometricOption.biometric,
          biometricLevel: PushAppBiometricLevel.strong,
          invalidateOnBiometricChange: false,
          biometricKeyStatus: BiometricPushKeyStatus.protected,
        );
        final policy = protectedWithoutBinding.toOtpAuthMap()
          ..[PushToken.APP_INVALIDATE_ON_BIOMETRIC_CHANGE] = 'true';

        final updated =
            protectedWithoutBinding.copyUpdateByTemplate(
                  TokenTemplate.withSerial(
                    otpAuthMap: policy,
                    serial: testSerial,
                  ),
                )
                as PushToken;

        expect(updated.invalidateOnBiometricChange, isTrue);
        expect(updated.biometricKeyStatus, BiometricPushKeyStatus.invalidated);
        expect(updated.privateTokenKey, isNull);
      },
    );

    test('tightening protection keeps an enrollment key before rollout', () {
      final before = createPush().copyWith(
        forceBiometricOption: ForceBiometricOption.biometric,
        biometricLevel: PushAppBiometricLevel.any,
        invalidateOnBiometricChange: false,
        privateTokenKey: () => 'legacy-private-key',
      );
      final policy = before.toOtpAuthMap()
        ..[PushToken.PUSH_APP_BIOMETRIC_LEVEL] = 'strong'
        ..[PushToken.PUSH_APP_INVALIDATE_ON_BIOMETRIC_CHANGE] = 'true';

      final updated =
          before.copyUpdateByTemplate(
                TokenTemplate.withSerial(
                  otpAuthMap: policy,
                  serial: testSerial,
                ),
              )
              as PushToken;

      expect(updated.invalidateOnBiometricChange, isTrue);
      expect(updated.biometricKeyStatus, BiometricPushKeyStatus.unprotected);
      expect(updated.privateTokenKey, 'legacy-private-key');
      expect(updated.requiresBiometricKeyProtection, isTrue);
    });

    test('tightening protection invalidates a deployed plaintext key', () {
      final before = createPush().copyWith(
        forceBiometricOption: ForceBiometricOption.biometric,
        biometricLevel: PushAppBiometricLevel.any,
        invalidateOnBiometricChange: false,
        privateTokenKey: () => 'legacy-private-key',
        isRolledOut: true,
        rolloutState: PushTokenRollOutState.rolloutComplete,
      );
      final policy = before.toOtpAuthMap()
        ..[PushToken.PUSH_APP_BIOMETRIC_LEVEL] = 'strong'
        ..[PushToken.PUSH_APP_INVALIDATE_ON_BIOMETRIC_CHANGE] = 'false';

      final updated =
          before.copyUpdateByTemplate(
                TokenTemplate.withSerial(
                  otpAuthMap: policy,
                  serial: testSerial,
                ),
              )
              as PushToken;

      expect(updated.requiresBiometricKeyProtection, isTrue);
      expect(updated.biometricKeyStatus, BiometricPushKeyStatus.invalidated);
      expect(updated.privateTokenKey, isNull);
    });

    test('a new deployed strong plaintext record fails closed', () {
      final imported = createPush().copyWith(
        forceBiometricOption: ForceBiometricOption.biometric,
        biometricLevel: PushAppBiometricLevel.strong,
        invalidateOnBiometricChange: true,
        privateTokenKey: () => 'private-key',
        isRolledOut: true,
        rolloutState: PushTokenRollOutState.rolloutComplete,
      );

      final stored = imported.withFailClosedBiometricLifecycle();

      expect(stored.biometricKeyStatus, BiometricPushKeyStatus.invalidated);
      expect(stored.privateTokenKey, isNull);
    });

    test('stale writes preserve a protected native key pair', () {
      final current = createPush().copyWith(
        forceBiometricOption: ForceBiometricOption.biometric,
        invalidateOnBiometricChange: true,
        publicTokenKey: 'public-a',
        privateTokenKey: () => null,
        biometricKeyStatus: BiometricPushKeyStatus.protected,
        isRolledOut: true,
        rolloutState: PushTokenRollOutState.rolloutComplete,
        fbToken: 'firebase-current',
      );
      final stale = createPush().copyWith(
        forceBiometricOption: ForceBiometricOption.biometric,
        invalidateOnBiometricChange: true,
      );

      final merged = stale.withMonotonicBiometricStateFrom(current);

      expect(merged.biometricKeyStatus, BiometricPushKeyStatus.protected);
      expect(merged.privateTokenKey, isNull);
      expect(merged.publicTokenKey, 'public-a');
    });
  });

  group('DayPasswordToken - Every Corner Suite', () {
    final testPeriod = const Duration(hours: 24);
    const baseSecret = 'JBSWY3DPEHPK3PXP';

    DayPasswordToken createDay({
      DayPasswordTokenViewMode viewMode = DayPasswordTokenViewMode.VALIDFOR,
      Duration? period,
    }) => DayPasswordToken(
      id: 'day-id',
      secret: baseSecret,
      label: 'Day',
      issuer: 'PI',
      algorithm: Algorithms.SHA1,
      digits: 6,
      period: period ?? testPeriod,
      viewMode: viewMode,
    );

    test('Fallback logic for invalid durations', () {
      final tokenZero = createDay(period: Duration.zero);
      final tokenNeg = createDay(period: const Duration(seconds: -1));
      expect(tokenZero.period, const Duration(hours: 24));
      expect(tokenNeg.period, const Duration(hours: 24));
    });

    test('Duration consistency (Sum of durations)', () {
      final token = createDay();
      final total = token.durationSinceLastOTP + token.durationUntilNextOTP;
      // The two getters each read DateTime.now() independently, so the sum can
      // drift by a few milliseconds (and cross a second boundary under .inSeconds).
      final errorMargin = (total - token.period).abs();
      expect(errorMargin.inMilliseconds, lessThan(100));
    });

    test('Time window sequence with microsecond margin', () {
      final token = createDay();
      final start = token.thisOTPTimeStart;
      final next = token.nextOTPTimeStart;

      expect(next.isAfter(start), isTrue);

      // Use a small margin (e.g., 100ms) to account for execution time between calls
      final difference = next.difference(start);
      final errorMargin = (difference - token.period).abs();

      expect(
        errorMargin.inMilliseconds,
        lessThan(100),
        reason:
            'The gap between time windows should be exactly the period, plus/minus execution jitter.',
      );
    });
    test('Serialization roundtrip with ViewMode as String', () {
      final map = {
        Token.LABEL: 'Day',
        OTPToken.SECRET_BASE32: baseSecret,
        OTPToken.ALGORITHM: 'SHA1',
        OTPToken.DIGITS: 6,
        TOTPToken.PERIOD_SECONDS: '86400',
      };

      final data = {DayPasswordToken.VIEW_MODE: 'validUntil'};
      final token = DayPasswordToken.fromOtpAuthMap(map, additionalData: data);

      expect(token.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
      expect(
        token.additionalData[DayPasswordToken.VIEW_MODE],
        DayPasswordTokenViewMode.VALIDUNTIL.name,
      );
    });
    test('copyUpdateByTemplate with DayPassword specific fields', () {
      final token = createDay();
      final template = TokenTemplate.withOtps(
        otpAuthMap: {Token.LABEL: 'Updated', TOTPToken.PERIOD_SECONDS: '3600'},
        otps: [],
        additionalData: {
          DayPasswordToken.VIEW_MODE: DayPasswordTokenViewMode.VALIDUNTIL,
        },
      );

      final updated = token.copyUpdateByTemplate(template);
      expect(updated.label, 'Updated');
      expect(updated.period, const Duration(hours: 1));
      expect(updated.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
    });

    test('Equality (==) includes viewMode and period', () {
      final t1 = createDay();
      final t2 = createDay(viewMode: DayPasswordTokenViewMode.VALIDUNTIL);
      final t3 = createDay(period: const Duration(hours: 1));

      expect(t1 == t2, isFalse);
      expect(t1 == t3, isFalse);
    });
  });
}
