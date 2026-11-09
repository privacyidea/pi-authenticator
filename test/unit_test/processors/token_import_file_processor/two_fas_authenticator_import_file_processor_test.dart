import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/enums/token_types.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/two_fas_import_file_processor.dart';
import 'package:privacyidea_authenticator/utils/token_import_origins.dart';

void main() {
  _testTwoFasImportFileProcessor();
  _testTwoFasImportFileProcessorEdgeCases();
}

void _assertSuccessResults(List<ProcessorResult<Token>> results) {
  expect(results.length, equals(3));

  final result0 = results[0];
  expect(result0, isA<ProcessorResultSuccess>());
  final token0 = result0.asSuccess!.resultData;
  expect(token0.label, '');
  expect(token0.issuer, 'Test1');
  expect(token0.type, TokenTypes.TOTP.name);
  expect(token0, isA<TOTPToken>());
  expect(token0.origin, isNotNull);
  expect(
    token0.origin!.appName,
    TokenImportOrigins.twoFasAuthenticator.appName,
  );
  expect(token0.origin!.source, TokenOriginSourceType.backupFile);
  final totpToken = token0 as TOTPToken;
  expect(totpToken.secret, equals('AAAAAAAA'));
  expect(totpToken.algorithm, Algorithms.SHA256);
  expect(totpToken.digits, 8);
  expect(totpToken.period, 60);
  expect(
    totpToken.otpFromTime(DateTime.fromMillisecondsSinceEpoch(1713519600602)),
    equals('46107496'),
  );
  final result1 = results[1];
  expect(result1, isA<ProcessorResultSuccess>());
  final token1 = result1.asSuccess!.resultData;
  expect(token1.label, '');
  expect(token1.issuer, 'Test2');
  expect(token1.type, TokenTypes.HOTP.name);
  expect(token1, isA<HOTPToken>());
  expect(token1.origin, isNotNull);
  expect(
    token1.origin!.appName,
    TokenImportOrigins.twoFasAuthenticator.appName,
  );
  expect(token1.origin!.source, TokenOriginSourceType.backupFile);
  final hotpToken = token1 as HOTPToken;
  expect(hotpToken.secret, equals('BBBBBBBB'));
  expect(hotpToken.algorithm, Algorithms.SHA1);
  expect(hotpToken.digits, 6);
  expect(hotpToken.counter, 5);
  expect(hotpToken.otpValue, equals('718223'));
  final result2 = results[2];
  expect(result2, isA<ProcessorResultSuccess>());
  final token2 = result2.asSuccess!.resultData;
  expect(token2.label, '');
  expect(token2.issuer, 'SteamTest');
  expect(token2.type, TokenTypes.STEAM.name);
  expect(token2, isA<SteamToken>());
  expect(token2.origin, isNotNull);
  expect(
    token2.origin!.appName,
    TokenImportOrigins.twoFasAuthenticator.appName,
  );
  expect(token2.origin!.source, TokenOriginSourceType.backupFile);
  final steamToken = token2 as SteamToken;
  expect(steamToken.secret, equals('CCCCCCCC'));
}

