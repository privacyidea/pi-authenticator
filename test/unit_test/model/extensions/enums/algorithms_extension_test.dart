import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/algorithms_extension.dart';

void main() {
  _testAlgorithmsExtension();
}

void _testAlgorithmsExtension() {
  final zeroTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

  final oneYearFromEpoch = DateTime.fromMillisecondsSinceEpoch(31536000 * 1000);
  group('Algorithms Extension', () {
    group('generateTOTPCodeString', () {
      group('OTP default (lengh 6, interval 30, SHA1)', () {
        test('OTP for zero seconds from epoch', () {
          final otpValue = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 30),
            time: zeroTimestamp,
          );
          expect(otpValue, equals('328482'));
        });
        test('OTP for one year from epoch', () {
          final otpValue = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 30),
            time: oneYearFromEpoch,
          );
          expect(otpValue, equals('869960'));
        });
      });
      group('different length 8 digits', () {
        test('OTP for zero seconds from epoch', () {
          final otpValue = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 8,
            interval: Duration(seconds: 30),
            time: zeroTimestamp,
          );
          expect(otpValue, equals('35328482'));
        });
        test('OTP for one year from epoch', () {
          final otpValue = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 8,
            interval: Duration(seconds: 30),
            time: oneYearFromEpoch,
          );
          expect(otpValue, equals('15869960'));
        });
      });
      group('different algorithms SHA 256', () {
        test('OTP for zero seconds from epoch', () {
          final otpValue = Algorithms.SHA256.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 30),
            time: zeroTimestamp,
          );
          expect(otpValue, equals('356306'));
        });
        test('OTP for one year from epoch', () {
          final otpValue = Algorithms.SHA256.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 30),
            time: oneYearFromEpoch,
          );
          expect(otpValue, equals('213627'));
        });
      });
      group('different algorithms SHA 512', () {
        test('OTP for zero seconds from epoch', () {
          final otpValue = Algorithms.SHA512.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 30),
            time: zeroTimestamp,
          );
          expect(otpValue, equals('674061'));
        });
        test('OTP for one year from epoch', () {
          final otpValue = Algorithms.SHA512.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 30),
            time: oneYearFromEpoch,
          );
          expect(otpValue, equals('495577'));
        });
      });
      group('different interval 60 Seconds', () {
        test('OTP for zero seconds from epoch', () {
          final otpValue = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 60),
            time: zeroTimestamp,
          );
          expect(otpValue, equals('328482'));
        });
        test('OTP for one year from epoch', () {
          final otpValue = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 60),
            time: oneYearFromEpoch,
          );
          expect(otpValue, equals('383428'));
        });
        test('compare half year 60 sec, 1 year 30 sec & hotp value', () {
          final oneYear60SecCounter = 31536000 ~/ 60;
          final halfYear30SecCounter = 15768000 ~/ 30;
          expect(oneYear60SecCounter, equals(halfYear30SecCounter));
          final hotpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: oneYear60SecCounter, length: 6);

          final otpValueOneYear60Sec = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 60),
            time: DateTime.fromMillisecondsSinceEpoch(31536000 * 1000),
          );
          final otpValueHalfYear30Sec = Algorithms.SHA1.generateTOTPCodeString(
            secret: 'secret',
            length: 6,
            interval: Duration(seconds: 30),
            time: DateTime.fromMillisecondsSinceEpoch(15768000 * 1000),
          );
          expect(otpValueOneYear60Sec, equals(otpValueHalfYear30Sec));
          expect(otpValueOneYear60Sec, equals(hotpValue));
        });
      });
      group('is not google', () {
        test('OTP for zero seconds from epoch', () {
          final otpValue =
              Algorithms.SHA1.generateTOTPCodeString(secret: 'secret', length: 6, interval: Duration(seconds: 30), time: zeroTimestamp, isGoogle: false);
          expect(otpValue, equals('862089'));
        });
        test('OTP for one year from epoch', () {
          final otpValue =
              Algorithms.SHA1.generateTOTPCodeString(secret: 'secret', length: 6, interval: Duration(seconds: 30), time: oneYearFromEpoch, isGoogle: false);
          expect(otpValue, equals('265498'));
        });
      });
    });

    group('generateHOTPCodeString', () {
      group('different couters 6 digits', () {
        test('OTP for counter == 0', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 0, length: 6);
          expect(otpValue, equals('328482'));
        });

        test('OTP for counter == 1', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 1, length: 6);
          expect(otpValue, equals('812658'));
        });

        test('OTP for counter == 2', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 2, length: 6);
          expect(otpValue, equals('073348'));
        });

        test('OTP for counter == 8', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 8, length: 6);
          expect(otpValue, equals('985814'));
        });
      });
      group('different couters 8 digits', () {
        test('OTP for counter == 0', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 0, length: 8);
          expect(otpValue, equals('35328482'));
        });

        test('OTP for counter == 1', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 1, length: 8);
          expect(otpValue, equals('30812658'));
        });

        test('OTP for counter == 2', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 2, length: 8);
          expect(otpValue, equals('41073348'));
        });

        test('OTP for counter == 8', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 8, length: 8);
          expect(otpValue, equals('12985814'));
        });
      });
      group('different algorithms 6 digits', () {
        test('OTP for sha1', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 0, length: 6);
          expect(otpValue, equals('328482'));
        });

        test('OTP for sha256', () {
          final otpValue = Algorithms.SHA256.generateHOTPCodeString(secret: 'secret', counter: 0, length: 6);
          expect(otpValue, equals('356306'));
        });

        test('OTP for sha512', () {
          final otpValue = Algorithms.SHA512.generateHOTPCodeString(secret: 'secret', counter: 0, length: 6);
          expect(otpValue, equals('674061'));
        });
      });
      group('different algorithms 8 digits', () {
        test('OTP for sha1', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 0, length: 8);
          expect(otpValue, equals('35328482'));
        });

        test('OTP for sha256', () {
          final otpValue = Algorithms.SHA256.generateHOTPCodeString(secret: 'secret', counter: 0, length: 8);
          expect(otpValue, equals('03356306'));
        });

        test('OTP for sha512', () {
          final otpValue = Algorithms.SHA512.generateHOTPCodeString(secret: 'secret', counter: 0, length: 8);
          expect(otpValue, equals('66674061'));
        });
      });
      group('is not google', () {
        test('OTP for sha1', () {
          final otpValue = Algorithms.SHA1.generateHOTPCodeString(secret: 'secret', counter: 0, length: 6, isGoogle: false);
          expect(otpValue, equals('814628'));
        });

        test('OTP for sha256', () {
          final otpValue = Algorithms.SHA256.generateHOTPCodeString(secret: 'secret', counter: 0, length: 6, isGoogle: false);
          expect(otpValue, equals('059019'));
        });

        test('OTP for sha512', () {
          final otpValue = Algorithms.SHA512.generateHOTPCodeString(secret: 'secret', counter: 0, length: 6, isGoogle: false);
          expect(otpValue, equals('377469'));
        });
      });
    });
  });
}
