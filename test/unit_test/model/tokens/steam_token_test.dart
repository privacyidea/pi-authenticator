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
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/token_template.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/version.dart';

/// Returns a skip reason unless the bug tests are enabled explicitly.
String? bug(String description) =>
    const bool.fromEnvironment('RUN_BUG_TESTS') ? null : 'BUG: $description';

const String _checkedContainerBug =
    'only DayPasswordToken.copyUpdateByTemplate applies the checkedContainer of the template additionalData, the other types drop it';

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

SteamToken _oldSteam({bool pin = false}) => SteamToken(
  id: 'steam-id',
  secret: _oldSecret,
  label: 'old label',
  issuer: 'old issuer',
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

SteamToken _fullSteam() => SteamToken(
  id: 'steam-id',
  secret: _secret,
  label: 'steam label',
  issuer: 'Steam',
  tokenImage: 'steam.png',
  pin: true,
  isLocked: true,
  isHidden: true,
  forceBiometricOption: ForceBiometricOption.any,
  folderId: 10,
  sortIndex: 6,
  containerSerial: 'CONT-3',
  checkedContainer: const ['CONT-3'],
  isOffline: true,
  origin: _jsonOrigin,
);

// --- helpers for the OTP values at fixed timestamps ---

String _base32(String ascii) => Encodings.base32.encode(utf8.encode(ascii));

DateTime _at(int seconds, [int millis = 0]) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + millis, isUtc: true);

HOTPToken _hotp({
  required int digits,
  required int counter,
  required String secret,
}) => HOTPToken(
  id: 'hotp',
  algorithm: Algorithms.SHA1,
  digits: digits,
  counter: counter,
  secret: secret,
);

void main() {
  group('SteamToken - Complete Deep Dive Suite', () {
    const String baseSecret = 'JBSWY3DPEHPK3PXP';
    const String testId = 'steam-unique-id';

    SteamToken createTestToken({
      String? id,
      String? secret,
      int? folderId,
      TokenOriginData? origin,
    }) => SteamToken(
      id: id ?? testId,
      secret: secret ?? baseSecret,
      label: 'SteamUser',
      issuer: 'Steam',
      folderId: folderId,
      origin: origin,
    );

    group('1. Construction & Fixed Constraints', () {
      test('Steam tokens must ignore variable TOTP parameters', () {
        final token = createTestToken();
        expect(token.type, 'STEAM');
        expect(token.digits, 5);
        expect(token.period, 30);
        expect(token.algorithm, Algorithms.SHA1);
        expect(token.isPrivacyIdeaToken, isFalse);
        expect(token.serial, isNull);
      });
    });

    group('2. Serialization & Factories', () {
      test(
        'fromOtpAuthMap creates valid instance and handles secret casing',
        () {
          final map = {
            Token.LABEL: 'SteamAccount',
            Token.ISSUER: 'Steam',
            OTPToken.SECRET_BASE32: 'jbswy3dpehpk3pxp',
          };
          final token = SteamToken.fromOtpAuthMap(map);

          expect(token.label, 'SteamAccount');
          expect(token.secret.toUpperCase(), baseSecret);
        },
      );

      test('toOtpAuthMap export format including period', () {
        final token = createTestToken();
        final map = token.toOtpAuthMap();

        expect(map[Token.TOKENTYPE_OTPAUTH], 'STEAM');
        expect(map[OTPToken.SECRET_BASE32], baseSecret);
        expect(map[TOTPToken.PERIOD_SECONDS], '30');
      });

      test('toJson / fromJson roundtrip', () {
        final original = createTestToken(folderId: 99);
        final json = original.toJson();
        final recovered = SteamToken.fromJson(json);

        expect(recovered.id, original.id);
        expect(recovered.folderId, 99);
      });
    });

    group('3. Copying & Templates', () {
      test('copyWith preserves enum-based origin source', () {
        final origin = TokenOriginData(
          source: TokenOriginSourceType.manually,
          appName: 'TestApp',
          data: 'test-data',
        );
        final token = createTestToken(origin: origin, folderId: 10);

        final copied = token.copyWith(label: 'NewName');

        expect(copied.label, 'NewName');
        expect(copied.origin?.source, TokenOriginSourceType.manually);
        expect(copied.folderId, 10);
      });

      test('copyUpdateByTemplate handles required secret mapping', () {
        final token = createTestToken();
        final template = TokenTemplate.withOtps(
          otpAuthMap: {
            Token.LABEL: 'UpdatedLabel',
            OTPToken.SECRET_BASE32: baseSecret,
          },
          otps: [],
        );

        final updated = token.copyUpdateByTemplate(template);
        expect(updated.label, 'UpdatedLabel');
        expect(updated.digits, 5);
      });
    });

    group('4. Logic & Edge Cases', () {
      test('otpFromTime uses the current counter until the period ends', () {
        final token = createTestToken(secret: 'SECRETA=');

        expect(
          token.otpFromTime(
            DateTime.fromMillisecondsSinceEpoch(1712666212056, isUtc: true),
          ),
          'QJTQN',
        );
        expect(
          token.otpFromTime(
            DateTime.fromMillisecondsSinceEpoch(1712666219999, isUtc: true),
          ),
          'QJTQN',
        );
        expect(
          token.otpFromTime(
            DateTime.fromMillisecondsSinceEpoch(1712666220000, isUtc: true),
          ),
          'JGPCJ',
        );
      });

      test('isSameTokenAs logic (ID vs Parameters)', () {
        final t1 = createTestToken(id: 'ID1', secret: 'SECRET_A');
        final t2 = createTestToken(id: 'ID2', secret: 'SECRET_A');

        expect(t1.isSameTokenAs(t2), isTrue);
      });
    });
  });

  _testCopyUpdateByTemplate();
  _testLockStateInCopyWith();
  _testJsonRoundTrip();
  _testOtpBoundaries();
}

