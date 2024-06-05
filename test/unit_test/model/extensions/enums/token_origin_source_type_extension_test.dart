import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';

void main() {
  _testTokenOriginSourceTypeExtension();
}

void _testTokenOriginSourceTypeExtension() {
  group('Token Origin Source Type Extension', () {
    test('toTokenOrigin', () {
      final TokenOriginData tokenOriginDataMatch = TokenOriginData(
        source: TokenOriginSourceType.qrScan,
        data: 'data',
        appName: 'appName',
        isPrivacyIdeaToken: true,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(1622160000000),
      );
      final TokenOriginData tokenOriginData = TokenOriginSourceType.qrScan.toTokenOrigin(
        data: 'data',
        appName: 'appName',
        isPrivacyIdeaToken: true,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(1622160000000),
      );
      expect(tokenOriginData.source, tokenOriginDataMatch.source);
      expect(tokenOriginData.data, tokenOriginDataMatch.data);
      expect(tokenOriginData.appName, tokenOriginDataMatch.appName);
      expect(tokenOriginData.isPrivacyIdeaToken, tokenOriginDataMatch.isPrivacyIdeaToken);
      expect(tokenOriginData.createdAt, tokenOriginDataMatch.createdAt);
      expect(tokenOriginData, tokenOriginDataMatch);
    });
    test('addOriginToToken', () {
      final token = HOTPToken(id: 'id', algorithm: Algorithms.SHA512, digits: 6, secret: 'secret');
      final TokenOriginData tokenOriginDataMatch = TokenOriginData(
        source: TokenOriginSourceType.qrScan,
        data: 'data',
        appName: 'appName',
        isPrivacyIdeaToken: true,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(1622160000000),
      );
      final tokenMatch = token.copyWith(origin: tokenOriginDataMatch);
      final tokenWithOrigin = TokenOriginSourceType.qrScan.addOriginToToken(
        token: token,
        data: 'data',
        appName: 'appName',
        isPrivacyIdeaToken: true,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(1622160000000),
      );
      expect(tokenWithOrigin.origin!.source, tokenOriginDataMatch.source);
      expect(tokenWithOrigin.origin!.data, tokenOriginDataMatch.data);
      expect(tokenWithOrigin.origin!.appName, tokenOriginDataMatch.appName);
      expect(tokenWithOrigin.origin!.isPrivacyIdeaToken, tokenOriginDataMatch.isPrivacyIdeaToken);
      expect(tokenWithOrigin.origin!.createdAt, tokenOriginDataMatch.createdAt);
      expect(tokenWithOrigin, tokenMatch);
    });
  });
}
