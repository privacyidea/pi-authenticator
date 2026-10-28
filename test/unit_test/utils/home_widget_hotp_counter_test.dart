import 'dart:async';

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

void main() {
  late _FakeTokenRepository repository;

  setUp(() {
    repository = _FakeTokenRepository();
    HomeWidgetUtils.debugTokenRepository = repository;
  });

  tearDown(() => HomeWidgetUtils.debugTokenRepository = null);

  group('HomeWidgetUtils.incrementHotpCounter', () {
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
