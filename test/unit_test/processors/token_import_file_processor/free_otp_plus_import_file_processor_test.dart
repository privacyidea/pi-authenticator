import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/enums/token_types.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/free_otp_plus_import_file_processor.dart';
import 'package:privacyidea_authenticator/utils/token_import_origins.dart';

void main() {
  _testFreeOtpPlusImportFileProcessor();
}

void _assertSuccessResults(List<ProcessorResult<Token>> results) {
  expect(results.length, equals(2));

  final result0 = results[0];
  expect(result0, isA<ProcessorResultSuccess>());
  final token0 = result0.asSuccess!.resultData;
  expect(token0.label, 'Test2');
  expect(token0.issuer, 'Test2');
  expect(token0.type, TokenTypes.HOTP.name);
  expect(token0, isA<HOTPToken>());
  expect(token0.origin, isNotNull);
  expect(token0.origin!.originName, TokenImportOrigins.freeOtpPlus.appName);
  expect(token0.origin!.source, TokenOriginSourceType.backupFile);
  final hotpToken = token0 as HOTPToken;
  expect(hotpToken.secret, 'BBBBBBBB');
  expect(hotpToken.algorithm, Algorithms.SHA1);
  expect(hotpToken.digits, 8);
  expect(hotpToken.counter, 5);
  expect(hotpToken.otpValue, equals('83718223'));
  final result1 = results[1];
  expect(result1, isA<ProcessorResultSuccess>());
  final token1 = result1.asSuccess!.resultData;
  expect(token1.label, 'Test1');
  expect(token1.issuer, 'Test1');
  expect(token1.type, TokenTypes.TOTP.name);
  expect(token1, isA<TOTPToken>());
  expect(token1.origin, isNotNull);
  expect(token1.origin!.originName, TokenImportOrigins.freeOtpPlus.appName);
  expect(token1.origin!.source, TokenOriginSourceType.backupFile);
  final totpToken = token1 as TOTPToken;
  expect(totpToken.secret, 'AAAAAAAA');
  expect(totpToken.algorithm, Algorithms.SHA256);
  expect(totpToken.digits, 8);
  expect(totpToken.period, 60);
  expect(totpToken.otpFromTime(DateTime.fromMillisecondsSinceEpoch(1713519600602)), equals('46107496'));
}