void _testTwoFasImportFileProcessor() {
  group('Two Fas Import File Processor Test', () {
    // Arrange
    const processor = TwoFasAuthenticatorImportFileProcessor();
    group('JSON', () {
      const jsonFileBytesString =
          '[123, 34, 115, 101, 114, 118, 105, 99, 101, 115, 34, 58, 91, 123, 34, 110, 97, 109, 101, 34, 58, 34, 84, 101, 115, 116, 49, 34, 44, 34, 115, 101, 99, 114, 101, 116, 34, 58, 34, 65, 65, 65, 65, 65, 65, 65, 65, 34, 44, 34, 117, 112, 100, 97, 116, 101, 100, 65, 116, 34, 58, 49, 55, 49, 51, 53, 50, 54, 55, 55, 48, 56, 55, 57, 44, 34, 111, 116, 112, 34, 58, 123, 34, 108, 97, 98, 101, 108, 34, 58, 34, 34, 44, 34, 97, 99, 99, 111, 117, 110,'
          '116, 34, 58, 34, 34, 44, 34, 100, 105, 103, 105, 116, 115, 34, 58, 56, 44, 34, 112, 101, 114, 105, 111, 100, 34, 58, 54, 48, 44, 34, 97, 108, 103, 111, 114, 105, 116, 104, 109, 34, 58, 34, 83, 72, 65, 50, 53, 54, 34, 44, 34, 116, 111, 107, 101, 110, 84, 121, 112, 101, 34, 58, 34, 84, 79, 84, 80, 34, 44, 34, 115, 111, 117, 114, 99, 101, 34, 58, 34, 77, 97, 110, 117, 97, 108, 34, 125, 44, 34, 111, 114, 100, 101, 114, 34, 58, 123, 34, 112, 111,'
          '115, 105, 116, 105, 111, 110, 34, 58, 48, 125, 44, 34, 105, 99, 111, 110, 34, 58, 123, 34, 115, 101, 108, 101, 99, 116, 101, 100, 34, 58, 34, 76, 97, 98, 101, 108, 34, 44, 34, 108, 97, 98, 101, 108, 34, 58, 123, 34, 116, 101, 120, 116, 34, 58, 34, 84, 69, 34, 44, 34, 98, 97, 99, 107, 103, 114, 111, 117, 110, 100, 67, 111, 108, 111, 114, 34, 58, 34, 66, 114, 111, 119, 110, 34, 125, 44, 34, 105, 99, 111, 110, 67, 111, 108, 108, 101, 99, 116, 105, 111,'
          '110, 34, 58, 123, 34, 105, 100, 34, 58, 34, 97, 53, 98, 51, 102, 98, 54, 53, 45, 52, 101, 99, 53, 45, 52, 51, 101, 54, 45, 56, 101, 99, 49, 45, 52, 57, 101, 50, 52, 99, 97, 57, 101, 55, 97, 100, 34, 125, 125, 125, 44, 123, 34, 110, 97, 109, 101, 34, 58, 34, 84, 101, 115, 116, 50, 34, 44, 34, 115, 101, 99, 114, 101, 116, 34, 58, 34, 66, 66, 66, 66, 66, 66, 66, 66, 34, 44, 34, 117, 112, 100, 97, 116, 101, 100, 65, 116, 34, 58, 49,'
          '55, 49, 51, 53, 50, 54, 57, 57, 54, 48, 55, 57, 44, 34, 111, 116, 112, 34, 58, 123, 34, 108, 97, 98, 101, 108, 34, 58, 34, 34, 44, 34, 97, 99, 99, 111, 117, 110, 116, 34, 58, 34, 34, 44, 34, 100, 105, 103, 105, 116, 115, 34, 58, 54, 44, 34, 112, 101, 114, 105, 111, 100, 34, 58, 51, 48, 44, 34, 97, 108, 103, 111, 114, 105, 116, 104, 109, 34, 58, 34, 83, 72, 65, 49, 34, 44, 34, 99, 111, 117, 110, 116, 101, 114, 34, 58, 53, 44, 34, 116,'
          '111, 107, 101, 110, 84, 121, 112, 101, 34, 58, 34, 72, 79, 84, 80, 34, 44, 34, 115, 111, 117, 114, 99, 101, 34, 58, 34, 77, 97, 110, 117, 97, 108, 34, 125, 44, 34, 111, 114, 100, 101, 114, 34, 58, 123, 34, 112, 111, 115, 105, 116, 105, 111, 110, 34, 58, 49, 125, 44, 34, 105, 99, 111, 110, 34, 58, 123, 34, 115, 101, 108, 101, 99, 116, 101, 100, 34, 58, 34, 76, 97, 98, 101, 108, 34, 44, 34, 108, 97, 98, 101, 108, 34, 58, 123, 34, 116, 101, 120, 116,'
          '34, 58, 34, 84, 69, 34, 44, 34, 98, 97, 99, 107, 103, 114, 111, 117, 110, 100, 67, 111, 108, 111, 114, 34, 58, 34, 79, 114, 97, 110, 103, 101, 34, 125, 44, 34, 105, 99, 111, 110, 67, 111, 108, 108, 101, 99, 116, 105, 111, 110, 34, 58, 123, 34, 105, 100, 34, 58, 34, 97, 53, 98, 51, 102, 98, 54, 53, 45, 52, 101, 99, 53, 45, 52, 51, 101, 54, 45, 56, 101, 99, 49, 45, 52, 57, 101, 50, 52, 99, 97, 57, 101, 55, 97, 100, 34, 125, 125, 125, 44,'
          '123, 34, 110, 97, 109, 101, 34, 58, 34, 83, 116, 101, 97, 109, 84, 101, 115, 116, 34, 44, 34, 115, 101, 99, 114, 101, 116, 34, 58, 34, 67, 67, 67, 67, 67, 67, 67, 67, 34, 44, 34, 117, 112, 100, 97, 116, 101, 100, 65, 116, 34, 58, 49, 55, 49, 51, 53, 50, 56, 55, 52, 56, 56, 48, 53, 44, 34, 111, 116, 112, 34, 58, 123, 34, 108, 97, 98, 101, 108, 34, 58, 34, 34, 44, 34, 97, 99, 99, 111, 117, 110, 116, 34, 58, 34, 34, 44, 34, 105, 115,'
          '115, 117, 101, 114, 34, 58, 34, 83, 116, 101, 97, 109, 34, 44, 34, 100, 105, 103, 105, 116, 115, 34, 58, 53, 44, 34, 112, 101, 114, 105, 111, 100, 34, 58, 51, 48, 44, 34, 97, 108, 103, 111, 114, 105, 116, 104, 109, 34, 58, 34, 83, 72, 65, 49, 34, 44, 34, 116, 111, 107, 101, 110, 84, 121, 112, 101, 34, 58, 34, 83, 84, 69, 65, 77, 34, 44, 34, 115, 111, 117, 114, 99, 101, 34, 58, 34, 77, 97, 110, 117, 97, 108, 34, 125, 44, 34, 111, 114, 100, 101,'
          '114, 34, 58, 123, 34, 112, 111, 115, 105, 116, 105, 111, 110, 34, 58, 50, 125, 44, 34, 105, 99, 111, 110, 34, 58, 123, 34, 115, 101, 108, 101, 99, 116, 101, 100, 34, 58, 34, 76, 97, 98, 101, 108, 34, 44, 34, 108, 97, 98, 101, 108, 34, 58, 123, 34, 116, 101, 120, 116, 34, 58, 34, 83, 84, 34, 44, 34, 98, 97, 99, 107, 103, 114, 111, 117, 110, 100, 67, 111, 108, 111, 114, 34, 58, 34, 76, 105, 103, 104, 116, 66, 108, 117, 101, 34, 125, 44, 34, 105, 99,'
          '111, 110, 67, 111, 108, 108, 101, 99, 116, 105, 111, 110, 34, 58, 123, 34, 105, 100, 34, 58, 34, 97, 53, 98, 51, 102, 98, 54, 53, 45, 52, 101, 99, 53, 45, 52, 51, 101, 54, 45, 56, 101, 99, 49, 45, 52, 57, 101, 50, 52, 99, 97, 57, 101, 55, 97, 100, 34, 125, 125, 125, 93, 44, 34, 103, 114, 111, 117, 112, 115, 34, 58, 91, 93, 44, 34, 117, 112, 100, 97, 116, 101, 100, 65, 116, 34, 58, 49, 55, 49, 51, 53, 50, 56, 56, 49, 57, 54, 54, 48,'
          '44, 34, 115, 99, 104, 101, 109, 97, 86, 101, 114, 115, 105, 111, 110, 34, 58, 52, 44, 34, 97, 112, 112, 86, 101, 114, 115, 105, 111, 110, 67, 111, 100, 101, 34, 58, 53, 48, 48, 48, 48, 49, 57, 44, 34, 97, 112, 112, 86, 101, 114, 115, 105, 111, 110, 78, 97, 109, 101, 34, 58, 34, 53, 46, 52, 46, 48, 34, 44, 34, 97, 112, 112, 79, 114, 105, 103, 105, 110, 34, 58, 34, 97, 110, 100, 114, 111, 105, 100, 34, 125]';
      final jsonFileBytes = (jsonDecode(jsonFileBytesString) as List)
          .cast<int>();
      final jsonFile = XFile.fromData(
        Uint8List.fromList(jsonFileBytes),
        name: 'Two_Fas_plain.json',
      );
      group('plain', () {
        group('fileIsValid', () {
          test('isTrue', () async {
            // Act
            final fileIsValid = await processor.fileIsValid(jsonFile);
            // Assert
            expect(fileIsValid, isTrue);
          });
          test('isFalse', () async {
            // Arrange
            final jsonFileBytes =
                (jsonDecode(jsonFileBytesString) as List).cast<int>()
                  ..removeLast();
            final jsonFileInvalid = XFile.fromData(
              Uint8List.fromList(jsonFileBytes),
              name: 'Two_Fas_plain_invalid.json',
            );
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
      group('encrypted', () {
        const jsonFileBytesString =
            '[123, 34, 115, 101, 114, 118, 105, 99, 101, 115, 34, 58, 91, 93, 44, 34, 103, 114, 111, 117, 112, 115, 34, 58, 91, 93, 44, 34, 117, 112, 100, 97, 116, 101, 100, 65, 116, 34, 58, 49, 55, 49, 51, 53, 50, 56, 56, 49, 50, 55, 48, 51, 44, 34, 115, 99, 104, 101, 109, 97, 86, 101, 114, 115, 105, 111, 110, 34, 58, 52, 44, 34, 97, 112, 112, 86, 101, 114, 115, 105, 111, 110, 67, 111, 100, 101, 34, 58, 53, 48, 48, 48, 48, 49, 57, 44, 34, 97, 112, 112,'
            '86, 101, 114, 115, 105, 111, 110, 78, 97, 109, 101, 34, 58, 34, 53, 46, 52, 46, 48, 34, 44, 34, 97, 112, 112, 79, 114, 105, 103, 105, 110, 34, 58, 34, 97, 110, 100, 114, 111, 105, 100, 34, 44, 34, 115, 101, 114, 118, 105, 99, 101, 115, 69, 110, 99, 114, 121, 112, 116, 101, 100, 34, 58, 34, 110, 121, 115, 88, 84, 84, 50, 86, 51, 78, 122, 111, 54, 48, 110, 113, 108, 118, 90, 99, 89, 83, 80, 108, 102, 65, 54, 57, 81, 54, 52, 86, 78, 105, 101, 113,'
            '76, 100, 107, 53, 112, 53, 75, 88, 104, 66, 104, 106, 65, 68, 99, 80, 109, 71, 120, 102, 99, 83, 71, 122, 66, 100, 107, 116, 109, 52, 114, 53, 71, 114, 107, 103, 67, 116, 107, 113, 115, 86, 97, 121, 71, 48, 116, 78, 116, 122, 54, 67, 79, 106, 70, 71, 57, 119, 43, 108, 43, 70, 119, 88, 84, 78, 89, 108, 71, 115, 55, 56, 73, 113, 67, 51, 86, 102, 68, 81, 72, 52, 72, 75, 104, 76, 48, 97, 83, 107, 106, 51, 86, 55, 100, 76, 90, 76, 101, 70,'
            '86, 78, 106, 75, 69, 76, 68, 56, 90, 111, 97, 109, 89, 49, 106, 107, 75, 52, 65, 79, 86, 121, 57, 97, 107, 49, 98, 122, 56, 106, 82, 117, 119, 115, 53, 100, 54, 66, 103, 103, 109, 47, 121, 122, 105, 119, 49, 102, 111, 57, 77, 72, 56, 101, 90, 101, 108, 47, 74, 111, 78, 68, 72, 74, 117, 68, 78, 43, 105, 78, 86, 83, 99, 66, 119, 120, 80, 119, 53, 55, 67, 52, 105, 113, 68, 79, 48, 70, 83, 103, 76, 85, 121, 69, 68, 103, 70, 56, 48, 80,'
            '121, 43, 114, 57, 66, 52, 54, 83, 51, 85, 72, 101, 116, 66, 43, 99, 113, 57, 76, 68, 122, 69, 55, 55, 122, 68, 67, 111, 48, 111, 66, 114, 112, 48, 86, 80, 70, 113, 50, 72, 68, 120, 43, 85, 81, 108, 68, 55, 65, 50, 120, 114, 115, 72, 90, 108, 54, 90, 80, 66, 89, 83, 75, 108, 90, 117, 70, 83, 100, 55, 65, 99, 54, 89, 105, 108, 98, 98, 113, 82, 69, 57, 80, 108, 110, 113, 89, 112, 103, 116, 69, 117, 50, 108, 51, 43, 43, 78, 56, 56,'
            '112, 55, 116, 101, 74, 109, 50, 120, 114, 89, 110, 90, 102, 67, 103, 107, 72, 48, 104, 57, 99, 116, 51, 55, 55, 116, 74, 70, 73, 76, 100, 111, 88, 54, 119, 68, 108, 112, 113, 117, 56, 43, 113, 47, 119, 102, 121, 121, 48, 112, 107, 105, 102, 109, 101, 48, 80, 77, 109, 76, 122, 69, 52, 87, 101, 80, 122, 121, 122, 85, 82, 105, 84, 83, 101, 83, 99, 121, 76, 71, 66, 100, 107, 119, 66, 48, 70, 110, 100, 66, 98, 122, 111, 122, 109, 82, 87, 52, 75, 108,'
            '54, 112, 71, 50, 121, 82, 107, 120, 72, 53, 55, 77, 75, 103, 109, 120, 70, 72, 114, 103, 114, 49, 54, 49, 53, 119, 83, 72, 67, 106, 119, 122, 56, 74, 89, 73, 118, 120, 43, 99, 49, 77, 47, 119, 106, 85, 70, 56, 108, 71, 85, 74, 113, 48, 89, 82, 109, 97, 84, 47, 87, 108, 74, 77, 121, 50, 73, 86, 108, 97, 43, 83, 121, 72, 52, 80, 50, 80, 116, 100, 47, 113, 77, 85, 51, 106, 107, 47, 80, 115, 69, 52, 77, 55, 113, 90, 55, 107, 98, 104,'
            '98, 98, 112, 47, 100, 100, 48, 89, 113, 50, 99, 73, 90, 75, 87, 102, 85, 72, 75, 66, 72, 52, 48, 110, 74, 67, 107, 72, 81, 100, 51, 56, 43, 103, 73, 112, 114, 48, 67, 104, 77, 88, 85, 65, 120, 114, 115, 80, 104, 74, 83, 71, 89, 119, 97, 105, 52, 122, 105, 97, 83, 98, 49, 54, 52, 117, 85, 114, 85, 104, 66, 43, 97, 105, 73, 51, 80, 48, 47, 74, 76, 99, 82, 116, 78, 121, 99, 79, 100, 97, 105, 71, 102, 85, 53, 72, 98, 105, 47, 81,'
            '108, 72, 121, 51, 121, 82, 111, 74, 50, 107, 118, 102, 69, 52, 66, 47, 80, 54, 70, 57, 78, 106, 71, 89, 57, 105, 113, 83, 107, 97, 114, 54, 114, 121, 76, 75, 110, 104, 116, 87, 68, 74, 86, 81, 69, 99, 105, 78, 111, 52, 68, 117, 76, 72, 75, 49, 86, 88, 118, 101, 67, 106, 72, 76, 50, 76, 97, 43, 87, 73, 84, 65, 83, 78, 84, 110, 100, 70, 85, 112, 43, 52, 79, 87, 111, 118, 43, 98, 75, 70, 85, 113, 115, 106, 43, 100, 85, 75, 81, 106,'
            '116, 83, 99, 102, 110, 70, 111, 77, 86, 90, 118, 86, 71, 69, 98, 121, 113, 53, 100, 76, 74, 90, 102, 72, 90, 105, 90, 72, 111, 111, 116, 87, 47, 103, 87, 82, 57, 65, 107, 52, 122, 65, 66, 54, 51, 87, 120, 104, 80, 79, 105, 51, 81, 82, 79, 68, 109, 101, 112, 115, 56, 86, 122, 70, 79, 50, 105, 81, 83, 98, 75, 80, 101, 90, 118, 112, 79, 88, 89, 102, 43, 89, 84, 84, 99, 73, 57, 84, 57, 109, 98, 70, 109, 99, 49, 102, 72, 87, 87, 114,'
            '55, 56, 66, 50, 119, 76, 119, 88, 110, 107, 102, 107, 83, 49, 116, 52, 114, 78, 57, 75, 100, 116, 120, 118, 97, 67, 48, 120, 88, 68, 99, 65, 89, 101, 103, 121, 85, 121, 110, 101, 119, 48, 110, 120, 120, 52, 53, 111, 52, 78, 121, 121, 82, 55, 115, 88, 85, 111, 112, 71, 47, 57, 48, 119, 110, 55, 57, 87, 77, 66, 112, 104, 119, 86, 109, 116, 56, 117, 88, 118, 108, 47, 51, 79, 83, 73, 56, 51, 120, 122, 114, 71, 48, 111, 90, 66, 52, 71, 103, 99,'
            '85, 74, 101, 47, 84, 118, 115, 47, 56, 43, 66, 73, 56, 106, 115, 43, 68, 106, 50, 83, 55, 99, 68, 49, 98, 83, 78, 48, 121, 86, 117, 85, 53, 48, 56, 55, 120, 104, 54, 100, 107, 48, 79, 115, 87, 110, 121, 102, 88, 54, 119, 111, 43, 71, 71, 119, 89, 116, 84, 86, 106, 104, 67, 55, 82, 53, 115, 74, 65, 53, 88, 52, 112, 89, 114, 117, 51, 72, 88, 56, 72, 50, 68, 116, 71, 76, 112, 108, 112, 80, 107, 72, 90, 54, 119, 74, 49, 75, 56, 72,'
            '72, 103, 53, 111, 108, 119, 102, 68, 48, 122, 87, 101, 102, 107, 53, 99, 47, 77, 51, 54, 110, 90, 85, 73, 100, 51, 52, 86, 121, 86, 80, 88, 74, 67, 76, 119, 72, 99, 47, 122, 106, 71, 68, 89, 77, 83, 77, 117, 75, 72, 122, 69, 43, 103, 107, 71, 53, 81, 86, 55, 76, 54, 53, 100, 99, 89, 111, 75, 116, 83, 87, 84, 51, 83, 116, 87, 101, 88, 49, 47, 107, 88, 67, 115, 101, 100, 50, 48, 108, 106, 102, 87, 101, 82, 109, 109, 52, 97, 112, 51,'
            '68, 119, 43, 88, 100, 69, 47, 68, 81, 101, 75, 99, 43, 119, 83, 81, 76, 114, 104, 101, 122, 65, 72, 119, 84, 57, 53, 120, 109, 70, 108, 76, 89, 110, 74, 52, 50, 82, 90, 54, 74, 89, 97, 87, 68, 76, 68, 54, 57, 69, 108, 82, 90, 86, 104, 121, 75, 75, 84, 112, 99, 116, 71, 103, 85, 114, 83, 87, 119, 77, 50, 54, 114, 77, 72, 52, 83, 68, 117, 103, 65, 77, 56, 118, 76, 87, 118, 114, 74, 55, 50, 51, 108, 75, 100, 83, 109, 121, 47, 88,'
            '99, 86, 112, 67, 119, 69, 107, 78, 65, 100, 77, 51, 87, 109, 77, 84, 100, 84, 47, 98, 89, 106, 97, 68, 103, 86, 117, 56, 77, 88, 86, 89, 74, 98, 49, 122, 70, 50, 57, 66, 106, 65, 117, 66, 110, 113, 99, 81, 50, 48, 85, 106, 108, 120, 50, 100, 52, 115, 99, 70, 56, 57, 105, 114, 101, 84, 87, 77, 52, 65, 112, 57, 47, 119, 101, 114, 66, 119, 104, 43, 119, 100, 43, 53, 57, 68, 99, 112, 117, 84, 71, 66, 79, 86, 110, 97, 109, 48, 90, 77,'
            '99, 67, 111, 105, 118, 88, 105, 103, 75, 65, 52, 100, 87, 51, 107, 100, 69, 65, 50, 71, 43, 81, 113, 110, 65, 108, 50, 65, 78, 84, 117, 97, 79, 104, 90, 43, 100, 83, 68, 70, 105, 116, 83, 90, 49, 103, 104, 55, 47, 114, 90, 97, 112, 68, 106, 73, 119, 49, 53, 106, 81, 52, 117, 103, 55, 106, 107, 88, 48, 118, 99, 52, 108, 97, 116, 113, 90, 66, 65, 79, 110, 114, 118, 68, 72, 119, 61, 61, 58, 54, 68, 114, 79, 56, 88, 72, 77, 111, 87, 57,'
            '117, 77, 120, 75, 57, 122, 112, 122, 57, 103, 122, 53, 81, 86, 78, 122, 104, 78, 90, 83, 90, 77, 106, 89, 50, 81, 75, 72, 113, 114, 118, 109, 57, 47, 69, 57, 67, 119, 101, 54, 104, 81, 121, 108, 55, 73, 70, 51, 109, 43, 109, 52, 66, 87, 53, 87, 49, 101, 117, 102, 108, 105, 66, 81, 109, 119, 97, 115, 98, 76, 51, 77, 86, 65, 84, 79, 65, 88, 109, 57, 97, 84, 98, 111, 89, 119, 102, 86, 86, 105, 50, 71, 87, 98, 74, 119, 105, 120, 54, 47,'
            '99, 116, 70, 48, 52, 101, 43, 102, 120, 90, 87, 119, 77, 80, 115, 82, 109, 53, 82, 51, 56, 102, 67, 122, 68, 54, 56, 82, 78, 67, 54, 86, 68, 51, 101, 122, 114, 54, 43, 52, 56, 85, 68, 120, 116, 112, 66, 72, 117, 69, 71, 47, 78, 78, 101, 77, 66, 70, 51, 43, 122, 69, 86, 89, 74, 98, 112, 114, 116, 79, 79, 75, 113, 102, 101, 43, 101, 50, 84, 66, 85, 100, 106, 77, 84, 74, 72, 108, 52, 57, 70, 70, 83, 89, 83, 50, 73, 102, 68, 48,'
            '105, 90, 73, 117, 77, 102, 105, 68, 53, 87, 76, 54, 67, 99, 69, 114, 76, 113, 54, 75, 98, 86, 73, 49, 65, 43, 74, 115, 98, 115, 80, 87, 108, 86, 109, 111, 79, 84, 112, 53, 43, 57, 116, 98, 67, 101, 83, 99, 56, 112, 52, 87, 110, 72, 49, 57, 70, 55, 81, 56, 105, 84, 103, 72, 89, 77, 88, 52, 89, 83, 108, 111, 121, 47, 68, 90, 70, 108, 119, 52, 88, 79, 70, 100, 110, 102, 77, 98, 53, 70, 70, 57, 69, 79, 49, 115, 54, 48, 87, 77,'
            '116, 76, 56, 65, 72, 109, 98, 107, 121, 53, 56, 57, 116, 97, 105, 43, 108, 78, 72, 88, 52, 77, 102, 55, 112, 80, 57, 107, 121, 89, 119, 61, 61, 58, 97, 54, 111, 108, 99, 101, 88, 80, 56, 110, 84, 52, 87, 71, 48, 84, 34, 44, 34, 114, 101, 102, 101, 114, 101, 110, 99, 101, 34, 58, 34, 113, 100, 49, 49, 78, 83, 79, 65, 54, 115, 72, 52, 106, 70, 67, 66, 78, 75, 122, 48, 117, 43, 86, 48, 82, 120, 85, 86, 86, 56, 90, 57, 73, 102, 113,'
            '55, 54, 65, 97, 100, 121, 77, 89, 104, 69, 121, 101, 121, 90, 109, 100, 73, 119, 110, 48, 99, 50, 101, 103, 87, 43, 86, 55, 73, 66, 73, 114, 76, 75, 57, 66, 43, 117, 98, 90, 76, 117, 53, 86, 83, 68, 77, 100, 103, 66, 90, 108, 97, 73, 47, 52, 54, 103, 98, 48, 84, 79, 53, 67, 88, 102, 79, 118, 113, 55, 47, 66, 97, 112, 76, 87, 107, 71, 68, 111, 114, 65, 108, 110, 71, 75, 116, 113, 100, 84, 97, 70, 109, 109, 70, 86, 65, 80, 47, 79,'
            '48, 118, 57, 84, 122, 73, 53, 78, 56, 113, 98, 102, 98, 79, 120, 110, 84, 113, 86, 66, 48, 65, 43, 82, 73, 106, 50, 85, 50, 99, 79, 121, 66, 80, 108, 90, 52, 89, 82, 97, 105, 113, 88, 79, 89, 86, 65, 68, 57, 105, 76, 74, 73, 113, 68, 43, 66, 104, 100, 103, 121, 108, 83, 82, 105, 50, 89, 100, 118, 113, 84, 48, 106, 84, 51, 71, 88, 52, 113, 90, 65, 116, 104, 111, 70, 78, 76, 54, 55, 120, 86, 83, 112, 71, 106, 118, 53, 85, 57, 80,'
            '110, 50, 114, 76, 80, 85, 111, 73, 112, 66, 49, 75, 113, 117, 121, 101, 104, 104, 106, 66, 86, 70, 67, 121, 99, 67, 72, 83, 115, 66, 56, 119, 55, 80, 83, 76, 115, 118, 51, 82, 89, 100, 77, 71, 82, 55, 110, 106, 72, 79, 103, 57, 114, 86, 71, 86, 79, 89, 71, 77, 51, 109, 52, 76, 80, 112, 89, 118, 88, 50, 103, 76, 73, 66, 55, 118, 99, 98, 100, 49, 65, 104, 111, 55, 54, 100, 106, 119, 111, 89, 79, 122, 49, 66, 101, 99, 102, 67, 114, 105,'
            '87, 47, 101, 80, 113, 78, 52, 101, 84, 79, 77, 51, 51, 107, 43, 106, 69, 101, 52, 43, 86, 76, 90, 89, 77, 101, 43, 56, 61, 58, 54, 68, 114, 79, 56, 88, 72, 77, 111, 87, 57, 117, 77, 120, 75, 57, 122, 112, 122, 57, 103, 122, 53, 81, 86, 78, 122, 104, 78, 90, 83, 90, 77, 106, 89, 50, 81, 75, 72, 113, 114, 118, 109, 57, 47, 69, 57, 67, 119, 101, 54, 104, 81, 121, 108, 55, 73, 70, 51, 109, 43, 109, 52, 66, 87, 53, 87, 49, 101, 117,'
            '102, 108, 105, 66, 81, 109, 119, 97, 115, 98, 76, 51, 77, 86, 65, 84, 79, 65, 88, 109, 57, 97, 84, 98, 111, 89, 119, 102, 86, 86, 105, 50, 71, 87, 98, 74, 119, 105, 120, 54, 47, 99, 116, 70, 48, 52, 101, 43, 102, 120, 90, 87, 119, 77, 80, 115, 82, 109, 53, 82, 51, 56, 102, 67, 122, 68, 54, 56, 82, 78, 67, 54, 86, 68, 51, 101, 122, 114, 54, 43, 52, 56, 85, 68, 120, 116, 112, 66, 72, 117, 69, 71, 47, 78, 78, 101, 77, 66, 70, 51,'
            '43, 122, 69, 86, 89, 74, 98, 112, 114, 116, 79, 79, 75, 113, 102, 101, 43, 101, 50, 84, 66, 85, 100, 106, 77, 84, 74, 72, 108, 52, 57, 70, 70, 83, 89, 83, 50, 73, 102, 68, 48, 105, 90, 73, 117, 77, 102, 105, 68, 53, 87, 76, 54, 67, 99, 69, 114, 76, 113, 54, 75, 98, 86, 73, 49, 65, 43, 74, 115, 98, 115, 80, 87, 108, 86, 109, 111, 79, 84, 112, 53, 43, 57, 116, 98, 67, 101, 83, 99, 56, 112, 52, 87, 110, 72, 49, 57, 70, 55, 81,'
            '56, 105, 84, 103, 72, 89, 77, 88, 52, 89, 83, 108, 111, 121, 47, 68, 90, 70, 108, 119, 52, 88, 79, 70, 100, 110, 102, 77, 98, 53, 70, 70, 57, 69, 79, 49, 115, 54, 48, 87, 77, 116, 76, 56, 65, 72, 109, 98, 107, 121, 53, 56, 57, 116, 97, 105, 43, 108, 78, 72, 88, 52, 77, 102, 55, 112, 80, 57, 107, 121, 89, 119, 61, 61, 58, 71, 103, 119, 105, 68, 99, 73, 79, 86, 84, 117, 68, 76, 80, 75, 75, 34, 125]';
        final jsonFileBytes = (jsonDecode(jsonFileBytesString) as List)
            .cast<int>();
        final jsonFile = XFile.fromData(
          Uint8List.fromList(jsonFileBytes),
          name: 'Two_Fas_encrypted.json',
        );
        group('fileIsValid', () {
          test('isTrue', () async {
            // Act
            final fileIsValid = await processor.fileIsValid(jsonFile);
            // Assert
            expect(fileIsValid, isTrue);
          });
          test('isFalse', () async {
            // Arrange
            final jsonFileBytes =
                (jsonDecode(jsonFileBytesString) as List).cast<int>()
                  ..removeLast();
            final jsonFileInvalid = XFile.fromData(
              Uint8List.fromList(jsonFileBytes),
              name: 'Two_Fas_encrypted_invalid.json',
            );
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
          expect(fileNeedsPassword, isTrue);
        });
        test('processFile', () async {
          // Arrange
          const password = 'test123';
          // Act
          final results = await processor.processFile(
            jsonFile,
            password: password,
          );
          // Assert
          _assertSuccessResults(results);
        });
      });
    });
  });
}

const _password = '2fas test password';
const _secretA = 'JBSWY3DPEHPK3PXP';
const _secretB = 'GEZDGNBVGY3TQOJQ';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

XFile _xFile(Object content, {String name = 'twofas.json'}) => XFile.fromData(
  Uint8List.fromList(
    utf8.encode(content is String ? content : jsonEncode(content)),
  ),
  name: name,
);

Uint8List _randomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

Map<String, dynamic> _service({
  String name = 'Example',
  String secret = _secretA,
  String tokenType = 'TOTP',
  String label = 'alice@example.com',
  String algorithm = 'SHA1',
  int digits = 6,
  int period = 30,
  int counter = 0,
}) => {
  'name': name,
  'secret': secret,
  'updatedAt': 1713519600602,
  'otp': {
    'label': label,
    'account': label,
    'digits': digits,
    'period': period,
    'algorithm': algorithm,
    'counter': counter,
    'tokenType': tokenType,
    'source': 'Manual',
  },
  'order': {'position': 0},
};

Map<String, dynamic> _plainFile(List<Object?> services) => {
  'services': services,
  'groups': <Object>[],
  'updatedAt': 1713519600602,
  'schemaVersion': 4,
  'appVersionCode': 5000019,
  'appVersionName': '5.4.0',
  'appOrigin': 'android',
};

/// Builds the `servicesEncrypted` value like 2FAS does it:
/// `base64(ciphertext + tag):base64(salt):base64(iv)` with PBKDF2-HMAC-SHA256 (10000 iterations)
/// and AES-256-GCM. 2FAS uses a 256 byte salt, the processor derives the key length from the salt length.
Future<String> _servicesEncrypted(
  String plain, {
  String password = _password,
}) async {
  final salt = _randomBytes(256);
  final iv = _randomBytes(12);
  final key = await crypto.Pbkdf2(
    macAlgorithm: crypto.Hmac.sha256(),
    iterations: 10000,
    bits: 256,
  ).deriveKeyFromPassword(password: password, nonce: salt);
  final box = await crypto.AesGcm.with256bits().encrypt(
    utf8.encode(plain),
    secretKey: key,
    nonce: iv,
  );
  return '${base64Encode(box.concatenation(nonce: false))}:${base64Encode(salt)}:${base64Encode(iv)}';
}

Future<Map<String, dynamic>> _encryptedFile(
  Object services, {
  String password = _password,
}) async => {
  'services': <Object>[],
  'groups': <Object>[],
  'updatedAt': 1713519600602,
  'servicesEncrypted': await _servicesEncrypted(
    services is String ? services : jsonEncode(services),
    password: password,
  ),
  'schemaVersion': 4,
  'appVersionCode': 5000019,
  'appVersionName': '5.4.0',
  'appOrigin': 'android',
};

Future<Object?> _outcomeOf(Future<List<ProcessorResult<Token>>> future) async {
  try {
    return await future;
  } catch (e) {
    return e;
  }
}

String _failureMessage(ProcessorResult<Token> result) =>
    result.asFailed!.message(AppLocalizationsEn());

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void _testTwoFasImportFileProcessorEdgeCases() {
  group('Two Fas Import File Processor edge cases', () {
    const processor = TwoFasAuthenticatorImportFileProcessor();

    group('file validation', () {
      test('plain export is valid and needs no password', () async {
        final file = _xFile(_plainFile([_service()]));
        expect(await processor.fileIsValid(file), isTrue);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });

      test('encrypted export is valid and needs a password', () async {
        final file = _xFile(await _encryptedFile([_service()]));
        expect(await processor.fileIsValid(file), isTrue);
        expect(await processor.fileNeedsPassword(file), isTrue);
      });

      test('non json content is neither valid nor needs a password', () async {
        final file = _xFile('<html>not json</html>');
        expect(await processor.fileIsValid(file), isFalse);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });

      test('a json list is neither valid nor needs a password', () async {
        final file = _xFile('[{"services": []}]');
        expect(await processor.fileIsValid(file), isFalse);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });

      test(
        'a json object with neither services nor servicesEncrypted is not valid',
        () async {
          final file = _xFile({'groups': <Object>[], 'schemaVersion': 4});
          expect(await processor.fileIsValid(file), isFalse);
          expect(await processor.fileNeedsPassword(file), isFalse);
        },
      );

      test('an empty file is not valid', () async {
        expect(await processor.fileIsValid(_xFile('')), isFalse);
      });
    });

    group('invalid input', () {
      test('non json content throws InvalidFileContentException', () async {
        await expectLater(
          processor.processFile(_xFile('no json')),
          throwsA(isA<InvalidFileContentException>()),
        );
        await expectLater(
          processor.processFile(_xFile('no json'), password: _password),
          throwsA(isA<InvalidFileContentException>()),
        );
      });

      test('a json list throws InvalidFileContentException', () async {
        await expectLater(
          processor.processFile(_xFile('[]')),
          throwsA(isA<InvalidFileContentException>()),
        );
      });

      test(
        'a json object without services and servicesEncrypted throws InvalidFileContentException',
        () async {
          final file = _xFile({'schemaVersion': 4});
          await expectLater(
            processor.processFile(file),
            throwsA(isA<InvalidFileContentException>()),
          );
          await expectLater(
            processor.processFile(file, password: _password),
            throwsA(isA<InvalidFileContentException>()),
          );
        },
      );

      test(
        'a file that fileIsValid accepts can be processed without throwing (UI contract)',
        () async {
          // import_start_page.dart calls fileIsValid() and then processFile() without a try/catch,
          // an exception leaves the import page in its loading state.
          final file = _xFile(_plainFile([]));
          expect(await processor.fileIsValid(file), isTrue);

          final outcome = await _outcomeOf(processor.processFile(file));

          expect(outcome, isA<List<ProcessorResult<Token>>>());
        },
        skip:
            'BUG: two_fas_import_file_processor.dart:152 an export with an empty services list passes fileIsValid (line 80) but processFile throws InvalidFileContentException, which the import page does not catch',
      );
    });

    group('plain export', () {
      test('imports totp, hotp and steam with all attributes', () async {
        final file = _xFile(
          _plainFile([
            _service(
              name: 'Issuer A',
              algorithm: 'SHA256',
              digits: 8,
              period: 60,
              label: 'bob',
            ),
            _service(
              name: 'Issuer B',
              secret: _secretB,
              tokenType: 'HOTP',
              algorithm: 'SHA512',
              digits: 7,
              counter: 12,
              label: 'carol',
            ),
            _service(
              name: 'Steam',
              secret: _secretB,
              tokenType: 'STEAM',
              digits: 5,
            ),
          ]),
        );

        final results = await processor.processFile(file);

        expect(results.length, 3);
        expect(
          results.every((r) => r.isSuccess),
          isTrue,
          reason: results
              .where((r) => r.isFailed)
              .map(_failureMessage)
              .join(' | '),
        );
        final totp = results[0].asSuccess!.resultData as TOTPToken;
        expect(totp.issuer, 'Issuer A');
        expect(totp.label, 'bob');
        expect(totp.secret, _secretA);
        expect(totp.algorithm, Algorithms.SHA256);
        expect(totp.digits, 8);
        expect(totp.period, 60);
        final hotp = results[1].asSuccess!.resultData as HOTPToken;
        expect(hotp.issuer, 'Issuer B');
        expect(hotp.label, 'carol');
        expect(hotp.secret, _secretB);
        expect(hotp.algorithm, Algorithms.SHA512);
        expect(hotp.digits, 7);
        expect(hotp.counter, 12);
        final steam = results[2].asSuccess!.resultData;
        expect(steam, isA<SteamToken>());
        expect((steam as SteamToken).secret, _secretB);
      });

      test('a plain export is imported even if a password is passed', () async {
        final file = _xFile(
          _plainFile([_service(name: 'plain with password')]),
        );

        final results = await processor.processFile(file, password: _password);

        expect(results.length, 1);
        expect(
          results.single.asSuccess!.resultData.issuer,
          'plain with password',
        );
      });

      test(
        'an unknown tokenType becomes a failed result and the others are imported',
        () async {
          final file = _xFile(
            _plainFile([
              _service(name: 'first'),
              _service(name: 'weird', tokenType: 'MOTP'),
              _service(name: 'last', tokenType: 'HOTP'),
            ]),
          );

          final results = await processor.processFile(file);

          expect(results.map((r) => r.isSuccess), [true, false, true]);
          expect(results[0].asSuccess!.resultData.issuer, 'first');
          expect(results[2].asSuccess!.resultData.issuer, 'last');
        },
      );

      test('a missing tokenType becomes a failed result', () async {
        final service = _service();
        (service['otp'] as Map).remove('tokenType');
        final file = _xFile(_plainFile([service, _service(name: 'ok')]));

        final results = await processor.processFile(file);

        expect(results.map((r) => r.isSuccess), [false, true]);
      });

      test(
        'a missing otp object becomes a failed result and the others are imported',
        () async {
          final service = _service(name: 'no otp')..remove('otp');
          final file = _xFile(
            _plainFile([
              _service(name: 'first'),
              service,
              _service(name: 'last'),
            ]),
          );

          final results = await processor.processFile(file);

          expect(results.map((r) => r.isSuccess), [true, false, true]);
          expect(results[2].asSuccess!.resultData.issuer, 'last');
        },
      );

      test('a missing secret becomes a failed result', () async {
        final service = _service()..remove('secret');
        final file = _xFile(_plainFile([service, _service(name: 'ok')]));

        final results = await processor.processFile(file);

        expect(results.map((r) => r.isSuccess), [false, true]);
      });

      test('a secret that is not base32 becomes a failed result', () async {
        final file = _xFile(
          _plainFile([
            _service(secret: 'not base32 !!!'),
            _service(name: 'ok'),
          ]),
        );

        final results = await processor.processFile(file);

        expect(results.map((r) => r.isSuccess), [false, true]);
      });

      test(
        'a service that is not an object becomes a failed result and the others are imported',
        () async {
          final file = _xFile(
            _plainFile([
              _service(name: 'first'),
              'garbage',
              _service(name: 'last'),
            ]),
          );

          final results = await processor.processFile(file);

          expect(results.map((r) => r.isSuccess), [true, false, true]);
        },
        skip:
            'BUG: two_fas_import_file_processor.dart:166 the lazy cast<Map> is evaluated in the for-in header outside the try block, a non-object service aborts the whole import with a raw TypeError',
      );

      test('the original service json is kept as token origin data', () async {
        final service = _service(name: 'origin');
        final file = _xFile(_plainFile([service]));

        final results = await processor.processFile(file);

        final origin = results.single.asSuccess!.resultData.origin;
        expect(origin, isNotNull);
        expect(jsonDecode(origin!.data), service);
      });
    });

    group('encrypted export', () {
      test('round trip with the correct password', () async {
        final file = _xFile(
          await _encryptedFile([
            _service(name: 'enc totp', digits: 8),
            _service(
              name: 'enc hotp',
              secret: _secretB,
              tokenType: 'HOTP',
              counter: 4,
            ),
          ]),
        );

        final results = await processor.processFile(file, password: _password);

        expect(results.length, 2);
        expect(results.every((r) => r.isSuccess), isTrue);
        final totp = results[0].asSuccess!.resultData as TOTPToken;
        expect(totp.issuer, 'enc totp');
        expect(totp.secret, _secretA);
        expect(totp.digits, 8);
        final hotp = results[1].asSuccess!.resultData as HOTPToken;
        expect(hotp.secret, _secretB);
        expect(hotp.counter, 4);
      });

      test('processEncryptedFile accepts the raw json string', () async {
        final json = await _encryptedFile([_service(name: 'from string')]);

        final results = await processor.processEncryptedFile(
          jsonString: jsonEncode(json),
          password: _password,
        );

        expect(results.single.asSuccess!.resultData.issuer, 'from string');
      });

      test('a wrong password throws BadDecryptionPasswordException', () async {
        final file = _xFile(await _encryptedFile([_service()]));

        await expectLater(
          processor.processFile(file, password: 'wrong password'),
          throwsA(isA<BadDecryptionPasswordException>()),
        );
      });

      test('an empty password throws BadDecryptionPasswordException', () async {
        final file = _xFile(await _encryptedFile([_service()]));

        await expectLater(
          processor.processFile(file, password: ''),
          throwsA(isA<BadDecryptionPasswordException>()),
        );
      });

      test(
        'an encrypted file processed without a password throws BadDecryptionPasswordException',
        () async {
          final file = _xFile(await _encryptedFile([_service()]));

          await expectLater(
            processor.processFile(file),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        },
      );

      test(
        'a manipulated ciphertext throws BadDecryptionPasswordException',
        () async {
          // AES-GCM cannot tell a wrong key from manipulated data
          final json = await _encryptedFile([_service()]);
          final parts = (json['servicesEncrypted'] as String).split(':');
          final data = base64Decode(parts[0]);
          data[0] ^= 0xFF;
          json['servicesEncrypted'] = [
            base64Encode(data),
            parts[1],
            parts[2],
          ].join(':');

          await expectLater(
            processor.processFile(_xFile(json), password: _password),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        },
      );

      test(
        'an encrypted export of zero services yields an empty result list',
        () async {
          final file = _xFile(await _encryptedFile(<Object>[]));

          final results = await processor.processFile(
            file,
            password: _password,
          );

          expect(results, isEmpty);
        },
      );

      test(
        'correct password but the payload is not json throws InvalidFileContentException',
        () async {
          final file = _xFile(await _encryptedFile('this is not json'));

          await expectLater(
            processor.processFile(file, password: _password),
            throwsA(isA<InvalidFileContentException>()),
          );
        },
      );

      test(
        'correct password but the payload is a json object instead of a list throws InvalidFileContentException',
        () async {
          final file = _xFile(await _encryptedFile('{"not": "a list"}'));

          await expectLater(
            processor.processFile(file, password: _password),
            throwsA(isA<InvalidFileContentException>()),
          );
        },
      );

      test(
        'an unknown tokenType inside the encrypted payload becomes a failed result',
        () async {
          final file = _xFile(
            await _encryptedFile([
              _service(name: 'ok'),
              _service(name: 'weird', tokenType: 'NOPE'),
            ]),
          );

          final results = await processor.processFile(
            file,
            password: _password,
          );

          expect(results.map((r) => r.isSuccess), [true, false]);
        },
      );

      test(
        'a missing otp object inside the encrypted payload becomes a failed result',
        () async {
          final service = _service(name: 'no otp')..remove('otp');
          final file = _xFile(
            await _encryptedFile([service, _service(name: 'ok')]),
          );

          final results = await processor.processFile(
            file,
            password: _password,
          );

          expect(results.map((r) => r.isSuccess), [false, true]);
        },
      );
    });

    group('malformed servicesEncrypted is not reported as a wrong password', () {
      void expectNotAPasswordProblem(Object? outcome) {
        expect(
          outcome,
          isNot(isA<BadDecryptionPasswordException>()),
          reason:
              'A corrupt file must not tell the user that the password is wrong',
        );
        expect(outcome, isA<InvalidFileContentException>());
      }

      Future<Object?> processMalformed(Object? servicesEncrypted) {
        final file = _xFile({
          'services': <Object>[],
          'servicesEncrypted': servicesEncrypted,
        });
        return _outcomeOf(processor.processFile(file, password: _password));
      }

      test(
        'without any separator',
        () async {
          expectNotAPasswordProblem(await processMalformed('abcdefgh'));
        },
        skip:
            'BUG: two_fas_import_file_processor.dart:132 catch (e) turns every failure while parsing/decrypting servicesEncrypted (RangeError, FormatException, TypeError) into BadDecryptionPasswordException',
      );

      test(
        'with only two segments',
        () async {
          expectNotAPasswordProblem(
            await processMalformed(
              '${base64Encode([1, 2, 3])}:${base64Encode([4, 5])}',
            ),
          );
        },
        skip:
            'BUG: two_fas_import_file_processor.dart:132 catch (e) turns every failure while parsing/decrypting servicesEncrypted into BadDecryptionPasswordException',
      );

      test(
        'with segments that are not base64',
        () async {
          expectNotAPasswordProblem(await processMalformed('%%%:%%%:%%%'));
        },
        skip:
            'BUG: two_fas_import_file_processor.dart:132 catch (e) turns every failure while parsing/decrypting servicesEncrypted into BadDecryptionPasswordException',
      );

      test(
        'that is not a string',
        () async {
          expectNotAPasswordProblem(await processMalformed(12345));
        },
        skip:
            'BUG: two_fas_import_file_processor.dart:132 catch (e) turns every failure while parsing/decrypting servicesEncrypted into BadDecryptionPasswordException',
      );

      test(
        'that is an empty string',
        () async {
          expectNotAPasswordProblem(await processMalformed(''));
        },
        skip:
            'BUG: two_fas_import_file_processor.dart:132 catch (e) turns every failure while parsing/decrypting servicesEncrypted into BadDecryptionPasswordException',
      );
    });
  });
}
