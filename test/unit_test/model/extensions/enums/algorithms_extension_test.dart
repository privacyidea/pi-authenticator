import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/algorithms_extension.dart';

void main() {
  _testAlgorithmsExtension();
}

void _testAlgorithmsExtension() {
  group('Algorithms Extension', () {
    group('generateTOTPCodeString', () {});
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
