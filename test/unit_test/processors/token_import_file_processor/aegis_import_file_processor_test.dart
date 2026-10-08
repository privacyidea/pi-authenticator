import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart' show Scrypt, ScryptParameters;
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_argument_error.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/aegis_import_file_processor.dart';
import 'package:privacyidea_authenticator/processors/token_import_file_processor/two_fas_import_file_processor.dart';

void main() {
  _testAegisImportFileProcessor();
  _testAegisImportFileProcessorEdgeCases();
}

void _testAegisImportFileProcessor() {
  group('Aegis Import File Processor test', () {
    group('version 3', () {
      group('import json', () {
        test('plain', () async {
          // Arrange
          const byteDataString =
              '[123, 10, 32, 32, 32, 32, 34, 118, 101, 114, 115, 105, 111, 110, 34, 58, 32, 49, 44, 10, 32, 32, 32, 32, 34, 104, 101, 97, 100, 101, 114, 34, 58, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 115, 108, 111, 116, 115, 34, 58, 32, 110, 117, 108, 108, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 112, 97, 114, 97, 109, 115, 34, 58, 32, 110, 117, 108, 108, 10, 32, 32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 34, 100, 98, 34, 58, 32,'
              '123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 118, 101, 114, 115, 105, 111, 110, 34, 58, 32, 51, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 101, 110, 116, 114, 105, 101, 115, 34, 58, 32, 91, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 121, 112, 101, 34, 58, 32, 34, 116, 111, 116, 112, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 34, 117, 117, 105, 100, 34, 58, 32, 34, 99, 52, 57, 51, 102, 50, 52, 97, 45, 48, 54, 102, 55, 45, 52, 54, 57, 51, 45, 57, 100, 98, 102, 45, 53, 50, 53, 102, 56, 49, 54, 54, 102, 57, 100, 97, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 97, 109, 101, 34, 58, 32, 34, 84, 101, 115, 116, 49, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 34, 105, 115, 115, 117, 101, 114, 34, 58, 32, 34, 84, 101, 115, 116, 105, 110, 103, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 111, 116, 101, 34, 58, 32, 34, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 102, 97, 118, 111, 114, 105, 116, 101, 34, 58, 32, 102, 97, 108, 115, 101, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 34, 105, 99, 111, 110, 34, 58, 32, 110, 117, 108, 108, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 105, 110, 102, 111, 34, 58, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 115, 101, 99, 114, 101, 116, 34, 58, 32, 34, 65, 65, 65, 65, 65, 65, 65, 65, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 34, 97, 108, 103, 111, 34, 58, 32, 34, 83, 72, 65, 49, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 100, 105, 103, 105, 116, 115, 34, 58, 32, 54, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 112, 101, 114, 105, 111, 100, 34, 58, 32, 51, 48, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 103, 114, 111, 117, 112, 115, 34, 58, 32, 91, 93, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 121, 112, 101, 34, 58, 32, 34, 104, 111, 116, 112, 34, 44, 10, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 117, 117, 105, 100, 34, 58, 32, 34, 50, 48, 55, 102, 49, 49, 102, 48, 45, 54, 100, 101, 52, 45, 52, 97, 52, 99, 45, 57, 97, 98, 97, 45, 57, 55, 98, 50, 55, 55, 102, 101, 54, 48, 56, 97, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 97, 109, 101, 34, 58, 32, 34, 84, 101, 115, 116, 50, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 105, 115, 115, 117, 101, 114, 34, 58, 32, 34, 84, 101, 115, 116, 105, 110, 103, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 111, 116, 101, 34, 58, 32, 34, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 102, 97, 118, 111, 114, 105, 116, 101, 34, 58, 32, 102, 97, 108, 115, 101, 44, 10, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 105, 99, 111, 110, 34, 58, 32, 110, 117, 108, 108, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 105, 110, 102, 111, 34, 58, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 115, 101, 99, 114, 101, 116, 34, 58, 32, 34, 65, 65, 65, 65, 65, 65, 65, 65, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 97, 108, 103, 111, 34, 58, 32, 34, 83, 72, 65, 49, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 100, 105, 103, 105, 116, 115, 34, 58, 32, 54, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 99, 111, 117, 110, 116, 101, 114, 34, 58, 32, 48, 10, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 103, 114, 111, 117, 112, 115, 34, 58, 32, 91, 93, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 125, 10, 32, 32, 32, 32, 32, 32, 32, 32, 93, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 103, 114, 111, 117, 112, 115, 34, 58, 32, 91, 93, 10, 32, 32, 32, 32, 125, 10, 125]';
          final byteData = ByteData.view(
            Uint8List.fromList(
              (jsonDecode(byteDataString) as List).cast(),
            ).buffer,
          );

          const aegisImportFileProcessor = AegisImportFileProcessor();
          final XFile file = XFile.fromData(
            byteData.buffer.asUint8List(),
            name: 'aegis_plain.json',
          );
          // Act
          final isValid = await aegisImportFileProcessor.fileIsValid(file);
          final results = await aegisImportFileProcessor.processFile(file);
          // Assert
          expect(isValid, isTrue);
          expect(results.length, equals(2));
          final result0 = results[0];
          expect(result0, isA<ProcessorResultSuccess>());
          final token0 = result0.asSuccess!.resultData;
          expect(token0.label, equals('Test1'));
          expect(token0.type, equals('TOTP'));
          expect(token0.origin, isNotNull);
          final totpToken = token0 as TOTPToken;
          expect(totpToken.digits, equals(6));
          expect(totpToken.algorithm.name, equals('SHA1'));
          expect(totpToken.period, equals(30));
          expect(totpToken.secret, equals('AAAAAAAA'));
          expect(totpToken.issuer, equals('Testing'));
          expect(
            totpToken.otpFromTime(
              DateTime.fromMillisecondsSinceEpoch(1713352639317),
            ),
            equals('220975'),
          );
          final result1 = results[1];
          expect(result1, isA<ProcessorResultSuccess>());
          final token1 = result1.asSuccess!.resultData;
          expect(token1.label, equals('Test2'));
          expect(token1.type, equals('HOTP'));
          expect(token1.origin, isNotNull);
          final hotpToken = token1 as HOTPToken;
          expect(hotpToken.digits, equals(6));
          expect(hotpToken.algorithm.name, equals('SHA1'));
          expect(hotpToken.counter, equals(0));
          expect(hotpToken.secret, equals('AAAAAAAA'));
          expect(hotpToken.issuer, equals('Testing'));
          expect(hotpToken.otpValue, equals('328482'));
        });

        test('encrypted', () async {
          // Arrange
          const encryptedBytesString =
              '[123, 10, 32, 32, 32, 32, 34, 118, 101, 114, 115, 105, 111, 110, 34, 58, 32, 49, 44, 10, 32, 32, 32, 32, 34, 104, 101, 97, 100, 101, 114, 34, 58, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 115, 108, 111, 116, 115, 34, 58, 32, 91, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 121, 112, 101, 34, 58, 32, 49, 44, 10, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 117, 117, 105, 100, 34, 58, 32, 34, 99, 101, 53, 50, 101, 98, 99, 56, 45, 53, 56, 53, 54, 45, 52, 52, 100, 52, 45, 97, 99, 49, 49, 45, 102, 102, 54, 48, 49, 57, 57, 53, 48, 101, 98, 102, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 107, 101, 121, 34, 58, 32, 34, 54, 48, 102, 51, 101, 99, 102, 101, 57, 57, 54, 53, 55, 54, 55, 98,'
              '97, 49, 53, 51, 53, 50, 49, 49, 48, 99, 50, 54, 56, 101, 53, 56, 48, 50, 53, 53, 56, 53, 101, 54, 52, 98, 57, 99, 54, 99, 53, 98, 53, 99, 97, 97, 54, 98, 101, 52, 56, 98, 53, 98, 101, 98, 57, 50, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 107, 101, 121, 95, 112, 97, 114, 97, 109, 115, 34, 58, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 34, 110, 111, 110, 99, 101, 34, 58, 32, 34, 98, 56, 100, 50, 54, 97, 48, 53, 99, 57, 51, 49, 56, 54, 99, 57, 55, 52, 98, 55, 49, 54, 99, 51, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 97, 103, 34, 58, 32, 34, 51, 56, 99, 49, 102, 48, 50, 100, 57, 48, 56, 51, 49, 50, 55, 56, 99, 53, 55, 56, 48, 100, 54, 53, 54, 97, 56, 99, 53, 50, 48, 97,'
              '34, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 34, 58, 32, 51, 50, 55, 54, 56, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 114, 34, 58, 32, 56, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 112, 34, 58, 32, 49, 44, 10, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 115, 97, 108, 116, 34, 58, 32, 34, 99, 51, 49, 57, 49, 57, 100, 53, 97, 50, 57, 48, 54, 102, 50, 54, 51, 57, 97, 51, 52, 50, 50, 99, 49, 53, 102, 102, 52, 52, 100, 51, 101, 55, 50, 50, 56, 53, 101, 97, 52, 54, 98, 48, 48, 97, 51, 48, 48, 57, 55, 52, 100, 57, 102, 98, 54, 99, 100, 97, 97, 48, 101, 100, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 34, 114, 101, 112, 97, 105, 114, 101, 100, 34, 58, 32, 116, 114, 117, 101, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 105, 115, 95, 98, 97, 99, 107, 117, 112, 34, 58, 32, 102, 97, 108, 115, 101, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 125, 10, 32, 32, 32, 32, 32, 32, 32, 32, 93, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 112, 97, 114, 97, 109, 115, 34, 58,'
              '32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 111, 110, 99, 101, 34, 58, 32, 34, 48, 57, 102, 48, 53, 54, 52, 49, 48, 50, 55, 49, 102, 50, 99, 50, 52, 97, 51, 51, 100, 52, 99, 54, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 97, 103, 34, 58, 32, 34, 51, 48, 54, 53, 54, 100, 102, 50, 102, 54, 97, 49, 97, 100, 99, 48, 99, 56, 51, 98, 99, 97, 55, 57, 99, 101, 101, 97,'
              '57, 99, 100, 54, 34, 10, 32, 32, 32, 32, 32, 32, 32, 32, 125, 10, 32, 32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 34, 100, 98, 34, 58, 32, 34, 82, 89, 75, 89, 119, 107, 119, 100, 71, 121, 54, 76, 49, 54, 85, 87, 119, 116, 68, 84, 57, 48, 67, 102, 100, 81, 77, 119, 97, 105, 115, 72, 78, 70, 99, 51, 116, 103, 103, 87, 87, 56, 65, 79, 84, 113, 118, 51, 118, 106, 121, 52, 74, 56, 50, 52, 107, 87, 66, 108, 108, 105, 77, 50, 65, 85,'
              '48, 92, 47, 53, 98, 116, 108, 108, 86, 106, 78, 77, 121, 74, 100, 97, 79, 86, 79, 98, 98, 121, 85, 90, 52, 106, 78, 117, 118, 72, 106, 114, 79, 97, 99, 73, 92, 47, 121, 97, 51, 88, 70, 54, 85, 48, 113, 43, 87, 89, 68, 111, 70, 97, 110, 57, 116, 110, 78, 56, 83, 48, 78, 78, 97, 66, 67, 102, 82, 87, 72, 66, 66, 118, 119, 83, 118, 77, 118, 112, 92, 47, 98, 109, 43, 66, 76, 113, 69, 56, 92, 47, 108, 82, 72, 74, 81, 119, 102, 54,'
              '71, 49, 83, 49, 106, 103, 56, 110, 84, 122, 108, 120, 113, 54, 53, 52, 109, 121, 103, 115, 122, 118, 111, 72, 80, 65, 97, 52, 76, 99, 83, 99, 48, 77, 103, 50, 87, 48, 109, 53, 99, 103, 81, 112, 69, 73, 111, 51, 73, 111, 88, 113, 104, 66, 87, 101, 67, 85, 55, 70, 70, 68, 87, 102, 88, 120, 86, 104, 117, 56, 99, 72, 69, 105, 112, 114, 86, 73, 103, 43, 73, 48, 83, 74, 82, 119, 98, 117, 78, 102, 88, 107, 106, 105, 75, 122, 67, 116, 52, 111,'
              '74, 119, 67, 85, 113, 111, 48, 88, 84, 57, 84, 121, 88, 87, 110, 75, 89, 51, 108, 70, 73, 107, 101, 77, 111, 101, 90, 114, 84, 100, 103, 122, 105, 118, 79, 111, 52, 54, 87, 80, 52, 76, 52, 67, 99, 74, 92, 47, 69, 110, 101, 73, 85, 83, 107, 100, 100, 73, 90, 109, 55, 106, 106, 88, 112, 70, 92, 47, 82, 112, 120, 106, 53, 107, 112, 67, 89, 75, 74, 54, 50, 69, 89, 54, 89, 108, 79, 88, 99, 110, 74, 78, 88, 81, 92, 47, 100, 86, 51, 75,'
              '66, 101, 112, 119, 51, 104, 69, 97, 113, 109, 116, 81, 43, 82, 75, 98, 102, 108, 111, 108, 69, 77, 106, 50, 80, 65, 120, 112, 114, 43, 104, 118, 79, 107, 112, 105, 69, 90, 86, 48, 113, 120, 79, 48, 43, 98, 70, 67, 66, 108, 120, 107, 78, 74, 50, 110, 99, 49, 110, 117, 82, 99, 88, 102, 73, 49, 56, 121, 75, 112, 56, 82, 51, 99, 69, 75, 43, 105, 99, 90, 119, 67, 54, 65, 114, 100, 120, 107, 101, 116, 76, 49, 122, 114, 80, 103, 68, 117, 67, 100,'
              '122, 54, 53, 108, 111, 43, 90, 69, 112, 118, 81, 116, 73, 78, 92, 47, 67, 115, 80, 69, 113, 118, 73, 89, 72, 55, 81, 55, 114, 111, 112, 112, 87, 101, 79, 105, 122, 80, 80, 120, 84, 118, 99, 98, 72, 57, 99, 80, 122, 50, 105, 76, 53, 104, 107, 105, 55, 48, 116, 97, 106, 85, 120, 113, 88, 103, 80, 120, 68, 116, 68, 113, 43, 78, 50, 120, 48, 92, 47, 103, 71, 100, 99, 105, 65, 118, 99, 98, 116, 97, 52, 55, 99, 74, 119, 88, 108, 76, 50, 67,'
              '97, 67, 69, 87, 116, 97, 89, 98, 54, 87, 54, 108, 112, 120, 67, 103, 57, 66, 54, 82, 56, 77, 43, 90, 73, 79, 115, 89, 83, 81, 114, 77, 117, 97, 99, 80, 51, 51, 90, 101, 76, 118, 97, 113, 99, 83, 80, 69, 115, 67, 78, 78, 107, 107, 122, 108, 71, 75, 90, 75, 100, 49, 54, 115, 90, 49, 43, 55, 112, 99, 69, 121, 76, 119, 68, 57, 74, 55, 107, 85, 115, 85, 80, 72, 88, 69, 53, 56, 101, 92, 47, 111, 97, 77, 68, 53, 109, 104, 85, 100,'
              '81, 66, 99, 66, 78, 112, 107, 101, 49, 50, 56, 73, 89, 109, 49, 51, 67, 85, 83, 119, 82, 120, 116, 85, 66, 48, 111, 98, 87, 87, 106, 120, 111, 102, 80, 115, 55, 54, 114, 89, 112, 84, 112, 75, 87, 103, 98, 99, 48, 118, 118, 104, 57, 66, 99, 43, 84, 100, 82, 101, 117, 51, 79, 88, 105, 80, 121, 92, 47, 111, 73, 73, 79, 117, 122, 53, 115, 92, 47, 54, 109, 56, 89, 106, 48, 48, 70, 74, 79, 67, 113, 110, 89, 108, 78, 100, 69, 99, 88, 107,'
              '90, 113, 89, 74, 97, 92, 47, 50, 54, 76, 85, 121, 54, 120, 69, 89, 97, 84, 78, 111, 109, 99, 89, 67, 73, 89, 56, 84, 92, 47, 112, 87, 116, 54, 97, 92, 47, 109, 111, 108, 89, 69, 52, 122, 82, 108, 80, 55, 71, 68, 88, 48, 104, 76, 51, 114, 51, 98, 84, 100, 97, 52, 120, 106, 57, 81, 112, 109, 110, 49, 100, 110, 116, 92, 47, 118, 101, 119, 116, 84, 103, 72, 100, 118, 100, 86, 97, 108, 120, 52, 75, 116, 105, 97, 86, 54, 107, 120, 80, 98,'
              '109, 110, 81, 121, 76, 79, 111, 86, 73, 121, 106, 70, 57, 92, 47, 56, 67, 48, 67, 106, 75, 109, 111, 85, 70, 100, 78, 89, 102, 68, 76, 66, 114, 122, 74, 56, 43, 80, 67, 103, 84, 71, 51, 88, 100, 75, 101, 51, 43, 110, 100, 51, 119, 50, 100, 121, 77, 121, 78, 69, 70, 104, 114, 50, 120, 99, 112, 74, 121, 116, 120, 69, 92, 47, 65, 57, 101, 108, 77, 77, 121, 74, 82, 103, 77, 51, 82, 120, 83, 98, 82, 84, 98, 89, 112, 109, 99, 102, 101, 54,'
              '72, 50, 100, 48, 110, 113, 118, 83, 97, 82, 110, 51, 98, 49, 57, 84, 48, 121, 49, 43, 57, 68, 67, 49, 113, 86, 78, 79, 102, 109, 109, 67, 66, 90, 43, 101, 87, 86, 68, 50, 78, 110, 107, 88, 81, 68, 110, 115, 67, 78, 71, 50, 104, 76, 52, 101, 73, 75, 117, 81, 97, 122, 68, 81, 112, 53, 86, 74, 104, 114, 100, 122, 105, 121, 106, 79, 68, 105, 85, 57, 78, 86, 77, 67, 70, 65, 68, 52, 76, 106, 102, 74, 79, 100, 116, 98, 122, 87, 78, 112,'
              '67, 100, 79, 109, 56, 66, 108, 86, 74, 121, 97, 56, 86, 48, 84, 81, 65, 100, 118, 54, 104, 70, 50, 119, 112, 65, 83, 54, 86, 92, 47, 104, 107, 109, 71, 101, 106, 103, 65, 57, 101, 108, 118, 118, 50, 82, 113, 97, 78, 90, 84, 79, 102, 103, 102, 80, 108, 110, 113, 74, 113, 81, 51, 102, 98, 81, 99, 116, 122, 72, 66, 118, 98, 114, 107, 100, 77, 87, 86, 76, 102, 108, 102, 49, 103, 92, 47, 90, 121, 115, 69, 97, 106, 66, 75, 121, 108, 43, 107, 57,'
              '115, 82, 102, 85, 76, 120, 112, 72, 116, 77, 70, 54, 86, 109, 117, 120, 52, 87, 51, 115, 43, 77, 88, 102, 67, 72, 66, 66, 71, 81, 112, 90, 105, 117, 48, 51, 98, 121, 86, 116, 101, 86, 111, 104, 68, 78, 97, 108, 52, 77, 70, 81, 117, 72, 52, 72, 66, 52, 106, 55, 71, 118, 99, 98, 113, 120, 56, 122, 56, 120, 73, 90, 113, 90, 104, 75, 73, 50, 111, 82, 97, 86, 81, 106, 53, 69, 48, 68, 56, 71, 85, 110, 74, 84, 49, 81, 100, 86, 65, 69,'
              '43, 77, 86, 75, 65, 78, 74, 68, 109, 104, 84, 56, 86, 111, 34, 10, 125]';

          final byteData = ByteData.view(
            Uint8List.fromList(
              (jsonDecode(encryptedBytesString) as List).cast(),
            ).buffer,
          );

          const aegisImportFileProcessor = AegisImportFileProcessor();
          final XFile file = XFile.fromData(
            byteData.buffer.asUint8List(),
            name: 'aegis_encrypted.json',
          );
          // Act
          final isValid = await aegisImportFileProcessor.fileIsValid(file);
          final fileNeedsPassword = await aegisImportFileProcessor
              .fileNeedsPassword(file);
          final results = await aegisImportFileProcessor.processFile(
            file,
            password: 'test123',
          );
          // Assert
          expect(isValid, isTrue);
          expect(fileNeedsPassword, isTrue);
          expect(results.length, equals(2));
          final result0 = results[0];
          expect(result0, isA<ProcessorResultSuccess>());
          final token0 = result0.asSuccess!.resultData;
          expect(token0.label, equals('Test1'));
          expect(token0.type, equals('TOTP'));
          expect(token0.origin, isNotNull);
          final totpToken = token0 as TOTPToken;
          expect(totpToken.digits, equals(6));
          expect(totpToken.algorithm.name, equals('SHA1'));
          expect(totpToken.period, equals(30));
          expect(totpToken.secret, equals('AAAAAAAA'));
          expect(totpToken.issuer, equals('Testing'));
          expect(
            totpToken.otpFromTime(
              DateTime.fromMillisecondsSinceEpoch(1713352639317),
            ),
            equals('220975'),
          );
          final result1 = results[1];
          expect(result1, isA<ProcessorResultSuccess>());
          final token1 = result1.asSuccess!.resultData;
          expect(token1.label, equals('Test2'));
          expect(token1.type, equals('HOTP'));
          expect(token1.origin, isNotNull);
          final hotpToken = token1 as HOTPToken;
          expect(hotpToken.digits, equals(6));
          expect(hotpToken.algorithm.name, equals('SHA1'));
          expect(hotpToken.counter, equals(0));
          expect(hotpToken.secret, equals('AAAAAAAA'));
          expect(hotpToken.issuer, equals('Testing'));
          expect(hotpToken.otpValue, equals('328482'));
        });

        test('exncrypted bad password', () async {
          // Arrange
          const encryptedBytesString =
              '[123, 10, 32, 32, 32, 32, 34, 118, 101, 114, 115, 105, 111, 110, 34, 58, 32, 49, 44, 10, 32, 32, 32, 32, 34, 104, 101, 97, 100, 101, 114, 34, 58, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 115, 108, 111, 116, 115, 34, 58, 32, 91, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 121, 112, 101, 34, 58, 32, 49, 44, 10, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 117, 117, 105, 100, 34, 58, 32, 34, 99, 101, 53, 50, 101, 98, 99, 56, 45, 53, 56, 53, 54, 45, 52, 52, 100, 52, 45, 97, 99, 49, 49, 45, 102, 102, 54, 48, 49, 57, 57, 53, 48, 101, 98, 102, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 107, 101, 121, 34, 58, 32, 34, 54, 48, 102, 51, 101, 99, 102, 101, 57, 57, 54, 53, 55, 54, 55, 98,'
              '97, 49, 53, 51, 53, 50, 49, 49, 48, 99, 50, 54, 56, 101, 53, 56, 48, 50, 53, 53, 56, 53, 101, 54, 52, 98, 57, 99, 54, 99, 53, 98, 53, 99, 97, 97, 54, 98, 101, 52, 56, 98, 53, 98, 101, 98, 57, 50, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 107, 101, 121, 95, 112, 97, 114, 97, 109, 115, 34, 58, 32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 34, 110, 111, 110, 99, 101, 34, 58, 32, 34, 98, 56, 100, 50, 54, 97, 48, 53, 99, 57, 51, 49, 56, 54, 99, 57, 55, 52, 98, 55, 49, 54, 99, 51, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 97, 103, 34, 58, 32, 34, 51, 56, 99, 49, 102, 48, 50, 100, 57, 48, 56, 51, 49, 50, 55, 56, 99, 53, 55, 56, 48, 100, 54, 53, 54, 97, 56, 99, 53, 50, 48, 97,'
              '34, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 34, 58, 32, 51, 50, 55, 54, 56, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 114, 34, 58, 32, 56, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 112, 34, 58, 32, 49, 44, 10, 32, 32, 32,'
              '32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 115, 97, 108, 116, 34, 58, 32, 34, 99, 51, 49, 57, 49, 57, 100, 53, 97, 50, 57, 48, 54, 102, 50, 54, 51, 57, 97, 51, 52, 50, 50, 99, 49, 53, 102, 102, 52, 52, 100, 51, 101, 55, 50, 50, 56, 53, 101, 97, 52, 54, 98, 48, 48, 97, 51, 48, 48, 57, 55, 52, 100, 57, 102, 98, 54, 99, 100, 97, 97, 48, 101, 100, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,'
              '32, 32, 32, 32, 32, 34, 114, 101, 112, 97, 105, 114, 101, 100, 34, 58, 32, 116, 114, 117, 101, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 105, 115, 95, 98, 97, 99, 107, 117, 112, 34, 58, 32, 102, 97, 108, 115, 101, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 125, 10, 32, 32, 32, 32, 32, 32, 32, 32, 93, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 34, 112, 97, 114, 97, 109, 115, 34, 58,'
              '32, 123, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 110, 111, 110, 99, 101, 34, 58, 32, 34, 48, 57, 102, 48, 53, 54, 52, 49, 48, 50, 55, 49, 102, 50, 99, 50, 52, 97, 51, 51, 100, 52, 99, 54, 34, 44, 10, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 34, 116, 97, 103, 34, 58, 32, 34, 51, 48, 54, 53, 54, 100, 102, 50, 102, 54, 97, 49, 97, 100, 99, 48, 99, 56, 51, 98, 99, 97, 55, 57, 99, 101, 101, 97,'
              '57, 99, 100, 54, 34, 10, 32, 32, 32, 32, 32, 32, 32, 32, 125, 10, 32, 32, 32, 32, 125, 44, 10, 32, 32, 32, 32, 34, 100, 98, 34, 58, 32, 34, 82, 89, 75, 89, 119, 107, 119, 100, 71, 121, 54, 76, 49, 54, 85, 87, 119, 116, 68, 84, 57, 48, 67, 102, 100, 81, 77, 119, 97, 105, 115, 72, 78, 70, 99, 51, 116, 103, 103, 87, 87, 56, 65, 79, 84, 113, 118, 51, 118, 106, 121, 52, 74, 56, 50, 52, 107, 87, 66, 108, 108, 105, 77, 50, 65, 85,'
              '48, 92, 47, 53, 98, 116, 108, 108, 86, 106, 78, 77, 121, 74, 100, 97, 79, 86, 79, 98, 98, 121, 85, 90, 52, 106, 78, 117, 118, 72, 106, 114, 79, 97, 99, 73, 92, 47, 121, 97, 51, 88, 70, 54, 85, 48, 113, 43, 87, 89, 68, 111, 70, 97, 110, 57, 116, 110, 78, 56, 83, 48, 78, 78, 97, 66, 67, 102, 82, 87, 72, 66, 66, 118, 119, 83, 118, 77, 118, 112, 92, 47, 98, 109, 43, 66, 76, 113, 69, 56, 92, 47, 108, 82, 72, 74, 81, 119, 102, 54,'
              '71, 49, 83, 49, 106, 103, 56, 110, 84, 122, 108, 120, 113, 54, 53, 52, 109, 121, 103, 115, 122, 118, 111, 72, 80, 65, 97, 52, 76, 99, 83, 99, 48, 77, 103, 50, 87, 48, 109, 53, 99, 103, 81, 112, 69, 73, 111, 51, 73, 111, 88, 113, 104, 66, 87, 101, 67, 85, 55, 70, 70, 68, 87, 102, 88, 120, 86, 104, 117, 56, 99, 72, 69, 105, 112, 114, 86, 73, 103, 43, 73, 48, 83, 74, 82, 119, 98, 117, 78, 102, 88, 107, 106, 105, 75, 122, 67, 116, 52, 111,'
              '74, 119, 67, 85, 113, 111, 48, 88, 84, 57, 84, 121, 88, 87, 110, 75, 89, 51, 108, 70, 73, 107, 101, 77, 111, 101, 90, 114, 84, 100, 103, 122, 105, 118, 79, 111, 52, 54, 87, 80, 52, 76, 52, 67, 99, 74, 92, 47, 69, 110, 101, 73, 85, 83, 107, 100, 100, 73, 90, 109, 55, 106, 106, 88, 112, 70, 92, 47, 82, 112, 120, 106, 53, 107, 112, 67, 89, 75, 74, 54, 50, 69, 89, 54, 89, 108, 79, 88, 99, 110, 74, 78, 88, 81, 92, 47, 100, 86, 51, 75,'
              '66, 101, 112, 119, 51, 104, 69, 97, 113, 109, 116, 81, 43, 82, 75, 98, 102, 108, 111, 108, 69, 77, 106, 50, 80, 65, 120, 112, 114, 43, 104, 118, 79, 107, 112, 105, 69, 90, 86, 48, 113, 120, 79, 48, 43, 98, 70, 67, 66, 108, 120, 107, 78, 74, 50, 110, 99, 49, 110, 117, 82, 99, 88, 102, 73, 49, 56, 121, 75, 112, 56, 82, 51, 99, 69, 75, 43, 105, 99, 90, 119, 67, 54, 65, 114, 100, 120, 107, 101, 116, 76, 49, 122, 114, 80, 103, 68, 117, 67, 100,'
              '122, 54, 53, 108, 111, 43, 90, 69, 112, 118, 81, 116, 73, 78, 92, 47, 67, 115, 80, 69, 113, 118, 73, 89, 72, 55, 81, 55, 114, 111, 112, 112, 87, 101, 79, 105, 122, 80, 80, 120, 84, 118, 99, 98, 72, 57, 99, 80, 122, 50, 105, 76, 53, 104, 107, 105, 55, 48, 116, 97, 106, 85, 120, 113, 88, 103, 80, 120, 68, 116, 68, 113, 43, 78, 50, 120, 48, 92, 47, 103, 71, 100, 99, 105, 65, 118, 99, 98, 116, 97, 52, 55, 99, 74, 119, 88, 108, 76, 50, 67,'
              '97, 67, 69, 87, 116, 97, 89, 98, 54, 87, 54, 108, 112, 120, 67, 103, 57, 66, 54, 82, 56, 77, 43, 90, 73, 79, 115, 89, 83, 81, 114, 77, 117, 97, 99, 80, 51, 51, 90, 101, 76, 118, 97, 113, 99, 83, 80, 69, 115, 67, 78, 78, 107, 107, 122, 108, 71, 75, 90, 75, 100, 49, 54, 115, 90, 49, 43, 55, 112, 99, 69, 121, 76, 119, 68, 57, 74, 55, 107, 85, 115, 85, 80, 72, 88, 69, 53, 56, 101, 92, 47, 111, 97, 77, 68, 53, 109, 104, 85, 100,'
              '81, 66, 99, 66, 78, 112, 107, 101, 49, 50, 56, 73, 89, 109, 49, 51, 67, 85, 83, 119, 82, 120, 116, 85, 66, 48, 111, 98, 87, 87, 106, 120, 111, 102, 80, 115, 55, 54, 114, 89, 112, 84, 112, 75, 87, 103, 98, 99, 48, 118, 118, 104, 57, 66, 99, 43, 84, 100, 82, 101, 117, 51, 79, 88, 105, 80, 121, 92, 47, 111, 73, 73, 79, 117, 122, 53, 115, 92, 47, 54, 109, 56, 89, 106, 48, 48, 70, 74, 79, 67, 113, 110, 89, 108, 78, 100, 69, 99, 88, 107,'
              '90, 113, 89, 74, 97, 92, 47, 50, 54, 76, 85, 121, 54, 120, 69, 89, 97, 84, 78, 111, 109, 99, 89, 67, 73, 89, 56, 84, 92, 47, 112, 87, 116, 54, 97, 92, 47, 109, 111, 108, 89, 69, 52, 122, 82, 108, 80, 55, 71, 68, 88, 48, 104, 76, 51, 114, 51, 98, 84, 100, 97, 52, 120, 106, 57, 81, 112, 109, 110, 49, 100, 110, 116, 92, 47, 118, 101, 119, 116, 84, 103, 72, 100, 118, 100, 86, 97, 108, 120, 52, 75, 116, 105, 97, 86, 54, 107, 120, 80, 98,'
              '109, 110, 81, 121, 76, 79, 111, 86, 73, 121, 106, 70, 57, 92, 47, 56, 67, 48, 67, 106, 75, 109, 111, 85, 70, 100, 78, 89, 102, 68, 76, 66, 114, 122, 74, 56, 43, 80, 67, 103, 84, 71, 51, 88, 100, 75, 101, 51, 43, 110, 100, 51, 119, 50, 100, 121, 77, 121, 78, 69, 70, 104, 114, 50, 120, 99, 112, 74, 121, 116, 120, 69, 92, 47, 65, 57, 101, 108, 77, 77, 121, 74, 82, 103, 77, 51, 82, 120, 83, 98, 82, 84, 98, 89, 112, 109, 99, 102, 101, 54,'
              '72, 50, 100, 48, 110, 113, 118, 83, 97, 82, 110, 51, 98, 49, 57, 84, 48, 121, 49, 43, 57, 68, 67, 49, 113, 86, 78, 79, 102, 109, 109, 67, 66, 90, 43, 101, 87, 86, 68, 50, 78, 110, 107, 88, 81, 68, 110, 115, 67, 78, 71, 50, 104, 76, 52, 101, 73, 75, 117, 81, 97, 122, 68, 81, 112, 53, 86, 74, 104, 114, 100, 122, 105, 121, 106, 79, 68, 105, 85, 57, 78, 86, 77, 67, 70, 65, 68, 52, 76, 106, 102, 74, 79, 100, 116, 98, 122, 87, 78, 112,'
              '67, 100, 79, 109, 56, 66, 108, 86, 74, 121, 97, 56, 86, 48, 84, 81, 65, 100, 118, 54, 104, 70, 50, 119, 112, 65, 83, 54, 86, 92, 47, 104, 107, 109, 71, 101, 106, 103, 65, 57, 101, 108, 118, 118, 50, 82, 113, 97, 78, 90, 84, 79, 102, 103, 102, 80, 108, 110, 113, 74, 113, 81, 51, 102, 98, 81, 99, 116, 122, 72, 66, 118, 98, 114, 107, 100, 77, 87, 86, 76, 102, 108, 102, 49, 103, 92, 47, 90, 121, 115, 69, 97, 106, 66, 75, 121, 108, 43, 107, 57,'
              '115, 82, 102, 85, 76, 120, 112, 72, 116, 77, 70, 54, 86, 109, 117, 120, 52, 87, 51, 115, 43, 77, 88, 102, 67, 72, 66, 66, 71, 81, 112, 90, 105, 117, 48, 51, 98, 121, 86, 116, 101, 86, 111, 104, 68, 78, 97, 108, 52, 77, 70, 81, 117, 72, 52, 72, 66, 52, 106, 55, 71, 118, 99, 98, 113, 120, 56, 122, 56, 120, 73, 90, 113, 90, 104, 75, 73, 50, 111, 82, 97, 86, 81, 106, 53, 69, 48, 68, 56, 71, 85, 110, 74, 84, 49, 81, 100, 86, 65, 69,'
              '43, 77, 86, 75, 65, 78, 74, 68, 109, 104, 84, 56, 86, 111, 34, 10, 125]';

          final byteData = ByteData.view(
            Uint8List.fromList(
              (jsonDecode(encryptedBytesString) as List).cast(),
            ).buffer,
          );

          const aegisImportFileProcessor = AegisImportFileProcessor();
          final XFile file = XFile.fromData(
            byteData.buffer.asUint8List(),
            name: 'aegis_encrypted.json',
          );
          // Act/Assert
          expect(
            () async => await aegisImportFileProcessor.processFile(
              file,
              password: 'wrongPassword',
            ),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        });
      });
      group('import HTML', () {
        // Unimplemented
      });

      group('import TXT', () {
        // Unimplemented
      });
    });
  });
}

const _password = 'aegis test password';
const _secretA = 'JBSWY3DPEHPK3PXP';
const _secretB = 'GEZDGNBVGY3TQOJQ';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

XFile _xFile(Object content, {String name = 'aegis.json'}) => XFile.fromData(
  Uint8List.fromList(
    utf8.encode(content is String ? content : jsonEncode(content)),
  ),
  name: name,
);

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Uint8List _randomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

Map<String, dynamic> _entry({
  String type = 'totp',
  String name = 'alice@example.com',
  String issuer = 'Example',
  String secret = _secretA,
  String algo = 'SHA1',
  int digits = 6,
  int period = 30,
  int? counter,
  String uuid = '11111111-2222-3333-4444-555555555555',
}) => {
  'type': type,
  'uuid': uuid,
  'name': name,
  'issuer': issuer,
  'note': '',
  'favorite': false,
  'icon': null,
  'info': {
    'secret': secret,
    'algo': algo,
    'digits': digits,
    if (type == 'hotp') 'counter': counter ?? 0 else 'period': period,
  },
  'groups': <String>[],
};

Map<String, dynamic> _db({Object? version = 3, List<Object?>? entries}) => {
  'version': ?version,
  'entries': entries ?? [_entry()],
  'groups': <Object>[],
};

/// An unencrypted Aegis export.
Map<String, dynamic> _plainFile(Map<String, dynamic> db) => {
  'version': 1,
  'header': {'slots': null, 'params': null},
  'db': db,
};

/// Builds an encrypted Aegis export the way Aegis itself does it:
/// password -> scrypt -> slot key -> AES-GCM(master key) and master key -> AES-GCM(db).
/// A small scrypt cost keeps the tests fast, the processor takes the cost from the slot.
Future<Map<String, dynamic>> _encryptedFile({
  required Object db,
  String password = _password,
  int n = 1024,
  bool dbIsRawText = false,
}) async {
  final salt = _randomBytes(32);
  final kdf = Scrypt()..init(ScryptParameters(n, 8, 1, 32, salt));
  final passwordKey = Uint8List(32);
  kdf.deriveKey(Uint8List.fromList(utf8.encode(password)), 0, passwordKey, 0);

  final masterKey = _randomBytes(32);
  final cipher = crypto.AesGcm.with256bits();

  final slotNonce = _randomBytes(12);
  final slotBox = await cipher.encrypt(
    masterKey,
    secretKey: crypto.SecretKey(passwordKey),
    nonce: slotNonce,
  );

  final dbNonce = _randomBytes(12);
  final dbPlain = dbIsRawText ? db as String : jsonEncode(db);
  final dbBox = await cipher.encrypt(
    utf8.encode(dbPlain),
    secretKey: crypto.SecretKey(masterKey),
    nonce: dbNonce,
  );

  return {
    'version': 1,
    'header': {
      'slots': [
        {
          'type': 1,
          'uuid': 'ce52ebc8-5856-44d4-ac11-ff6019950ebf',
          'key': _hex(slotBox.cipherText),
          'key_params': {
            'nonce': _hex(slotNonce),
            'tag': _hex(slotBox.mac.bytes),
          },
          'n': n,
          'r': 8,
          'p': 1,
          'salt': _hex(salt),
          'repaired': true,
          'is_backup': false,
        },
      ],
      'params': {'nonce': _hex(dbNonce), 'tag': _hex(dbBox.mac.bytes)},
    },
    'db': base64Encode(dbBox.cipherText),
  };
}

Future<Object?> _outcomeOf(Future<List<ProcessorResult<Token>>> future) async {
  try {
    return await future;
  } catch (e) {
    return e;
  }
}

String _failureMessage(ProcessorResult<Token> result) =>
    result.asFailed!.message(AppLocalizationsEn());

void _expectDomainException(Object? outcome) {
  expect(
    outcome,
    anyOf(
      isA<InvalidFileContentException>(),
      isA<BadDecryptionPasswordException>(),
    ),
    reason:
        'A broken file has to surface as a processor exception, not as a raw crypto/type/format error',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void _testAegisImportFileProcessorEdgeCases() {
  group('Aegis Import File Processor edge cases', () {
    const processor = AegisImportFileProcessor();

    group('file validation', () {
      test('plain vault is valid and needs no password', () async {
        final file = _xFile(_plainFile(_db()));
        expect(await processor.fileIsValid(file), isTrue);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });

      test('encrypted vault is valid and needs a password', () async {
        final file = _xFile(await _encryptedFile(db: _db()));
        expect(await processor.fileIsValid(file), isTrue);
        expect(await processor.fileNeedsPassword(file), isTrue);
      });

      test('non json content is neither valid nor needs a password', () async {
        final file = _xFile('this is not json');
        expect(await processor.fileIsValid(file), isFalse);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });

      test('a json list is neither valid nor needs a password', () async {
        final file = _xFile('[1, 2, 3]');
        expect(await processor.fileIsValid(file), isFalse);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });

      test('plain vault without entries is not valid', () async {
        final file = _xFile(_plainFile(_db(entries: [])));
        expect(await processor.fileIsValid(file), isFalse);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });

      test('db that is neither an object nor a string is not valid', () async {
        final file = _xFile({
          'version': 1,
          'header': {'slots': null, 'params': null},
          'db': 42,
        });
        expect(await processor.fileIsValid(file), isFalse);
      });

      test('encrypted vault without any slot is not valid', () async {
        final json = await _encryptedFile(db: _db());
        (json['header'] as Map)['slots'] = [];
        final file = _xFile(json);
        expect(await processor.fileIsValid(file), isFalse);
        expect(await processor.fileNeedsPassword(file), isFalse);
      });
    });

    group('invalid input', () {
      test('non json content throws InvalidFileContentException', () async {
        await expectLater(
          processor.processFile(_xFile('no json at all')),
          throwsA(isA<InvalidFileContentException>()),
        );
      });

      test('a json list throws InvalidFileContentException', () async {
        await expectLater(
          processor.processFile(_xFile('[]')),
          throwsA(isA<InvalidFileContentException>()),
        );
      });

      test('a json object without db throws "Invalid file format"', () async {
        await expectLater(
          processor.processFile(_xFile({'version': 1})),
          throwsA(
            predicate((e) => e.toString().contains('Invalid file format')),
          ),
        );
      });

      test(
        'a plain vault with an empty entries list throws "Invalid file format"',
        () async {
          await expectLater(
            processor.processFile(_xFile(_plainFile(_db(entries: [])))),
            throwsA(
              predicate((e) => e.toString().contains('Invalid file format')),
            ),
          );
        },
      );

      test(
        'a file that fileIsValid accepts can be processed without throwing (UI contract)',
        () async {
          // import_start_page.dart calls fileIsValid() and then processFile() without a try/catch
          for (final file in [
            _xFile(_plainFile(_db())),
            _xFile(_plainFile(_db(entries: []))),
          ]) {
            if (await processor.fileIsValid(file)) {
              expect(await processor.processFile(file), isNotEmpty);
            }
          }
        },
      );
    });

    group('plain vault, version 3', () {
      test('imports totp and hotp with all attributes', () async {
        final file = _xFile(
          _plainFile(
            _db(
              entries: [
                _entry(
                  name: 'bob',
                  issuer: 'Issuer A',
                  algo: 'SHA256',
                  digits: 8,
                  period: 60,
                ),
                _entry(
                  type: 'hotp',
                  name: 'carol',
                  issuer: 'Issuer B',
                  secret: _secretB,
                  algo: 'SHA512',
                  digits: 7,
                  counter: 7,
                ),
              ],
            ),
          ),
        );

        final results = await processor.processFile(file);

        expect(results.length, 2);
        expect(results.every((r) => r.isSuccess), isTrue);
        final totp = results[0].asSuccess!.resultData as TOTPToken;
        expect(totp.label, 'bob');
        expect(totp.issuer, 'Issuer A');
        expect(totp.secret, _secretA);
        expect(totp.algorithm, Algorithms.SHA256);
        expect(totp.digits, 8);
        expect(totp.period, 60);
        final hotp = results[1].asSuccess!.resultData as HOTPToken;
        expect(hotp.label, 'carol');
        expect(hotp.issuer, 'Issuer B');
        expect(hotp.secret, _secretB);
        expect(hotp.algorithm, Algorithms.SHA512);
        expect(hotp.digits, 7);
        expect(hotp.counter, 7);
      });

      test('imports a steam entry', () async {
        final file = _xFile(
          _plainFile(
            _db(
              entries: [
                _entry(
                  type: 'steam',
                  issuer: 'Steam',
                  digits: 5,
                  secret: _secretB,
                ),
              ],
            ),
          ),
        );

        final results = await processor.processFile(file);

        expect(results.length, 1);
        expect(results.single.isSuccess, isTrue);
        final token = results.single.asSuccess!.resultData;
        expect(token, isA<SteamToken>());
        expect((token as SteamToken).secret, _secretB);
      });

      test(
        'unsupported entry types (motp, yandex) become failed results and do not stop the import',
        () async {
          final file = _xFile(
            _plainFile(
              _db(
                entries: [
                  _entry(name: 'first'),
                  _entry(type: 'motp', name: 'old-motp'),
                  _entry(type: 'yandex', name: 'ya'),
                  _entry(type: 'hotp', name: 'last', counter: 3),
                ],
              ),
            ),
          );

          final results = await processor.processFile(file);

          expect(results.length, 4);
          expect(results[0].isSuccess, isTrue);
          expect(results[1].isFailed, isTrue);
          expect(_failureMessage(results[1]), contains('motp'));
          expect(results[2].isFailed, isTrue);
          expect(_failureMessage(results[2]), contains('yandex'));
          expect(results[3].isSuccess, isTrue);
          expect((results[3].asSuccess!.resultData as HOTPToken).counter, 3);
        },
      );

      test(
        'an entry without info becomes a failed result, the others are imported',
        () async {
          final broken = _entry(name: 'broken')..remove('info');
          final file = _xFile(
            _plainFile(
              _db(
                entries: [
                  _entry(name: 'good'),
                  broken,
                  _entry(name: 'also good'),
                ],
              ),
            ),
          );

          final results = await processor.processFile(file);

          expect(results.map((r) => r.isSuccess), [true, false, true]);
          expect(results[0].asSuccess!.resultData.label, 'good');
          expect(results[2].asSuccess!.resultData.label, 'also good');
        },
      );

      test('a secret that is not base32 becomes a failed result', () async {
        final file = _xFile(
          _plainFile(
            _db(
              entries: [
                _entry(secret: 'not base32 !!!'),
                _entry(name: 'ok'),
              ],
            ),
          ),
        );

        final results = await processor.processFile(file);

        expect(results.map((r) => r.isSuccess), [false, true]);
      });

      test(
        'an unknown algorithm silently falls back to SHA1 (withDefault validator)',
        () async {
          final file = _xFile(
            _plainFile(
              _db(
                entries: [
                  _entry(algo: 'MD5'),
                  _entry(name: 'ok'),
                ],
              ),
            ),
          );

          final results = await processor.processFile(file);

          expect(results.map((r) => r.isSuccess), [true, true]);
          expect(
            (results[0].asSuccess!.resultData as TOTPToken).algorithm,
            Algorithms.SHA1,
          );
        },
      );

      test('the algorithm name is matched case insensitive', () async {
        final file = _xFile(_plainFile(_db(entries: [_entry(algo: 'sha512')])));

        final results = await processor.processFile(file);

        expect(
          (results.single.asSuccess!.resultData as TOTPToken).algorithm,
          Algorithms.SHA512,
        );
      });

      test('a missing name and issuer are imported as empty strings', () async {
        final entry = _entry()
          ..remove('name')
          ..remove('issuer');
        final file = _xFile(_plainFile(_db(entries: [entry])));

        final results = await processor.processFile(file);

        expect(results.single.isSuccess, isTrue);
        expect(results.single.asSuccess!.resultData.label, '');
        expect(results.single.asSuccess!.resultData.issuer, '');
      });

      test(
        'an entry that is not an object becomes a failed result, the others are imported',
        () async {
          final file = _xFile(
            _plainFile(
              _db(
                entries: [
                  _entry(name: 'good'),
                  'garbage',
                  _entry(name: 'also good'),
                ],
              ),
            ),
          );

          final results = await processor.processFile(file);

          expect(results.map((r) => r.isSuccess), [true, false, true]);
        },
        skip:
            'BUG: aegis_import_file_processor.dart:281 the element cast in the for-in header is outside the try block, a non-object entry aborts the whole import with a raw TypeError',
      );
    });

    group('plain vault, version 2', () {
      Map<String, dynamic> v2Entry({
        String type = 'totp',
        String secret = _secretA,
        String name = 'alice@example.com',
        String issuer = 'Example',
        int? counter,
      }) =>
          _entry(
              type: type,
              secret: secret,
              name: name,
              issuer: issuer,
              counter: counter,
              digits: 8,
              algo: 'SHA256',
              period: 45,
            )
            ..['group'] = null
            ..remove('groups');

      test(
        'imports the secret from info.secret',
        () async {
          final file = _xFile(
            _plainFile({
              'version': 2,
              'entries': [
                v2Entry(),
                v2Entry(
                  type: 'hotp',
                  secret: _secretB,
                  name: 'bob',
                  issuer: 'Other',
                  counter: 9,
                ),
              ],
            }),
          );

          final results = await processor.processFile(file);

          expect(results.length, 2);
          expect(
            results.every((r) => r.isSuccess),
            isTrue,
            reason: results
                .where((r) => r.isFailed)
                .map(_failureMessage)
                .join(' | '),
          );
          final totp = results[0].asSuccess!.resultData as TOTPToken;
          expect(totp.secret, _secretA);
          expect(totp.label, 'alice@example.com');
          expect(totp.issuer, 'Example');
          expect(totp.algorithm, Algorithms.SHA256);
          expect(totp.digits, 8);
          expect(totp.period, 45);
          final hotp = results[1].asSuccess!.resultData as HOTPToken;
          expect(hotp.secret, _secretB);
          expect(hotp.counter, 9);
        },
        skip:
            'BUG: aegis_import_file_processor.dart:205 V2 reads the secret from entry[secret] (null) instead of entry[info][secret], every V2 entry fails; line 217 would additionally re-encode the already base32 secret',
      );

      test(
        'encrypted version 2 vault imports the secret as well',
        () async {
          final file = _xFile(
            await _encryptedFile(
              db: {
                'version': 2,
                'entries': [v2Entry()],
              },
            ),
          );

          final results = await processor.processFile(
            file,
            password: _password,
          );

          expect(results.length, 1);
          expect(
            results.single.isSuccess,
            isTrue,
            reason: results
                .where((r) => r.isFailed)
                .map(_failureMessage)
                .join(' | '),
          );
          expect(
            (results.single.asSuccess!.resultData as TOTPToken).secret,
            _secretA,
          );
        },
        skip:
            'BUG: aegis_import_file_processor.dart:205 V2 reads the secret from entry[secret] (null) instead of entry[info][secret]',
      );

      test(
        'entries keep their uuid as token id',
        () async {
          final file = _xFile(
            _plainFile({
              'version': 2,
              'entries': [v2Entry()],
            }),
          );

          final results = await processor.processFile(file);

          expect(results.single.isSuccess, isTrue);
          expect(
            results.single.asSuccess!.resultData.id,
            '11111111-2222-3333-4444-555555555555',
          );
        },
        skip:
            'BUG: aegis_import_file_processor.dart:205 V2 reads the secret from entry[secret] (null) instead of entry[info][secret], so no V2 token is created at all',
      );
    });

    group('db.version', () {
      test(
        'unknown version 4 with version 3 shaped entries is imported by trying the latest format',
        () async {
          final file = _xFile(
            _plainFile(_db(version: 4, entries: [_entry(name: 'future')])),
          );

          final results = await processor.processFile(file);

          expect(results.length, 1);
          expect(results.single.isSuccess, isTrue);
          expect(results.single.asSuccess!.resultData.label, 'future');
        },
      );

      test('version 1 is imported by trying the latest format', () async {
        final file = _xFile(
          _plainFile(_db(version: 1, entries: [_entry(name: 'legacy')])),
        );

        final results = await processor.processFile(file);

        expect(results.single.isSuccess, isTrue);
        expect(results.single.asSuccess!.resultData.label, 'legacy');
      });

      test(
        'unknown version with entries that cannot be read throws a LocalizedArgumentError',
        () async {
          final file = _xFile(_plainFile(_db(version: 4, entries: [1, 2, 3])));

          await expectLater(
            processor.processFile(file),
            throwsA(isA<LocalizedArgumentError>()),
          );
        },
        skip:
            'BUG: aegis_import_file_processor.dart:186 invalidValue: db[version] passes an int to the String parameter of LocalizedArgumentError, so the "unsupported version" error itself dies with a TypeError',
      );

      test(
        'the unsupported version error names the version',
        () async {
          final file = _xFile(_plainFile(_db(version: 99, entries: [1])));

          final outcome = await _outcomeOf(processor.processFile(file));

          expect(outcome, isA<LocalizedArgumentError>());
          expect((outcome as LocalizedArgumentError).invalidValue, '99');
          expect(outcome.message, contains('99'));
        },
        skip:
            'BUG: aegis_import_file_processor.dart:186 invalidValue: db[version] passes an int to the String parameter of LocalizedArgumentError, so the "unsupported version" error itself dies with a TypeError',
      );

      test(
        'a missing version falls back to the latest format instead of crashing',
        () async {
          final file = _xFile(
            _plainFile(
              _db(version: null, entries: [_entry(name: 'no version')]),
            ),
          );

          final outcome = await _outcomeOf(processor.processFile(file));

          expect(
            outcome,
            isNot(isA<TypeError>()),
            reason: 'a missing version must not end in a raw cast error',
          );
          expect(outcome, isA<List<ProcessorResult<Token>>>());
          expect(
            (outcome as List<ProcessorResult<Token>>).single.isSuccess,
            isTrue,
          );
        },
        skip:
            'BUG: aegis_import_file_processor.dart:169 json[db][version] as int throws a raw TypeError for a missing version instead of reaching _processPlainTryLatest',
      );

      test(
        'a non integer version falls back to the latest format instead of crashing',
        () async {
          final file = _xFile(
            _plainFile(
              _db(
                version: '3',
                entries: [_entry(name: 'string version')],
              ),
            ),
          );

          final outcome = await _outcomeOf(processor.processFile(file));

          expect(
            outcome,
            isNot(isA<TypeError>()),
            reason: 'a non integer version must not end in a raw cast error',
          );
          expect(outcome, isA<List<ProcessorResult<Token>>>());
          expect(
            (outcome as List<ProcessorResult<Token>>).single.isSuccess,
            isTrue,
          );
        },
        skip:
            'BUG: aegis_import_file_processor.dart:169 json[db][version] as int throws a raw TypeError for a non integer version instead of reaching _processPlainTryLatest',
      );
    });

    group('encrypted vault', () {
      test('round trip with the correct password', () async {
        final file = _xFile(
          await _encryptedFile(
            db: _db(
              entries: [
                _entry(name: 'enc totp', digits: 8),
                _entry(
                  type: 'hotp',
                  name: 'enc hotp',
                  secret: _secretB,
                  counter: 11,
                ),
              ],
            ),
          ),
        );

        final results = await processor.processFile(file, password: _password);

        expect(results.length, 2);
        expect(results.every((r) => r.isSuccess), isTrue);
        final totp = results[0].asSuccess!.resultData as TOTPToken;
        expect(totp.label, 'enc totp');
        expect(totp.secret, _secretA);
        expect(totp.digits, 8);
        final hotp = results[1].asSuccess!.resultData as HOTPToken;
        expect(hotp.secret, _secretB);
        expect(hotp.counter, 11);
      });

      test('a wrong password throws BadDecryptionPasswordException', () async {
        final file = _xFile(await _encryptedFile(db: _db()));

        await expectLater(
          processor.processFile(file, password: 'not the password'),
          throwsA(isA<BadDecryptionPasswordException>()),
        );
      });

      test('an empty password throws BadDecryptionPasswordException', () async {
        final file = _xFile(await _encryptedFile(db: _db()));

        await expectLater(
          processor.processFile(file, password: ''),
          throwsA(isA<BadDecryptionPasswordException>()),
        );
      });

      test(
        'a manipulated slot key throws BadDecryptionPasswordException',
        () async {
          final json = await _encryptedFile(db: _db());
          final slot = ((json['header'] as Map)['slots'] as List).first as Map;
          final key = (slot['key'] as String).split('');
          key[0] = key[0] == '0' ? '1' : '0';
          slot['key'] = key.join();

          await expectLater(
            processor.processFile(_xFile(json), password: _password),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        },
      );

      test(
        'an encrypted vault with no password throws BadDecryptionPasswordException',
        () async {
          final file = _xFile(await _encryptedFile(db: _db()));

          await expectLater(
            processor.processFile(file),
            throwsA(isA<BadDecryptionPasswordException>()),
          );
        },
        skip:
            'BUG: aegis_import_file_processor.dart:385 password! throws a raw null check TypeError instead of BadDecryptionPasswordException',
      );

      test(
        'a manipulated db ciphertext with the correct password is reported as a processor exception',
        () async {
          final json = await _encryptedFile(db: _db());
          final dbBytes = base64Decode(json['db'] as String);
          dbBytes[dbBytes.length ~/ 2] ^= 0xFF;
          json['db'] = base64Encode(dbBytes);

          final outcome = await _outcomeOf(
            processor.processFile(_xFile(json), password: _password),
          );

          _expectDomainException(outcome);
        },
        skip:
            'BUG: aegis_import_file_processor.dart:405 the second cipher.decrypt is outside the try block, a tampered db surfaces as a raw SecretBoxAuthenticationError',
      );

      test(
        'a manipulated db tag with the correct password is reported as a processor exception',
        () async {
          final json = await _encryptedFile(db: _db());
          final params = (json['header'] as Map)['params'] as Map;
          final tag = (params['tag'] as String).split('');
          tag[0] = tag[0] == '0' ? '1' : '0';
          params['tag'] = tag.join();

          final outcome = await _outcomeOf(
            processor.processFile(_xFile(json), password: _password),
          );

          _expectDomainException(outcome);
        },
        skip:
            'BUG: aegis_import_file_processor.dart:405 the second cipher.decrypt is outside the try block, a wrong db tag surfaces as a raw SecretBoxAuthenticationError',
      );

      test(
        'a db that decrypts to text which is not json is reported as a processor exception',
        () async {
          final file = _xFile(
            await _encryptedFile(db: 'this is not json', dbIsRawText: true),
          );

          final outcome = await _outcomeOf(
            processor.processFile(file, password: _password),
          );

          _expectDomainException(outcome);
        },
        skip:
            'BUG: aegis_import_file_processor.dart:414 jsonDecode of the decrypted db is not guarded, a FormatException escapes',
      );

      test(
        'a slot without key_params is reported as a processor exception',
        () async {
          final json = await _encryptedFile(db: _db());
          (((json['header'] as Map)['slots'] as List).first as Map).remove(
            'key_params',
          );

          final outcome = await _outcomeOf(
            processor.processFile(_xFile(json), password: _password),
          );

          _expectDomainException(outcome);
        },
        skip:
            'BUG: aegis_import_file_processor.dart:375 fileIsValid accepts the file but _processEncrypted casts the missing key_params and throws a raw TypeError',
      );

      test(
        'invalid scrypt cost parameters fail instead of hanging forever',
        () async {
          final json = await _encryptedFile(db: _db());
          // scrypt needs N to be a power of two, n = 3 makes the kdf isolate crash
          (((json['header'] as Map)['slots'] as List).first as Map)['n'] = 3;

          final outcome = await _outcomeOf(
            processor
                .processFile(_xFile(json), password: _password)
                .timeout(const Duration(seconds: 10)),
          );

          expect(
            outcome,
            isNot(isA<TimeoutException>()),
            reason: 'the future never completes when the kdf isolate dies',
          );
          _expectDomainException(outcome);
        },
        skip:
            'BUG: aegis_import_file_processor.dart:363 runIsolatedKdf waits on receivePort.first without an error/exit listener, a crashing isolate hangs the import (spinner forever)',
      );

      test(
        'an encrypted vault without entries yields an empty result list',
        () async {
          final file = _xFile(await _encryptedFile(db: _db(entries: [])));

          final results = await processor.processFile(
            file,
            password: _password,
          );

          expect(results, isEmpty);
        },
      );

      test('processTokenMigrate forwards the password', () async {
        final file = _xFile(
          await _encryptedFile(
            db: _db(entries: [_entry(name: 'migrated')]),
          ),
        );

        final results = await processor.processTokenMigrate(
          file,
          args: _password,
        );

        expect(results.single.asSuccess!.resultData.label, 'migrated');
      });
    });
  });
}
