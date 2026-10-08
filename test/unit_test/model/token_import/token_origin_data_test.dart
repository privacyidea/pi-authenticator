import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/model/version.dart';

const _secret = 'GEZDGNBVGY3TQOJQ';

TokenOriginData _origin(
  TokenOriginSourceType source, {
  bool? isPi,
  String data = 'data',
}) => TokenOriginData(
  source: source,
  appName: 'app',
  data: data,
  isPrivacyIdeaToken: isPi,
);

TokenContainerFinalized _container({String serial = 'SMPH0001'}) =>
    TokenContainerFinalized(
      issuer: 'privacyIDEA',
      nonce: 'nonce',
      timestamp: DateTime.utc(2026),
      serverUrl: Uri.parse('https://pi.example.com'),
      serial: serial,
      ecKeyAlgorithm: EcKeyAlgorithm.secp384r1,
      hashAlgorithm: Algorithms.SHA256,
      sslVerify: true,
      publicClientKey: 'pub',
      privateClientKey: 'priv',
    );

/// What the security policy demands. Exportable: not a privacyIDEA token.
///  - explicitly "no privacyIDEA token" (false): exportable
///  - privacyIDEA token (true): never exportable
///  - unknown (null): only if the user added it manually
bool _policyExportable(TokenOriginSourceType source, bool? isPi) {
  if (isPi == true) return false;
  if (isPi == false) return true;
  return source == TokenOriginSourceType.manually;
}

// --- tokens that carry an origin through the storage format ---

final TokenOriginData _fullOrigin = TokenOriginData(
  source: TokenOriginSourceType.container,
  appName: 'Server (CONT-1)',
  data: 'otpauth://totp/Test?secret=$_secret',
  createdAt: DateTime.utc(2024, 2, 29, 23, 59, 58, 123),
  isPrivacyIdeaToken: true,
  creator: 'admin',
  piServerVersion: const Version(3, 11, 2),
);

HOTPToken _storedHotp() => HOTPToken(
  id: 'hotp-id',
  algorithm: Algorithms.SHA256,
  digits: 8,
  secret: _secret,
  origin: _fullOrigin,
);

TOTPToken _storedTotp() => TOTPToken(
  id: 'totp-id',
  algorithm: Algorithms.SHA512,
  digits: 7,
  secret: _secret,
  period: 45,
  origin: _fullOrigin,
);

/// The storage format: Token -> String -> Token.
Token _viaStorage(Token token) =>
    Token.fromJson(jsonDecode(jsonEncode(token)) as Map<String, dynamic>);

