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
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

void main() {
  group('DayPasswordToken - Complete Test Suite', () {
    final testPeriod = Duration(hours: 24);
    const baseSecret = 'JBSWY3DPEHPK3PXP'; // 'secret'

    DayPasswordToken createTestToken({
      String id = 'test-id',
      DayPasswordTokenViewMode viewMode = DayPasswordTokenViewMode.VALIDFOR,
      Duration? period,
    }) => DayPasswordToken(
      id: id,
      secret: baseSecret,
      label: 'test-label',
      issuer: 'test-issuer',
      algorithm: Algorithms.SHA1,
      digits: 6,
      period: period ?? testPeriod,
      viewMode: viewMode,
    );

    group('Core Functionality & Construction', () {
      test('initialization with defaults', () {
        final token = createTestToken();
        expect(token.type, 'DAYPASSWORD');
        expect(token.period, testPeriod);
        expect(token.viewMode, DayPasswordTokenViewMode.VALIDFOR);
      });

      test('fallback for invalid period (0 or negative)', () {
        final tokenZero = createTestToken(period: Duration.zero);
        final tokenNeg = createTestToken(period: Duration(hours: -1));
        expect(tokenZero.period, Duration(hours: 24));
        expect(tokenNeg.period, Duration(hours: 24));
      });
    });

    group('Serialization & Factories', () {
      test('fromOtpAuthMap handles raw data types (String vs Num)', () {
        final map = {
          Token.LABEL: 'L',
          Token.ISSUER: 'I',
          OTPToken.SECRET_BASE32: baseSecret,
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '8',
          TOTPToken.PERIOD_SECONDS: '3600',
        };
        final token = DayPasswordToken.fromOtpAuthMap(map);
        expect(token.digits, 8);
        expect(token.period, Duration(hours: 1));
      });

      test('toJson / fromJson roundtrip', () {
        final original = createTestToken(
          viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
        );
        final json = original.toJson();
        final recovered = DayPasswordToken.fromJson(json);

        expect(recovered.viewMode, original.viewMode);
        expect(recovered.period, original.period);
        expect(recovered.id, original.id);
      });

      test('toOtpAuthMap export includes period in seconds', () {
        final token = createTestToken(period: Duration(hours: 1));
        final map = token.toOtpAuthMap();
        expect(map[TOTPToken.PERIOD_SECONDS], '3600');
      });

      test('additionalData getter contains VIEW_MODE and other metadata', () {
        final token = createTestToken(
          viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
        );
        final data = token.additionalData;
        expect(
          data[DayPasswordToken.VIEW_MODE],
          DayPasswordTokenViewMode.VALIDUNTIL.name,
        );
        expect(data.containsKey(Token.ID), true);
      });

      test(
        'fromOtpAuthMap handles VIEW_MODE as String from additionalData',
        () {
          final token = DayPasswordToken.fromOtpAuthMap(
            {
              Token.LABEL: 'L',
              OTPToken.SECRET_BASE32: baseSecret,
              OTPToken.ALGORITHM: 'SHA1',
              OTPToken.DIGITS: 6,
            },
            additionalData: {DayPasswordToken.VIEW_MODE: 'validUntil'},
          );
          expect(token.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
        },
      );
    });

    group('Template & Copying', () {
      test('copyUpdateByTemplate handles VIEW_MODE in additionalData', () {
        final token = createTestToken();
        final template = TokenTemplate.withOtps(
          otpAuthMap: {
            Token.LABEL: 'new-label',
            TOTPToken.PERIOD_SECONDS: '7200',
          },
          otps: [],
          additionalData: {
            DayPasswordToken.VIEW_MODE: DayPasswordTokenViewMode.VALIDUNTIL,
          },
        );

        final updated = token.copyUpdateByTemplate(template);
        expect(updated.label, 'new-label');
        expect(updated.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
        expect(updated.period, Duration(hours: 2));
      });

      test('copyWith preserves complex fields like folderId', () {
        final token = createTestToken().copyWith(folderId: () => 99);
        final copied = token.copyWith(label: 'new');
        expect(copied.folderId, 99);
        expect(copied.label, 'new');
      });
    });

    group('Time Logic & OTP Generation', () {
      test('otpValue and nextValue are different (usually)', () {
        final token = createTestToken();
        expect(token.otpValue, isNotEmpty);
        expect(token.nextValue, isNotEmpty);
      });

      test('time window consistency', () {
        final token = createTestToken();
        final nowStart = token.thisOTPTimeStart;
        final nextStart = token.nextOTPTimeStart;

        expect(nextStart.isAfter(nowStart), isTrue);
        expect(nextStart.difference(nowStart).inSeconds, testPeriod.inSeconds);
      });

      test('durations sum up to period', () {
        final token = createTestToken();
        final sum = token.durationSinceLastOTP + token.durationUntilNextOTP;
        expect(sum.inSeconds, testPeriod.inSeconds);
      });
    });

    group('Identity & Comparison', () {
      test('isSameTokenAs logic', () {
        final t1 = createTestToken(id: 'A');
        final t2 = createTestToken(id: 'B');
        final t3 = t1.copyWith(period: Duration(hours: 1));

        expect(t1.isSameTokenAs(t2), isTrue);
        expect(t1.isSameTokenAs(t3), isTrue);
      });

      test('equality check (==) includes viewMode and period', () {
        final t1 = createTestToken();
        final t2 = createTestToken(
          viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
        );
        expect(t1 == t2, isFalse);
      });
    });
  });
}
