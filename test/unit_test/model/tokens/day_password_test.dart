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

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/version.dart';

/// Returns a skip reason unless the bug tests are enabled explicitly.
String? bug(String description) =>
    const bool.fromEnvironment('RUN_BUG_TESTS') ? null : 'BUG: $description';

const String _serialErasedBug =
    'copyUpdateByTemplate sets serial: () => uriMap[SERIAL], so a template without serial erases the existing serial';

const String _frozenBug =
    'copyWith passes this.isLocked/this.isHidden (derived getters) as explicit state, '
    'so a lock derived from pin/forceBiometricOption survives removing it';

const String _oldSecret = 'JBSWY3DPEHPK3PXP';
const String _newSecret = 'GEZDGNBVGY3TQOJQ';

final TokenOriginData _copyUpdateOrigin = TokenOriginData(
  source: TokenOriginSourceType.qrScan,
  appName: 'TestApp',
  data: 'otpauth://totp/test',
  createdAt: DateTime.utc(2024, 1, 2, 3, 4, 5),
  isPrivacyIdeaToken: true,
);

TokenTemplate _template(
  Map<String, dynamic> otpAuthMap, {
  Map<String, dynamic> additionalData = const {},
}) => TokenTemplate.withOtps(
  otpAuthMap: otpAuthMap,
  otps: const [],
  additionalData: additionalData,
);

void _expectMetadataKept(Token before, Token after) {
  expect(after.id, before.id);
  expect(after.type, before.type);
  expect(after.folderId, 4);
  expect(after.sortIndex, 9);
  expect(after.containerSerial, 'CONT-1');
  expect(after.checkedContainer, ['CONT-1']);
  expect(after.origin, _copyUpdateOrigin);
  expect(after.isOffline, isTrue);
  expect(after.forceBiometricOption, ForceBiometricOption.none);
}

DayPasswordToken _oldDayPassword({String? serial = 'OLD-SERIAL', bool pin = false}) =>
    DayPasswordToken(
      id: 'day-id',
      serial: serial,
      label: 'old label',
      issuer: 'old issuer',
      algorithm: Algorithms.SHA256,
      digits: 8,
      secret: _oldSecret,
      period: const Duration(hours: 6),
      tokenImage: 'old.png',
      pin: pin,
      folderId: 4,
      sortIndex: 9,
      containerSerial: 'CONT-1',
      checkedContainer: const ['CONT-1'],
      isOffline: true,
      origin: _copyUpdateOrigin,
    );

const String _secret = 'JBSWY3DPEHPK3PXP';

final TokenOriginData _jsonOrigin = TokenOriginData(
  source: TokenOriginSourceType.container,
  appName: 'Server (CONT-1)',
  data: 'otpauth://totp/Test?secret=$_secret',
  createdAt: DateTime.utc(2024, 2, 29, 23, 59, 58, 123),
  isPrivacyIdeaToken: true,
  creator: 'admin',
  piServerVersion: const Version(3, 11, 2),
);

/// The storage format: Token -> String -> Token.
Token _viaStorage(Token token) =>
    Token.fromJson(jsonDecode(jsonEncode(token)) as Map<String, dynamic>);

Map<String, dynamic> _jsonOf(Token token) =>
    jsonDecode(jsonEncode(token)) as Map<String, dynamic>;

/// Compares everything that is part of the base Token.
void _expectBaseEqual(Token actual, Token expected) {
  expect(actual.runtimeType, expected.runtimeType);
  expect(actual.id, expected.id);
  expect(actual.type, expected.type);
  expect(actual.label, expected.label);
  expect(actual.issuer, expected.issuer);
  expect(actual.serial, expected.serial);
  expect(actual.containerSerial, expected.containerSerial);
  expect(actual.checkedContainer, expected.checkedContainer);
  expect(actual.pin, expected.pin);
  expect(actual.forceBiometricOption, expected.forceBiometricOption);
  expect(actual.tokenImage, expected.tokenImage);
  expect(actual.folderId, expected.folderId);
  expect(actual.sortIndex, expected.sortIndex);
  expect(actual.isOffline, expected.isOffline);
  expect(actual.isLocked, expected.isLocked);
  expect(actual.isHidden, expected.isHidden);
  expect(actual.origin, expected.origin);
}

