import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/day_password_token_view_mode.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';

void main() {
  _testDayPasswordToken();
}

void _testDayPasswordToken() {
  group('Day password creation/method', () {
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
      isLocked: false,
      folderId: 0,
    );
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
