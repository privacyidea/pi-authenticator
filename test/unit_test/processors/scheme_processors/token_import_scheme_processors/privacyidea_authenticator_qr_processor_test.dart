import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/token_types.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/pia_scheme_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/encryption/token_encryption.dart';

void main() {
  _testPrivacyideaAuthenticatorQrProcessor();
  _testPiaSchemeProcessorUriHandling();
}

void _testPrivacyideaAuthenticatorQrProcessor() {
  group('Pia Scheme Processor test', () {
    test('processUri', () async {
      final tokensList = [
        HOTPToken(
          id: 'id1',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'secret1',
        ),
        TOTPToken(
          period: 30,
          id: 'id2',
          algorithm: Algorithms.SHA256,
          digits: 8,
          secret: 'secret2',
        ),
        SteamToken(id: 'id3', secret: 'secret3'),
        DayPasswordToken(
          period: const Duration(hours: 24),
          id: 'id4',
          algorithm: Algorithms.SHA512,
          digits: 10,
          secret: 'secret4',
        ),
        PushToken(serial: 'serial', id: 'id5'),
      ];
      const uriStrings = [
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQxIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IkhPVFAiLCJhbGdvcml0aG0iOiJTSEExIiwiZGlnaXRzIjo2LCJzZWNyZXQiOiJzZWNyZXQxIiwiY291bnRlciI6MH0=',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQyIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlRPVFAiLCJhbGdvcml0aG0iOiJTSEEyNTYiLCJkaWdpdHMiOjgsInNlY3JldCI6InNlY3JldDIiLCJwZXJpb2QiOjMwfQ==',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQzIiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlNURUFNIiwic2VjcmV0Ijoic2VjcmV0MyJ9',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQ0IiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IkRBWVBBU1NXT1JEIiwiYWxnb3JpdGhtIjoiU0hBNTEyIiwiZGlnaXRzIjoxMCwic2VjcmV0Ijoic2VjcmV0NCIsInZpZXdNb2RlIjoiVkFMSURGT1IiLCJwZXJpb2QiOjg2NDAwMDAwMDAwfQ==',
        'pia://qrbackup?data=eyJsYWJlbCI6IiIsImlzc3VlciI6IiIsImlkIjoiaWQ1IiwicGluIjpmYWxzZSwiaXNMb2NrZWQiOmZhbHNlLCJpc0hpZGRlbiI6ZmFsc2UsInRva2VuSW1hZ2UiOm51bGwsImZvbGRlcklkIjpudWxsLCJzb3J0SW5kZXgiOm51bGwsIm9yaWdpbiI6bnVsbCwidHlwZSI6IlBJUFVTSCIsImV4cGlyYXRpb25EYXRlIjpudWxsLCJzZXJpYWwiOiJzZXJpYWwiLCJmYlRva2VuIjpudWxsLCJzc2xWZXJpZnkiOmZhbHNlLCJlbnJvbGxtZW50Q3JlZGVudGlhbHMiOm51bGwsInVybCI6bnVsbCwiaXNSb2xsZWRPdXQiOmZhbHNlLCJyb2xsb3V0U3RhdGUiOiJyb2xsb3V0Tm90U3RhcnRlZCIsInB1YmxpY1NlcnZlcktleSI6bnVsbCwicHJpdmF0ZVRva2VuS2V5IjpudWxsLCJwdWJsaWNUb2tlbktleSI6bnVsbH0=',
      ];
      const processor = PiaSchemeProcessor();
      for (var i = 0; i < uriStrings.length; i++) {
        final token = tokensList[i];
        final uri = Uri.parse(uriStrings[i]);
        final result = await processor.processUri(uri);
        expect(result?.length, 1);
        expect(result![0].isSuccess, true);
        expect(result[0].asSuccess, isNotNull);
        expect(result[0].asSuccess!.resultData, token);
      }
    });
  });
}

const _processor = PiaSchemeProcessor();
final _l = AppLocalizationsEn();

const _pushQuery =
    'url=https%3A//123.456.78.9/ttype/push&ttl=10&issuer=privacyIDEA'
    '&enrollment_credential=3342826741eb64e8f94e01920a88745bccdecd9e'
    '&v=1&serial=PIPU0000D79E&sslverify=0';

Future<List<ProcessorResult<Token>>?> _run(String uri) =>
    _processor.processUri(Uri.parse(uri));

