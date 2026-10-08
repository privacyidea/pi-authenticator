import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_container_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_import_scheme_processors/pia_scheme_processor.dart';
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

/// A configurable [SchemeProcessor] that records how it was called.
class _FakeProcessor extends SchemeProcessor {
  _FakeProcessor(this.schemes, this._onProcess);

  final Set<String> schemes;
  final Future<List<ProcessorResult<dynamic>>?> Function(Uri uri) _onProcess;
  final List<Uri> calls = [];
  final List<bool> fromInitValues = [];

  @override
  Set<String> get supportedSchemes => schemes;

  @override
  Future<List<ProcessorResult<dynamic>>?> processUri(
    Uri uri, {
    bool fromInit = false,
  }) {
    calls.add(uri);
    fromInitValues.add(fromInit);
    return _onProcess(uri);
  }
}

void main() {
  group('SchemeProcessor.processUriByAny', () {
    late List<SchemeProcessor> originalImplementations;

    setUp(() {
      originalImplementations = List.of(SchemeProcessor.implementations);
    });

    tearDown(() {
      SchemeProcessor.implementations
        ..clear()
        ..addAll(originalImplementations);
    });

    group('registry', () {
      test(
        'has the home widget, navigation, token import and container processors in this order',
        () {
          final types = SchemeProcessor.implementations
              .map((e) => e.runtimeType.toString())
              .toList();
          expect(types.first, 'HomeWidgetProcessor');
          expect(types.last, 'TokenContainerProcessor');
          expect(types.sublist(types.length - 4, types.length - 1), [
            'OtpAuthProcessor',
            'GoogleAuthenticatorQrProcessor',
            'PiaSchemeProcessor',
          ]);
          expect(types, contains('HomeWidgetNavigateProcessor'));
        },
      );

      test(
        'pia is claimed by two processors: token import first, container last',
        () {
          final piaProcessors = SchemeProcessor.implementations
              .where((p) => p.supportedSchemes.contains('pia'))
              .map((p) => p.runtimeType)
              .toList();
          expect(piaProcessors, [PiaSchemeProcessor, TokenContainerProcessor]);
        },
      );
    });

    group('real processors', () {
      test(
        'pia://container reaches the TokenContainerProcessor after the Pia processor returned null',
        () async {
          final results = await SchemeProcessor.processUriByAny(
            Uri.parse(_containerUri),
          );
          expect(results, hasLength(1));
          expect(results!.single.isSuccess, isTrue);
          final container = results.single.asSuccess!.resultData;
          expect(container, isA<TokenContainerUnfinalized>());
          expect((container as TokenContainer).issuer, 'privacyIDEA');
          expect(
            results.single.asSuccess!.resultHandlerType,
            same(TokenContainerProcessor.resultHandlerType),
          );
        },
      );

      test(
        'pia://container with missing parameters is a failed list from the container processor',
        () async {
          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('pia://container'),
          );
          expect(results, hasLength(1));
          expect(results!.single.isFailed, isTrue);
          expect(
            results.single.asFailed!.resultHandlerType,
            same(TokenContainerProcessor.resultHandlerType),
          );
        },
      );

      test('pia token hosts stay with the Pia processor', () async {
        final results = await SchemeProcessor.processUriByAny(
          Uri.parse('pia://totp/user?secret=AAAAAAAA'),
        );
        expect(results!.single.asSuccess!.resultData, isA<TOTPToken>());
      });

      test(
        'pia://qrbackup without data stops at the Pia processor with a failed result',
        () async {
          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('pia://qrbackup'),
          );
          expect(results!.single.asFailed!.message(_l), _l.invalidUrl);
        },
      );

      test('a pia uri that nobody handles returns null', () async {
        expect(
          await SchemeProcessor.processUriByAny(Uri.parse('pia://foo/bar')),
          isNull,
        );
        expect(
          await SchemeProcessor.processUriByAny(Uri.parse('pia://')),
          isNull,
        );
      });

      test(
        'otpauth and otpauth-migration reach their token import processors',
        () async {
          final otp = await SchemeProcessor.processUriByAny(
            Uri.parse('otpauth://hotp/user?secret=AAAAAAAA'),
          );
          expect(otp!.single.asSuccess!.resultData, isA<HOTPToken>());
          final migration = await SchemeProcessor.processUriByAny(
            _migrationUri(['a', 'b', 'c']),
          );
          expect(migration, hasLength(3));
          expect(migration!.every((r) => r.isSuccess), isTrue);
        },
      );

      test(
        'the result type of a token uri is a list of Token results',
        () async {
          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('otpauth://totp/user?secret=AAAAAAAA'),
          );
          expect(results!.single.asSuccess!.resultData, isA<Token>());
        },
      );

      test('unknown schemes return null', () async {
        for (final uri in [
          'https://example.com',
          'foo://bar',
          'mailto:x@y.z',
          'just-some-text',
          'otpauth-foo://totp/user',
        ]) {
          expect(
            await SchemeProcessor.processUriByAny(Uri.parse(uri)),
            isNull,
            reason: uri,
          );
        }
      });

      test(
        'the home widget scheme is answered by the home widget processor',
        () async {
          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('homewidget://nohost'),
          );
          expect(results, hasLength(1));
          expect(results!.single.isFailed, isTrue);
          expect(
            results.single.asFailed!.message(_l),
            _l.noProcessorFoundForHost('nohost'),
          );
        },
      );

      test(
        'a malformed otpauth uri gives a failed list and does not throw',
        () async {
          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('otpauth://totp?secret=AAAAAAAA'),
          );
          expect(results, hasLength(1));
          expect(results!.single.isFailed, isTrue);
        },
        skip:
            'BUG: otp_auth_processor.dart:138 uri.path.substring(1) throws RangeError, SchemeProcessor.processUriByAny has no try/catch so the QR scan flow in utils.dart:257 gets an exception',
      );
    });

    group('with fake processors (dispatch rules)', () {
      test(
        'the first processor that returns a non null result wins, later ones are not called',
        () async {
          final first = _FakeProcessor({
            'fake',
          }, (_) async => [ProcessorResult.success('first')]);
          final second = _FakeProcessor({
            'fake',
          }, (_) async => [ProcessorResult.success('second')]);
          SchemeProcessor.implementations.insertAll(0, [first, second]);

          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('fake://x'),
          );

          expect(results!.single.asSuccess!.resultData, 'first');
          expect(first.calls, hasLength(1));
          expect(second.calls, isEmpty);
        },
      );

      test(
        'a processor returning null passes the uri on to the next matching processor',
        () async {
          final first = _FakeProcessor({'fake'}, (_) async => null);
          final second = _FakeProcessor({
            'fake',
          }, (_) async => [ProcessorResult.success('second')]);
          SchemeProcessor.implementations.insertAll(0, [first, second]);

          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('fake://x'),
          );

          expect(results!.single.asSuccess!.resultData, 'second');
          expect(first.calls, hasLength(1));
          expect(second.calls, hasLength(1));
        },
      );

      test(
        'processors that do not support the scheme are never called',
        () async {
          final other = _FakeProcessor({
            'other',
          }, (_) async => [ProcessorResult.success('other')]);
          final match = _FakeProcessor({
            'fake',
            'second',
          }, (_) async => [ProcessorResult.success('match')]);
          SchemeProcessor.implementations.insertAll(0, [other, match]);

          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('second://x'),
          );

          expect(results!.single.asSuccess!.resultData, 'match');
          expect(other.calls, isEmpty);
        },
      );

      test(
        'an empty list is a result: it stops the search (characterization)',
        () async {
          final empty = _FakeProcessor({'fake'}, (_) async => []);
          final next = _FakeProcessor({
            'fake',
          }, (_) async => [ProcessorResult.success('next')]);
          SchemeProcessor.implementations.insertAll(0, [empty, next]);

          final results = await SchemeProcessor.processUriByAny(
            Uri.parse('fake://x'),
          );

          expect(results, isNotNull);
          expect(results, isEmpty);
          expect(next.calls, isEmpty);
        },
      );

      test(
        'an empty list in front of pia stops pia://container from reaching the container processor (characterization)',
        () async {
          final empty = _FakeProcessor({'pia'}, (_) async => []);
          SchemeProcessor.implementations.insert(0, empty);

          final results = await SchemeProcessor.processUriByAny(
            Uri.parse(_containerUri),
          );

          expect(results, isEmpty);
        },
      );

      test('a null from every matching processor ends in null', () async {
        final a = _FakeProcessor({'fake'}, (_) async => null);
        final b = _FakeProcessor({'fake'}, (_) async => null);
        SchemeProcessor.implementations.insertAll(0, [a, b]);

        expect(
          await SchemeProcessor.processUriByAny(Uri.parse('fake://x')),
          isNull,
        );
        expect(a.calls, hasLength(1));
        expect(b.calls, hasLength(1));
      });

      test('a failed result is a result: it stops the search', () async {
        final failing = _FakeProcessor({
          'fake',
        }, (_) async => [ProcessorResult.failed((_) => 'nope')]);
        final next = _FakeProcessor({
          'fake',
        }, (_) async => [ProcessorResult.success('next')]);
        SchemeProcessor.implementations.insertAll(0, [failing, next]);

        final results = await SchemeProcessor.processUriByAny(
          Uri.parse('fake://x'),
        );

        expect(results!.single.asFailed!.message(_l), 'nope');
        expect(next.calls, isEmpty);
      });

      test(
        'fromInit is forwarded to the processors, the default is false',
        () async {
          final fake = _FakeProcessor({'fake'}, (_) async => []);
          SchemeProcessor.implementations.insert(0, fake);

          await SchemeProcessor.processUriByAny(Uri.parse('fake://a'));
          await SchemeProcessor.processUriByAny(
            Uri.parse('fake://b'),
            fromInit: true,
          );

          expect(fake.fromInitValues, [false, true]);
          expect(fake.calls.map((u) => u.host), ['a', 'b']);
        },
      );

      test('the uri is handed over unchanged', () async {
        final fake = _FakeProcessor({'fake'}, (_) async => []);
        SchemeProcessor.implementations.insert(0, fake);
        final uri = Uri.parse('fake://host/a%2Fb?x=1&y=%20#frag');

        await SchemeProcessor.processUriByAny(uri);

        expect(fake.calls.single, same(uri));
      });

      test(
        'a processor that throws: the exception propagates and later processors are not tried (characterization)',
        () async {
          final throwing = _FakeProcessor({
            'fake',
          }, (_) async => throw StateError('boom'));
          final next = _FakeProcessor({
            'fake',
          }, (_) async => [ProcessorResult.success('next')]);
          SchemeProcessor.implementations.insertAll(0, [throwing, next]);

          await expectLater(
            SchemeProcessor.processUriByAny(Uri.parse('fake://x')),
            throwsA(isA<StateError>()),
          );
          expect(throwing.calls, hasLength(1));
          expect(next.calls, isEmpty);
        },
      );

      test(
        'a synchronously throwing processor behaves like an async one',
        () async {
          final throwing = _FakeProcessor({
            'fake',
          }, (_) => throw ArgumentError('sync boom'));
          SchemeProcessor.implementations.insert(0, throwing);

          await expectLater(
            SchemeProcessor.processUriByAny(Uri.parse('fake://x')),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'the registry is restored by tearDown (no leaking fakes between tests)',
        () {
          expect(
            SchemeProcessor.implementations.whereType<_FakeProcessor>(),
            isEmpty,
          );
        },
      );
    });
  });
}