void _testCopyUpdateByTemplate() {
  group('SteamToken.copyUpdateByTemplate', () {
    test('ignores algorithm, digits, period and serial of the template', () {
      final updated = _oldSteam().copyUpdateByTemplate(
        _template({
          Token.LABEL: 'new label',
          OTPToken.SECRET_BASE32: _newSecret,
          OTPToken.ALGORITHM: 'SHA512',
          OTPToken.DIGITS: '8',
          TOTPToken.PERIOD_SECONDS: '60',
          Token.SERIAL: 'SOME-SERIAL',
        }),
      );
      expect(updated.label, 'new label');
      expect(updated.secret, _newSecret);
      expect(updated.algorithm, Algorithms.SHA1);
      expect(updated.digits, 5);
      expect(updated.period, 30);
      expect(updated.serial, isNull);
    });

    test('applies label, issuer, image and secret and keeps the metadata', () {
      final original = _oldSteam();
      final updated = original.copyUpdateByTemplate(
        _template({
          Token.LABEL: 'new label',
          Token.ISSUER: 'new issuer',
          Token.IMAGE: 'new.png',
          OTPToken.SECRET_BASE32: _newSecret,
        }),
      );
      expect(updated.label, 'new label');
      expect(updated.issuer, 'new issuer');
      expect(updated.tokenImage, 'new.png');
      expect(updated.secret, _newSecret);
      _expectMetadataKept(original, updated);
    });

    test('the updated secret changes the generated code', () {
      final time = DateTime.fromMillisecondsSinceEpoch(1712666212056, isUtc: true);
      final updated = _oldSteam().copyUpdateByTemplate(
        _template({OTPToken.SECRET_BASE32: _newSecret}),
      );
      final reference = SteamToken(id: 'ref', secret: _newSecret);
      expect(updated.otpFromTime(time), reference.otpFromTime(time));
      expect(updated.otpFromTime(time), isNot(_oldSteam().otpFromTime(time)));
    });

    test('an update by the own template changes nothing', () {
      final original = _oldSteam();
      final template = original.toTemplate();
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
    });
  });

  group('SteamToken.copyUpdateByTemplate pin handling', () {
    final minimalTemplate = <String, dynamic>{OTPToken.SECRET_BASE32: _oldSecret};

    test('pin True in the template locks the token', () {
      final updated = _oldSteam().copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_TRUE}),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('pin False in the template removes the pin and unlocks the token', () {
      final original = _oldSteam(pin: true);
      expect(original.isLocked, isTrue);
      final updated = original.copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_FALSE}),
      );
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });

    test('a template without pin keeps a pin protected token protected', () {
      final updated = _oldSteam(pin: true).copyUpdateByTemplate(
        _template(minimalTemplate),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('a template without pin keeps an unprotected token unprotected', () {
      final updated = _oldSteam().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });
  });

  group('SteamToken.copyUpdateByTemplate checkedContainer', () {
    final minimalTemplate = <String, dynamic>{OTPToken.SECRET_BASE32: _oldSecret};

    test('keeps the existing checkedContainer when the template carries none', () {
      final updated = _oldSteam().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.checkedContainer, ['CONT-1']);
    });

    test(
      'applies the checkedContainer of the template additionalData',
      () {
        final updated = _oldSteam().copyUpdateByTemplate(
          _template(
            minimalTemplate,
            additionalData: {
              Token.CHECKED_CONTAINERS: <String>['CONT-2', 'CONT-3'],
            },
          ),
        );
        expect(updated.checkedContainer, ['CONT-2', 'CONT-3']);
      },
      skip: bug(_checkedContainerBug),
    );
  });
}