Future<Token> _ok(String uri) async {
  final results = await _run(uri);
  expect(results, isNotNull, reason: uri);
  expect(results, hasLength(1), reason: uri);
  expect(
    results!.single.isSuccess,
    isTrue,
    reason: '$uri failed: ${results.single.asFailed?.message(_l)}',
  );
  return results.single.asSuccess!.resultData;
}

Future<Token> _okOtpAuth(String uri) async {
  final results = await const OtpAuthProcessor().processUri(Uri.parse(uri));
  expect(results.single.isSuccess, isTrue, reason: uri);
  return results.single.asSuccess!.resultData;
}

/// The values that must be the same, no matter if the token came in as
/// pia:// or as otpauth://.
Map<String, Object?> _essence(Token t) => {
  'runtimeType': t.runtimeType,
  'type': t.type,
  'label': t.label,
  'issuer': t.issuer,
  'serial': t.serial,
  if (t is OTPToken) 'secret': t.secret,
  if (t is OTPToken) 'digits': t.digits,
  if (t is OTPToken) 'algorithm': t.algorithm,
  if (t is TOTPToken) 'period': t.period,
  if (t is HOTPToken) 'counter': t.counter,
  if (t is DayPasswordToken) 'dayPeriod': t.period,
  if (t is PushToken) 'url': t.url,
  if (t is PushToken) 'sslVerify': t.sslVerify,
  if (t is PushToken) 'enrollment': t.enrollmentCredentials,
};

String _qrBackup(String data) => 'pia://qrbackup?data=$data';
String _b64Json(Object json) => base64Url.encode(utf8.encode(jsonEncode(json)));

