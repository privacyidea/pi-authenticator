import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_argument_error.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_exception.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';

void main() {
  _testOtpAuthProcessor();
  _testOtpAuthProcessorEdgeCases();
}

void _testOtpAuthProcessor() {
  group('Otp Auth Processor Test', () {
    group('TOTP', () {
      test('processUri', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8&period=45';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&digits=6&period=30';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA1&period=30';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://totp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA1&digits=6';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://totp/account?issuer=issuer&algorithm=SHA1&digits=6&period=30';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>());
        final message = result0.asFailed!.message(AppLocalizationsEn());
        final error = result0.asFailed!.error;
        expect(
          message.toLowerCase().contains('secret') ||
              error.toString().toLowerCase().contains('secret'),
          isTrue,
        );
      });
      test('processUri issuer from path', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://totp/issuer:account?secret=AAAAAAAA&issuer=issuer2&algorithm=SHA1&digits=6&period=30';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final totpToken = token0 as TOTPToken;
        expect(totpToken.period, equals(30));
        expect(totpToken.digits, equals(6));
        expect(totpToken.algorithm.name, equals('SHA1'));
      });
      group('2step', () {
        test('processUri', () async {
          // Arrange
          const processor = OtpAuthProcessor();
          const uriString =
              'otpauth://totp/issuer:account?secret=AAAAAAAA&algorithm=SHA256&digits=8&period=45&2step_salt=10&2step_output=20&2step_difficulty=10000';
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
          expect(
            token0.origin!.appName,
            ApplicationCustomization.defaultCustomization.appName,
          );
          expect(token0.origin!.isPrivacyIdeaToken, isNull);
          expect(token0.origin!.data, equals(uriString));
          final totpToken = token0 as TOTPToken;
          expect(totpToken.period, equals(45));
          expect(totpToken.digits, equals(8));
          expect(totpToken.algorithm.name, equals('SHA256'));
          // Secret should differ from original due to 2step PBKDF2 derivation
          expect(totpToken.secret, isNot(equals('AAAAAAAA')));
        });
      });
    });
    group('HOTP', () {
      test('processUri', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8&counter=5';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&digits=8&counter=5';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&counter=5';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final hotpToken = token0 as HOTPToken;
        expect(hotpToken.counter, equals(5));
        expect(hotpToken.digits, equals(6));
        expect(hotpToken.algorithm.name, equals('SHA256'));
      });
      test('processUri missing counter uses default 0', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://hotp/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8';
        final uri = Uri.parse(uriString);

        // Act
        final results = await processor.processUri(uri);

        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];

        expect(result0, isA<ProcessorResultSuccess<Token>>());

        final token = result0.asSuccess!.resultData as HOTPToken;

        expect(token.counter, equals(0));
        expect(token.label, equals('account'));
        expect(token.issuer, equals('issuer'));
      });
      test('processUri missing secret', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://hotp/account?issuer=issuer&algorithm=SHA256&digits=8&counter=5';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>());
        final message = result0.asFailed!.message(AppLocalizationsEn());
        final error = result0.asFailed!.error;
        expect(
          message.toLowerCase().contains(OTPToken.SECRET_BASE32) ||
              error.toString().toLowerCase().contains(OTPToken.SECRET_BASE32),
          isTrue,
        );
      });
      test('processUri issuer from path', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://hotp/issuer:account?secret=AAAAAAAA&algorithm=SHA256&digits=8&counter=5';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        expect(result0, isA<ProcessorResultSuccess>());
        final token0 = result0.asSuccess!.resultData;
        expect(token0.issuer, equals('issuer'));
        expect(token0.label, equals('account'));
        expect(token0.type, equals('HOTP'));
        expect(token0.origin, isNotNull);
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final hotpToken = token0 as HOTPToken;
        expect(hotpToken.counter, equals(5));
        expect(hotpToken.digits, equals(8));
        expect(hotpToken.algorithm.name, equals('SHA256'));
        // Secret should differ from original due to 2step PBKDF2 derivation
        expect(hotpToken.secret, isNot(equals('AAAAAAAA')));
      });
    });
    group('DayPassword', () {
      test('processUri', () async {
        // Arrange
        const processor = OtpAuthProcessor();
        const uriString =
            'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&period=86400&digits=8';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&period=86400&digits=8';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&period=172800';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://daypassword/account?secret=AAAAAAAA&issuer=issuer&algorithm=SHA256&digits=8';
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
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
        const uriString =
            'otpauth://daypassword/account?issuer=issuer&algorithm=SHA256&period=86400&digits=8';
        final uri = Uri.parse(uriString);
        // Act
        final results = await processor.processUri(uri);
        // Assert
        expect(results.length, equals(1));
        final result0 = results[0];
        expect(result0, isA<ProcessorResultFailed>());
        final message = result0.asFailed!.message(AppLocalizationsEn());
        final error = result0.asFailed!.error;
        expect(
          message.toLowerCase().contains('secret') ||
              error.toString().toLowerCase().contains('secret'),
          isTrue,
        );
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
        expect(
          token0.origin!.appName,
          ApplicationCustomization.defaultCustomization.appName,
        );
        expect(token0.origin!.isPrivacyIdeaToken, isNull);
        expect(token0.origin!.data, equals(uriString));
        final pushToken = token0 as PushToken;
        expect(
          pushToken.url,
          equals(Uri.parse('https://123.456.78.9/ttype/push')),
        );
        expect(pushToken.expirationDate, isNotNull);
        // DateTimes.now() are never the same
        // So we check the difference in minutes and allow a 5 second difference (9:59 => 9 minutes, 10:04 => 10 minutes)
        expect(
          pushToken.expirationDate!
              .difference(DateTime.now().subtract(const Duration(seconds: 5)))
              .inMinutes,
          equals(10),
        );
        expect(pushToken.serial, equals('PIPU0000D79E'));
        expect(pushToken.sslVerify, isFalse);
      });
    });
  });
}

