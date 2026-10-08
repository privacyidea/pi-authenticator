import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/pia_scheme_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/proto/generated/GoogleAuthenticatorImport.pb.dart';

final _l = AppLocalizationsEn();

const _containerUri =
    'pia://container/SMPH00067A2F'
    '?issuer=privacyIDEA'
    '&ttl=10'
    '&nonce=b33d3a11c8d1b45f19640035e27944ccf0b2383d'
    '&time=2024-12-06T11%3A14%3A26.885409%2B00%3A00'
    '&url=http://192.168.0.230:5000/'
    '&serial=SMPH00067A2F'
    '&key_algorithm=secp384r1'
    '&hash_algorithm=SHA256'
    '&ssl_verify=False'
    '&passphrase=';

Uri _migrationUri(List<String> names) {
  final bytes = GoogleAuthenticatorImport(
    otpParameters: [
      for (final name in names)
        GoogleAuthenticatorImport_OtpParameters(
          secret: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
          name: name,
        ),
    ],
    version: 1,
    batchSize: 1,
    batchIndex: 0,
    batchId: 1,
  ).writeToBuffer();
  return Uri.parse(
    'otpauth-migration://offline?data=${Uri.encodeComponent(base64.encode(bytes))}',
  );
}

void main() {
  group('TokenImportSchemeProcessor', () {
    group('registry', () {
      test('supports exactly otpauth, otpauth-migration and pia', () {
        expect(TokenImportSchemeProcessor.allSupportedSchemes, {
          'otpauth',
          'otpauth-migration',
          'pia',
        });
      });

      test('contains the three processors in a fixed order', () {
        expect(
          TokenImportSchemeProcessor.implementations.map((e) => e.runtimeType),
          [
            OtpAuthProcessor,
            GoogleAuthenticatorQrProcessor,
            PiaSchemeProcessor,
          ],
        );
      });

      test(
        'no scheme is claimed by two processors, so the order cannot change a result',
        () {
          final all = TokenImportSchemeProcessor.implementations
              .expand((p) => p.supportedSchemes)
              .toList();
          expect(all.toSet(), hasLength(all.length));
        },
      );
    });

    group('processUriByAny', () {
      test('otpauth goes to the OtpAuthProcessor', () async {
        final results = await TokenImportSchemeProcessor.processUriByAny(
          Uri.parse('otpauth://totp/ACME:alice?secret=AAAAAAAA'),
        );
        expect(results, hasLength(1));
        final token = results!.single.asSuccess!.resultData;
        expect(token, isA<TOTPToken>());
        expect(token.issuer, 'ACME');
        expect(token.origin!.data, 'otpauth://totp/ACME:alice?secret=AAAAAAAA');
      });

      test(
        'otpauth-migration goes to the GoogleAuthenticatorQrProcessor',
        () async {
          final results = await TokenImportSchemeProcessor.processUriByAny(
            _migrationUri(['one', 'two']),
          );
          expect(results, hasLength(2));
          expect(results!.map((r) => r.asSuccess!.resultData.label), [
            'one',
            'two',
          ]);
          expect(
            results.first.asSuccess!.resultData.origin!.isPrivacyIdeaToken,
            isFalse,
          );
        },
      );

      test('pia token hosts go to the PiaSchemeProcessor', () async {
        final results = await TokenImportSchemeProcessor.processUriByAny(
          Uri.parse('pia://hotp/user?secret=AAAAAAAA&counter=4'),
        );
        expect(results, hasLength(1));
        final token = results!.single.asSuccess!.resultData;
        expect(token, isA<HOTPToken>());
        expect((token as HOTPToken).counter, 4);
      });

      test(
        'pia://container is not handled here: the Pia processor returns null and there is no fall through',
        () async {
          final results = await TokenImportSchemeProcessor.processUriByAny(
            Uri.parse(_containerUri),
          );
          expect(results, isNull);
        },
      );

      test('unknown schemes return null', () async {
        for (final uri in [
          'https://example.com/totp/user?secret=AAAAAAAA',
          'foo://totp/user',
          'otpauth-foo://totp/user?secret=AAAAAAAA',
          'mailto:someone@example.com',
          'homewidget://show?widgetId=1',
          'just-some-text',
        ]) {
          expect(
            await TokenImportSchemeProcessor.processUriByAny(Uri.parse(uri)),
            isNull,
            reason: uri,
          );
        }
      });

      test('the scheme is matched case insensitively', () async {
        final results = await TokenImportSchemeProcessor.processUriByAny(
          Uri.parse('OTPAUTH://TOTP/user?secret=AAAAAAAA'),
        );
        expect(results!.single.asSuccess!.resultData, isA<TOTPToken>());
      });

      test(
        'a matching scheme with an unsupported host is a failed list, not null',
        () async {
          final results = await TokenImportSchemeProcessor.processUriByAny(
            Uri.parse('otpauth://unknown/user?secret=AAAAAAAA'),
          );
          expect(results, hasLength(1));
          expect(results!.single.isFailed, isTrue);
          expect(
            results.single.asFailed!.message(_l),
            contains('not supported'),
          );
        },
      );

      test(
        'an empty result list is returned as it is (valid uri, no tokens), not null',
        () async {
          for (final uri in [
            'otpauth-migration://offline',
            'otpauth-migration://offline?data=',
            'otpauth-migration://online?data=abc',
          ]) {
            final results = await TokenImportSchemeProcessor.processUriByAny(
              Uri.parse(uri),
            );
            expect(results, isNotNull, reason: uri);
            expect(results, isEmpty, reason: uri);
          }
        },
      );

      test('pia://qrbackup failures are returned as failed results', () async {
        final results = await TokenImportSchemeProcessor.processUriByAny(
          Uri.parse('pia://qrbackup'),
        );
        expect(results!.single.asFailed!.message(_l), _l.invalidUrl);
      });

      test(
        'a processor that throws on a malformed uri still gets a failed result',
        () async {
          final results = await TokenImportSchemeProcessor.processUriByAny(
            Uri.parse('otpauth://totp?secret=AAAAAAAA'),
          );
          expect(results, hasLength(1));
          expect(results!.single.isFailed, isTrue);
        },
        skip:
            'BUG: otp_auth_processor.dart:138 uri.path.substring(1) throws RangeError, processUriByAny has no try/catch so the exception reaches the caller (TokenNotifier.handleLink)',
      );

      test(
        'currently the exception of a throwing processor propagates (characterization)',
        () async {
          await expectLater(
            TokenImportSchemeProcessor.processUriByAny(
              Uri.parse('otpauth://totp?secret=AAAAAAAA'),
            ),
            throwsA(isA<RangeError>()),
          );
        },
      );
    });

    group('processTokenMigrate', () {
      test('forwards to processUri for every implementation', () async {
        final viaMigrate = await const OtpAuthProcessor().processTokenMigrate(
          Uri.parse('otpauth://totp/user?secret=AAAAAAAA'),
        );
        expect(viaMigrate, hasLength(1));
        expect(viaMigrate!.single.asSuccess!.resultData.label, 'user');

        final google = await const GoogleAuthenticatorQrProcessor()
            .processTokenMigrate(_migrationUri(['x']));
        expect(google, hasLength(1));

        final pia = await const PiaSchemeProcessor().processTokenMigrate(
          Uri.parse('pia://container'),
        );
        expect(pia, isNull);
      });
    });
  });
}