void _testPiaSchemeProcessorUriHandling() {
  group('PiaSchemeProcessor token hosts', () {
    test('static configuration', () {
      expect(_processor.supportedSchemes, {'pia'});
      expect(PiaSchemeProcessor.scheme, 'pia');
      expect(PiaSchemeProcessor.qrBackupHost, 'qrbackup');
      expect(
        PiaSchemeProcessor.tokenHosts.toSet(),
        TokenTypes.values.map((e) => e.name.toLowerCase()).toSet(),
      );
      expect(
        PiaSchemeProcessor.tokenHosts,
        containsAll(['totp', 'hotp', 'pipush', 'push', 'daypassword', 'steam']),
      );
    });

    test(
      'pia://totp is rebuilt to an otpauth totp token with all parameters',
      () async {
        final token =
            await _ok(
                  'pia://totp/ACME:alice?secret=JBSWY3DPEHPK3PXP&digits=8&period=60&algorithm=SHA512',
                )
                as TOTPToken;
        expect(token.type, 'TOTP');
        expect(token.issuer, 'ACME');
        expect(token.label, 'alice');
        expect(token.digits, 8);
        expect(token.period, 60);
        expect(token.algorithm, Algorithms.SHA512);
        expect(token.secret, 'JBSWY3DPEHPK3PXP');
      },
    );

    test('pia://hotp keeps the counter and the issuer parameter', () async {
      final token =
          await _ok('pia://hotp/user?secret=AAAAAAAA&counter=7&issuer=X')
              as HOTPToken;
      expect(token.counter, 7);
      expect(token.issuer, 'X');
      expect(token.label, 'user');
    });

    test(
      'pia://pipush gives the same push token as otpauth://pipush',
      () async {
        final fromPia = await _ok('pia://pipush/PIPU0000D79E?$_pushQuery');
        final fromOtpAuth = await _okOtpAuth(
          'otpauth://pipush/PIPU0000D79E?$_pushQuery',
        );
        expect(fromPia, isA<PushToken>());
        expect(_essence(fromPia), _essence(fromOtpAuth));
        final push = fromPia as PushToken;
        expect(push.serial, 'PIPU0000D79E');
        expect(push.issuer, 'privacyIDEA');
        expect(push.label, 'PIPU0000D79E');
        expect(push.url, Uri.parse('https://123.456.78.9/ttype/push'));
        expect(push.sslVerify, isFalse);
        expect(
          push.enrollmentCredentials,
          '3342826741eb64e8f94e01920a88745bccdecd9e',
        );
      },
    );

    test(
      'pia://steam and pia://daypassword create the matching token types',
      () async {
        expect(
          await _ok('pia://steam/user?secret=AAAAAAAA'),
          isA<SteamToken>(),
        );
        final day =
            await _ok('pia://daypassword/user?secret=AAAAAAAA&period=3600')
                as DayPasswordToken;
        expect(day.period, const Duration(hours: 1));
      },
    );

    test('pia://push without a serial fails and names the serial', () async {
      final results = await _run('pia://push/user?secret=AAAAAAAA');
      expect(results!.single.isFailed, isTrue);
      expect(
        results.single.asFailed!.message(_l),
        _l.invalidValue('serial', 'Null', 'null'),
      );
    });

    test('host and scheme casing do not matter', () async {
      expect(await _ok('pia://TOTP/user?secret=AAAAAAAA'), isA<TOTPToken>());
      expect(await _ok('PIA://totp/user?secret=AAAAAAAA'), isA<TOTPToken>());
      expect(await _ok('PIA://HOTP/user?secret=AAAAAAAA'), isA<HOTPToken>());
      expect(
        await _ok('pia://PIPUSH/PIPU0000D79E?$_pushQuery'),
        isA<PushToken>(),
      );
    });

    test('results carry the token import result handler type', () async {
      final results = await _run('pia://totp/user?secret=AAAAAAAA');
      expect(
        results!.single.asSuccess!.resultHandlerType,
        same(TokenImportSchemeProcessor.resultHandlerType),
      );
    });

    test(
      'a failing token keeps the otpauth failure (message and error)',
      () async {
        final results = await _run('pia://totp/user?secret=AAAAAAAA&period=0');
        final failed = results!.single.asFailed!;
        expect(failed.message(_l), _l.invalidValue('period', 'String', '0'));
        expect(failed.error, isNotNull);
      },
    );

    group('label and issuer survive the rebuild', () {
      final labels = <String, (String issuer, String label)>{
        // path -> expected (issuer, label)
        'plain': ('', 'plain'),
        'a/b': ('', 'a/b'),
        'a%2Fb': ('', 'a/b'),
        'a%2Fb%2Fc': ('', 'a/b/c'),
        'ACME:alice': ('ACME', 'alice'),
        'ACME%3Aalice': ('ACME', 'alice'),
        'a%2Fb:c%20d': ('a/b', 'c d'),
        'Is%20su:user%20name': ('Is su', 'user name'),
        'Is su:user name': ('Is su', 'user name'),
        'a%20%20b': ('', 'a  b'),
        'us+er': ('', 'us+er'),
        'Iss:us+er': ('Iss', 'us+er'),
        'J%C3%BCrgen:M%C3%BCller': ('Jürgen', 'Müller'),
        'a%3Fb%23c': ('', 'a?b#c'),
        'a%3Fb%23c:d%3Fe%23f': ('a?b#c', 'd?e#f'),
        '100%25:x': ('100%', 'x'),
        'a%2541': ('', 'a%41'),
        ':user': ('', 'user'),
        'user:': ('user', ''),
      };
      for (final entry in labels.entries) {
        test('path "${entry.key}"', () async {
          final token = await _ok('pia://totp/${entry.key}?secret=AAAAAAAA');
          expect(token.issuer, entry.value.$1);
          expect(token.label, entry.value.$2);
        });
      }

      test(
        'each of these paths gives the same token via pia:// and otpauth://',
        () async {
          for (final path in labels.keys) {
            final fromPia = await _ok('pia://totp/$path?secret=AAAAAAAA');
            final fromOtpAuth = await _okOtpAuth(
              'otpauth://totp/$path?secret=AAAAAAAA',
            );
            expect(_essence(fromPia), _essence(fromOtpAuth), reason: path);
          }
        },
      );

      test(
        'an empty segment between slashes gives empty label and issuer',
        () async {
          final token = await _ok('pia://totp//?secret=AAAAAAAA');
          expect(token.label, '');
          expect(token.issuer, '');
        },
      );

      test(
        'issuer parameter: plus is a space, %2B a plus, %26 and %3D are kept',
        () async {
          expect(
            (await _ok('pia://totp/u?secret=AAAAAAAA&issuer=a+b')).issuer,
            'a b',
          );
          expect(
            (await _ok('pia://totp/u?secret=AAAAAAAA&issuer=a%2Bb')).issuer,
            'a+b',
          );
          expect(
            (await _ok('pia://totp/u?secret=AAAAAAAA&issuer=a%20b')).issuer,
            'a b',
          );
          expect(
            (await _ok('pia://totp/u?secret=AAAAAAAA&issuer=A%26B%3DC')).issuer,
            'A&B=C',
          );
        },
      );

      test(
        'a label prefix wins over the issuer parameter (same as otpauth://)',
        () async {
          final token = await _ok(
            'pia://totp/Prefix:user?secret=AAAAAAAA&issuer=Param',
          );
          expect(token.issuer, 'Prefix');
        },
      );

      test('a fragment in the uri does not disturb the token', () async {
        final token = await _ok('pia://totp/user?secret=AAAAAAAA#frag');
        expect(token.label, 'user');
        expect((token as OTPToken).secret, 'AAAAAAAA');
      });
    });

    group('origin', () {
      test(
        'origin data is the rebuilt otpauth uri with the same path and parameters',
        () async {
          final token = await _ok(
            'pia://totp/ACME:alice?secret=AAAAAAAA&digits=8&issuer=ACME',
          );
          expect(token.origin, isNotNull);
          final data = Uri.parse(token.origin!.data);
          expect(data.scheme, 'otpauth');
          expect(data.host, 'totp');
          expect(Uri.decodeFull(data.path), '/ACME:alice');
          expect(data.queryParameters, {
            'secret': 'AAAAAAAA',
            'digits': '8',
            'issuer': 'ACME',
          });
        },
      );

      test(
        'without creator parameter the token is not marked as privacyIDEA token',
        () async {
          final token = await _ok('pia://totp/user?secret=AAAAAAAA');
          expect(token.origin!.isPrivacyIdeaToken, isNull);
          expect(token.origin!.creator, isNull);
        },
      );

      test(
        'with creator parameter the token is marked as privacyIDEA token',
        () async {
          final token = await _ok(
            'pia://totp/user?secret=AAAAAAAA&creator=privacyIDEA',
          );
          expect(token.origin!.isPrivacyIdeaToken, isTrue);
          expect(token.origin!.creator, 'privacyIDEA');
        },
      );
    });

    group('missing path', () {
      test(
        'pia://totp without a path does not throw',
        () async {
          final results = await _run('pia://totp?secret=AAAAAAAA');
          expect(results, isNotNull);
          expect(results!.single.isFailed, isTrue);
        },
        skip:
            'BUG: otp_auth_processor.dart:138 uri.path.substring(1) throws RangeError for the empty path of the rebuilt uri (outside try/catch)',
      );

      test(
        'pia://totp/ (trailing slash only) is handled like otpauth://totp/',
        () async {
          final results = await _run('pia://totp/?secret=AAAAAAAA');
          expect(results, isNotNull);
          expect(results, hasLength(1));
        },
        skip:
            'BUG: pia_scheme_processor.dart:80-88 the rebuild via pathSegments drops the lone "/" so otp_auth_processor.dart:138 substring(1) throws RangeError, while otpauth://totp/ itself is accepted',
      );

      test(
        'currently the missing path surfaces as RangeError (characterization)',
        () async {
          await expectLater(
            _run('pia://totp?secret=AAAAAAAA'),
            throwsA(isA<RangeError>()),
          );
          await expectLater(
            _run('pia://totp/?secret=AAAAAAAA'),
            throwsA(isA<RangeError>()),
          );
        },
      );
    });
  });

  group('PiaSchemeProcessor unsupported uris', () {
    test(
      'unknown hosts return null so that other processors can try',
      () async {
        for (final uri in [
          'pia://foo/bar',
          'pia://totp2/user?secret=AAAAAAAA',
          'pia://xtotp/user?secret=AAAAAAAA',
          'pia://qrbackups?data=abc',
        ]) {
          expect(await _run(uri), isNull, reason: uri);
        }
      },
    );

    test('pia://container is left to the container processor (null)', () async {
      expect(await _run('pia://container?issuer=privacyIDEA'), isNull);
      expect(await _run('pia://CONTAINER/SMPH00067A2F?serial=x'), isNull);
    });

    test('a uri without host returns null', () async {
      expect(await _run('pia://'), isNull);
      expect(await _run('pia:///totp/user?secret=AAAAAAAA'), isNull);
      expect(await _run('pia:totp/user?secret=AAAAAAAA'), isNull);
    });

    test('other schemes return null, even with a token host', () async {
      expect(await _run('otpauth://totp/user?secret=AAAAAAAA'), isNull);
      expect(await _run('https://totp/user?secret=AAAAAAAA'), isNull);
      expect(await _run('otpauth-migration://offline?data=x'), isNull);
    });
  });

  group('PiaSchemeProcessor qrbackup', () {
    void expectInvalidUrl(List<ProcessorResult<Token>>? results, String why) {
      expect(results, isNotNull, reason: why);
      expect(results, hasLength(1), reason: why);
      final failed = results!.single.asFailed;
      expect(failed, isNotNull, reason: why);
      expect(failed!.message(_l), _l.invalidUrl, reason: why);
      expect(
        failed.resultHandlerType,
        same(TokenImportSchemeProcessor.resultHandlerType),
        reason: why,
      );
    }

    test('without data parameter', () async {
      expectInvalidUrl(await _run('pia://qrbackup'), 'no query');
      expectInvalidUrl(await _run('pia://qrbackup?foo=bar'), 'other query');
      expectInvalidUrl(await _run('pia://qrbackup?data='), 'empty data');
    });

    test('broken base64', () async {
      for (final data in ['!!!', 'abc', 'a', '====', 'e30']) {
        expectInvalidUrl(await _run(_qrBackup(data)), 'data=$data');
      }
    });

    test('valid base64 that is not json', () async {
      final data = base64Url.encode(utf8.encode('this is not json'));
      expectInvalidUrl(await _run(_qrBackup(data)), 'plain text');
    });

    test('valid base64 with invalid utf8', () async {
      final data = base64Url.encode([0xff, 0xfe, 0xfd]);
      expectInvalidUrl(await _run(_qrBackup(data)), 'invalid utf8');
    });

    test(
      'valid json of the wrong shape or without a usable token type',
      () async {
        expectInvalidUrl(await _run(_qrBackup(_b64Json({}))), 'empty object');
        expectInvalidUrl(await _run(_qrBackup(_b64Json([1, 2]))), 'json array');
        expectInvalidUrl(
          await _run(_qrBackup(_b64Json('text'))),
          'json string',
        );
        expectInvalidUrl(
          await _run(_qrBackup(_b64Json({'type': 'UNKNOWN', 'id': 'x'}))),
          'unknown type',
        );
        expectInvalidUrl(
          await _run(_qrBackup(_b64Json({'type': 'HOTP', 'id': 'x'}))),
          'HOTP without secret',
        );
      },
    );

    test('host casing: pia://QRBACKUP is handled as qrbackup', () async {
      expectInvalidUrl(await _run('pia://QRBACKUP?data=x'), 'uppercase host');
    });

    test('export uri round trip keeps the complete token', () async {
      final tokens = <Token>[
        HOTPToken(
          id: 'id1',
          algorithm: Algorithms.SHA256,
          digits: 8,
          secret: 'JBSWY3DPEHPK3PXP',
          counter: 42,
          label: 'a b+c/d:e?f#g%h',
          issuer: 'Jürgen & Söhne 🔑',
        ),
        TOTPToken(
          id: 'id2',
          algorithm: Algorithms.SHA512,
          digits: 7,
          secret: 'JBSWY3DPEHPK3PXP',
          period: 45,
          label: 'x',
          issuer: 'y',
        ),
        SteamToken(id: 'id3', secret: 'JBSWY3DPEHPK3PXP', label: 'steam user'),
        DayPasswordToken(
          id: 'id4',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: 'JBSWY3DPEHPK3PXP',
          period: const Duration(hours: 12),
          label: 'day',
        ),
        PushToken(
          id: 'id5',
          serial: 'PIPU0001',
          label: 'push',
          issuer: 'privacyIDEA',
        ),
      ];
      for (final token in tokens) {
        final exportUri = TokenEncryption.generateExportUri(token: token);
        final results = await _processor.processUri(exportUri);
        expect(results, hasLength(1), reason: token.type);
        expect(results!.single.isSuccess, isTrue, reason: token.type);
        final imported = results.single.asSuccess!.resultData;
        expect(imported.runtimeType, token.runtimeType);
        expect(imported.toJson(), token.toJson(), reason: token.type);
      }
    });
  });
}
