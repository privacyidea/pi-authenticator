import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/version.dart';

void main() {
  _testTokenOriginData();
}

void _testTokenOriginData() {
  group('Token Origin Data', () {
    TokenOriginData;
    group('create', () {
      test('constructor', () {
        final tokenOriginData = TokenOriginData(
          source: TokenOriginSourceType.manually,
          data: 'data',
          appName: 'appName',
          isPrivacyIdeaToken: true,
          createdAt: DateTime.now(),
          creator: 'creator',
          piServerVersion: const Version(1, 0, 0),
        );
        expect(tokenOriginData.source, TokenOriginSourceType.manually);
        expect(tokenOriginData.data, 'data');
        expect(tokenOriginData.appName, 'appName');
        expect(tokenOriginData.isPrivacyIdeaToken, true);
        expect(tokenOriginData.createdAt, isA<DateTime>());
        expect(tokenOriginData.piServerVersion, isA<Version>());
      });
      test('copyWith', () {
        final tokenOriginData = TokenOriginData(
          source: TokenOriginSourceType.manually,
          data: 'data',
          appName: 'appName',
          isPrivacyIdeaToken: true,
          createdAt: DateTime.now(),
          creator: 'creator',
          piServerVersion: const Version(1, 0, 0),
        );
        final copy = tokenOriginData.copyWith(
          source: TokenOriginSourceType.qrScan,
          data: 'data2',
          appName: 'appName2',
          isPrivacyIdeaToken: () => false,
          createdAt: DateTime.now().add(const Duration(days: 1)),
          piServerVersion: () => const Version(1, 0, 1),
        );
        expect(copy.source, TokenOriginSourceType.qrScan);
        expect(copy.data, 'data2');
        expect(copy.appName, 'appName2');
        expect(copy.isPrivacyIdeaToken, false);
        expect(copy.createdAt, isA<DateTime>());
        expect(copy.piServerVersion, isA<Version>());
      });
    });
  });
}