void _testLockStateInCopyWith() {
  group('SteamToken lock state in copyWith', () {
    SteamToken build({
      bool? pin,
      ForceBiometricOption? biometric,
      bool? isLocked,
      bool? isHidden,
    }) => SteamToken(
      id: 'id',
      secret: _secret,
      pin: pin,
      forceBiometricOption: biometric ?? ForceBiometricOption.none,
      isLocked: isLocked,
      isHidden: isHidden,
    );

    SteamToken copyOf(
      SteamToken token, {
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
  group('SteamToken JSON round trip', () {
    test('all metadata survive the round trip and the fixed values stay fixed', () {
      final original = _fullSteam();
      final restored = _viaStorage(original) as SteamToken;
      _expectBaseEqual(restored, original);
      expect(restored.secret, _secret);
      expect(restored.digits, 5);
      expect(restored.period, 30);
      expect(restored.algorithm, Algorithms.SHA1);
      expect(restored.serial, isNull);
    });

    test('the JSON is stable and has no serial entry', () {
      final original = _fullSteam();
      expect(_jsonOf(_viaStorage(original)), _jsonOf(original));
      expect(_jsonOf(original).containsKey('serial'), isFalse);
    });

    test('the restored token generates the same codes', () {
      final original = _fullSteam();
      final restored = _viaStorage(original) as SteamToken;
      final time = DateTime.utc(2024, 3, 4, 5, 6, 7);
      expect(restored.otpFromTime(time), original.otpFromTime(time));
    });


    test('SteamToken: Token.fromJson dispatches to the own type', () {
      final restored = _viaStorage(_fullSteam());
      expect(restored.runtimeType.toString(), 'SteamToken');
      expect(restored.type, _fullSteam().type);
    });

    test('SteamToken: every ForceBiometricOption survives and locks the token', () {
      for (final option in ForceBiometricOption.values) {
        final token = _fullSteam().copyWith(
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

    test('SteamToken: folder and sort index survive, also when null', () {
      final withValues = _viaStorage(_fullSteam());
      expect(withValues.folderId, _fullSteam().folderId);
      expect(withValues.sortIndex, _fullSteam().sortIndex);
      final cleared = _viaStorage(_fullSteam().copyWith(folderId: () => null));
      expect(cleared.folderId, isNull);
    });

    test('SteamToken: a JSON written without the optional keys loads with defaults', () {
      final json = _jsonOf(_fullSteam())
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

void _testOtpBoundaries() {
  group('Steam OTP boundaries', () {
    const alphabet = SteamToken.steamAlphabet;
    final secrets = [
      'JBSWY3DPEHPK3PXP',
      'GEZDGNBVGY3TQOJQ',
      _base32('steam shared secret 20b'),
    ];

    test('the alphabet has 26 distinct symbols and none of the confusing ones', () {
      expect(alphabet, '23456789BCDFGHJKMNPQRTVWXY');
      expect(alphabet.length, 26);
      expect(alphabet.split('').toSet().length, 26);
      for (final c in ['0', '1', 'A', 'E', 'I', 'L', 'O', 'S', 'U', 'Z']) {
        expect(alphabet.contains(c), isFalse, reason: c);
      }
    });

    test('every code has 5 characters and only characters of the steam alphabet', () {
      final seen = <String>{};
      for (final secret in secrets) {
        final token = SteamToken(id: 's', secret: secret);
        for (var i = 0; i < 1500; i++) {
          final time = DateTime.fromMillisecondsSinceEpoch(
            1700000000000 + i * 30000 + (i % 29) * 1000 + (i % 1000),
            isUtc: true,
          );
          final code = token.otpFromTime(time);
          expect(code.length, 5, reason: '$secret at $time');
          for (final char in code.split('')) {
            expect(alphabet.contains(char), isTrue, reason: '"$char" in $code');
            seen.add(char);
          }
        }
      }
      // 3 * 1500 * 5 characters must reach (nearly) the whole alphabet
      expect(seen.length, greaterThanOrEqualTo(24));
    });

    test('a window gives one code from its first to its last millisecond', () {
      final token = SteamToken(id: 's', secret: secrets[0]);
      const windowStart = 1712666190; // multiple of 30
      expect(windowStart % 30, 0);
      final code = token.otpFromTime(_at(windowStart));
      expect(token.otpFromTime(_at(windowStart, 1)), code);
      expect(token.otpFromTime(_at(windowStart + 15)), code);
      expect(token.otpFromTime(_at(windowStart + 29, 999)), code);
      final next = token.otpFromTime(_at(windowStart + 30));
      expect(next, isNot(code));
      expect(token.otpFromTime(_at(windowStart + 59, 999)), next);
      expect(token.otpFromTime(_at(windowStart - 1, 999)), isNot(code));
    });

    test('29.999 s is floored to the first window, never rounded up to the second', () {
      final token = SteamToken(id: 's', secret: secrets[1]);
      final first = token.otpFromTime(_at(0));
      final second = token.otpFromTime(_at(30));
      expect(first, isNot(second));
      expect(token.otpFromTime(_at(29, 999)), first);
      expect(token.otpFromTime(_at(30)), second);
      expect(token.otpFromTime(_at(59, 999)), second);
      expect(token.otpFromTime(_at(60)), isNot(second));
    });

    test('the code equals the steam encoding of the 31 bit HOTP value of the same counter', () {
      for (final secret in secrets) {
        final token = SteamToken(id: 's', secret: secret);
        for (final seconds in [0, 29, 30, 59, 1712666212, 2000000000, 20000000000]) {
          final counter = seconds ~/ 30;
          // 10 digits are enough to hold the whole 31 bit value (max 2147483647)
          var value = int.parse(
            _hotp(
              digits: 10,
              counter: counter,
              secret: secret,
            ).otpValue,
          );
          expect(value, lessThan(1 << 31));
          final expected = StringBuffer();
          for (var i = 0; i < 5; i++) {
            expected.write(alphabet[value % alphabet.length]);
            value ~/= alphabet.length;
          }
          expect(
            token.otpFromTime(_at(seconds)),
            expected.toString(),
            reason: '$secret at $seconds s',
          );
        }
      }
    });

    test('the secret is case insensitive', () {
      final upper = SteamToken(id: 'a', secret: secrets[0]);
      final lower = SteamToken(id: 'b', secret: secrets[0].toLowerCase());
      expect(lower.otpFromTime(_at(1712666212)), upper.otpFromTime(_at(1712666212)));
    });

    test('another secret gives another code', () {
      final a = SteamToken(id: 'a', secret: secrets[0]).otpFromTime(_at(1712666212));
      final b = SteamToken(id: 'b', secret: secrets[1]).otpFromTime(_at(1712666212));
      expect(a, isNot(b));
    });

    test('otpValue and nextValue lie in the bracket of the surrounding calls', () {
      final token = SteamToken(id: 's', secret: secrets[0]);
      final before = DateTime.now();
      final value = token.otpValue;
      final next = token.nextValue;
      final after = DateTime.now();
      expect({
        token.otpFromTime(before),
        token.otpFromTime(after),
      }, contains(value));
      expect({
        token.otpFromTime(before.add(const Duration(seconds: 30))),
        token.otpFromTime(after.add(const Duration(seconds: 30))),
      }, contains(next));
      expect(value.length, 5);
      expect(next.length, 5);
    });
  });
}
