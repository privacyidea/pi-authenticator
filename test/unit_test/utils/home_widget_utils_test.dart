import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';

/// In-memory token storage; [failNextLoad] makes the next load throw once.
class _FakeTokenRepository implements TokenRepository {
  final Map<String, Token> stored = {};
  bool failNextLoad = false;

  /// If set, every load waits for it, so two loads can be interleaved.
  Completer<void>? loadGate;

  @override
  Future<List<Token>> loadTokens() async {
    await loadGate?.future;
    if (failNextLoad) {
      failNextLoad = false;
      throw StateError('storage broken');
    }
    return stored.values.toList();
  }

  @override
  Future<Token?> loadToken(String id) async => stored[id];

  @override
  Future<List<T>> saveOrReplaceTokens<T extends Token>(List<T> tokens) async {
    for (final token in tokens) {
      stored[token.id] = token;
    }
    return [];
  }

  @override
  Future<bool> saveOrReplaceToken(Token token) async {
    stored[token.id] = token;
    return true;
  }

  @override
  Future<bool> deleteToken(Token token) async => stored.remove(token.id) != null;

  @override
  Future<List<T>> deleteTokens<T extends Token>(List<T> tokens) async => [];
}

HOTPToken _hotp(String id, int counter) => HOTPToken(
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
  counter: counter,
);

