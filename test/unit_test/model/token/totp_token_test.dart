import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';

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

void main() {
  _testTotpToken();
}

void _testTotpToken() {
  group('TOTP Token creation', () {
    test('constructor', () {
      expect(totpToken.period, 30);
      expect(totpToken.label, 'label');
      expect(totpToken.issuer, 'issuer');
      expect(totpToken.id, 'id');
      expect(totpToken.algorithm, Algorithms.SHA1);
      expect(totpToken.digits, 6);
      expect(totpToken.secret, 'secret');
      expect(totpToken.type, 'TOTP');
      expect(totpToken.pin, false);
      expect(totpToken.tokenImage, 'example.png');
      expect(totpToken.sortIndex, 0);
      expect(totpToken.isLocked, false);
      expect(totpToken.folderId, 0);
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
      expect(totpCopy.type, 'TOTP');
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
          Token.OTPAUTH_TYPE: 'totp',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: '6',
          OTPToken.SECRET_BASE32: Encodings.base32.encode(utf8.encode('secret')),
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
        expect(totpFromUriMap.pin, false);
        expect(totpFromUriMap.tokenImage, 'example.png');
      });
      test('with missing secret', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'totp',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: 6,
          TOTPToken.PERIOD_SECONDS: 30,
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
      });
      test('with zero period', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'totp',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: 6,
          OTPToken.SECRET_BASE32: Uint8List.fromList(utf8.encode('secret')),
          TOTPToken.PERIOD_SECONDS: 0,
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
      });
      test('with zero digits', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'totp',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'SHA1',
          OTPToken.DIGITS: 0,
          OTPToken.SECRET_BASE32: Uint8List.fromList(utf8.encode('secret')),
          TOTPToken.PERIOD_SECONDS: 30,
        };
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
      });
      test('with lowercase algorithm', () {
        final uriMap = {
          Token.LABEL: 'label',
          Token.ISSUER: 'issuer',
          Token.OTPAUTH_TYPE: 'totp',
          Token.PIN: Token.PIN_VALUE_FALSE,
          Token.IMAGE: 'example.png',
          OTPToken.ALGORITHM: 'sha1',
          OTPToken.DIGITS: '6',
          OTPToken.SECRET_BASE32: Uint8List.fromList(utf8.encode('secret')),
          TOTPToken.PERIOD_SECONDS: '30',
        };
        final totpFromUriMap = TOTPToken.fromOtpAuthMap(uriMap);
        expect(totpFromUriMap.algorithm, Algorithms.SHA1);
      });
      test('with empty map', () {
        final uriMap = <String, dynamic>{};
        expect(() => TOTPToken.fromOtpAuthMap(uriMap), throwsA(isA<ArgumentError>()));
      });
    });
    test('toUriMap', () {
      final totpUriMap = totpToken.toOtpAuthMap();
      expect(totpUriMap[Token.LABEL], 'label');
      expect(totpUriMap[Token.ISSUER], 'issuer');
      expect(totpUriMap[Token.OTPAUTH_TYPE], 'TOTP');
      expect(totpUriMap[Token.PIN], 'False');
      expect(totpUriMap[Token.IMAGE], 'example.png');
      expect(totpUriMap[OTPToken.ALGORITHM], 'SHA1');
      expect(totpUriMap[OTPToken.DIGITS], '6');
      expect(totpUriMap[OTPToken.SECRET_BASE32], 'secret');
      expect(totpUriMap[TOTPToken.PERIOD_SECONDS], '30');
    });
    test('fromJson', () {
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
      final totpFromJson = TOTPToken.fromJson(totpJson);
      expect(totpFromJson.period, 11);
      expect(totpFromJson.label, 'label');
      expect(totpFromJson.issuer, 'issuer');
      expect(totpFromJson.id, 'id');
      expect(totpFromJson.algorithm, Algorithms.SHA1);
      expect(totpFromJson.digits, 22);
      expect(totpFromJson.secret, 'secret');
      expect(totpFromJson.type, 'totp');
      expect(totpFromJson.pin, true);
      expect(totpFromJson.tokenImage, 'example.png');
      expect(totpFromJson.sortIndex, 33);
      expect(totpFromJson.isLocked, true);
      expect(totpFromJson.folderId, 44);
    });
    test('toJson', () {
      final totpJson = totpToken.toJson();
      expect(totpJson['period'], 30);
      expect(totpJson['label'], 'label');
      expect(totpJson['issuer'], 'issuer');
      expect(totpJson['id'], 'id');
      expect(totpJson['algorithm'], 'SHA1');
      expect(totpJson['digits'], 6);
      expect(totpJson['secret'], 'secret');
      expect(totpJson['type'], 'TOTP');
      expect(totpJson['pin'], false);
      expect(totpJson['tokenImage'], 'example.png');
      expect(totpJson['sortIndex'], 0);
      expect(totpJson['isLocked'], false);
      expect(totpJson['folderId'], 0);
    });
  });
  group('isSameTokenAs', () {
    test('no serial | same id | same parameters', () {
      // No serial. Should recognize by id or parameters
      final totpToken = TOTPToken(
        period: 30,
        label: 'label',
        issuer: 'issuer',
        id: 'id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
      );

      expect(totpToken.isSameTokenAs(totpToken.copyWith()), isTrue);
    });
    test('no serial | same id | different parameters', () {
      // No serial. Should recognize by id
      final totpToken = TOTPToken(
        period: 30,
        label: 'label',
        issuer: 'issuer',
        id: 'id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
      );

      expect(totpToken.isSameTokenAs(totpToken.copyWith(algorithm: Algorithms.SHA256)), isTrue);
    });
    test('no serial | different id | same parameters', () {
      // No serial, different id. Should recognize by parameters
      final totpToken = TOTPToken(
        period: 30,
        label: 'label',
        issuer: 'issuer',
        id: 'id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
      );

      expect(totpToken.isSameTokenAs(totpToken.copyWith(id: 'id2')), isTrue);
    });
    test('no serial | different id | different parameters', () {
      // No serial, different id, different parameters. Should not recognize
      final totpToken = TOTPToken(
        period: 30,
        label: 'label',
        issuer: 'issuer',
        id: 'id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
      );

      expect(totpToken.isSameTokenAs(totpToken.copyWith(id: 'id2', algorithm: Algorithms.SHA256)), isFalse);
    });
    test('same serial | different id | different parameters', () {
      // Different id, different parameters. Should recognize by serial
      final totpToken = TOTPToken(
        period: 30,
        label: 'label',
        issuer: 'issuer',
        serial: 'serial',
        id: 'id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
      );

      expect(totpToken.isSameTokenAs(totpToken.copyWith(id: 'id2', algorithm: Algorithms.SHA256)), isTrue);
    });
    test('different serial | same id | different parameters', () {
      // Different serial, different parameters. Should recognize by id
      final totpToken = TOTPToken(
        period: 30,
        label: 'label',
        issuer: 'issuer',
        serial: 'serial',
        id: 'id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
      );

      expect(totpToken.isSameTokenAs(totpToken.copyWith(serial: 'serial2', algorithm: Algorithms.SHA256)), isTrue);
    });
    test('different serial | different id | same parameters', () {
      // Different serial, different id. Should NOT recognize by parameters
      final totpToken = TOTPToken(
        period: 30,
        label: 'label',
        issuer: 'issuer',
        serial: 'serial',
        id: 'id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
      );

      expect(totpToken.isSameTokenAs(totpToken.copyWith(serial: 'serial2', id: 'id2')), isFalse);
    });
  });
  group('Calculate TOTP Token values', () {
    // Basicly the TOTP token is a HOTP token but the counter is calculated based on the current time.
    // So we can test TOTP token by comparing its OTP value with a HOTP value with the same counter.
    // as we know the HOTP token works, we can assume the TOTP token works as well when they have the same otp value.
    group('different periods 6 digits', () {
      const digits = 6;
      test('30s period', () {
        const period = Duration(seconds: 30);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
      test('60s period', () {
        const period = Duration(seconds: 60);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
    });
    group('different periods 8 digits', () {
      const digits = 8;
      test('30s period', () {
        const period = Duration(seconds: 30);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
      test('60s period', () {
        const period = Duration(seconds: 60);
        final hotpToken = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
          counter: (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period.inSeconds,
        );
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: Algorithms.SHA1,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
    });
    group('different algorithms 6 digits', () {
      const digits = 6;
      const period = Duration(seconds: 30);
      test('algorithm SHA1', () {
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
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
      test('algorithm SHA256', () {
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
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
      test('algorithm SHA512', () {
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
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
    });
    group('different algorithms 8 digits', () {
      const digits = 8;
      const period = Duration(seconds: 30);
      test('algorithm SHA1', () {
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
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
      test('algorithm SHA256', () {
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
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
      test('algorithm SHA512', () {
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
        final totpToken = TOTPToken(
          period: period.inSeconds,
          label: '',
          issuer: '',
          id: '',
          algorithm: algorithm,
          digits: digits,
          secret: Encodings.base32.encode(utf8.encode('secret')),
        );
        expect(totpToken.otpValue, hotpToken.otpValue);
      });
    });
  });
}