DayPasswordToken _fullDayPassword() => DayPasswordToken(
  id: 'day-id',
  serial: 'DAY-SERIAL',
  label: 'day label',
  issuer: 'day issuer',
  algorithm: Algorithms.SHA1,
  digits: 9,
  secret: _secret,
  period: const Duration(hours: 6, minutes: 30, seconds: 15),
  viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
  tokenImage: 'day.png',
  pin: true,
  isLocked: true,
  isHidden: false,
  forceBiometricOption: ForceBiometricOption.any,
  folderId: 9,
  sortIndex: 5,
  containerSerial: 'CONT-2',
  checkedContainer: const ['CONT-2'],
  isOffline: true,
  origin: _jsonOrigin,
);

/// The reference TOTP of the DayPasswordToken window tests.
TOTPToken _totp({required String secret}) => TOTPToken(
  id: 'totp',
  algorithm: Algorithms.SHA1,
  digits: 8,
  period: 30,
  secret: secret,
);

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
        // The two getters each read DateTime.now() independently, so the sum can
        // drift by a few milliseconds (and cross a second boundary under .inSeconds).
        final errorMargin = (sum - testPeriod).abs();
        expect(errorMargin.inMilliseconds, lessThan(100));
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

  _testCopyUpdateByTemplate();
  _testLockStateInCopyWith();
  _testJsonRoundTrip();
  _testWindows();
}

void _testCopyUpdateByTemplate() {
  group('DayPasswordToken.copyUpdateByTemplate', () {
    final fullTemplate = <String, dynamic>{
      Token.LABEL: 'new label',
      Token.ISSUER: 'new issuer',
      Token.IMAGE: 'new.png',
      Token.SERIAL: 'NEW-SERIAL',
      OTPToken.ALGORITHM: 'SHA512',
      OTPToken.DIGITS: '6',
      OTPToken.SECRET_BASE32: _newSecret,
      TOTPToken.PERIOD_SECONDS: '7200',
    };

    test('applies every value the template describes', () {
      final updated = _oldDayPassword().copyUpdateByTemplate(_template(fullTemplate));
      expect(updated.label, 'new label');
      expect(updated.issuer, 'new issuer');
      expect(updated.tokenImage, 'new.png');
      expect(updated.serial, 'NEW-SERIAL');
      expect(updated.algorithm, Algorithms.SHA512);
      expect(updated.digits, 6);
      expect(updated.secret, _newSecret);
      expect(updated.period, const Duration(hours: 2));
    });

    test('keeps the identity and metadata the template does not describe', () {
      final original = _oldDayPassword();
      final updated = original.copyUpdateByTemplate(_template(fullTemplate));
      _expectMetadataKept(original, updated);
    });

    test('returns a new object and leaves the original untouched', () {
      final original = _oldDayPassword();
      final updated = original.copyUpdateByTemplate(_template(fullTemplate));
      expect(identical(updated, original), isFalse);
      expect(original.label, 'old label');
      expect(original.serial, 'OLD-SERIAL');
      expect(original.algorithm, Algorithms.SHA256);
      expect(original.secret, _oldSecret);
    });

    test('an update by the own template of a token with serial changes nothing', () {
      final original = _oldDayPassword();
      final template = original.toTemplate();
      expect(template.serial, 'OLD-SERIAL');
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
    });

    test('an update by the own template of a token without serial changes nothing', () {
      final original = _oldDayPassword(serial: null);
      final template = original.toTemplate();
      expect(template.serial, isNull);
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
      expect(updated.serial, isNull);
    });

    test('a template with a serial replaces the serial', () {
      final updated = _oldDayPassword().copyUpdateByTemplate(
        _template({
          OTPToken.SECRET_BASE32: _oldSecret,
          Token.SERIAL: 'OTHER-SERIAL',
        }),
      );
      expect(updated.serial, 'OTHER-SERIAL');
    });

    test(
      'a template without serial keeps the existing serial',
      () {
        final updated = _oldDayPassword().copyUpdateByTemplate(
          _template({
            OTPToken.SECRET_BASE32: _oldSecret,
            Token.LABEL: 'only the label changes',
          }),
        );
        expect(updated.label, 'only the label changes');
        expect(updated.serial, 'OLD-SERIAL');
      },
      skip: bug(_serialErasedBug),
    );

    test('a template without serial never invents a serial for a token without one', () {
      final updated = _oldDayPassword(serial: null).copyUpdateByTemplate(
        _template({OTPToken.SECRET_BASE32: _oldSecret}),
      );
      expect(updated.serial, isNull);
    });
  });

  group('DayPasswordToken.copyUpdateByTemplate with a partial template', () {
    test('keeps algorithm, digits, secret and period that the template omits', () {
      final original = _oldDayPassword();
      final updated = original.copyUpdateByTemplate(
        _template({Token.LABEL: 'only the label'}),
      );
      expect(updated.label, 'only the label');
      expect(updated.algorithm, Algorithms.SHA256);
      expect(updated.digits, 8);
      expect(updated.secret, _oldSecret);
      expect(updated.period, const Duration(hours: 6));
      expect(updated.issuer, 'old issuer');
      expect(updated.tokenImage, 'old.png');
    });
  });

  group('DayPasswordToken.copyUpdateByTemplate pin handling', () {
    final minimalTemplate = <String, dynamic>{};

    test('pin True in the template locks the token', () {
      final updated = _oldDayPassword().copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_TRUE}),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('pin False in the template removes the pin and unlocks the token', () {
      final original = _oldDayPassword(pin: true);
      expect(original.isLocked, isTrue);
      final updated = original.copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_FALSE}),
      );
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });

    test('a template without pin keeps a pin protected token protected', () {
      final updated = _oldDayPassword(pin: true).copyUpdateByTemplate(
        _template(minimalTemplate),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('a template without pin keeps an unprotected token unprotected', () {
      final updated = _oldDayPassword().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });
  });

  group('DayPasswordToken.copyUpdateByTemplate checkedContainer', () {
    final minimalTemplate = <String, dynamic>{};

    test('keeps the existing checkedContainer when the template carries none', () {
      final updated = _oldDayPassword().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.checkedContainer, ['CONT-1']);
    });

    test('replaces the checkedContainer with the one of the template', () {
      final updated = _oldDayPassword().copyUpdateByTemplate(
        _template(
          minimalTemplate,
          additionalData: {
            Token.CHECKED_CONTAINERS: <String>['CONT-2', 'CONT-3'],
          },
        ),
      );
      expect(updated.checkedContainer, ['CONT-2', 'CONT-3']);
    });
  });
}