/// Tests for [homeWidgetBackgroundCallback] (de-duplication of widget taps)
/// and for [HomeWidgetUtils.incrementHotpCounter].
///
/// The callback talks to the native side through the `home_widget` method
/// channel only (`getWidgetData` / `saveWidgetData`), so the channel is mocked
/// with a tiny in-memory key/value store.
///
/// What happens after the de-duplication (`HomeWidgetProcessor().processUri`)
/// is fire-and-forget and, on non-Android hosts, handled by
/// `UnsupportedHomeWidgetUtils`, so "processed" is observed through the new
/// timestamp that the callback writes back into the store.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  const key = '_lastBackgroundCallback';
  final uriA = Uri.parse('homewidget://show?widgetId=1');
  final uriB = Uri.parse('homewidget://show?widgetId=2');

  late Map<String, Object?> store;
  late List<MethodCall> calls;

  /// All values that were written to the de-duplication key, in order.
  List<String> writes() => calls
      .where(
        (c) => c.method == 'saveWidgetData' && c.arguments['id'] == key,
      )
      .map((c) => c.arguments['data'] as String)
      .toList();

  int microsOf(String stored) => int.parse(stored.split('|').last);

  void seed(Uri uri, Duration age) {
    store[key] =
        '$uri|${DateTime.now().microsecondsSinceEpoch - age.inMicroseconds}';
  }

  setUp(() {
    store = {};
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'getWidgetData':
              return store[call.arguments['id']] ??
                  call.arguments['defaultValue'];
            case 'saveWidgetData':
              final data = call.arguments['data'];
              if (data == null) {
                store.remove(call.arguments['id']);
              } else {
                store[call.arguments['id']] = data;
              }
              return true;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('homeWidgetBackgroundCallback', () {
    test('null uri returns immediately without touching the channel', () async {
      await homeWidgetBackgroundCallback(null);

      expect(calls, isEmpty);
      expect(store, isEmpty);
    });

    test('first call without stored value is processed and remembered', () async {
      final before = DateTime.now().microsecondsSinceEpoch;
      await homeWidgetBackgroundCallback(uriA);
      final after = DateTime.now().microsecondsSinceEpoch;

      final written = writes();
      expect(written, hasLength(1));
      expect(written.single.startsWith('${uriA.toString()}|'), isTrue);
      expect(microsOf(written.single), inInclusiveRange(before, after));
    });

    test('same uri again within the window is dropped and does not extend it', () async {
      await homeWidgetBackgroundCallback(uriA);
      final firstStored = store[key];

      await homeWidgetBackgroundCallback(uriA);

      expect(writes(), hasLength(1), reason: 'duplicate must not be saved');
      expect(store[key], firstStored, reason: 'timestamp must stay unchanged');
    });

    test('same uri seeded 0.5 s ago is dropped', () async {
      seed(uriA, const Duration(milliseconds: 500));
      final seeded = store[key];

      await homeWidgetBackgroundCallback(uriA);

      expect(writes(), isEmpty);
      expect(store[key], seeded);
    });

    test('same uri seeded 2.5 s ago is processed with a fresh timestamp', () async {
      seed(uriA, const Duration(milliseconds: 2500));
      final oldMicros = microsOf(store[key] as String);

      await homeWidgetBackgroundCallback(uriA);

      final written = writes();
      expect(written, hasLength(1));
      expect(written.single.startsWith('${uriA.toString()}|'), isTrue);
      expect(microsOf(written.single), greaterThan(oldMicros));
    });

    test('different uri within the window is processed and replaces the stored one', () async {
      await homeWidgetBackgroundCallback(uriA);
      await homeWidgetBackgroundCallback(uriB);

      final written = writes();
      expect(written, hasLength(2));
      expect(written.last.startsWith('${uriB.toString()}|'), isTrue);
      expect((store[key] as String).startsWith('${uriB.toString()}|'), isTrue);
    });

    test('only the last uri is remembered: A, B, A within the window processes all three', () async {
      await homeWidgetBackgroundCallback(uriA);
      await homeWidgetBackgroundCallback(uriB);
      await homeWidgetBackgroundCallback(uriA);

      expect(writes(), hasLength(3));
    });

    group('corrupt stored value is never treated as duplicate', () {
      final corruptValues = <String, String>{
        'no separator at all': 'garbage',
        'uri only without separator': uriA.toString(),
        'non numeric time': '$uriA|abc',
        'empty time': '$uriA|',
        'only a separator': '|',
        'empty string': '',
        'too many parts': '$uriA|123|456',
      };
      for (final entry in corruptValues.entries) {
        test(entry.key, () async {
          store[key] = entry.value;

          await homeWidgetBackgroundCallback(uriA);

          final written = writes();
          expect(written, hasLength(1));
          expect(written.single.startsWith('${uriA.toString()}|'), isTrue);
          expect(
            int.tryParse(written.single.split('|').last),
            isNotNull,
            reason: 'corrupt value must be replaced with a valid one',
          );
        });
      }

      test('corrupt value self-heals: the next identical call is dropped', () async {
        store[key] = 'garbage';

        await homeWidgetBackgroundCallback(uriA);
        await homeWidgetBackgroundCallback(uriA);

        expect(writes(), hasLength(1));
      });
    });

    group('uri containing a pipe character', () {
      final uriWithPipe = Uri.parse('homewidget://show?widgetId=1&x=a|b');

      test('pipe is percent encoded so the stored value keeps exactly two parts', () async {
        await homeWidgetBackgroundCallback(uriWithPipe);

        final stored = store[key] as String;
        expect(stored.split('|'), hasLength(2));
        expect(stored.startsWith('${uriWithPipe.toString()}|'), isTrue);
      });

      test('duplicate detection still works for such an uri', () async {
        await homeWidgetBackgroundCallback(uriWithPipe);
        await homeWidgetBackgroundCallback(uriWithPipe);

        expect(writes(), hasLength(1));
      });

      test('uri that differs only in the pipe part is not a duplicate', () async {
        await homeWidgetBackgroundCallback(uriWithPipe);
        await homeWidgetBackgroundCallback(
          Uri.parse('homewidget://show?widgetId=1&x=a'),
        );

        expect(writes(), hasLength(2));
      });
    });

    group('uris that the processor rejects', () {
      final rejected = <String, Uri>{
        'foreign scheme': Uri.parse('https://example.com/show?widgetId=1'),
        'unknown host': Uri.parse('homewidget://unknown?widgetId=1'),
        'missing widgetId': Uri.parse('homewidget://show'),
      };
      for (final entry in rejected.entries) {
        test('${entry.key} completes without throwing and is still remembered', () async {
          await expectLater(homeWidgetBackgroundCallback(entry.value), completes);
          // Let the fire-and-forget processor future finish; an error in it
          // would surface as an unhandled exception and fail this test.
          await Future<void>.delayed(Duration.zero);

          expect(writes(), hasLength(1));
        });
      }
    });

    test('a stored timestamp in the future (clock moved backwards) does not suppress taps', () async {
      seed(uriA, const Duration(hours: -1));

      await homeWidgetBackgroundCallback(uriA);

      expect(writes(), hasLength(1));
    });

    test('SUSPECTED BUG: two concurrent identical callbacks must only be processed once', () async {
      // Check-then-act on the stored value is not atomic: both calls read the
      // (empty) store before either of them wrote, so both are processed.
      await Future.wait([
        homeWidgetBackgroundCallback(uriA),
        homeWidgetBackgroundCallback(uriA),
      ]);

      expect(writes(), hasLength(1));
    }, skip: 'BUG: lib/utils/home_widget_utils.dart:68-90 read-then-write of _lastBackgroundCallback is not atomic, concurrent duplicates both pass');
  });

  _testIncrementHotpCounter();
}

void _testIncrementHotpCounter() {
  group('HomeWidgetUtils.incrementHotpCounter', () {
    late _FakeTokenRepository repository;

    setUp(() {
      repository = _FakeTokenRepository();
      HomeWidgetUtils.debugTokenRepository = repository;
    });

    tearDown(() => HomeWidgetUtils.debugTokenRepository = null);

    test('raises the stored counter by one and returns the token', () async {
      repository.stored['h'] = _hotp('h', 5);

      final token = await HomeWidgetUtils.incrementHotpCounter('h');

      expect(token?.counter, 6);
      expect((repository.stored['h'] as HOTPToken).counter, 6);
    });

    test('two taps at the same time count two steps', () async {
      repository.stored['h'] = _hotp('h', 5);
      repository.loadGate = Completer<void>();

      final first = HomeWidgetUtils.incrementHotpCounter('h');
      final second = HomeWidgetUtils.incrementHotpCounter('h');
      await pumpEventQueue();
      repository.loadGate!.complete();
      await Future.wait([first, second]);

      expect((repository.stored['h'] as HOTPToken).counter, 7);
    });

    test('a storage error does not block the next tap', () async {
      repository.stored['h'] = _hotp('h', 5);
      repository.failNextLoad = true;
      await expectLater(
        HomeWidgetUtils.incrementHotpCounter('h'),
        throwsStateError,
      );

      var completed = false;
      unawaited(
        HomeWidgetUtils.incrementHotpCounter('h').then((_) => completed = true),
      );
      await pumpEventQueue();

      expect(completed, isTrue, reason: 'the failed tap must release the lock');
      expect((repository.stored['h'] as HOTPToken).counter, 6);
    });

    test('a token that is gone returns null and blocks nothing', () async {
      repository.stored['other'] = _hotp('other', 1);

      expect(await HomeWidgetUtils.incrementHotpCounter('gone'), isNull);
      expect(
        (await HomeWidgetUtils.incrementHotpCounter('other'))?.counter,
        2,
      );
    });

    test('a token that is not HOTP is left alone', () async {
      repository.stored['t'] = TOTPToken(
        id: 't',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
        period: 30,
      );

      expect(await HomeWidgetUtils.incrementHotpCounter('t'), isNull);
    });
  });
}
