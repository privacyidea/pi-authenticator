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
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/version.dart';

TOTPToken get totpToken => TOTPToken(
  period: 30,
  label: 'label',
  issuer: 'issuer',
  id: 'id',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret',
  pin: false,
  tokenImage: 'example.png',
  sortIndex: 0,
  isLocked: false,
  folderId: 0,
);

/// Returns a skip reason unless the bug tests are enabled explicitly.
String? bug(String description) =>
    const bool.fromEnvironment('RUN_BUG_TESTS') ? null : 'BUG: $description';

const String _serialErasedBug =
    'copyUpdateByTemplate sets serial: () => uriMap[SERIAL], so a template without serial erases the existing serial';

const String _checkedContainerBug =
    'only DayPasswordToken.copyUpdateByTemplate applies the checkedContainer of the template additionalData, the other types drop it';

const String _frozenBug =
    'copyWith passes this.isLocked/this.isHidden (derived getters) as explicit state, '
    'so a lock derived from pin/forceBiometricOption survives removing it';

const String _frozenAfterLoadBug =
    'copyWith passes this.isLocked/this.isHidden as explicit state and the JSON stores the derived values, '
    'so a token loaded from storage does not become hidden when a pin is added';

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

TOTPToken _oldTotp({String? serial = 'OLD-SERIAL', bool pin = false}) => TOTPToken(
  id: 'totp-id',
  serial: serial,
  label: 'old label',
  issuer: 'old issuer',
  algorithm: Algorithms.SHA256,
  digits: 8,
  secret: _oldSecret,
  period: 60,
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

TOTPToken _fullTotp() => TOTPToken(
  id: 'totp-id',
  serial: 'TOTP-SERIAL',
  label: 'totp label',
  issuer: 'totp issuer',
  algorithm: Algorithms.SHA512,
  digits: 7,
  secret: _secret,
  period: 45,
  tokenImage: 'totp.png',
  pin: true,
  isLocked: true,
  isHidden: true,
  forceBiometricOption: ForceBiometricOption.pin,
  folderId: 8,
  sortIndex: 4,
  containerSerial: 'CONT-1',
  checkedContainer: const ['CONT-1'],
  isOffline: true,
  origin: _jsonOrigin,
);

// --- helpers for the OTP values at fixed timestamps ---

String _base32(String ascii) => Encodings.base32.encode(utf8.encode(ascii));

/// The seed values of RFC 6238 appendix B, one per algorithm.
final Map<Algorithms, String> _rfcSecrets = {
  Algorithms.SHA1: _base32('12345678901234567890'),
  Algorithms.SHA256: _base32('12345678901234567890123456789012'),
  Algorithms.SHA512: _base32(
    '1234567890123456789012345678901234567890123456789012345678901234',
  ),
};

/// RFC 6238 appendix B, 8 digits, 30 seconds. The RFC lists the times up to
/// 20000000000 s; the values are [SHA1, SHA256, SHA512].
const Map<int, List<String>> _rfcVectors = {
  59: ['94287082', '46119246', '90693936'],
  1111111109: ['07081804', '68084774', '25091201'],
  1111111111: ['14050471', '67062674', '99943326'],
  1234567890: ['89005924', '91819424', '93441116'],
  2000000000: ['69279037', '90698825', '38618901'],
  20000000000: ['65353130', '77737706', '47863826'],
};

DateTime _at(int seconds, [int millis = 0]) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + millis, isUtc: true);

TOTPToken _totp({
  Algorithms algorithm = Algorithms.SHA1,
  int digits = 8,
  int period = 30,
  String? secret,
}) => TOTPToken(
  id: 'totp',
  algorithm: algorithm,
  digits: digits,
  period: period,
  secret: secret ?? _rfcSecrets[algorithm]!,
);

HOTPToken _hotp({
  Algorithms algorithm = Algorithms.SHA1,
  int digits = 8,
  required int counter,
  String? secret,
}) => HOTPToken(
  id: 'hotp',
  algorithm: algorithm,
  digits: digits,
  counter: counter,
  secret: secret ?? _rfcSecrets[algorithm]!,
);