void _testLockStateInCopyWith() {
  group('DayPasswordToken lock state in copyWith', () {
    DayPasswordToken build({
      bool? pin,
      ForceBiometricOption? biometric,
      bool? isLocked,
      bool? isHidden,
    }) => DayPasswordToken(
      id: 'id',
      period: const Duration(hours: 24),
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: _secret,
      pin: pin,
      forceBiometricOption: biometric ?? ForceBiometricOption.none,
      isLocked: isLocked,
      isHidden: isHidden,
    );

    DayPasswordToken copyOf(
      DayPasswordToken token, {
      bool? pin,
      ForceBiometricOption? biometric,
      bool? isLocked,
      bool? isHidden,
      String? label,
    }) => token.copyWith(
      pin: pin,
      forceBiometricOption: biometric,
      isLocked: isLocked,
      isHidden: isHidden,
      label: label,
    );

    group('behaviour that already holds', () {
        test('a fresh token without pin is neither locked nor hidden', () {
          final token = build();
          expect(token.isLocked, isFalse);
          expect(token.isHidden, isFalse);
        });

        test('an unrelated copyWith keeps an unlocked token unlocked and visible', () {
          final copy = copyOf(build(), label: 'renamed');
          expect(copy.label, 'renamed');
          expect(copy.isLocked, isFalse);
          expect(copy.isHidden, isFalse);
        });

        test('an unrelated copyWith keeps a pin protected token locked', () {
          final copy = copyOf(build(pin: true), label: 'renamed');
          expect(copy.pin, isTrue);
          expect(copy.isLocked, isTrue);
        });

        test('an unrelated copyWith keeps a biometric protected token locked', () {
          final copy = copyOf(
            build(biometric: ForceBiometricOption.biometric),
            label: 'renamed',
          );
          expect(copy.forceBiometricOption, ForceBiometricOption.biometric);
          expect(copy.isLocked, isTrue);
        });

        test('adding a pin locks the token', () {
          final copy = copyOf(build(), pin: true);
          expect(copy.pin, isTrue);
          expect(copy.isLocked, isTrue);
        });

        test('forcing biometrics locks the token', () {
          final copy = copyOf(build(), biometric: ForceBiometricOption.any);
          expect(copy.isLocked, isTrue);
        });

        test('isLocked: true locks a token that has no pin', () {
          final copy = copyOf(build(), isLocked: true);
          expect(copy.pin, isFalse);
          expect(copy.isLocked, isTrue);
        });

        test('isLocked: false unlocks a token that was only locked explicitly', () {
          final copy = copyOf(build(isLocked: true), isLocked: false);
          expect(copy.isLocked, isFalse);
        });

        test('isLocked: false can not unlock a pin protected token', () {
          final copy = copyOf(build(pin: true), isLocked: false);
          expect(copy.pin, isTrue);
          expect(copy.isLocked, isTrue);
        });

        test('isLocked: false can not unlock a biometric protected token', () {
          final copy = copyOf(
            build(biometric: ForceBiometricOption.pin),
            isLocked: false,
          );
          expect(copy.isLocked, isTrue);
        });

        test('an explicit lock survives the removal of the pin', () {
          final copy = copyOf(build(pin: true, isLocked: true), pin: false);
          expect(copy.pin, isFalse);
          expect(copy.isLocked, isTrue);
        });

          test('isHidden: true hides an unlocked token', () {
            final copy = copyOf(build(), isHidden: true);
            expect(copy.isLocked, isFalse);
            expect(copy.isHidden, isTrue);
          });

          test('isHidden: false shows a locked token without unlocking it', () {
            final copy = copyOf(build(pin: true), isHidden: false);
            expect(copy.isLocked, isTrue);
            expect(copy.isHidden, isFalse);
          });

          test('an explicit isHidden: false survives an unrelated copyWith', () {
            final token = build(pin: true, isHidden: false);
            expect(token.isHidden, isFalse);
            expect(copyOf(token, label: 'x').isHidden, isFalse);
          });

          test('an explicit isHidden: true survives an unrelated copyWith', () {
            final token = build(isHidden: true);
            expect(token.isHidden, isTrue);
            expect(copyOf(token, label: 'x').isHidden, isTrue);
          });

          test('a locked token without explicit isHidden is hidden', () {
            final token = build(pin: true);
            expect(token.isHidden, isTrue);
            expect(copyOf(token, label: 'x').isHidden, isTrue);
          });
    });

    group('derived lock state must not be frozen by copyWith', () {
        test(
          'removing the pin unlocks a token that was only locked by its pin',
          () {
            final copy = copyOf(build(pin: true), pin: false);
            expect(copy.pin, isFalse);
            expect(copy.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );

        test(
          'removing forced biometrics unlocks a token that was only locked by them',
          () {
            final copy = copyOf(
              build(biometric: ForceBiometricOption.biometric),
              biometric: ForceBiometricOption.none,
            );
            expect(copy.forceBiometricOption, ForceBiometricOption.none);
            expect(copy.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );

        test(
          'an unrelated copyWith does not freeze the pin lock for a later pin removal',
          () {
            final renamed = copyOf(build(pin: true), label: 'renamed');
            final unpinned = copyOf(renamed, pin: false);
            expect(unpinned.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );

        test(
          'removing the pin and the biometric requirement in two steps unlocks the token',
          () {
            final both = build(
              pin: true,
              biometric: ForceBiometricOption.biometric,
            );
            final step1 = copyOf(both, pin: false);
            expect(step1.isLocked, isTrue, reason: 'biometrics still force the lock');
            final step2 = copyOf(step1, biometric: ForceBiometricOption.none);
            expect(step2.isLocked, isFalse);
          },
          skip: bug(_frozenBug),
        );

          test(
            'removing the pin shows a token that was only hidden because it was locked',
            () {
              final copy = copyOf(build(pin: true), pin: false);
              expect(copy.isHidden, isFalse);
            },
            skip: bug(_frozenBug),
          );

          test(
            'adding a pin hides a token whose visibility was never set explicitly',
            () {
              final copy = copyOf(build(), pin: true);
              expect(copy.isLocked, isTrue);
              expect(copy.isHidden, isTrue);
            },
            skip: bug(_frozenBug),
          );
    });
  });
}

void _testJsonRoundTrip() {
  group('DayPasswordToken JSON round trip', () {
    test('all metadata, period and viewMode survive the round trip', () {
      final original = _fullDayPassword();
      final restored = _viaStorage(original) as DayPasswordToken;
      _expectBaseEqual(restored, original);
      expect(restored.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
      expect(restored.period, const Duration(hours: 6, minutes: 30, seconds: 15));
      expect(restored.algorithm, Algorithms.SHA1);
      expect(restored.digits, 9);
      expect(restored.secret, _secret);
    });

    test('the JSON is stable', () {
      final original = _fullDayPassword();
      expect(_jsonOf(_viaStorage(original)), _jsonOf(original));
    });

    test('both view modes survive', () {
      for (final mode in DayPasswordTokenViewMode.values) {
        final restored =
            _viaStorage(_fullDayPassword().copyWith(viewMode: mode))
                as DayPasswordToken;
        expect(restored.viewMode, mode);
      }
    });

    test('the restored token equals the original (== includes period and viewMode)', () {
      final original = _fullDayPassword();
      expect(_viaStorage(original) == original, isTrue);
    });


    test('DayPasswordToken: Token.fromJson dispatches to the own type', () {
      final restored = _viaStorage(_fullDayPassword());
      expect(restored.runtimeType.toString(), 'DayPasswordToken');
      expect(restored.type, _fullDayPassword().type);
    });

    test('DayPasswordToken: every ForceBiometricOption survives and locks the token', () {
      for (final option in ForceBiometricOption.values) {
        final token = _fullDayPassword().copyWith(
          pin: false,
          isLocked: false,
          forceBiometricOption: option,
        );
        final restored = _viaStorage(token);
        expect(restored.forceBiometricOption, option, reason: '$option');
        expect(
          restored.isLocked,
          option != ForceBiometricOption.none,
          reason: 'isLocked for $option',
        );
      }
    });

    test('DayPasswordToken: folder and sort index survive, also when null', () {
      final withValues = _viaStorage(_fullDayPassword());
      expect(withValues.folderId, _fullDayPassword().folderId);
      expect(withValues.sortIndex, _fullDayPassword().sortIndex);
      final cleared = _viaStorage(_fullDayPassword().copyWith(folderId: () => null));
      expect(cleared.folderId, isNull);
    });

    test('DayPasswordToken: a JSON written without the optional keys loads with defaults', () {
      final json = _jsonOf(_fullDayPassword())
        ..remove('isOffline')
        ..remove('forceBiometricOption')
        ..remove('checkedContainer')
        ..remove('label')
        ..remove('issuer')
        ..remove('pin')
        ..remove('isLocked')
        ..remove('isHidden');
      final restored = Token.fromJson(json);
      expect(restored.isOffline, isFalse);
      expect(restored.forceBiometricOption, ForceBiometricOption.none);
      expect(restored.checkedContainer, isEmpty);
      expect(restored.label, '');
      expect(restored.issuer, '');
      expect(restored.pin, isFalse);
      expect(restored.isLocked, isFalse);
      expect(restored.isHidden, isFalse);
    });
  });
}

void _testWindows() {
  group('DayPasswordToken windows', () {
    const secret = 'JBSWY3DPEHPK3PXP';

    DayPasswordToken day(Duration period, {Algorithms algorithm = Algorithms.SHA1}) =>
        DayPasswordToken(
          id: 'day',
          algorithm: algorithm,
          digits: 8,
          secret: secret,
          period: period,
        );

    TOTPToken sameAsTotp(DayPasswordToken token) => TOTPToken(
      id: 'ref',
      algorithm: token.algorithm,
      digits: token.digits,
      secret: token.secret,
      period: token.period.inSeconds,
    );

    final periods = [
      const Duration(seconds: 1),
      const Duration(seconds: 90),
      const Duration(hours: 1),
      const Duration(hours: 24),
      const Duration(days: 7),
    ];

    for (final period in periods) {
      test('thisOTPTimeStart is aligned to the epoch grid of $period', () {
        final token = day(period);
        final before = DateTime.now();
        final start = token.thisOTPTimeStart;
        final after = DateTime.now();
        expect(start.millisecondsSinceEpoch % period.inMilliseconds, 0);
        // the window start lies in the past and at most one period back
        expect(start.isAfter(after), isFalse);
        expect(
          before.difference(start),
          lessThan(period + const Duration(milliseconds: 1)),
        );
      });

      test('durationSinceLastOTP is in [0, period) and durationUntilNextOTP in (0, period] for $period', () {
        final token = day(period);
        final since = token.durationSinceLastOTP;
        final until = token.durationUntilNextOTP;
        expect(since, greaterThanOrEqualTo(Duration.zero));
        expect(since, lessThan(period));
        expect(until, greaterThan(Duration.zero));
        expect(until, lessThanOrEqualTo(period));
      });

      test('the OTP is the same for a whole window and changes at its end for $period', () {
        final token = day(period);
        final reference = sameAsTotp(token);
        final start = token.thisOTPTimeStart;
        final atStart = reference.otpFromTime(start);
        expect(
          reference.otpFromTime(start.add(period - const Duration(milliseconds: 1))),
          atStart,
          reason: 'last millisecond of the window',
        );
        expect(
          reference.otpFromTime(start.add(period)),
          isNot(atStart),
          reason: 'first millisecond of the next window',
        );
      });

      test('otpValue and nextValue match the TOTP of the same period for $period', () {
        final token = day(period);
        final reference = sameAsTotp(token);
        final startBefore = token.thisOTPTimeStart;
        final value = token.otpValue;
        final next = token.nextValue;
        final startAfter = token.thisOTPTimeStart;
        expect({
          reference.otpFromTime(startBefore),
          reference.otpFromTime(startAfter),
        }, contains(value));
        expect({
          reference.otpFromTime(startBefore.add(period)),
          reference.otpFromTime(startAfter.add(period)),
        }, contains(next));
      });
    }

    test('nextOTPTimeStart lies one period after the window start (plus the 1 ms guard)', () {
      final token = day(const Duration(hours: 24));
      final start = token.thisOTPTimeStart;
      final next = token.nextOTPTimeStart;
      final periodMs = token.period.inMilliseconds;
      // The getters read the clock separately, so the window may have moved on once.
      final gapMs = next.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      expect(
        [periodMs + 1, 2 * periodMs + 1],
        contains(gapMs),
        reason: 'gap was $gapMs ms',
      );
      expect(
        (next.millisecondsSinceEpoch - 1) % periodMs,
        0,
        reason: 'next start is the grid point plus 1 ms',
      );
    });

    test(
      'thisOTPTimeStart is aligned to the epoch grid down to the microsecond',
      () {
        const period = Duration(hours: 1);
        final start = day(period).thisOTPTimeStart;
        expect(start.microsecondsSinceEpoch % period.inMicroseconds, 0);
      },
      skip: bug(
        'thisOTPTimeStart = now.subtract(ms since window start) keeps the sub-millisecond part of DateTime.now(), so it is off the grid (minor, display only)',
      ),
    );

    test('a period below one second falls back to 24 hours', () {
      expect(day(const Duration(milliseconds: 999)).period, const Duration(hours: 24));
      expect(day(const Duration(seconds: 1)).period, const Duration(seconds: 1));
    });

    test('DayPassword codes differ from TOTP codes of another period', () {
      // 24 h and 30 s windows must not be confused
      final dayToken = day(const Duration(hours: 24));
      final reference = _totp(secret: secret);
      final time = DateTime.utc(2024, 1, 1, 12);
      expect(
        sameAsTotp(dayToken).otpFromTime(time),
        isNot(reference.otpFromTime(time)),
      );
    });
  });
}
