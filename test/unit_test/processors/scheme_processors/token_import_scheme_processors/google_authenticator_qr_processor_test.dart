import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_argument_error.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/token_import/token_origin_data.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/steam_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import 'package:privacyidea_authenticator/proto/generated/GoogleAuthenticatorImport.pb.dart';
import 'package:privacyidea_authenticator/utils/token_import_origins.dart';
import 'package:protobuf/protobuf.dart' show InvalidProtocolBufferException;

void main() {
  _testGooleAuthenticatorQrProcessor();
  _testGoogleAuthenticatorQrProcessorEdgeCases();
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
        data:
            'ChkKCpklNznImSU3OcgSBVRlc3QxIAEoATACChsKCpklNznamSU3OdoSBVRlc3QyIAEoATABOAAQARgBIAAo8enF1vr/////AQ==',
        appName: TokenImportOrigins.googleAuthenticator.appName,
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
        data:
            'ChkKCpklNznImSU3OcgSBVRlc3QxIAEoATACChsKCpklNznamSU3OdoSBVRlc3QyIAEoATABOAAQARgBIAAo8enF1vr/////AQ==',
        appName: TokenImportOrigins.googleAuthenticator.appName,
        isPrivacyIdeaToken: false,
        createdAt: token1.origin!.createdAt,
      );
      expect(token1.origin, tokenOriginData1Matcher);
    });
  });
}

const _processor = GoogleAuthenticatorQrProcessor();
final _l = AppLocalizationsEn();
const _defaultSecret = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

typedef _Param = GoogleAuthenticatorImport_OtpParameters;

_Param _param({
  List<int> secret = _defaultSecret,
  String name = 'name',
  String issuer = '',
  GoogleAuthenticatorImport_Algorithm? algorithm,
  GoogleAuthenticatorImport_DigitCount? digits,
  GoogleAuthenticatorImport_OtpType? type,
  int? counter,
}) => _Param(
  secret: secret,
  name: name,
  issuer: issuer,
  algorithm: algorithm,
  digits: digits,
  type: type,
  counter: counter == null ? null : Int64(counter),
);

List<int> _buffer(List<_Param> params) => GoogleAuthenticatorImport(
  otpParameters: params,
  version: 1,
  batchSize: 1,
  batchIndex: 0,
  batchId: 7,
).writeToBuffer();

/// The migration uri as the Google Authenticator app produces it
/// (base64 is percent encoded).
Uri _uri(List<_Param> params) => _uriFromBytes(_buffer(params));
Uri _uriFromBytes(List<int> bytes) => Uri.parse(
  'otpauth-migration://offline?data=${Uri.encodeComponent(base64.encode(bytes))}',
);

Future<List<ProcessorResult<Token>>> _run(Uri uri) =>
    _processor.processUri(uri);

Future<Token> _single(_Param param) async {
  final results = await _run(_uri([param]));
  expect(results, hasLength(1));
  expect(
    results.single.isSuccess,
    isTrue,
    reason: 'failed: ${results.single.asFailed?.message(_l)}',
  );
  return results.single.asSuccess!.resultData;
}

// Raw protobuf helpers to put values on the wire that the generated enums
// do not know (a real QR code from a newer app version could contain them).
List<int> _varint(int v) {
  final out = <int>[];
  var x = v;
  while (x > 0x7f) {
    out.add((x & 0x7f) | 0x80);
    x >>= 7;
  }
  out.add(x);
  return out;
}

List<int> _lengthDelimited(int field, List<int> bytes) => [
  ..._varint(field << 3 | 2),
  ..._varint(bytes.length),
  ...bytes,
];
List<int> _varintField(int field, int value) => [
  ..._varint(field << 3),
  ..._varint(value),
];