void main() {
  group('TOTP Token creation', () {
    test('constructor', () {
      final token = totpToken;
      expect(token.period, 30);
      expect(token.label, 'label');
      expect(token.issuer, 'issuer');
      expect(token.id, 'id');
      expect(token.algorithm, Algorithms.SHA1);
      expect(token.digits, 6);
      expect(token.secret, 'secret');
      expect(token.type, 'TOTP');
      expect(token.pin, false);
      expect(token.tokenImage, 'example.png');
      expect(token.sortIndex, 0);
      expect(token.isLocked, false);
      expect(token.folderId, 0);
    });

    test('copyWith', () {
      final totpCopy = totpToken.copyWith(
        period: 60,
        label: 'labelCopy',
        issuer: 'issuerCopy',
        id: 'idCopy',
        algorithm: Algorithms.SHA256,
        digits: 8,
        secret: 'secretCopy',
        pin: true,
        tokenImage: 'exampleCopy.png',
        sortIndex: 1,
        isLocked: true,
        folderId: () => 1,
      );
      expect(totpCopy.period, 60);
      expect(totpCopy.label, 'labelCopy');
      expect(totpCopy.issuer, 'issuerCopy');
      expect(totpCopy.id, 'idCopy');
      expect(totpCopy.algorithm, Algorithms.SHA256);
      expect(totpCopy.digits, 8);
      expect(totpCopy.secret, 'secretCopy');
      expect(totpCopy.pin, true);
      expect(totpCopy.tokenImage, 'exampleCopy.png');
      expect(totpCopy.sortIndex, 1);
      expect(totpCopy.isLocked, true);
      expect(totpCopy.folderId, 1);
    });
  });

  group('serialization', () {
    group('fromUriMap', () {
      test('with full map', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.TOKENTYPE_OTPAUTH: 'totp',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '6',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
          TOTPToken.PERIOD_SECONDS: '30',
        };
        final totpFromUriMap = TOTPToken.fromOtpAuthMap(uriMap);
        expect(totpFromUriMap.period, 30);
        expect(totpFromUriMap.label, 'label');
        expect(totpFromUriMap.issuer, 'issuer');
        expect(totpFromUriMap.algorithm, Algorithms.SHA1);
        expect(totpFromUriMap.digits, 6);
        expect(totpFromUriMap.secret, 'ONSWG4TFOQ======');
        expect(totpFromUriMap.type, 'TOTP');
      });

      test('with missing secret throws', () {
        final uriMap = {
          Token.TOKENTYPE_OTPAUTH: 'totp',
          OTPToken.DIGITS: '6',
          TOTPToken.PERIOD_SECONDS: '30',
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('with zero period throws', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
          TOTPToken.PERIOD_SECONDS: '0',
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('with zero digits throws', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
          OTPToken.DIGITS: '0',
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('with lowercase algorithm', () {
        final uriMap = {
          OTPToken.ALGORITHM: 'sha1',
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
        };
        final totpFromUriMap = TOTPToken.fromOtpAuthMap(uriMap);
        expect(totpFromUriMap.algorithm, Algorithms.SHA1);
      });
    });

    test('toUriMap', () {
      final totpUriMap = totpToken.toOtpAuthMap();
      expect(totpUriMap[Token.LABEL], 'label');
      expect(totpUriMap[Token.ISSUER], 'issuer');
      expect(totpUriMap[OTPToken.ALGORITHM], 'SHA1');
      expect(totpUriMap[OTPToken.DIGITS], '6');
      expect(totpUriMap[TOTPToken.PERIOD_SECONDS], '30');
    });

    test('fromJson/toJson consistency', () {
      final totpJson = {
        'period': 11,
        'label': 'label',
        'issuer': 'issuer',
        'id': 'id',
        'algorithm': 'SHA1',
        'digits': 22,
        'secret': 'secret',
        'type': 'totp',
        'pin': true,
        'tokenImage': 'example.png',
        'sortIndex': 33,
        'isLocked': true,
        'folderId': 44,
      };
      final fromJson = TOTPToken.fromJson(totpJson);
      expect(fromJson.period, 11);
      expect(fromJson.digits, 22);
      expect(fromJson.toJson()['period'], 11);
    });
  });

  group('isSameTokenAs', () {
    test('same serial | different id', () {
      final t1 = totpToken.copyWith(serial: () => 'SN1', id: 'id1');
      final t2 = totpToken.copyWith(serial: () => 'SN1', id: 'id2');
      expect(t1.isSameTokenAs(t2), isTrue);
    });

    test('no serial | different id | same params', () {
      final t1 = totpToken.copyWith(id: 'id1');
      final t2 = totpToken.copyWith(id: 'id2');
      expect(t1.isSameTokenAs(t2), isTrue);
    });

    test('no serial | different id | different params', () {
      final t1 = totpToken.copyWith(id: 'id1', algorithm: Algorithms.SHA1);
      final t2 = totpToken.copyWith(id: 'id2', algorithm: Algorithms.SHA256);
      expect(t1.isSameTokenAs(t2), isFalse);
    });
  });

  group('Calculate TOTP values (Full Algorithms & Digits)', () {
    final now = DateTime.now();
    final secret = Encodings.base32.encode(utf8.encode('secret'));

    void testTotpVsHotp(int period, int digits, Algorithms algorithm) {
      final counter = (now.millisecondsSinceEpoch / 1000) ~/ period;

      final hotp = HOTPToken(
        id: '',
        algorithm: algorithm,
        digits: digits,
        counter: counter,
        secret: secret,
      );

      final totp = TOTPToken(
        period: period,
        id: '',
        algorithm: algorithm,
        digits: digits,
        secret: secret,
      );

      expect(
        totp.otpFromTime(now),
        hotp.otpValue,
        reason: 'Failed for $algorithm, $digits digits, $period period',
      );
    }

    test('SHA1 - 6 digits - 30s', () => testTotpVsHotp(30, 6, Algorithms.SHA1));
    test('SHA1 - 6 digits - 60s', () => testTotpVsHotp(60, 6, Algorithms.SHA1));
    test('SHA1 - 8 digits - 30s', () => testTotpVsHotp(30, 8, Algorithms.SHA1));
    test(
      'SHA256 - 6 digits - 30s',
      () => testTotpVsHotp(30, 6, Algorithms.SHA256),
    );
    test(
      'SHA512 - 8 digits - 60s',
      () => testTotpVsHotp(60, 8, Algorithms.SHA512),
    );
  });

  _testCopyUpdateByTemplate();
  _testLockStateInCopyWith();
  _testJsonRoundTrip();
  _testOtpAtFixedTimes();
}

void _testCopyUpdateByTemplate() {
  group('TOTPToken.copyUpdateByTemplate', () {
    final fullTemplate = <String, dynamic>{
      Token.LABEL: 'new label',
      Token.ISSUER: 'new issuer',
      Token.IMAGE: 'new.png',
      Token.SERIAL: 'NEW-SERIAL',
      OTPToken.ALGORITHM: 'SHA512',
      OTPToken.DIGITS: '6',
      OTPToken.SECRET_BASE32: _newSecret,
      TOTPToken.PERIOD_SECONDS: '45',
    };

    test('applies every value the template describes', () {
      final updated = _oldTotp().copyUpdateByTemplate(_template(fullTemplate));
      expect(updated.label, 'new label');
      expect(updated.issuer, 'new issuer');
      expect(updated.tokenImage, 'new.png');
      expect(updated.serial, 'NEW-SERIAL');
      expect(updated.algorithm, Algorithms.SHA512);
      expect(updated.digits, 6);
      expect(updated.secret, _newSecret);
      expect(updated.period, 45);
    });

    test('keeps the identity and metadata the template does not describe', () {
      final original = _oldTotp();
      final updated = original.copyUpdateByTemplate(_template(fullTemplate));
      _expectMetadataKept(original, updated);
    });

    test('returns a new object and leaves the original untouched', () {
      final original = _oldTotp();
      final updated = original.copyUpdateByTemplate(_template(fullTemplate));
      expect(identical(updated, original), isFalse);
      expect(original.label, 'old label');
      expect(original.serial, 'OLD-SERIAL');
      expect(original.algorithm, Algorithms.SHA256);
      expect(original.secret, _oldSecret);
    });

    test('an update by the own template of a token with serial changes nothing', () {
      final original = _oldTotp();
      final template = original.toTemplate();
      expect(template.serial, 'OLD-SERIAL');
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
    });

    test('an update by the own template of a token without serial changes nothing', () {
      final original = _oldTotp(serial: null);
      final template = original.toTemplate();
      expect(template.serial, isNull);
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
      expect(updated.serial, isNull);
    });

    test('a template with a serial replaces the serial', () {
      final updated = _oldTotp().copyUpdateByTemplate(
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
        final updated = _oldTotp().copyUpdateByTemplate(
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
      final updated = _oldTotp(serial: null).copyUpdateByTemplate(
        _template({OTPToken.SECRET_BASE32: _oldSecret}),
      );
      expect(updated.serial, isNull);
    });
  });

  group('TOTPToken.copyUpdateByTemplate pin handling', () {
    final minimalTemplate = <String, dynamic>{OTPToken.SECRET_BASE32: _oldSecret};

    test('pin True in the template locks the token', () {
      final updated = _oldTotp().copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_TRUE}),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('pin False in the template removes the pin and unlocks the token', () {
      final original = _oldTotp(pin: true);
      expect(original.isLocked, isTrue);
      final updated = original.copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_FALSE}),
      );
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });

    test('a template without pin keeps a pin protected token protected', () {
      final updated = _oldTotp(pin: true).copyUpdateByTemplate(
        _template(minimalTemplate),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('a template without pin keeps an unprotected token unprotected', () {
      final updated = _oldTotp().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });
  });

  group('TOTPToken.copyUpdateByTemplate checkedContainer', () {
    final minimalTemplate = <String, dynamic>{OTPToken.SECRET_BASE32: _oldSecret};

    test('keeps the existing checkedContainer when the template carries none', () {
      final updated = _oldTotp().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.checkedContainer, ['CONT-1']);
    });

    test(
      'applies the checkedContainer of the template additionalData',
      () {
        final updated = _oldTotp().copyUpdateByTemplate(
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
  group('TOTPToken lock state in copyWith', () {
    TOTPToken build({
      bool? pin,
      ForceBiometricOption? biometric,
      bool? isLocked,
      bool? isHidden,
    }) => TOTPToken(
      id: 'id',
      period: 30,
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: _secret,
      pin: pin,
      forceBiometricOption: biometric ?? ForceBiometricOption.none,
      isLocked: isLocked,
      isHidden: isHidden,
    );

    TOTPToken copyOf(
      TOTPToken token, {
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

  group('lock state after loading', () {
    test(
      'a token loaded from storage hides itself when a pin is added',
      () {
        final stored = TOTPToken(
          id: 'x',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: _secret,
          period: 30,
        );
        final loaded = _viaStorage(stored) as TOTPToken;
        final pinned = loaded.copyWith(pin: true);
        expect(pinned.isLocked, isTrue);
        expect(pinned.isHidden, isTrue);
      },
      skip: bug(_frozenAfterLoadBug),
    );
  });
}

void _testJsonRoundTrip() {
  group('TOTPToken JSON round trip', () {
    test('all metadata and OTP fields survive the round trip', () {
      final original = _fullTotp();
      final restored = _viaStorage(original) as TOTPToken;
      _expectBaseEqual(restored, original);
      expect(restored.algorithm, Algorithms.SHA512);
      expect(restored.digits, 7);
      expect(restored.secret, _secret);
      expect(restored.period, 45);
      final time = DateTime.utc(2024, 5, 6, 7, 8, 9);
      expect(restored.otpFromTime(time), original.otpFromTime(time));
    });

    test('the JSON is stable', () {
      final original = _fullTotp();
      expect(_jsonOf(_viaStorage(original)), _jsonOf(original));
    });

    test('a minimal token survives', () {
      final minimal = TOTPToken(
        id: 'min',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: _secret,
        period: 30,
      );
      final restored = _viaStorage(minimal) as TOTPToken;
      _expectBaseEqual(restored, minimal);
      expect(restored.period, 30);
    });


    test('TOTPToken: Token.fromJson dispatches to the own type', () {
      final restored = _viaStorage(_fullTotp());
      expect(restored.runtimeType.toString(), 'TOTPToken');
      expect(restored.type, _fullTotp().type);
    });

    test('TOTPToken: every ForceBiometricOption survives and locks the token', () {
      for (final option in ForceBiometricOption.values) {
        final token = _fullTotp().copyWith(
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

    test('TOTPToken: folder and sort index survive, also when null', () {
      final withValues = _viaStorage(_fullTotp());
      expect(withValues.folderId, _fullTotp().folderId);
      expect(withValues.sortIndex, _fullTotp().sortIndex);
      final cleared = _viaStorage(_fullTotp().copyWith(folderId: () => null));
      expect(cleared.folderId, isNull);
    });

    test('TOTPToken: a JSON written without the optional keys loads with defaults', () {
      final json = _jsonOf(_fullTotp())
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

    test('an explicit lock without pin is stored and restored', () {
      final token = TOTPToken(
        id: 'x',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: _secret,
        period: 30,
        isLocked: true,
      );
      expect(token.pin, isFalse);
      expect(token.isLocked, isTrue);
      final restored = _viaStorage(token);
      expect(restored.pin, isFalse);
      expect(restored.isLocked, isTrue);
      expect(restored.isHidden, isTrue);
    });

    test('OTP tokens of every algorithm keep generating the same codes', () {
      for (final algorithm in Algorithms.values) {
        final original = TOTPToken(
          id: 'a',
          algorithm: algorithm,
          digits: 8,
          secret: _secret,
          period: 30,
        );
        final restored = _viaStorage(original) as OTPToken;
        final time = DateTime.utc(2001, 9, 9, 1, 46, 40);
        expect(
          (restored as TOTPToken).otpFromTime(time),
          original.otpFromTime(time),
          reason: '$algorithm',
        );
      }
    });
  });
}

void _testOtpAtFixedTimes() {
  group('TOTP RFC 6238 vectors (8 digits, 30 s)', () {
    for (final entry in _rfcVectors.entries) {
      for (final (index, algorithm) in Algorithms.values.indexed) {
        test('${algorithm.name} at ${entry.key} s', () {
          expect(
            _totp(algorithm: algorithm).otpFromTime(_at(entry.key)),
            entry.value[index],
          );
        });
      }
    }

    test('the vector table covers every algorithm of the enum', () {
      expect(Algorithms.values, [
        Algorithms.SHA1,
        Algorithms.SHA256,
        Algorithms.SHA512,
      ]);
      expect(_rfcSecrets.keys.toSet(), Algorithms.values.toSet());
    });

    test('a local (non UTC) DateTime gives the same code as the UTC one', () {
      for (final entry in _rfcVectors.entries) {
        final local = DateTime.fromMillisecondsSinceEpoch(entry.key * 1000);
        expect(
          _totp().otpFromTime(local),
          entry.value[0],
          reason: 'at ${entry.key} s',
        );
      }
    });

    test('the 6 and 7 digit codes are the tail of the 8 digit code', () {
      for (final entry in _rfcVectors.entries) {
        for (final (index, algorithm) in Algorithms.values.indexed) {
          final eight = entry.value[index];
          expect(
            _totp(algorithm: algorithm, digits: 6).otpFromTime(_at(entry.key)),
            eight.substring(2),
          );
          expect(
            _totp(algorithm: algorithm, digits: 7).otpFromTime(_at(entry.key)),
            eight.substring(1),
          );
        }
      }
    });

    test('leading zeros are kept (RFC value 07081804)', () {
      final code = _totp().otpFromTime(_at(1111111109));
      expect(code, '07081804');
      expect(code.length, 8);
    });

    test('the code has exactly [digits] characters and only digits', () {
      for (final digits in [4, 5, 6, 7, 8, 9, 10]) {
        for (var i = 0; i < 50; i++) {
          final code = _totp(digits: digits).otpFromTime(_at(i * 30 + 7));
          expect(code, matches(RegExp('^[0-9]{$digits}\$')));
        }
      }
    });
  });

  group('TOTP period boundaries', () {
    for (final period in [1, 15, 30, 60, 3600]) {
      for (final algorithm in Algorithms.values) {
        test('${algorithm.name}, period $period s: window edges', () {
          final token = _totp(algorithm: algorithm, period: period);
          final periodMs = period * 1000;
          for (final k in [0, 1, 2, 12345, 40000000]) {
            final windowStart = k * periodMs;
            final expected = _hotp(
              algorithm: algorithm,
              counter: k,
            ).otpValue;
            DateTime ms(int value) =>
                DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
            expect(
              token.otpFromTime(ms(windowStart)),
              expected,
              reason: 'first millisecond of window $k',
            );
            expect(
              token.otpFromTime(ms(windowStart + periodMs ~/ 2)),
              expected,
              reason: 'middle of window $k',
            );
            expect(
              token.otpFromTime(ms(windowStart + periodMs - 1)),
              expected,
              reason: 'last millisecond of window $k',
            );
            expect(
              token.otpFromTime(ms(windowStart + periodMs)),
              _hotp(algorithm: algorithm, counter: k + 1).otpValue,
              reason: 'first millisecond of window ${k + 1}',
            );
          }
        });
      }
    }

    test('period - 1 ms still belongs to the old window, period belongs to the new one', () {
      final token = _totp();
      final before = token.otpFromTime(_at(29, 999));
      final at = token.otpFromTime(_at(30));
      expect(before, token.otpFromTime(_at(0)));
      expect(at, isNot(before));
      expect(at, token.otpFromTime(_at(59, 999)));
      expect(token.otpFromTime(_at(60)), isNot(at));
    });

    test('every second of a window has the same code', () {
      final token = _totp();
      final code = token.otpFromTime(_at(1111111110));
      // 1111111110 = 37037037 * 30, a window start
      for (var s = 0; s < 30; s++) {
        expect(token.otpFromTime(_at(1111111110 + s)), code, reason: '+$s s');
      }
      expect(token.otpFromTime(_at(1111111110 + 30)), isNot(code));
      expect(token.otpFromTime(_at(1111111110 - 1)), isNot(code));
    });

    test('the value one period later is the value of the next counter', () {
      final token = _totp();
      const start = 1111111110;
      for (var k = 0; k < 6; k++) {
        expect(
          token.otpFromTime(_at(start + 30 * k, 4321)),
          _hotp(counter: start ~/ 30 + k).otpValue,
          reason: 'k = $k',
        );
      }
      expect(
        token.otpFromTime(_at(start + 30)),
        _hotp(counter: start ~/ 30 + 1).otpValue,
      );
    });

    test('the same secret gives other codes for other periods in the same second', () {
      final a = _totp().otpFromTime(_at(1234567890));
      final b = _totp(period: 60).otpFromTime(_at(1234567890));
      expect(a, '89005924');
      expect(a, isNot(b));
      expect(b, _hotp(counter: 1234567890 ~/ 60).otpValue);
    });

    test('period 0 or negative falls back to 30 s and generates 30 s codes', () {
      for (final period in [0, -1, -30]) {
        final token = _totp(period: period);
        expect(token.period, 30);
        expect(token.otpFromTime(_at(59)), '94287082');
      }
    });

    test('the secret is case insensitive', () {
      final lower = _totp(secret: _rfcSecrets[Algorithms.SHA1]!.toLowerCase());
      expect(lower.otpFromTime(_at(59)), '94287082');
    });
  });

  group('TOTP getters that read the clock', () {
    test('otpValue and nextValue lie in the bracket of the surrounding calls', () {
      final token = _totp();
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
    });

    test('secondsUntilNextOTP and currentProgress stay inside their ranges', () {
      for (final period in [1, 30, 60, 3600]) {
        final token = _totp(period: period);
        final until = token.secondsUntilNextOTP;
        final progress = token.currentProgress;
        expect(until, greaterThan(0));
        expect(until, lessThanOrEqualTo(period));
        expect(progress, greaterThanOrEqualTo(0));
        expect(progress, lessThan(1));
      }
    });
  });
}