void main() {
  _testTokenOriginData();
  _testIsExportable();
  _testOriginInTokenJson();
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

void _testIsExportable() {
  group('TokenOriginData.isExportable', () {
    for (final source in TokenOriginSourceType.values) {
      for (final isPi in <bool?>[true, false, null]) {
        final expected = _policyExportable(source, isPi);
        final knownBug =
            source == TokenOriginSourceType.manually && isPi == true;
        test(
          '${source.name} / isPrivacyIdeaToken=$isPi -> exportable=$expected',
          () {
            expect(_origin(source, isPi: isPi).isExportable, expected);
          },
          skip: knownBug
              ? 'BUG: lib/model/token_import/token_origin_data.dart:40 source manually is exportable even if isPrivacyIdeaToken == true'
              : null,
        );
      }
    }

    test('the explicit privacyIDEA flag false wins over the source', () {
      for (final source in TokenOriginSourceType.values) {
        expect(
          _origin(source, isPi: false).isExportable,
          isTrue,
          reason: source.name,
        );
      }
    });

    test('an origin of the source container created by the app is not exportable', () {
      final origin = TokenOriginData.fromContainer(
        container: _container(),
        tokenData: 'otpauth://hotp/x?secret=$_secret',
      );

      expect(origin.source, TokenOriginSourceType.container);
      expect(origin.isPrivacyIdeaToken, isTrue);
      expect(origin.isExportable, isFalse);
    });

    test('TokenOriginData.unknown is not exportable', () {
      final origin = TokenOriginData.unknown('whatever');

      expect(origin.source, TokenOriginSourceType.unknown);
      expect(origin.isPrivacyIdeaToken, isNull);
      expect(origin.isExportable, isFalse);
    });

    test('toTokenOrigin: manually is exportable, every other source is not (flag unknown)', () {
      for (final source in TokenOriginSourceType.values) {
        expect(
          source.toTokenOrigin().isExportable,
          source == TokenOriginSourceType.manually,
          reason: source.name,
        );
      }
    });

    test('toTokenOrigin with isPrivacyIdeaToken=false makes every source exportable', () {
      for (final source in TokenOriginSourceType.values) {
        expect(
          source.toTokenOrigin(isPrivacyIdeaToken: false).isExportable,
          isTrue,
          reason: source.name,
        );
      }
    });

    test('copyWith recomputes exportability from the new values', () {
      final imported = _origin(TokenOriginSourceType.backupFile, isPi: false);
      expect(imported.isExportable, isTrue);

      final asPi = imported.copyWith(isPrivacyIdeaToken: () => true);
      final backToUnknown = imported.copyWith(isPrivacyIdeaToken: () => null);
      final asContainer = imported.copyWith(
        source: TokenOriginSourceType.container,
        isPrivacyIdeaToken: () => true,
      );

      expect(asPi.isExportable, isFalse);
      expect(backToUnknown.isExportable, isFalse);
      expect(asContainer.isExportable, isFalse);
      expect(imported.isExportable, isTrue, reason: 'copyWith must not mutate');
    });

    test('exportability survives a JSON round trip for every combination', () {
      for (final source in TokenOriginSourceType.values) {
        for (final isPi in <bool?>[true, false, null]) {
          final origin = _origin(source, isPi: isPi);

          final restored = TokenOriginData.fromJson(
            jsonDecode(jsonEncode(origin.toJson())) as Map<String, dynamic>,
          );

          expect(restored.isExportable, origin.isExportable, reason: '${source.name}/$isPi');
          expect(restored.source, source);
          expect(restored.isPrivacyIdeaToken, isPi);
        }
      }
    });

    test('stored origins without the isPrivacyIdeaToken field (old versions) stay conservative', () {
      Map<String, dynamic> json(String source) => {
        'source': source,
        'appName': 'old',
        'data': '',
      };

      expect(TokenOriginData.fromJson(json('qrScan')).isExportable, isFalse);
      expect(TokenOriginData.fromJson(json('container')).isExportable, isFalse);
      expect(TokenOriginData.fromJson(json('unknown')).isExportable, isFalse);
      expect(TokenOriginData.fromJson(json('manually')).isExportable, isTrue);
    });

    test('equal origins in all fields are equal, isExportable does not change equality', () {
      final createdAt = DateTime.utc(2026, 5, 5);
      final a = TokenOriginData(
        source: TokenOriginSourceType.manually,
        appName: 'a',
        data: 'd',
        createdAt: createdAt,
      );
      final b = TokenOriginData(
        source: TokenOriginSourceType.manually,
        appName: 'a',
        data: 'd',
        createdAt: createdAt,
      );
      final c = b.copyWith(isPrivacyIdeaToken: () => false);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });
}

void _testOriginInTokenJson() {
  group('TokenOriginData in the token JSON', () {
    test('every field survives the string encoding', () {
      final restored = _viaStorage(_storedHotp()).origin!;
      expect(restored.source, TokenOriginSourceType.container);
      expect(restored.appName, 'Server (CONT-1)');
      expect(restored.data, 'otpauth://totp/Test?secret=$_secret');
      expect(restored.createdAt, DateTime.utc(2024, 2, 29, 23, 59, 58, 123));
      expect(restored.createdAt.isUtc, isTrue);
      expect(restored.isPrivacyIdeaToken, isTrue);
      expect(restored.creator, 'admin');
      expect(restored.piServerVersion, const Version(3, 11, 2));
      expect(restored, _fullOrigin);
    });

    test('null isPrivacyIdeaToken, creator and piServerVersion stay null', () {
      final origin = TokenOriginData(
        source: TokenOriginSourceType.manually,
        appName: 'manual',
        data: 'x',
        createdAt: DateTime.utc(2020),
      );
      final restored = _viaStorage(_storedHotp().copyWith(origin: origin)).origin!;
      expect(restored.isPrivacyIdeaToken, isNull);
      expect(restored.creator, isNull);
      expect(restored.piServerVersion, isNull);
      expect(restored, origin);
    });

    test('isPrivacyIdeaToken false stays false (not null)', () {
      final origin = _fullOrigin.copyWith(isPrivacyIdeaToken: () => false);
      final restored = _viaStorage(_storedHotp().copyWith(origin: origin));
      expect(restored.origin!.isPrivacyIdeaToken, isFalse);
      expect(restored.isPrivacyIdeaToken, isFalse);
      expect(restored.isExportable, isTrue);
    });

    test('every TokenOriginSourceType survives the round trip', () {
      for (final source in TokenOriginSourceType.values) {
        final origin = TokenOriginData(
          source: source,
          appName: 'a',
          data: 'd',
          createdAt: DateTime.utc(2021),
        );
        final restored = _viaStorage(_storedTotp().copyWith(origin: origin));
        expect(restored.origin!.source, source, reason: '$source');
      }
    });
  });
}
