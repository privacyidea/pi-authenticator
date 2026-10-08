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
import 'package:privacyidea_authenticator/model/version.dart';

HOTPToken get hotpToken => HOTPToken(
  counter: 1,
  label: 'label',
  issuer: 'issuer',
  id: 'id',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret',
  pin: true,
  tokenImage: 'example.png',
  sortIndex: 0,
  isLocked: true,
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

HOTPToken _oldHotp({String? serial = 'OLD-SERIAL', bool pin = false}) => HOTPToken(
  id: 'hotp-id',
  serial: serial,
  label: 'old label',
  issuer: 'old issuer',
  algorithm: Algorithms.SHA256,
  digits: 8,
  secret: _oldSecret,
  counter: 5,
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

HOTPToken _fullHotp() => HOTPToken(
  id: 'hotp-id',
  serial: 'HOTP-SERIAL',
  label: 'hotp label',
  issuer: 'hotp issuer',
  algorithm: Algorithms.SHA256,
  digits: 8,
  secret: _secret,
  counter: 1 << 40,
  tokenImage: 'https://example.com/hotp.png',
  pin: true,
  isLocked: true,
  isHidden: false,
  forceBiometricOption: ForceBiometricOption.biometric,
  folderId: 7,
  sortIndex: 3,
  containerSerial: 'CONT-1',
  checkedContainer: const ['CONT-1', 'CONT-2'],
  isOffline: true,
  origin: _jsonOrigin,
);

void main() {
  _testHotpToken();
  _testCopyUpdateByTemplate();
  _testLockStateInCopyWith();
  _testJsonRoundTrip();
}

void _testHotpToken() {
  group('HOTP Token creation', () {
    test('constructor', () {
      expect(hotpToken.counter, 1);
      expect(hotpToken.label, 'label');
      expect(hotpToken.issuer, 'issuer');
      expect(hotpToken.id, 'id');
      expect(hotpToken.algorithm, Algorithms.SHA1);
      expect(hotpToken.digits, 6);
      expect(hotpToken.secret, 'secret');
      expect(hotpToken.type, 'HOTP');
      expect(hotpToken.pin, true);
      expect(hotpToken.tokenImage, 'example.png');
      expect(hotpToken.sortIndex, 0);
      expect(hotpToken.isLocked, true);
      expect(hotpToken.folderId, 0);
    });

    test('withNextCounter', () {
      final withNextCounter = hotpToken.withNextCounter();
      expect(withNextCounter.counter, 2);
    });

    test('copyWith', () {
      final hotpCopy = hotpToken.copyWith(
        counter: 5,
        label: 'labelCopy',
        issuer: 'issuerCopy',
        id: 'idCopy',
        algorithm: Algorithms.SHA256,
        digits: 8,
        secret: 'secretCopy',
        pin: false,
        tokenImage: 'exampleCopy.png',
        sortIndex: 1,
        isLocked: false,
        folderId: () => 1,
      );
      expect(hotpCopy.counter, 5);
      expect(hotpCopy.label, 'labelCopy');
      expect(hotpCopy.issuer, 'issuerCopy');
      expect(hotpCopy.id, 'idCopy');
      expect(hotpCopy.algorithm, Algorithms.SHA256);
      expect(hotpCopy.digits, 8);
      expect(hotpCopy.secret, 'secretCopy');
      expect(hotpCopy.pin, false);
      expect(hotpCopy.tokenImage, 'exampleCopy.png');
      expect(hotpCopy.sortIndex, 1);
      expect(hotpCopy.isLocked, false);
      expect(hotpCopy.folderId, 1);
    });

    test('copyWith handles folderId null reset', () {
      final tokenWithFolder = hotpToken.copyWith(folderId: () => 5);
      final resetToken = tokenWithFolder.copyWith(folderId: () => null);
      expect(resetToken.folderId, isNull);
    });
  });

  group('serialization', () {
    group('fromUriMap', () {
      test('with full map', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.TOKENTYPE_OTPAUTH: 'HOTP',
          Token.PIN: Token.PIN_VALUE_TRUE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
          OTPToken.DIGITS: '6',
          HOTPToken.COUNTER: '10',
        };
        final hotpFromUriMap = HOTPToken.fromOtpAuthMap(uriMap);
        expect(hotpFromUriMap.counter, 10);
        expect(hotpFromUriMap.label, 'label');
        expect(hotpFromUriMap.issuer, 'issuer');
        expect(hotpFromUriMap.algorithm, Algorithms.SHA1);
        expect(hotpFromUriMap.secret, 'ONSWG4TFOQ======');
        expect(hotpFromUriMap.digits, 6);
        expect(hotpFromUriMap.type, 'HOTP');
        expect(hotpFromUriMap.pin, true);
        expect(hotpFromUriMap.tokenImage, 'example.png');
      });

      test('without secret', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.TOKENTYPE_OTPAUTH: 'HOTP',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '6',
          HOTPToken.COUNTER: '10',
        };
        expect(() => HOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('digits is zero', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
          OTPToken.DIGITS: '0',
        };
        expect(() => HOTPToken.fromOtpAuthMap(uriMap), throwsArgumentError);
      });

      test('invalid counter format defaults to 0', () {
        final uriMap = {
          OTPToken.SECRET_BASE32: 'JBSWY3DPEHPK3PXP',
          HOTPToken.COUNTER: 'abc',
        };
        final token = HOTPToken.fromOtpAuthMap(uriMap);
        expect(token.counter, 0);
      });

      test('with lowercase algorithm', () {
        final uriMap = {
          OTPToken.ALGORITHM: 'sha1',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(
            utf8.encode('secret'),
          ),
        };
        final hotpFromUriMap = HOTPToken.fromOtpAuthMap(uriMap);
        expect(hotpFromUriMap.algorithm, Algorithms.SHA1);
      });
    });

    test('toUriMap', () {
      final uriMap = hotpToken.toOtpAuthMap();
      expect(uriMap[Token.LABEL], 'label');
      expect(uriMap[OTPToken.ALGORITHM], 'SHA1');
      expect(uriMap[HOTPToken.COUNTER], '1');
    });

    test('fromJson/toJson', () {
      final json = hotpToken.toJson();
      final fromJson = HOTPToken.fromJson(json);
      expect(fromJson.counter, hotpToken.counter);
      expect(fromJson.secret, hotpToken.secret);
    });
  });

  group('isSameTokenAs', () {
    test('same id | same parameters', () {
      final token = hotpToken;
      expect(token.isSameTokenAs(token), true);
    });

    test('different id | same parameters', () {
      final t1 = hotpToken;
      final t2 = t1.copyWith(id: 'other-id');
      expect(t1.isSameTokenAs(t2), true);
    });

    test('same serial | different parameters', () {
      final t1 = HOTPToken(
        id: '1',
        secret: 's1',
        serial: 'SER1',
        algorithm: Algorithms.SHA1,
        digits: 6,
      );
      final t2 = HOTPToken(
        id: '2',
        secret: 's2',
        counter: 5,
        serial: 'SER1',
        algorithm: Algorithms.SHA1,
        digits: 6,
      );
      expect(t1.isSameTokenAs(t2), true);
    });
  });

  group('Calculate HOTP values (Legacy & RFC Vectors)', () {
    group('different counters 6 digits', () {
      test('OTP for counter == 0', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(token0.otpValue, '814628');
      });
      test('OTP for counter == 1', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: 1,
        );
        expect(token1.otpValue, '533881');
      });
    });

    group('different counters 8 digits', () {
      test('OTP for counter == 0', () {
        HOTPToken token0 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(token0.otpValue, '31814628');
      });
    });

    group('different algorithms 6 digits', () {
      test('OTP for sha256', () {
        HOTPToken token1 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('Secret')),
        );
        expect(token1.otpValue, '203782');
      });
      test('OTP for sha512', () {
        HOTPToken token2 = HOTPToken(
          id: '',
          algorithm: Algorithms.SHA512,
          digits: 6,
          secret: Encodings.base32.encode(utf8.encode('Secret')),
        );
        expect(token2.otpValue, '636350');
      });
    });
  });
}