void _testFreeOtpPlusImportFileProcessor() {
  group('Free Otp Plus File Processor Test', () {
    const processor = FreeOtpPlusImportFileProcessor();
    // No encryption or password protection is used in the FreeOTP+ App at all.
    group('JSON plain', () {
      // Arrange
      const jsonFileBytesString =
          '[123, 34, 116, 111, 107, 101, 110, 79, 114, 100, 101, 114, 34, 58, 91, 34, 84, 101, 115, 116, 50, 58, 84, 101, 115, 116, 50, 34, 44, 34, 84, 101, 115, 116, 49, 58, 84, 101, 115, 116, 49, 34, 93, 44, 34, 116, 111, 107, 101, 110, 115, 34, 58, 91, 123, 34, 97, 108, 103, 111, 34, 58, 34, 83, 72, 65, 49, 34, 44, 34, 99, 111, 117, 110, 116, 101, 114, 34, 58, 52, 44, 34, 100, 105, 103, 105, 116, 115, 34, 58, 56, 44, 34, 105, 115, 115, 117, 101, 114, 69,'
          '120, 116, 34, 58, 34, 84, 101, 115, 116, 50, 34, 44, 34, 108, 97, 98, 101, 108, 34, 58, 34, 84, 101, 115, 116, 50, 34, 44, 34, 112, 101, 114, 105, 111, 100, 34, 58, 51, 48, 44, 34, 115, 101, 99, 114, 101, 116, 34, 58, 91, 56, 44, 54, 54, 44, 49, 54, 44, 45, 49, 50, 52, 44, 51, 51, 93, 44, 34, 116, 121, 112, 101, 34, 58, 34, 72, 79, 84, 80, 34, 125, 44, 123, 34, 97, 108, 103, 111, 34, 58, 34, 83, 72, 65, 50, 53, 54, 34, 44, 34,'
          '99, 111, 117, 110, 116, 101, 114, 34, 58, 48, 44, 34, 100, 105, 103, 105, 116, 115, 34, 58, 56, 44, 34, 105, 115, 115, 117, 101, 114, 69, 120, 116, 34, 58, 34, 84, 101, 115, 116, 49, 34, 44, 34, 108, 97, 98, 101, 108, 34, 58, 34, 84, 101, 115, 116, 49, 34, 44, 34, 112, 101, 114, 105, 111, 100, 34, 58, 54, 48, 44, 34, 115, 101, 99, 114, 101, 116, 34, 58, 91, 48, 44, 48, 44, 48, 44, 48, 44, 48, 93, 44, 34, 116, 121, 112, 101, 34, 58, 34, 84,'
          '79, 84, 80, 34, 125, 93, 125]';
      final jsonFileBytes = (jsonDecode(jsonFileBytesString) as List).cast<int>();
      final jsonFile = XFile.fromData(Uint8List.fromList(jsonFileBytes), name: 'Free_OTP_Plus_plain.json');

      group('fileIsValid', () {
        test('isTrue', () async {
          // Act
          final fileIsValid = await processor.fileIsValid(jsonFile);
          // Assert
          expect(fileIsValid, isTrue);
        });
        test('isFalse', () async {
          // Arrange
          final jsonFileBytes = (jsonDecode(jsonFileBytesString) as List).cast<int>()..removeLast();
          final jsonFileInvalid = XFile.fromData(Uint8List.fromList(jsonFileBytes), name: 'Free_OTP_Plus_plain_invalid.json');
          // Act
          final fileIsValid = await processor.fileIsValid(jsonFileInvalid);
          // Assert
          expect(fileIsValid, isFalse);
        });
      });
      test('fileNeedsPassword', () async {
        // Act
        final fileNeedsPassword = await processor.fileNeedsPassword(jsonFile);
        // Assert
        expect(fileNeedsPassword, isFalse);
      });
      test('processFile', () async {
        // Act
        final results = await processor.processFile(jsonFile);
        // Assert
        _assertSuccessResults(results);
      });
    });
    group('Uri List plain', () {
      const uriListByteString =
          '[111, 116, 112, 97, 117, 116, 104, 58, 47, 47, 104, 111, 116, 112, 47, 84, 101, 115, 116, 50, 37, 51, 65, 84, 101, 115, 116, 50, 63, 115, 101, 99, 114, 101, 116, 61, 66, 66, 66, 66, 66, 66, 66, 66, 38, 97, 108, 103, 111, 114, 105, 116, 104, 109, 61, 83, 72, 65, 49, 38, 100, 105, 103, 105, 116, 115, 61, 56, 38, 112, 101, 114, 105, 111, 100, 61, 51, 48, 38, 99, 111, 117, 110, 116, 101, 114, 61, 53, 10, 111, 116, 112, 97, 117, 116, 104, 58, 47, 47, 116,'
          '111, 116, 112, 47, 84, 101, 115, 116, 49, 37, 51, 65, 84, 101, 115, 116, 49, 63, 115, 101, 99, 114, 101, 116, 61, 65, 65, 65, 65, 65, 65, 65, 65, 38, 97, 108, 103, 111, 114, 105, 116, 104, 109, 61, 83, 72, 65, 50, 53, 54, 38, 100, 105, 103, 105, 116, 115, 61, 56, 38, 112, 101, 114, 105, 111, 100, 61, 54, 48, 10]';
      final uriListBytes = (jsonDecode(uriListByteString) as List).cast<int>();
      final uriListFile = XFile.fromData(Uint8List.fromList(uriListBytes), name: 'Free_OTP_Plus_uri_list_plain.txt');
      group('fileIsValid', () {
        test('isTrue', () async {
          // Act
          final fileIsValid = await processor.fileIsValid(uriListFile);
          // Assert
          expect(fileIsValid, isTrue);
        });
        test('isFalse', () async {
          // Arrange
          final uriListBytes = (jsonDecode(uriListByteString) as List).cast<int>()..removeAt(0);
          final uriListFileInvalid = XFile.fromData(Uint8List.fromList(uriListBytes), name: 'Free_OTP_Plus_uri_list_plain_invalid.txt');
          // Act
          final fileIsValid = await processor.fileIsValid(uriListFileInvalid);
          // Assert
          expect(fileIsValid, isFalse);
        });
      });
      test('fileNeedsPassword', () async {
        // Act
        final fileNeedsPassword = await processor.fileNeedsPassword(uriListFile);
        // Assert
        expect(fileNeedsPassword, isFalse);
      });
      test('processFile', () async {
        // Act
        final results = await processor.processFile(uriListFile);
        // Assert
        _assertSuccessResults(results);
      });
    });
  });
}