void _testGoogleAuthenticatorQrProcessorEdgeCases() {
  group('GoogleAuthenticatorQrProcessor edge cases', () {
    group('malformed input', () {
      test(
        'invalid base64 returns a single failed result and does not throw',
        () async {
          for (final data in ['!!!notbase64', 'abc', 'a', '%%%']) {
            final results = await _run(
              Uri.parse('otpauth-migration://offline?data=$data'),
            );
            expect(results, hasLength(1), reason: data);
            expect(results.single.isFailed, isTrue, reason: data);
          }
        },
        skip:
            'BUG: google_authenticator_qr_processor.dart:64-65 Uri.decodeComponent/base64.decode run outside any try/catch, the FormatException escapes processUri',
      );

      test(
        'valid base64 but invalid protobuf returns a single failed result and does not throw',
        () async {
          final invalidProtobufs = <String, List<int>>{
            'invalid wire type': [0xff, 0xff, 0xff, 0xff, 0x01],
            'truncated message': [0x0a, 0x20, 0x01],
            'plain text': utf8.encode('hello world'),
          };
          for (final entry in invalidProtobufs.entries) {
            final results = await _run(_uriFromBytes(entry.value));
            expect(results, hasLength(1), reason: entry.key);
            expect(results.single.isFailed, isTrue, reason: entry.key);
          }
        },
        skip:
            'BUG: google_authenticator_qr_processor.dart:67 GoogleAuthenticatorImport.fromBuffer runs outside any try/catch, the InvalidProtocolBufferException escapes processUri',
      );

      test(
        'currently invalid base64 throws a FormatException (characterization)',
        () async {
          await expectLater(
            _run(Uri.parse('otpauth-migration://offline?data=!!!notbase64')),
            throwsA(isA<FormatException>()),
          );
        },
      );

      test(
        'currently invalid protobuf throws InvalidProtocolBufferException (characterization)',
        () async {
          await expectLater(
            _run(_uriFromBytes([0xff, 0xff, 0xff, 0xff, 0x01])),
            throwsA(isA<InvalidProtocolBufferException>()),
          );
        },
      );

      test(
        'additional query parameters after data do not make processUri throw',
        () async {
          final uri = Uri.parse('${_uri([_param()])}&foo=bar');
          await expectLater(_run(uri), completes);
        },
        skip:
            'BUG: google_authenticator_qr_processor.dart:58-62 the regex data=(.*)\$ swallows "&foo=bar" into the base64 payload, so the decode throws a FormatException (uri.queryParameters["data"] would be correct)',
      );

      test('empty data and missing data give an empty result', () async {
        expect(
          await _run(Uri.parse('otpauth-migration://offline?data=')),
          isEmpty,
        );
        expect(await _run(Uri.parse('otpauth-migration://offline')), isEmpty);
      });

      test(
        'a valid batch without any otp parameters gives an empty result',
        () async {
          expect(await _run(_uri([])), isEmpty);
        },
      );

      test(
        'other schemes and hosts are ignored with an empty result',
        () async {
          final payload = Uri.encodeComponent(
            base64.encode(_buffer([_param()])),
          );
          expect(
            await _run(Uri.parse('otpauth://offline?data=$payload')),
            isEmpty,
          );
          expect(await _run(Uri.parse('pia://offline?data=$payload')), isEmpty);
          expect(
            await _run(Uri.parse('otpauth-migration://online?data=$payload')),
            isEmpty,
          );
        },
      );

      test(
        'raw base64 and percent encoded base64 give the same token',
        () async {
          // This secret produces "+" and "/" in the base64 payload.
          final bytes = _buffer([
            _param(
              secret: [0xfb, 0xff, 0xbf, 0xfe, 0xfa, 0xff, 0xff, 0x3e],
              name: 'plus',
            ),
          ]);
          final b64 = base64.encode(bytes);
          expect(b64, allOf(contains('+'), contains('/')));
          final raw = await _run(
            Uri.parse('otpauth-migration://offline?data=$b64'),
          );
          final encoded = await _run(
            Uri.parse(
              'otpauth-migration://offline?data=${Uri.encodeComponent(b64)}',
            ),
          );
          expect(raw, hasLength(1));
          expect(encoded, hasLength(1));
          expect(raw.single.isSuccess, isTrue);
          expect(
            (raw.single.asSuccess!.resultData as OTPToken).secret,
            (encoded.single.asSuccess!.resultData as OTPToken).secret,
          );
          expect(
            Encodings.base32.decode(
              (encoded.single.asSuccess!.resultData as OTPToken).secret,
            ),
            [0xfb, 0xff, 0xbf, 0xfe, 0xfa, 0xff, 0xff, 0x3e],
          );
        },
      );
    });

    group('single token', () {
      test('TOTP token: all fields, secret round trip and origin', () async {
        final bytes = _buffer([
          _param(
            name: 'alice',
            issuer: 'ACME',
            algorithm: GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA256,
            digits: GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_EIGHT,
            type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_TOTP,
          ),
        ]);
        final results = await _run(_uriFromBytes(bytes));
        expect(results, hasLength(1));
        final token = results.single.asSuccess!.resultData as TOTPToken;
        expect(token.issuer, 'ACME');
        expect(token.label, 'alice');
        expect(token.algorithm, Algorithms.SHA256);
        expect(token.digits, 8);
        expect(token.period, 30);
        expect(Encodings.base32.decode(token.secret), _defaultSecret);
        expect(token.origin, isNotNull);
        expect(token.origin!.source, TokenOriginSourceType.qrScanImport);
        expect(
          token.origin!.appName,
          TokenImportOrigins.googleAuthenticator.appName,
        );
        expect(token.origin!.isPrivacyIdeaToken, isFalse);
        expect(token.origin!.data, base64.encode(bytes));
      });

      test('results use the token notifier result handler type', () async {
        final results = await _run(_uri([_param()]));
        expect(
          results.single.asSuccess!.resultHandlerType,
          same(OtpAuthProcessor.resultHandlerType),
        );
        expect(
          GoogleAuthenticatorQrProcessor.resultHandlerType,
          same(OtpAuthProcessor.resultHandlerType),
        );
      });

      test(
        'secrets of 1 to 5 bytes and 32 bytes survive the round trip',
        () async {
          for (final length in [1, 2, 3, 4, 5, 10, 32]) {
            final secret = List<int>.generate(
              length,
              (i) => (i * 37 + 11) & 0xff,
            );
            final token = await _single(_param(secret: secret)) as OTPToken;
            expect(
              Encodings.base32.decode(token.secret),
              secret,
              reason: '$length bytes -> ${token.secret}',
            );
          }
        },
      );

      test('empty secret is a failed result, not an exception', () async {
        final results = await _run(_uri([_param(secret: [])]));
        expect(results, hasLength(1));
        expect(results.single.isFailed, isTrue);
        expect(results.single.asFailed!.message(_l), _l.unableToCreateToken);
      });

      test(
        'unspecified type defaults to TOTP with a 30 second period',
        () async {
          final token = await _single(
            _param(
              type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_UNSPECIFIED,
            ),
          );
          expect(token, isA<TOTPToken>());
          expect((token as TOTPToken).period, 30);
        },
      );
    });

    group('HOTP', () {
      test('counter is taken over', () async {
        final token = await _single(
          _param(
            type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_HOTP,
            counter: 7,
          ),
        );
        expect(token, isA<HOTPToken>());
        expect((token as HOTPToken).counter, 7);
      });

      test('omitted counter is 0', () async {
        final token = await _single(
          _param(type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_HOTP),
        );
        expect((token as HOTPToken).counter, 0);
      });

      test('counter above 32 bit is not truncated', () async {
        final token = await _single(
          _param(
            type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_HOTP,
            counter: 4000000000,
          ),
        );
        expect((token as HOTPToken).counter, 4000000000);
      });

      test('negative counter is a failed result naming the counter', () async {
        final results = await _run(
          _uri([
            _param(
              type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_HOTP,
              counter: -1,
            ),
          ]),
        );
        expect(results, hasLength(1));
        final failed = results.single.asFailed!;
        expect(failed.message(_l), _l.invalidValue('counter', 'String', '-1'));
        expect(failed.error, isA<LocalizedArgumentError>());
      });

      test('the counter is ignored for TOTP tokens', () async {
        final token = await _single(
          _param(
            type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_TOTP,
            counter: 99,
          ),
        );
        expect(token, isA<TOTPToken>());
      });
    });

    group('algorithm / digits / type enums', () {
      test('known algorithms are mapped', () async {
        final expected = {
          GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA1: Algorithms.SHA1,
          GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA256:
              Algorithms.SHA256,
          GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA512:
              Algorithms.SHA512,
          GoogleAuthenticatorImport_Algorithm.ALGORITHM_UNSPECIFIED:
              Algorithms.SHA1,
        };
        for (final entry in expected.entries) {
          final token = await _single(_param(algorithm: entry.key)) as OTPToken;
          expect(token.algorithm, entry.value, reason: entry.key.name);
        }
      });

      test(
        'MD5 is not supported by the app and silently becomes SHA1 (characterization)',
        () async {
          final token =
              await _single(
                    _param(
                      algorithm:
                          GoogleAuthenticatorImport_Algorithm.ALGORITHM_MD5,
                    ),
                  )
                  as OTPToken;
          expect(token.algorithm, Algorithms.SHA1);
        },
      );

      test('digits are mapped, unspecified means 6', () async {
        final expected = {
          GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_UNSPECIFIED: 6,
          GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_SIX: 6,
          GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_EIGHT: 8,
        };
        for (final entry in expected.entries) {
          final token = await _single(_param(digits: entry.key)) as OTPToken;
          expect(token.digits, entry.value, reason: entry.key.name);
        }
      });

      test(
        'enum values unknown to the app fall back to TOTP, SHA1 and 6 digits',
        () async {
          final parameters = [
            ..._lengthDelimited(1, _defaultSecret),
            ..._lengthDelimited(2, utf8.encode('future')),
            ..._lengthDelimited(3, utf8.encode('ACME')),
            ..._varintField(4, 99),
            ..._varintField(5, 99),
            ..._varintField(6, 99),
          ];
          final bytes = [
            ..._lengthDelimited(1, parameters),
            ..._varintField(2, 1),
            ..._varintField(3, 1),
            ..._varintField(4, 0),
            ..._varintField(5, 7),
          ];
          final results = await _run(_uriFromBytes(bytes));
          expect(results, hasLength(1));
          expect(results.single.isSuccess, isTrue);
          final token = results.single.asSuccess!.resultData as TOTPToken;
          expect(token.label, 'future');
          expect(token.issuer, 'ACME');
          expect(token.algorithm, Algorithms.SHA1);
          expect(token.digits, 6);
          expect(token.period, 30);
        },
      );
    });

    group('batch', () {
      test('multiple tokens keep their order and individual settings', () async {
        final bytes = _buffer([
          _param(name: 'one', issuer: 'A'),
          _param(
            name: 'two',
            issuer: 'B',
            type: GoogleAuthenticatorImport_OtpType.OTP_TYPE_HOTP,
            counter: 3,
          ),
          _param(
            name: 'three',
            issuer: 'C',
            algorithm: GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA512,
            digits: GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_EIGHT,
          ),
        ]);
        final results = await _run(_uriFromBytes(bytes));
        expect(results, hasLength(3));
        expect(results.every((r) => r.isSuccess), isTrue);
        final tokens = results.map((r) => r.asSuccess!.resultData).toList();
        expect(tokens.map((t) => t.label), ['one', 'two', 'three']);
        expect(tokens.map((t) => t.issuer), ['A', 'B', 'C']);
        expect(tokens[0], isA<TOTPToken>());
        expect(tokens[1], isA<HOTPToken>());
        expect((tokens[1] as HOTPToken).counter, 3);
        expect((tokens[2] as OTPToken).algorithm, Algorithms.SHA512);
        expect((tokens[2] as OTPToken).digits, 8);
        // All tokens of one scan share the same origin data (the whole payload).
        for (final token in tokens) {
          expect(token.origin!.data, base64.encode(bytes));
        }
        // Every token gets its own id.
        expect(tokens.map((t) => t.id).toSet(), hasLength(3));
      });

      test('one broken token does not drop the others', () async {
        final results = await _run(
          _uri([
            _param(name: 'one'),
            _param(name: 'broken', secret: []),
            _param(name: 'three'),
          ]),
        );
        expect(results, hasLength(3));
        expect(results.map((r) => r.isSuccess), [true, false, true]);
        expect(results[0].asSuccess!.resultData.label, 'one');
        expect(results[2].asSuccess!.resultData.label, 'three');
        expect(results[1].asFailed!.message(_l), _l.unableToCreateToken);
      });

      test(
        'a failed result keeps its failure and gets no token origin',
        () async {
          final results = await _run(_uri([_param(secret: [])]));
          expect(results.single, isA<ProcessorResultFailed<Token>>());
          expect(results.single.asSuccess, isNull);
        },
      );

      test(
        'a large batch of 60 tokens is processed completely and in order',
        () async {
          final params = [
            for (var i = 0; i < 60; i++)
              _param(name: 'user$i', issuer: 'iss$i'),
          ];
          final results = await _run(_uri(params));
          expect(results, hasLength(60));
          for (var i = 0; i < 60; i++) {
            expect(results[i].asSuccess!.resultData.label, 'user$i');
            expect(results[i].asSuccess!.resultData.issuer, 'iss$i');
          }
        },
      );
    });

    group('names and issuers', () {
      test('name with issuer prefix splits into issuer and label', () async {
        final token = await _single(_param(name: 'ACME:alice', issuer: 'ACME'));
        expect(token.issuer, 'ACME');
        expect(token.label, 'alice');
      });

      test('name without prefix uses the issuer field', () async {
        final token = await _single(_param(name: 'alice', issuer: 'ACME'));
        expect(token.issuer, 'ACME');
        expect(token.label, 'alice');
      });

      test(
        'a colon in the name wins over a different issuer field (characterization)',
        () async {
          final token = await _single(
            _param(name: 'ACME:alice', issuer: 'Other'),
          );
          expect(token.issuer, 'ACME');
          expect(token.label, 'alice');
        },
      );

      test(
        'name with several colons keeps the part after the first colon',
        () async {
          final token = await _single(_param(name: 'A:B:C', issuer: 'A'));
          expect(token.issuer, 'A');
          expect(token.label, 'B:C');
        },
        skip:
            'BUG: otp_auth_processor.dart:144-145 split(":") only takes split[0] and split[1], the rest of the name ("C") is silently dropped',
      );

      test('percent signs in the name are kept literally', () async {
        expect((await _single(_param(name: '100% user'))).label, '100% user');
        expect((await _single(_param(name: 'a%41'))).label, 'a%41');
        expect((await _single(_param(name: 'x%2Fy'))).label, 'x%2Fy');
      });

      test('spaces, plus, ampersand and slash in the name are kept', () async {
        for (final name in ['a b', 'a+b', 'a&b', 'a/b', 'a=b']) {
          expect((await _single(_param(name: name, issuer: 'X'))).label, name);
        }
      });

      test('unicode name and issuer are kept', () async {
        final token = await _single(
          _param(name: 'Jürgen 🔑', issuer: 'Müller'),
        );
        expect(token.label, 'Jürgen 🔑');
        expect(token.issuer, 'Müller');
      });

      test('an empty name gives an empty label and keeps the issuer', () async {
        final token = await _single(_param(name: '', issuer: 'X'));
        expect(token.label, '');
        expect(token.issuer, 'X');
      });

      test(
        '"#" and "?" in the name are kept in the label',
        () async {
          for (final name in ['Test #1', 'who?', 'a#b?c']) {
            final results = await _run(_uri([_param(name: name, issuer: 'X')]));
            expect(results, hasLength(1), reason: name);
            expect(
              results.single.isSuccess,
              isTrue,
              reason: '"$name" failed: ${results.single.asFailed?.message(_l)}',
            );
            expect(results.single.asSuccess!.resultData.label, name);
          }
        },
        skip:
            'BUG: google_authenticator_qr_processor.dart:72 Uri.encodeFull does not escape "#" and "?", the otpauth uri is cut off and the token fails with "secret is null"',
      );

      test('issuer with ampersand and equals sign is kept', () async {
        final token = await _single(_param(name: 'a', issuer: 'a&b=c'));
        expect(token.issuer, 'a&b=c');
      });

      test('issuer with a space and with a lone percent is kept', () async {
        expect((await _single(_param(name: 'a', issuer: 'I S'))).issuer, 'I S');
        expect(
          (await _single(_param(name: 'a', issuer: '100%'))).issuer,
          '100%',
        );
      });

      test(
        'an issuer containing a percent escape is kept literally',
        () async {
          final token = await _single(_param(name: 'a', issuer: 'a%41'));
          expect(token.issuer, 'a%41');
        },
        skip:
            'BUG: otp_auth_processor.dart:164 Uri.decodeFull is applied to an issuer that queryParameters already decoded, "a%41" becomes "aA"',
      );

      test('issuer Steam creates a Steam token (characterization)', () async {
        final token = await _single(_param(name: 'a', issuer: 'Steam'));
        expect(token, isA<SteamToken>());
        expect((token as SteamToken).digits, 5);
      });
    });
  });
}