const _processor = OtpAuthProcessor();
final _l = AppLocalizationsEn();

Future<List<ProcessorResult<Token>>> _run(String uri) =>
    _processor.processUri(Uri.parse(uri));

/// Processes [uri] and expects exactly one successful result.
Future<Token> _ok(String uri) async {
  final results = await _run(uri);
  expect(results, hasLength(1), reason: uri);
  final result = results.single;
  expect(
    result.isSuccess,
    isTrue,
    reason: '$uri failed: ${result.asFailed?.message(_l)}',
  );
  return result.asSuccess!.resultData;
}

/// Processes [uri] and expects exactly one failed result.
Future<ProcessorResultFailed<Token>> _failed(String uri) async {
  final results = await _run(uri);
  expect(results, hasLength(1), reason: uri);
  expect(results.single.isFailed, isTrue, reason: '$uri should have failed');
  return results.single.asFailed!;
}

/// True if [secret] (as stored in a token) decodes to at least one key byte.
bool _hasUsableKey(String secret) {
  try {
    return Encodings.base32.decode(secret).isNotEmpty;
  } catch (_) {
    return false;
  }
}

void _testOtpAuthProcessorEdgeCases() {
  group('OtpAuthProcessor edge cases', () {
    group('path / label / issuer', () {
      test(
        'otpauth://totp without a path returns a failed result and does not throw',
        () async {
          final results = await _run('otpauth://totp?secret=AAAAAAAA');
          expect(results, hasLength(1));
          expect(results.single.isFailed, isTrue);
        },
        skip:
            'BUG: otp_auth_processor.dart:138 uri.path.substring(1) throws RangeError for an empty path (outside try/catch)',
      );

      test(
        'otpauth://hotp and pipush without a path also return a failed result',
        () async {
          for (final uri in [
            'otpauth://hotp?secret=AAAAAAAA',
            'otpauth://pipush?serial=x',
          ]) {
            final results = await _run(uri);
            expect(results.single.isFailed, isTrue, reason: uri);
          }
        },
        skip:
            'BUG: otp_auth_processor.dart:138 uri.path.substring(1) throws RangeError for an empty path (outside try/catch)',
      );

      test(
        'currently the missing path surfaces as RangeError (characterization)',
        () async {
          await expectLater(
            _run('otpauth://totp?secret=AAAAAAAA'),
            throwsA(isA<RangeError>()),
          );
        },
      );

      test(
        'a lone slash as path yields a token with empty label and issuer',
        () async {
          final token = await _ok('otpauth://totp/?secret=AAAAAAAA');
          expect(token.label, '');
          expect(token.issuer, '');
          expect(token.type, 'TOTP');
        },
      );

      test('label without issuer: issuer stays empty', () async {
        final token = await _ok('otpauth://totp/alice?secret=AAAAAAAA');
        expect(token.label, 'alice');
        expect(token.issuer, '');
      });

      test('issuer only from the issuer parameter', () async {
        final token = await _ok(
          'otpauth://totp/alice?secret=AAAAAAAA&issuer=ACME',
        );
        expect(token.label, 'alice');
        expect(token.issuer, 'ACME');
      });

      test('issuer prefix in the label is split off', () async {
        final token = await _ok('otpauth://totp/ACME:alice?secret=AAAAAAAA');
        expect(token.issuer, 'ACME');
        expect(token.label, 'alice');
      });

      test(
        'equal label prefix and issuer parameter give that issuer',
        () async {
          final token = await _ok(
            'otpauth://totp/ACME:alice?secret=AAAAAAAA&issuer=ACME',
          );
          expect(token.issuer, 'ACME');
          expect(token.label, 'alice');
        },
      );

      test(
        'conflicting label prefix and issuer parameter: label prefix wins',
        () async {
          final token = await _ok(
            'otpauth://totp/Prefix:alice?secret=AAAAAAAA&issuer=Param',
          );
          expect(token.issuer, 'Prefix');
          expect(token.label, 'alice');
        },
      );

      test(
        'percent encoded colon (%3A) separates issuer and label like a plain colon',
        () async {
          final token = await _ok(
            'otpauth://totp/ACME%3Aalice?secret=AAAAAAAA',
          );
          expect(token.issuer, 'ACME');
          expect(token.label, 'alice');
        },
      );

      test('A:B:C does not throw and uses A as issuer', () async {
        final token = await _ok('otpauth://totp/A:B:C?secret=AAAAAAAA');
        expect(token.issuer, 'A');
        expect(token.label, startsWith('B'));
      });

      test(
        'A:B:C keeps everything after the first colon in the label',
        () async {
          final token = await _ok('otpauth://totp/A:B:C?secret=AAAAAAAA');
          expect(token.issuer, 'A');
          expect(token.label, 'B:C');
        },
        skip:
            'BUG: otp_auth_processor.dart:144-145 split(":") only takes split[0] and split[1], the rest of the label ("C") is silently dropped',
      );

      test(
        'whitespace after the colon: issuer is kept and label contains the user name',
        () async {
          final token = await _ok(
            'otpauth://totp/Issuer:%20user?secret=AAAAAAAA',
          );
          expect(token.issuer, 'Issuer');
          expect(token.label.trim(), 'user');
        },
      );

      test(
        '"Issuer: user" (space after the colon) is trimmed to the label "user"',
        () async {
          for (final uri in [
            'otpauth://totp/Issuer: user?secret=AAAAAAAA',
            'otpauth://totp/Issuer:%20user?secret=AAAAAAAA',
            'otpauth://totp/Issuer%3A%20user?secret=AAAAAAAA',
          ]) {
            final token = await _ok(uri);
            expect(token.issuer, 'Issuer', reason: uri);
            expect(token.label, 'user', reason: uri);
          }
        },
        skip:
            'BUG: otp_auth_processor.dart:145 the label is not trimmed, so the token label is " user" (leading space)',
      );

      test('unicode label and issuer, percent encoded and raw', () async {
        for (final uri in [
          'otpauth://totp/J%C3%BCrgen%3AM%C3%BCller?secret=AAAAAAAA',
          'otpauth://totp/Jürgen:Müller?secret=AAAAAAAA',
        ]) {
          final token = await _ok(uri);
          expect(token.issuer, 'Jürgen', reason: uri);
          expect(token.label, 'Müller', reason: uri);
        }
      });

      test('emoji issuer survives', () async {
        final token = await _ok(
          'otpauth://totp/%F0%9F%94%91%3Akey?secret=AAAAAAAA',
        );
        expect(token.issuer, '🔑');
        expect(token.label, 'key');
      });

      test('unicode issuer parameter survives', () async {
        final token = await _ok(
          'otpauth://totp/user?secret=AAAAAAAA&issuer=J%C3%BCrgen',
        );
        expect(token.issuer, 'Jürgen');
      });

      test(
        'encoded slash and percent in the label are decoded exactly once',
        () async {
          expect(
            (await _ok('otpauth://totp/a%2Fb?secret=AAAAAAAA')).label,
            'a/b',
          );
          expect(
            (await _ok('otpauth://totp/a%25b?secret=AAAAAAAA')).label,
            'a%b',
          );
          expect(
            (await _ok('otpauth://totp/a%2541?secret=AAAAAAAA')).label,
            'a%41',
          );
        },
      );

      test('a plus sign in the label path stays a plus sign', () async {
        final token = await _ok('otpauth://totp/a+b?secret=AAAAAAAA');
        expect(token.label, 'a+b');
      });

      test(
        'a malformed percent sequence in the label does not throw',
        () async {
          final token = await _ok('otpauth://totp/a%zz?secret=AAAAAAAA');
          expect(token.label, startsWith('a'));
        },
      );

      test(
        'issuer parameter: plus is a space, %2B is a plus, %20 is a space',
        () async {
          expect(
            (await _ok('otpauth://totp/u?secret=AAAAAAAA&issuer=a+b')).issuer,
            'a b',
          );
          expect(
            (await _ok('otpauth://totp/u?secret=AAAAAAAA&issuer=a%2Bb')).issuer,
            'a+b',
          );
          expect(
            (await _ok('otpauth://totp/u?secret=AAAAAAAA&issuer=a%20b')).issuer,
            'a b',
          );
        },
      );

      test('issuer parameter with a lone percent does not throw', () async {
        final token = await _ok(
          'otpauth://totp/u?secret=AAAAAAAA&issuer=100%25',
        );
        expect(token.issuer, '100%');
      });

      test(
        'issuer parameter is percent decoded exactly once (a%2520b is "a%20b")',
        () async {
          final token = await _ok(
            'otpauth://totp/u?secret=AAAAAAAA&issuer=a%2520b',
          );
          expect(token.issuer, 'a%20b');
        },
        skip:
            'BUG: otp_auth_processor.dart:164 Uri.decodeFull is applied to a value that queryParameters already decoded (double decoding)',
      );

      test('origin data is the unmodified uri string', () async {
        const uri =
            'otpauth://totp/ACME:alice?secret=AAAAAAAA&issuer=ACME&digits=8';
        final token = await _ok(uri);
        expect(token.origin, isNotNull);
        expect(token.origin!.data, uri);
        expect(token.origin!.isPrivacyIdeaToken, isNull);
        expect(token.origin!.creator, isNull);
      });

      test('creator parameter marks the token as privacyIDEA token', () async {
        final token = await _ok(
          'otpauth://totp/alice?secret=AAAAAAAA&creator=privacyIDEA',
        );
        expect(token.origin!.isPrivacyIdeaToken, isTrue);
        expect(token.origin!.creator, 'privacyIDEA');
      });
    });

    group('secret', () {
      test('lowercase secret is normalised to uppercase', () async {
        final token =
            await _ok('otpauth://totp/u?secret=jbswy3dpehpk3pxp') as OTPToken;
        expect(token.secret, 'JBSWY3DPEHPK3PXP');
      });

      test(
        'lowercase, spaced and upper secrets generate the same code',
        () async {
          final reference =
              await _ok('otpauth://hotp/u?secret=JBSWY3DPEHPK3PXP')
                  as HOTPToken;
          for (final secret in [
            'jbswy3dpehpk3pxp',
            'JBSWY3DP%20EHPK%203PXP',
            'jbswy3dp+ehpk+3pxp',
          ]) {
            final token =
                await _ok('otpauth://hotp/u?secret=$secret') as HOTPToken;
            expect(token.otpValue, reference.otpValue, reason: secret);
          }
        },
      );

      test(
        'omitted and explicit padding decode to the same key (RFC 4648 vectors)',
        () async {
          // base32("foo") = MZXW6===, base32("foob") = MZXW6YQ=,
          // base32("fooba") = MZXW6YTB, base32("foobar") = MZXW6YTBOI======
          final cases = <String, List<String>>{
            'foo': ['MZXW6===', 'MZXW6'],
            'foob': ['MZXW6YQ=', 'MZXW6YQ'],
            'fooba': ['MZXW6YTB'],
            'foobar': ['MZXW6YTBOI======', 'MZXW6YTBOI'],
          };
          for (final entry in cases.entries) {
            for (final secret in entry.value) {
              final token =
                  await _ok('otpauth://hotp/u?secret=$secret') as OTPToken;
              expect(
                Encodings.base32.decode(token.secret),
                utf8.encode(entry.key),
                reason: '$secret -> ${token.secret}',
              );
            }
          }
        },
      );

      test('padded and unpadded secrets generate the same HOTP code', () async {
        final padded =
            await _ok('otpauth://hotp/u?secret=MZXW6YQ=') as HOTPToken;
        final unpadded =
            await _ok('otpauth://hotp/u?secret=MZXW6YQ') as HOTPToken;
        expect(unpadded.otpValue, padded.otpValue);
      });

      test(
        'a 5 character secret is a valid unpadded base32 key of 3 bytes',
        () async {
          final token = await _ok('otpauth://totp/u?secret=MZXW6') as OTPToken;
          expect(Encodings.base32.decode(token.secret), utf8.encode('foo'));
        },
      );

      test(
        'secrets that decode to no key at all (1, 3 and 6 characters) are rejected',
        () async {
          for (final secret in ['A', 'AAA', 'AAAAAA']) {
            final results = await _run('otpauth://totp/u?secret=$secret');
            final result = results.single;
            final usable =
                result.isFailed ||
                _hasUsableKey(
                  (result.asSuccess!.resultData as OTPToken).secret,
                );
            expect(
              usable,
              isTrue,
              reason: 'secret "$secret" yields an empty key',
            );
          }
        },
        skip:
            'BUG: validators.base32String only checks the alphabet, so 1/3/6 character secrets (invalid base32 length) create a token with an empty key',
      );

      test(
        'characters outside the base32 alphabet are rejected with the generic message',
        () async {
          for (final secret in ['0189', '!!!!', 'AAAA=AAA', 'AAAA-AAAA']) {
            final failed = await _failed('otpauth://totp/u?secret=$secret');
            expect(failed.message(_l), _l.unableToCreateToken, reason: secret);
            expect(failed.error, isA<ArgumentError>(), reason: secret);
          }
        },
      );

      test('empty secret is rejected', () async {
        final failed = await _failed('otpauth://totp/u?secret=');
        expect(failed.message(_l), _l.unableToCreateToken);
      });

      test('missing secret reports the parameter name', () async {
        final failed = await _failed('otpauth://totp/u?issuer=ACME');
        expect(failed.message(_l), _l.invalidValue('secret', 'Null', 'null'));
        expect(failed.error, isA<LocalizedArgumentError>());
      });

      test('duplicate secret parameter: the last value wins', () async {
        final token =
            await _ok('otpauth://totp/u?secret=AAAAAAAA&secret=MZXW6YTB')
                as OTPToken;
        expect(Encodings.base32.decode(token.secret), utf8.encode('fooba'));
      });
    });

    group('digits / period / counter / algorithm', () {
      test(
        'digits 0 and negative digits are rejected with the parameter in the message',
        () async {
          for (final digits in ['0', '-1']) {
            final failed = await _failed(
              'otpauth://totp/u?secret=AAAAAAAA&digits=$digits',
            );
            expect(
              failed.message(_l),
              _l.invalidValue('digits', 'String', digits),
            );
            expect(failed.error, isA<LocalizedArgumentError>());
          }
        },
      );

      test('non numeric or overflowing digits fall back to 6', () async {
        for (final digits in ['abc', '', '99999999999999999999999', '6.5']) {
          final token =
              await _ok('otpauth://totp/u?secret=AAAAAAAA&digits=$digits')
                  as OTPToken;
          expect(token.digits, 6, reason: 'digits="$digits"');
        }
      });

      test('digits 6, 7, 8 and 10 are taken over', () async {
        for (final digits in [6, 7, 8, 10]) {
          final token =
              await _ok('otpauth://totp/u?secret=AAAAAAAA&digits=$digits')
                  as OTPToken;
          expect(token.digits, digits);
        }
      });

      test(
        'an absurd digit count (100) is rejected or yields a token that can generate a code',
        () async {
          final result = (await _run(
            'otpauth://hotp/u?secret=JBSWY3DPEHPK3PXP&digits=100',
          )).single;
          var usable = result.isFailed;
          if (result.isSuccess) {
            try {
              (result.asSuccess!.resultData as OTPToken).otpValue;
              usable = true;
            } catch (_) {
              usable = false;
            }
          }
          expect(usable, isTrue);
        },
        skip:
            'BUG: Validators.otpDigits only requires > 0, digits=100 creates a token whose otpValue throws IntegerDivisionByZeroException',
      );

      test('period 0 and negative period are rejected', () async {
        for (final period in ['0', '-5']) {
          final failed = await _failed(
            'otpauth://totp/u?secret=AAAAAAAA&period=$period',
          );
          expect(
            failed.message(_l),
            _l.invalidValue('period', 'String', period),
          );
        }
      });

      test('non numeric or overflowing period falls back to 30', () async {
        for (final period in ['abc', '99999999999999999999999']) {
          final token =
              await _ok('otpauth://totp/u?secret=AAAAAAAA&period=$period')
                  as TOTPToken;
          expect(token.period, 30, reason: 'period="$period"');
        }
      });

      test('period 1 and 60 are taken over', () async {
        for (final period in [1, 60]) {
          final token =
              await _ok('otpauth://totp/u?secret=AAAAAAAA&period=$period')
                  as TOTPToken;
          expect(token.period, period);
        }
      });

      test('negative HOTP counter is rejected', () async {
        final failed = await _failed(
          'otpauth://hotp/u?secret=AAAAAAAA&counter=-1',
        );
        expect(failed.message(_l), _l.invalidValue('counter', 'String', '-1'));
        expect(failed.error, isA<LocalizedArgumentError>());
      });

      test(
        'HOTP counter: 0 and the maximum int are accepted, garbage falls back to 0',
        () async {
          expect(
            (await _ok('otpauth://hotp/u?secret=AAAAAAAA&counter=0')
                    as HOTPToken)
                .counter,
            0,
          );
          expect(
            (await _ok(
                      'otpauth://hotp/u?secret=AAAAAAAA&counter=9223372036854775807',
                    )
                    as HOTPToken)
                .counter,
            9223372036854775807,
          );
          for (final counter in ['abc', '9223372036854775808']) {
            expect(
              (await _ok('otpauth://hotp/u?secret=AAAAAAAA&counter=$counter')
                      as HOTPToken)
                  .counter,
              0,
              reason: counter,
            );
          }
        },
      );

      test('algorithm names are case insensitive', () async {
        for (final entry in {
          'sha1': Algorithms.SHA1,
          'SHA256': Algorithms.SHA256,
          'sha256': Algorithms.SHA256,
          'Sha512': Algorithms.SHA512,
        }.entries) {
          final token =
              await _ok(
                    'otpauth://totp/u?secret=AAAAAAAA&algorithm=${entry.key}',
                  )
                  as OTPToken;
          expect(token.algorithm, entry.value, reason: entry.key);
        }
      });

      test(
        'unknown algorithms silently fall back to SHA1 (characterization)',
        () async {
          for (final algorithm in ['MD5', 'SHA-256', 'FOO', '']) {
            final token =
                await _ok(
                      'otpauth://totp/u?secret=AAAAAAAA&algorithm=$algorithm',
                    )
                    as OTPToken;
            expect(
              token.algorithm,
              Algorithms.SHA1,
              reason: 'algorithm="$algorithm"',
            );
          }
        },
      );
    });

    group('scheme / host / token type', () {
      test('host is matched case insensitively', () async {
        final token = await _ok('otpauth://TOTP/u?secret=AAAAAAAA');
        expect(token.type, 'TOTP');
        final hotp = await _ok('otpauth://HotP/u?secret=AAAAAAAA');
        expect(hotp.type, 'HOTP');
      });

      test(
        'unknown host is reported as not supported without an error object',
        () async {
          final failed = await _failed('otpauth://unknown/u?secret=AAAAAAAA');
          expect(failed.message(_l), contains('not supported'));
          expect(failed.error, isNull);
        },
      );

      test(
        'the not supported message names the unsupported host, not the (supported) scheme',
        () async {
          final failed = await _failed('otpauth://unknown/u?secret=AAAAAAAA');
          expect(failed.message(_l), contains('unknown'));
        },
        skip:
            'BUG (minor): otp_auth_processor.dart:61 uses l.notSupported("scheme", uri.scheme) for an unsupported host, so the user reads "The scheme [otpauth] not supported"',
      );

      test('foreign scheme is not supported and names the scheme', () async {
        final failed = await _failed('https://example.com/u?secret=AAAAAAAA');
        expect(failed.message(_l), _l.notSupported('scheme', 'https'));
      });

      test(
        'failed results carry the token import result handler type',
        () async {
          final failed = await _failed('otpauth://unknown/u?secret=AAAAAAAA');
          expect(
            failed.resultHandlerType,
            same(TokenImportSchemeProcessor.resultHandlerType),
          );
          final success = (await _run(
            'otpauth://totp/u?secret=AAAAAAAA',
          )).single;
          expect(
            success.asSuccess!.resultHandlerType,
            same(TokenImportSchemeProcessor.resultHandlerType),
          );
        },
      );

      test('tokentype parameter overrides the host', () async {
        final token = await _ok(
          'otpauth://totp/u?secret=AAAAAAAA&tokentype=hotp',
        );
        expect(token, isA<HOTPToken>());
      });

      test(
        'unsupported tokentype is a failed result with the generic message',
        () async {
          final failed = await _failed(
            'otpauth://totp/u?secret=AAAAAAAA&tokentype=foo',
          );
          expect(failed.message(_l), _l.unableToCreateToken);
          expect(failed.error, isA<ArgumentError>());
        },
      );

      test('issuer=Steam forces a Steam token on the totp host', () async {
        final token = await _ok(
          'otpauth://totp/u?secret=AAAAAAAA&issuer=Steam',
        );
        expect(token, isA<SteamToken>());
        expect(token.type, 'STEAM');
        expect(token.issuer, 'Steam');
        expect((token as SteamToken).digits, 5);
        expect(token.period, 30);
      });

      test('issuer=Steam forces a Steam token on the hotp host as well', () async {
        final token = await _ok(
          'otpauth://hotp/u?secret=AAAAAAAA&issuer=Steam&digits=8&algorithm=SHA256',
        );
        expect(token, isA<SteamToken>());
        // Steam always uses 5 digits and SHA1, parameters from the uri are ignored.
        expect((token as SteamToken).digits, 5);
        expect(token.algorithm, Algorithms.SHA1);
      });

      test('steam host creates a Steam token without issuer', () async {
        final token = await _ok('otpauth://steam/u?secret=AAAAAAAA');
        expect(token, isA<SteamToken>());
      });

      test(
        'the Steam check is case sensitive and ignores a Steam label prefix',
        () async {
          expect(
            await _ok('otpauth://totp/u?secret=AAAAAAAA&issuer=steam'),
            isA<TOTPToken>(),
          );
          final prefixOnly = await _ok(
            'otpauth://totp/Steam:u?secret=AAAAAAAA',
          );
          expect(prefixOnly, isA<TOTPToken>());
          expect(prefixOnly.issuer, 'Steam');
        },
      );

      test(
        'Steam is decided by the issuer parameter even if the label prefix names another issuer',
        () async {
          final token = await _ok(
            'otpauth://totp/Other:u?secret=AAAAAAAA&issuer=Steam',
          );
          expect(token, isA<SteamToken>());
          expect(token.issuer, 'Other');
        },
      );
    });

    group('error propagation', () {
      test(
        'non LocalizedException maps to unableToCreateToken and keeps the error',
        () async {
          final failed = await _failed(
            'otpauth://totp/u?secret=AAAAAAAA&tokentype=foo',
          );
          expect(failed.message(_l), _l.unableToCreateToken);
          expect(failed.error, isA<ArgumentError>());
          expect(failed.error, isNot(isA<LocalizedException>()));
        },
      );

      test(
        'LocalizedArgumentError message is passed through unchanged',
        () async {
          final failed = await _failed(
            'otpauth://totp/u?secret=AAAAAAAA&period=0',
          );
          final error = failed.error as LocalizedArgumentError;
          expect(failed.message(_l), error.localizedMessage(_l));
          expect(failed.message(_l), _l.invalidValue('period', 'String', '0'));
          expect(failed.message(_l), isNot(_l.unableToCreateToken));
        },
      );

      test('push token without serial reports the missing serial', () async {
        final failed = await _failed('otpauth://pipush/label?issuer=x');
        expect(failed.message(_l), _l.invalidValue('serial', 'Null', 'null'));
        expect(failed.error, isA<LocalizedArgumentError>());
      });
    });

    group('2step', () {
      test(
        'a failing PBKDF2 (iterations < 1) returns twoStepSecretFailed',
        () async {
          final failed = await _failed(
            'otpauth://totp/u?secret=AAAAAAAA&2step_salt=10&2step_output=20&2step_difficulty=-1',
          );
          expect(failed.message(_l), _l.twoStepSecretFailed);
          expect(failed.error, isNull);
        },
      );

      test(
        'a non numeric 2step parameter returns a failed result instead of throwing',
        () async {
          final results = await _run(
            'otpauth://totp/u?secret=AAAAAAAA&2step_salt=abc&2step_output=20&2step_difficulty=10000',
          );
          expect(results.single.isFailed, isTrue);
        },
        skip:
            'BUG: otp_auth_processor.dart:77,181 _parse2StepSecret validates/parses synchronously outside the try/catch, the FormatException escapes processUri',
      );

      test(
        'incomplete 2step parameters (only 2step_salt) return a failed result instead of throwing',
        () async {
          final results = await _run(
            'otpauth://totp/u?secret=AAAAAAAA&2step_salt=10',
          );
          expect(results.single.isFailed, isTrue);
        },
        skip:
            'BUG: otp_auth_processor.dart:77,181 validateMap in _parse2StepSecret throws LocalizedArgumentError outside the try/catch',
      );

      test(
        '2step parameters without a secret return a failed result instead of throwing',
        () async {
          final results = await _run(
            'otpauth://totp/u?2step_salt=10&2step_output=20&2step_difficulty=100',
          );
          expect(results.single.isFailed, isTrue);
        },
        skip:
            'BUG: otp_auth_processor.dart:77,181 validateMap in _parse2StepSecret throws LocalizedArgumentError outside the try/catch',
      );

      test(
        'currently incomplete 2step parameters throw (characterization)',
        () async {
          await expectLater(
            _run('otpauth://totp/u?secret=AAAAAAAA&2step_salt=10'),
            throwsA(isA<LocalizedArgumentError>()),
          );
          await expectLater(
            _run(
              'otpauth://totp/u?secret=AAAAAAAA&2step_salt=abc&2step_output=20&2step_difficulty=10',
            ),
            throwsA(isA<FormatException>()),
          );
        },
      );
    });
  });
}