void _testCopyUpdateByTemplate() {
  group('HOTPToken.copyUpdateByTemplate', () {
    final fullTemplate = <String, dynamic>{
      Token.LABEL: 'new label',
      Token.ISSUER: 'new issuer',
      Token.IMAGE: 'new.png',
      Token.SERIAL: 'NEW-SERIAL',
      OTPToken.ALGORITHM: 'SHA512',
      OTPToken.DIGITS: '6',
      OTPToken.SECRET_BASE32: _newSecret,
      HOTPToken.COUNTER: '42',
    };

    test('applies every value the template describes', () {
      final updated = _oldHotp().copyUpdateByTemplate(_template(fullTemplate));
      expect(updated.label, 'new label');
      expect(updated.issuer, 'new issuer');
      expect(updated.tokenImage, 'new.png');
      expect(updated.serial, 'NEW-SERIAL');
      expect(updated.algorithm, Algorithms.SHA512);
      expect(updated.digits, 6);
      expect(updated.secret, _newSecret);
      expect(updated.counter, 42);
    });

    test('keeps the identity and metadata the template does not describe', () {
      final original = _oldHotp();
      final updated = original.copyUpdateByTemplate(_template(fullTemplate));
      _expectMetadataKept(original, updated);
    });

    test('returns a new object and leaves the original untouched', () {
      final original = _oldHotp();
      final updated = original.copyUpdateByTemplate(_template(fullTemplate));
      expect(identical(updated, original), isFalse);
      expect(original.label, 'old label');
      expect(original.serial, 'OLD-SERIAL');
      expect(original.algorithm, Algorithms.SHA256);
      expect(original.secret, _oldSecret);
    });

    test('an update by the own template of a token with serial changes nothing', () {
      final original = _oldHotp();
      final template = original.toTemplate();
      expect(template.serial, 'OLD-SERIAL');
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
    });

    test('an update by the own template of a token without serial changes nothing', () {
      final original = _oldHotp(serial: null);
      final template = original.toTemplate();
      expect(template.serial, isNull);
      final updated = original.copyUpdateByTemplate(template);
      expect(updated.toJson(), original.toJson());
      expect(updated.serial, isNull);
    });

    test('a template with a serial replaces the serial', () {
      final updated = _oldHotp().copyUpdateByTemplate(
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
        final updated = _oldHotp().copyUpdateByTemplate(
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
      final updated = _oldHotp(serial: null).copyUpdateByTemplate(
        _template({OTPToken.SECRET_BASE32: _oldSecret}),
      );
      expect(updated.serial, isNull);
    });
  });

  group('HOTPToken.copyUpdateByTemplate pin handling', () {
    final minimalTemplate = <String, dynamic>{OTPToken.SECRET_BASE32: _oldSecret};

    test('pin True in the template locks the token', () {
      final updated = _oldHotp().copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_TRUE}),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('pin False in the template removes the pin and unlocks the token', () {
      final original = _oldHotp(pin: true);
      expect(original.isLocked, isTrue);
      final updated = original.copyUpdateByTemplate(
        _template({...minimalTemplate, Token.PIN: Token.PIN_VALUE_FALSE}),
      );
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });

    test('a template without pin keeps a pin protected token protected', () {
      final updated = _oldHotp(pin: true).copyUpdateByTemplate(
        _template(minimalTemplate),
      );
      expect(updated.pin, isTrue);
      expect(updated.isLocked, isTrue);
    });

    test('a template without pin keeps an unprotected token unprotected', () {
      final updated = _oldHotp().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.pin, isFalse);
      expect(updated.isLocked, isFalse);
    });
  });

  group('HOTPToken.copyUpdateByTemplate checkedContainer', () {
    final minimalTemplate = <String, dynamic>{OTPToken.SECRET_BASE32: _oldSecret};

    test('keeps the existing checkedContainer when the template carries none', () {
      final updated = _oldHotp().copyUpdateByTemplate(_template(minimalTemplate));
      expect(updated.checkedContainer, ['CONT-1']);
    });

    test(
      'applies the checkedContainer of the template additionalData',
      () {
        final updated = _oldHotp().copyUpdateByTemplate(
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
  group('HOTPToken lock state in copyWith', () {
    HOTPToken build({
      bool? pin,
      ForceBiometricOption? biometric,
      bool? isLocked,
      bool? isHidden,
    }) => HOTPToken(
      id: 'id',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: _secret,
      pin: pin,
      forceBiometricOption: biometric ?? ForceBiometricOption.none,
      isLocked: isLocked,
      isHidden: isHidden,
    );

    HOTPToken copyOf(
      HOTPToken token, {
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
  group('HOTPToken JSON round trip', () {
    test('all metadata and OTP fields survive the round trip', () {
      final original = _fullHotp();
      final restored = _viaStorage(original) as HOTPToken;
      _expectBaseEqual(restored, original);
      expect(restored.algorithm, Algorithms.SHA256);
      expect(restored.digits, 8);
      expect(restored.secret, _secret);
      expect(restored.counter, 1 << 40);
      expect(restored.otpValue, original.otpValue);
      expect(restored.nextValue, original.nextValue);
    });

    test('the JSON is stable (toJson of the restored token is identical)', () {
      final original = _fullHotp();
      expect(_jsonOf(_viaStorage(original)), _jsonOf(original));
    });

    test('counter 0 and a pure minimal token survive', () {
      final minimal = HOTPToken(
        id: 'min',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: _secret,
      );
      final restored = _viaStorage(minimal) as HOTPToken;
      _expectBaseEqual(restored, minimal);
      expect(restored.counter, 0);
      expect(restored.folderId, isNull);
      expect(restored.sortIndex, isNull);
      expect(restored.origin, isNull);
      expect(restored.serial, isNull);
      expect(restored.containerSerial, isNull);
      expect(restored.tokenImage, isNull);
      expect(restored.checkedContainer, isEmpty);
      expect(restored.isOffline, isFalse);
      expect(restored.pin, isFalse);
      expect(restored.isLocked, isFalse);
      expect(restored.isHidden, isFalse);
    });

    test('withNextCounter result survives the round trip', () {
      final restored = _viaStorage(_fullHotp().withNextCounter()) as HOTPToken;
      expect(restored.counter, (1 << 40) + 1);
    });


    test('HOTPToken: Token.fromJson dispatches to the own type', () {
      final restored = _viaStorage(_fullHotp());
      expect(restored.runtimeType.toString(), 'HOTPToken');
      expect(restored.type, _fullHotp().type);
    });

    test('HOTPToken: every ForceBiometricOption survives and locks the token', () {
      for (final option in ForceBiometricOption.values) {
        final token = _fullHotp().copyWith(
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

    test('HOTPToken: folder and sort index survive, also when null', () {
      final withValues = _viaStorage(_fullHotp());
      expect(withValues.folderId, _fullHotp().folderId);
      expect(withValues.sortIndex, _fullHotp().sortIndex);
      final cleared = _viaStorage(_fullHotp().copyWith(folderId: () => null));
      expect(cleared.folderId, isNull);
    });

    test('HOTPToken: a JSON written without the optional keys loads with defaults', () {
      final json = _jsonOf(_fullHotp())
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
