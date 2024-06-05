import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/free_otp_plus_qr_processor.dart';

void main() {
  _testFreeOtpPlusQrProcessor();
}

void _testFreeOtpPlusQrProcessor() {
  group('Free Otp Plus Qr Processor', () {
    FreeOtpPlusQrProcessor;
    test('processUri', () async {
      // Arrange
      final normalOtpAuthUri = Uri.parse('otpauth://totp/FreeOTP+:alice?secret=secret&issuer=FreeOTP&algorithm=SHA1&digits=6&period=30');
      // Act
      final results = await const FreeOtpPlusQrProcessor().processUri(normalOtpAuthUri);
      // Assert
      expect(results.length, equals(1));
      expect(results.first, isA<ProcessorResultSuccess<Token>>());
      final firstResult = results.first as ProcessorResultSuccess<Token>;
      expect(firstResult.resultData, isA<Token>());
      expect(firstResult.resultData.issuer, equals('FreeOTP+'));
      expect(firstResult.resultData.label, equals('alice'));
      expect(firstResult.resultData, isA<TOTPToken>());
      expect(firstResult.resultData.origin!.appName, equals('FreeOTP+'));
    });
    test('processUri without secret', () async {
      // Arrange
      final normalOtpAuthUri = Uri.parse('otpauth://totp/FreeOTP+:alice?issuer=FreeOTP&algorithm=SHA1&digits=6&period=30');
      // Act
      final results = await const FreeOtpPlusQrProcessor().processUri(normalOtpAuthUri);
      // Assert
      expect(results.length, equals(1));
      expect(results.first, isA<ProcessorResultFailed<Token>>());
      final firstResult = results.first as ProcessorResultFailed<Token>;
      expect(firstResult.message.isNotEmpty, equals(true));
    });
    test('processUri without counter', () async {
      // Arrange
      final normalOtpAuthUri = Uri.parse('otpauth://hotp/FreeOTP+:alice?secret=secret&issuer=FreeOTP&algorithm=SHA1&digits=6');
      // Act
      final results = await const FreeOtpPlusQrProcessor().processUri(normalOtpAuthUri);
      // Assert
      expect(results.length, equals(1));
      expect(results.first, isA<ProcessorResultSuccess<Token>>());
      final firstResult = results.first.asSuccess!;
      expect(firstResult.resultData, isA<Token>());
      expect(firstResult.resultData.issuer, equals('FreeOTP+'));
      expect(firstResult.resultData.label, equals('alice'));
      expect(firstResult.resultData, isA<HOTPToken>());
      expect(firstResult.resultData.origin!.appName, equals('FreeOTP+'));
      final hotpToken = firstResult.resultData as HOTPToken;
      expect(hotpToken.counter, equals(0));
    });
  });
}
