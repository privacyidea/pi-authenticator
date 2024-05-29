import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';
import 'package:privacyidea_authenticator/utils/token_import_origins.dart';

void main() {
  _testGooleAuthenticatorQrProcessor();
}

void _testGooleAuthenticatorQrProcessor() {
  group('Google Authenticator Qr Processor', () {
    test('processUri', () async {
      // Arrange
      const processor = GoogleAuthenticatorQrProcessor();
      const uriString =
          'otpauth-migration://offline?data=ChkKCpklNznImSU3OcgSBVRlc3QxIAEoATACChsKCpklNznamSU3OdoSBVRlc3QyIAEoATABOAAQARgBIAAo8enF1vr%2F%2F%2F%2F%2FAQ%3D%3D';
      final uri = Uri.parse(uriString);
      // Act
      final results = await processor.processUri(uri);
      // Assert
      expect(results.length, equals(2));
      final result0 = results[0];
      expect(result0, isA<ProcessorResultSuccess>());
      final token0 = result0.asSuccess!.resultData;
      expect(token0.label, equals('Test1'));
      expect(token0.type, equals('TOTP'));
      expect(token0.origin, isNotNull);
      final tokenOriginData0Matcher = TokenOriginData(
        source: TokenOriginSourceType.qrScanImport,
        data: 'ChkKCpklNznImSU3OcgSBVRlc3QxIAEoATACChsKCpklNznamSU3OdoSBVRlc3QyIAEoATABOAAQARgBIAAo8enF1vr/////AQ==',
        originName: TokenImportOrigins.googleAuthenticator.appName,
        isPrivacyIdeaToken: false,
        createdAt: token0.origin!.createdAt,
      );
      expect(token0.origin, tokenOriginData0Matcher);
      final result1 = results[1];
      expect(result1, isA<ProcessorResultSuccess>());
      final token1 = result1.asSuccess!.resultData;
      expect(token1.label, equals('Test2'));
      expect(token1.type, equals('HOTP'));
      expect(token1.origin, isNotNull);
      final tokenOriginData1Matcher = TokenOriginData(
        source: TokenOriginSourceType.qrScanImport,
        data: 'ChkKCpklNznImSU3OcgSBVRlc3QxIAEoATACChsKCpklNznamSU3OdoSBVRlc3QyIAEoATABOAAQARgBIAAo8enF1vr/////AQ==',
        originName: TokenImportOrigins.googleAuthenticator.appName,
        isPrivacyIdeaToken: false,
        createdAt: token1.origin!.createdAt,
      );
      expect(token1.origin, tokenOriginData1Matcher);
    });
  });
}
