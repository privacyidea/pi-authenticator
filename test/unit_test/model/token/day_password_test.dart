import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

DayPasswordToken get dayPasswordToken => DayPasswordToken(
      period: const Duration(hours: 24),
      viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
      label: 'label',
      issuer: 'issuer',
      id: 'id',
      algorithm: Algorithms.SHA1,
      digits: 6,
      secret: 'secret',
      pin: true,
      tokenImage: 'example.png',
      sortIndex: 0,
      isLocked: false, // if pin is true, its automatically forced to be locked=true
      folderId: 0,
    );
void main() {
  _testDayPasswordToken();
}

void _testDayPasswordToken() {
  group('Day password creation', () {
    test('constructor', () {
      expect(dayPasswordToken.period, const Duration(hours: 24));
      expect(dayPasswordToken.viewMode, DayPasswordTokenViewMode.VALIDUNTIL);
      expect(dayPasswordToken.label, 'label');
      expect(dayPasswordToken.issuer, 'issuer');
      expect(dayPasswordToken.id, 'id');
      expect(dayPasswordToken.algorithm, Algorithms.SHA1);
      expect(dayPasswordToken.digits, 6);
      expect(dayPasswordToken.secret, 'secret');
      expect(dayPasswordToken.pin, true);
      expect(dayPasswordToken.tokenImage, 'example.png');
      expect(dayPasswordToken.sortIndex, 0);
      expect(dayPasswordToken.isLocked, true);
      expect(dayPasswordToken.folderId, 0);
    });
    test('copyWith', () {
      final totpCopy = dayPasswordToken.copyWith(
        period: const Duration(hours: 12),
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
      expect(totpCopy.period, const Duration(hours: 12));
      expect(totpCopy.label, 'labelCopy');
      expect(totpCopy.issuer, 'issuerCopy');
      expect(totpCopy.id, 'idCopy');
      expect(totpCopy.algorithm, Algorithms.SHA256);
      expect(totpCopy.digits, 8);
      expect(totpCopy.secret, 'secretCopy');
      expect(totpCopy.type, 'DAYPASSWORD');
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
          Token.OTPAUTH_TYPE: 'DAYPASSWORD',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '6',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(utf8.encode('secret')),
          TOTPToken.PERIOD_SECONDS: '30',
        };
        final totpFromUriMap = DayPasswordToken.fromOtpAuthMap(uriMap);
        expect(totpFromUriMap.period, const Duration(seconds: 30));
        expect(totpFromUriMap.label, 'label');
        expect(totpFromUriMap.issuer, 'issuer');
        expect(totpFromUriMap.algorithm, Algorithms.SHA1);
        expect(totpFromUriMap.digits, 6);
        expect(totpFromUriMap.secret, 'ONSWG4TFOQ======');
        expect(totpFromUriMap.type, 'DAYPASSWORD');
        expect(totpFromUriMap.pin, false);
        expect(totpFromUriMap.tokenImage, 'example.png');
      });
      test('with missing secret', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'DAYPASSWORD',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: 6,
          TOTPToken.PERIOD_SECONDS: 30,
        };
        expect(() => DayPasswordToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
      });
      test('with zero period', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'DAYPASSWORD',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '6',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(utf8.encode('secret')),
          TOTPToken.PERIOD_SECONDS: '0',
        };
        expect(() => DayPasswordToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
        var errorContainsPeriod = false;
        try {
          DayPasswordToken.fromOtpAuthMap(uriMap);
        } catch (e) {
          errorContainsPeriod = e.toString().contains(TOTPToken.PERIOD_SECONDS);
        }
        expect(errorContainsPeriod, true);
      });
      test('with zero digits', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'DAYPASSWORD',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '0',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(utf8.encode('secret')),
          TOTPToken.PERIOD_SECONDS: '30',
        };
        expect(() => DayPasswordToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
        var errorContainsDigits = false;
        try {
          DayPasswordToken.fromOtpAuthMap(uriMap);
        } catch (e) {
          errorContainsDigits = e.toString().contains(OTPToken.DIGITS);
        }
        expect(errorContainsDigits, true);
      });
      test('with lowercase algorithm', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'DAYPASSWORD',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'sha1',
          OTPToken.DIGITS: '6',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(utf8.encode('secret')),
          TOTPToken.PERIOD_SECONDS: '30',
        };
        final totpFromUriMap = DayPasswordToken.fromOtpAuthMap(uriMap);
        expect(totpFromUriMap.algorithm, Algorithms.SHA1);
      });
      test('with empty map', () {
        final uriMap = <String, dynamic>{};
        expect(() => DayPasswordToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
      });
    });
    test('toUriMap', () {
      final uriMap = dayPasswordToken.toOtpAuthMap();
      expect(uriMap[Token.LABEL], 'label');
      expect(uriMap[Token.ISSUER], 'issuer');
      expect(uriMap[Token.OTPAUTH_TYPE], 'DAYPASSWORD');
      expect(uriMap[Token.PIN], Token.PIN_VALUE_TRUE);
      expect(uriMap[Token.IMAGE], 'example.png');
      expect(uriMap[OTPToken.ALGORITHM], 'SHA1');
      expect(uriMap[OTPToken.DIGITS], '6');
      expect(uriMap[OTPToken.SECRET_BASE32], 'secret');
      expect(uriMap[TOTPToken.PERIOD_SECONDS], '86400');
    });
    test('fromJson', () {
      final totpJson = {
        'period': 11000000,
        'label': 'label',
        'issuer': 'issuer',
        'id': 'id',
        'algorithm': 'SHA1',
        'digits': 22,
        'secret': 'secret',
        'type': 'DAYPASSWORD',
        'pin': true,
        'tokenImage': 'example.png',
        'sortIndex': 33,
        'isLocked': true,
        'folderId': 44,
      };
      final totpFromJson = DayPasswordToken.fromJson(totpJson);
      expect(totpFromJson.period, const Duration(seconds: 11));
      expect(totpFromJson.label, 'label');
      expect(totpFromJson.issuer, 'issuer');
      expect(totpFromJson.id, 'id');
      expect(totpFromJson.algorithm, Algorithms.SHA1);
      expect(totpFromJson.digits, 22);
      expect(totpFromJson.secret, 'secret');
      expect(totpFromJson.type, 'DAYPASSWORD');
      expect(totpFromJson.pin, true);
      expect(totpFromJson.tokenImage, 'example.png');
      expect(totpFromJson.sortIndex, 33);
      expect(totpFromJson.isLocked, true);
      expect(totpFromJson.folderId, 44);
    });
    test('toJson', () {
      final totpJson = dayPasswordToken.toJson();
      expect(totpJson['period'], 86400000000);
      expect(totpJson['label'], 'label');
      expect(totpJson['issuer'], 'issuer');
      expect(totpJson['id'], 'id');
      expect(totpJson['algorithm'], 'SHA1');
      expect(totpJson['digits'], 6);
      expect(totpJson['secret'], 'secret');
      expect(totpJson['type'], 'DAYPASSWORD');
      expect(totpJson['pin'], true);
      expect(totpJson['tokenImage'], 'example.png');
      expect(totpJson['sortIndex'], 0);
      expect(totpJson['isLocked'], true);
      expect(totpJson['folderId'], 0);
    });
  });
  group('isSameTokenAs', () {
    test('no serial | same id | same parameters', () {
      // No serial. Should recognize by id or parameters
      final dayPasswordToken = DayPasswordToken(
        period: const Duration(hours: 24),
        viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
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

      expect(dayPasswordToken.isSameTokenAs(dayPasswordToken.copyWith()), true);
    });
    test('no serial | same id | different parameters', () {
      // No serial. Should recognize by id
      final dayPasswordToken = DayPasswordToken(
        period: const Duration(hours: 24),
        viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
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

      expect(dayPasswordToken.isSameTokenAs(dayPasswordToken.copyWith(algorithm: Algorithms.SHA256)), true);
    });
    test('no serial | different id | same parameters', () {
      // No serial, different id. Should recognize by parameters
      final dayPasswordToken = DayPasswordToken(
        period: const Duration(hours: 24),
        viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
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

      expect(dayPasswordToken.isSameTokenAs(dayPasswordToken.copyWith(id: 'id2')), true);
    });
    test('no serial | different id | different parameters', () {
      // No serial, different id, different parameters. Should not recognize
      final dayPasswordToken = DayPasswordToken(
        period: const Duration(hours: 24),
        viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
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

      expect(dayPasswordToken.isSameTokenAs(dayPasswordToken.copyWith(id: 'id2', algorithm: Algorithms.SHA256)), false);
    });
    test('same serial | different id | different parameters', () {
      // Different id, different parameters. Should recognize by serial
      final dayPasswordToken = DayPasswordToken(
        period: const Duration(hours: 24),
        viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
        label: 'label',
        issuer: 'issuer',
        serial: 'serial',
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

      expect(dayPasswordToken.isSameTokenAs(dayPasswordToken.copyWith(id: 'id2', algorithm: Algorithms.SHA256)), true);
    });
    test('different serial | same id | different parameters', () {
      // Different serial, different parameters. Should recognize by id
      final dayPasswordToken = DayPasswordToken(
        period: const Duration(hours: 24),
        viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
        label: 'label',
        issuer: 'issuer',
        serial: 'serial',
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

      expect(dayPasswordToken.isSameTokenAs(dayPasswordToken.copyWith(serial: 'serial2', algorithm: Algorithms.SHA256)), true);
    });
    test('different serial | different id | same parameters', () {
      // Different serial, different id. Should NOT recognize by parameters
      final dayPasswordToken = DayPasswordToken(
        period: const Duration(hours: 24),
        viewMode: DayPasswordTokenViewMode.VALIDUNTIL,
        label: 'label',
        issuer: 'issuer',
        serial: 'serial',
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

      expect(dayPasswordToken.isSameTokenAs(dayPasswordToken.copyWith(serial: 'serial2', id: 'id2')), false);
    });
  });
  group('Calculate day password values', () {
    // Basicly the day password is a HOTP token but the counter is calculated based on the current time.
    // So we can test day password token by comparing its OTP value with a HOTP value with the same counter.
    // as we know the HOTP token works, we can assume the day password token works as well when they have the same otp value.

    group('different periods 6 digits', () {
      const digits = 6;
      test('1h period', () {
        const period = Duration(hours: 1);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('12h period', () {
        const period = Duration(hours: 12);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('24h period', () {
        const period = Duration(hours: 24);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('3 days period', () {
        const period = Duration(days: 3);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('28 days period', () {
        const period = Duration(days: 28);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
    });
    group('different periods 8 digits', () {
      const digits = 8;
      test('1h period', () {
        const period = Duration(hours: 1);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('12h period', () {
        const period = Duration(hours: 12);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('24h period', () {
        const period = Duration(hours: 24);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('3 days period', () {
        const period = Duration(days: 3);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('28 days period', () {
        const period = Duration(days: 28);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
    });
    group('different algorithms 6 digits', () {
      const digits = 6;
      const period = Duration(hours: 24);
      test('SHA1 algorithm', () {
        const algorithm = Algorithms.SHA1;
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('SHA256 algorithm', () {
        const algorithm = Algorithms.SHA256;
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('SHA512 algorithm', () {
        const algorithm = Algorithms.SHA512;
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
    });
    group('different algorithms 8 digits', () {
      const digits = 8;
      const period = Duration(hours: 24);
      test('SHA1 algorithm', () {
        const algorithm = Algorithms.SHA1;
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('SHA256 algorithm', () {
        const algorithm = Algorithms.SHA256;
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
      test('SHA512 algorithm', () {
        const algorithm = Algorithms.SHA512;
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final dayPassword1h = DayPasswordToken(
          label: '',
          issuer: '',
          id: '',
          period: period,
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(hotpToken.otpValue, dayPassword1h.otpValue);
      });
    });
  });
}
