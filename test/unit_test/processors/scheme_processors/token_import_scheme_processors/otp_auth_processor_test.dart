import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';

void main() {
  _testOtpAuthProcessor();
}

void _testOtpAuthProcessor() {
  group('Otp Auth Processor Test', () {
    group('TOTP', () {
      test('processUri', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8&period=45';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('TOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final totpToken = token0 as TOTPToken;
        expect(totpToken.period, equals(45));
        expect(totpToken.digits, equals(8));
        expect(totpToken.algorithm.name, equals('SHA256'));
      });
      test('processUri missing algorithm', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&digits=6&period=30';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('TOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final totpToken = token0 as TOTPToken;
        expect(totpToken.period, equals(30));
        expect(totpToken.digits, equals(6));
        expect(totpToken.algorithm.name, equals('SHA1'));
      });
      test('processUri missing digits', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA1&period=30';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('TOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final totpToken = token0 as TOTPToken;
        expect(totpToken.period, equals(30));
        expect(totpToken.digits, equals(6));
        expect(totpToken.algorithm.name, equals('SHA1'));
      });
      test('processUri missing period', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA1&digits=6';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('TOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final totpToken = token0 as TOTPToken;
        expect(totpToken.period, equals(30));
        expect(totpToken.digits, equals(6));
        expect(totpToken.algorithm.name, equals('SHA1'));
      });
      test('processUri missing secret', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://totp/account?issuer=issuer&algorithm=SHA1&digits=6&period=30';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>());
        final message = result0.asFailed!.message;
        final error = result0.asFailed!.error;
        expect(message.toLowerCase().contains('secret') || error.toString().toLowerCase().contains('secret'), isTrue);
      });
      test('processUri issuer from path', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://totp/issuer:account?secret=AAAAAAAA&issuer=issuer2&algorithm=SHA1&digits=6&period=30';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('TOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final totpToken = token0 as TOTPToken;
        expect(totpToken.period, equals(30));
        expect(totpToken.digits, equals(6));
        expect(totpToken.algorithm.name, equals('SHA1'));
      });
      group('2step', () {});
    });
    group('HOTP', () {
      test('processUri', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8&counter=5';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('HOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final hotpToken = token0 as HOTPToken;
        expect(hotpToken.counter, equals(5));
        expect(hotpToken.digits, equals(8));
        expect(hotpToken.algorithm.name, equals('SHA256'));
      });
      test('processUri missing algorithm', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&digits=8&counter=5';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('HOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final hotpToken = token0 as HOTPToken;
        expect(hotpToken.counter, equals(5));
        expect(hotpToken.digits, equals(8));
        expect(hotpToken.algorithm.name, equals('SHA1'));
      });
      test('processUri missing digits', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&counter=5';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('HOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final hotpToken = token0 as HOTPToken;
        expect(hotpToken.counter, equals(5));
        expect(hotpToken.digits, equals(6));
        expect(hotpToken.algorithm.name, equals('SHA256'));
      });
      test('processUri missing counter', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>());
        final message = result0.asFailed!.message;
        final error = result0.asFailed!.error;
        expect(message.toLowerCase().contains(HOTPToken.COUNTER) || error.toString().toLowerCase().contains(HOTPToken.COUNTER), isTrue);
      });
      test('processUri missing secret', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://hotp/account?issuer=issuer&algorithm=SHA256&digits=8&counter=5';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>());
        final message = result0.asFailed!.message;
        final error = result0.asFailed!.error;
        expect(message.toLowerCase().contains(OTPToken.SECRET_BASE32) || error.toString().toLowerCase().contains(OTPToken.SECRET_BASE32), isTrue);
      });
      test('processUri issuer from path', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://hotp/issuer:account?secret=AAAAAAAA&algorithm=SHA256&digits=8&counter=5';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('HOTP'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final hotpToken = token0 as HOTPToken;
        expect(hotpToken.counter, equals(5));
        expect(hotpToken.digits, equals(8));
        expect(hotpToken.algorithm.name, equals('SHA256'));
      });

      test('2step', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://hotp/issuer:account?secret=AAAAAAAA&algorithm=SHA256&digits=8&counter=5&2step_salt=10&2step_output=20&2step_difficulty=10000';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>()); // FIXME: 2step secret is currently generated by the ui so it will fail in tests
      });
    });
    group('DayPassword', () {
      test('processUri', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&period=86400&digits=8';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type.toLowerCase(), equals('daypassword'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final dayPasswordToken = token0 as DayPasswordToken;
        expect(dayPasswordToken.period, equals(const Duration(days: 1)));
        expect(dayPasswordToken.digits, equals(8));
        expect(dayPasswordToken.algorithm.name, equals('SHA256'));
      });

      test('processUri missing algorithm', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&period=86400&digits=8';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type.toLowerCase(), equals('daypassword'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final dayPasswordToken = token0 as DayPasswordToken;
        expect(dayPasswordToken.period, equals(const Duration(days: 1)));
        expect(dayPasswordToken.digits, equals(8));
        expect(dayPasswordToken.algorithm.name, equals('SHA1'));
      });

      test('processUri missing digits', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&period=172800';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type.toLowerCase(), equals('daypassword'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final dayPasswordToken = token0 as DayPasswordToken;
        expect(dayPasswordToken.period, equals(const Duration(days: 2)));
        expect(dayPasswordToken.digits, equals(6));
        expect(dayPasswordToken.algorithm.name, equals('SHA256'));
      });

      test('processUri missing period', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type.toLowerCase(), equals('daypassword'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final dayPasswordToken = token0 as DayPasswordToken;
        expect(dayPasswordToken.period, equals(const Duration(days: 1)));
        expect(dayPasswordToken.digits, equals(8));
        expect(dayPasswordToken.algorithm.name, equals('SHA256'));
      });

      test('processUri missing secret', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString = 'otpauth://daypassword/account?issuer=issuer&algorithm=SHA256&period=86400&digits=8';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>());
        final message = result0.asFailed!.message;
        final error = result0.asFailed!.error;
        expect(message.toLowerCase().contains('secret') || error.toString().toLowerCase().contains('secret'), isTrue);
      });
    });
    group('Push Token', () {
      test('processUri', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://pipush/PIPU0000D79E?url=https%3A//123.456.78.9/ttype/push&ttl=10&issuer=privacyIDEA&enrollment_credential=3342826741eb64e8f94e01920a88745bccdecd9e&v=1&serial=PIPU0000D79E&sslverify=0';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('privacyIDEA'));
        expect(token0.label, equals('PIPU0000D79E'));
        expect(token0.type.toLowerCase(), equals('pipush'));
        expect(token0.origin, isNotNull);
        expect(token0.origin!.appName, ApplicationCustomization.defaultCustomization.appName);
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final pushToken = token0 as PushToken;
        expect(pushToken.url, equals(Uri.parse('https://123.456.78.9/ttype/push')));
        expect(pushToken.expirationDate, isNotNull);
        // DateTimes.now() are never the same
        // So we check the difference in minutes and allow a 5 second difference (9:59 => 9 minutes, 10:04 => 10 minutes)
        expect(pushToken.expirationDate!.difference(DateTime.now().subtract(const Duration(seconds: 5))).inMinutes, equals(10));
        expect(pushToken.serial, equals('PIPU0000D79E'));
        expect(pushToken.sslVerify, isFalse);
      });
    });
  });
}
