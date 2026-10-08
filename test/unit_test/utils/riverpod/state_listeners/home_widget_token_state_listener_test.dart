import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_listeners/home_widget_token_state_listener.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

/// IMPORTANT LIMITATION
///
/// `HomeWidgetTokenStateListener._onNewState` collects the tokens that changed
/// and hands them to `HomeWidgetUtils().updateTokensIfLinked(...)`. On every
/// host except Android `HomeWidgetUtils()` returns a fresh
/// `UnsupportedHomeWidgetUtils` whose methods are no-ops, and there is no
/// injection point, so the list that is passed on is NOT observable from a
/// unit test. Which tokens trigger an update (issuer/label/lock/HOTP counter),
/// and the suspected gap that `HomeWidgetUtils.updateTokensIfLinked` only
/// handles `HOTPToken`s (so TOTP/DayPassword label or lock changes never reach
/// the widget), can therefore not be asserted here without a lib seam.
///
/// What these tests do verify against the real listener:
///  * its wiring (name, callback, provider handling),
///  * that every kind of state transition is processed without throwing,
///  * the `TokenState.lastlyUpdatedTokens` contract the listener relies on.
class _EmitTokenNotifier extends TokenNotifier {
  @override
  Future<TokenState> build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) async => const TokenState(tokens: []);

  void emit(TokenState s) => state = AsyncData(s);
  void emitLoading() => state = const AsyncLoading<TokenState>();
  void emitError() =>
      state = AsyncError<TokenState>(Exception('boom'), StackTrace.current);
}

HOTPToken _hotp({
  String id = 'hotp',
  String label = 'label',
  String issuer = 'issuer',
  int counter = 0,
  bool isLocked = false,
}) => HOTPToken(
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'JBSWY3DPEHPK3PXP',
  label: label,
  issuer: issuer,
  counter: counter,
  isLocked: isLocked,
);

TOTPToken _totp({
  String id = 'totp',
  String label = 'label',
  String issuer = 'issuer',
  bool isLocked = false,
}) => TOTPToken(
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'JBSWY3DPEHPK3PXP',
  period: 30,
  label: label,
  issuer: issuer,
  isLocked: isLocked,
);

DayPasswordToken _day({
  String id = 'day',
  String label = 'label',
  bool isLocked = false,
}) => DayPasswordToken(
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'JBSWY3DPEHPK3PXP',
  period: const Duration(hours: 24),
  label: label,
  isLocked: isLocked,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// `WidgetRef` is sealed, so a real one is captured from a pumped Consumer.
  /// `_onNewState` does not use it.
  Future<WidgetRef> pumpRef(WidgetTester tester) async {
    late WidgetRef captured;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            captured = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  group('wiring', () {
    test('has the expected listener name and a callback', () {
      final listener = HomeWidgetTokenStateListener(provider: null);

      expect(listener.listenerName, 'HomeWidgetUtils().updateTokensIfLinked');
      expect(listener.onNewState, isNotNull);
    });

    testWidgets('buildListen without a provider is a no-op', (tester) async {
      final listener = HomeWidgetTokenStateListener(provider: null);
      final ref = await pumpRef(tester);

      expect(() => listener.buildListen(ref), returnsNormally);
    });
  });

  group('onNewState processes any transition without throwing', () {
    late void Function(
      AsyncValue<TokenState>? previous,
      AsyncValue<TokenState> next,
    )
    call;

    /// Registers a testWidgets that provides [call] with a real ref.
    void scenario(String name, void Function() body) {
      testWidgets(name, (tester) async {
        final listener = HomeWidgetTokenStateListener(provider: null);
        final ref = await pumpRef(tester);
        call = (previous, next) => listener.onNewState!(previous, next, ref);
        body();
      });
    }

    AsyncValue<TokenState> data(
      List<Token> tokens, {
      List<Token>? lastlyUpdated,
    }) => AsyncData(TokenState(tokens: tokens, lastlyUpdatedTokens: lastlyUpdated));

    scenario('first state (previous == null)', () {
      expect(() => call(null, data([_hotp(), _totp(), _day()])), returnsNormally);
    });

    scenario('previous is loading', () {
      expect(
        () => call(const AsyncLoading<TokenState>(), data([_hotp()])),
        returnsNormally,
      );
    });

    scenario('previous is an error', () {
      expect(
        () => call(
          AsyncError<TokenState>(Exception('x'), StackTrace.current),
          data([_hotp()]),
        ),
        returnsNormally,
      );
    });

    scenario('next is loading (value == null)', () {
      expect(
        () => call(data([_hotp()]), const AsyncLoading<TokenState>()),
        returnsNormally,
      );
    });

    scenario('next is an error (value == null)', () {
      expect(
        () => call(
          data([_hotp()]),
          AsyncError<TokenState>(Exception('x'), StackTrace.current),
        ),
        returnsNormally,
      );
    });

    scenario('empty previous and empty next', () {
      expect(() => call(data([]), data([])), returnsNormally);
    });

    scenario('HOTP counter change', () {
      expect(
        () => call(data([_hotp(counter: 1)]), data([_hotp(counter: 2)])),
        returnsNormally,
      );
    });

    scenario('issuer, label and lock changes of HOTP, TOTP and DayPassword tokens', () {
      final before = [_hotp(), _totp(), _day()];
      final after = [
        _hotp(issuer: 'new', label: 'new', isLocked: true),
        _totp(issuer: 'new', label: 'new', isLocked: true),
        _day(label: 'new', isLocked: true),
      ];
      expect(() => call(data(before), data(after)), returnsNormally);
    });

    scenario('updated token that is not in the previous state (new token)', () {
      expect(
        () => call(data([_hotp(id: 'a')]), data([_hotp(id: 'a'), _hotp(id: 'b')], lastlyUpdated: [_hotp(id: 'b')])),
        returnsNormally,
      );
    });

    scenario('previous token has a different type than the next one with the same id', () {
      expect(
        () => call(data([_hotp(id: 'x')]), data([_totp(id: 'x')])),
        returnsNormally,
      );
    });

    scenario('nothing changed', () {
      final tokens = [_hotp(), _totp()];
      expect(() => call(data(tokens), data(tokens)), returnsNormally);
    });

    scenario('removal only (lastlyUpdatedTokens empty)', () {
      final tokens = [_hotp(), _totp()];
      final next = TokenState(tokens: tokens).withoutToken(tokens.first);
      expect(() => call(data(tokens), AsyncData(next)), returnsNormally);
    });
  });

  group('wired to a provider', () {
    Future<_EmitTokenNotifier> pumpListener(WidgetTester tester) async {
      final listener = HomeWidgetTokenStateListener(provider: tokenProvider);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [tokenProvider.overrideWith(_EmitTokenNotifier.new)],
          child: Consumer(
            builder: (context, ref, _) {
              listener.buildListen(ref);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Consumer)),
      );
      return container.read(tokenProvider.notifier) as _EmitTokenNotifier;
    }

    testWidgets('survives a sequence of real provider emissions', (tester) async {
      final notifier = await pumpListener(tester);

      notifier.emit(TokenState(tokens: [_hotp(counter: 1), _totp()]));
      await tester.pump();
      notifier.emit(
        TokenState(tokens: [_hotp(counter: 2), _totp()]).withToken(_day()),
      );
      await tester.pump();
      notifier.emitLoading();
      await tester.pump();
      notifier.emitError();
      await tester.pump();
      notifier.emit(TokenState(tokens: [_hotp(counter: 3)]));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('TokenState.lastlyUpdatedTokens contract used by the listener', () {
    test('defaults to all tokens (a freshly loaded state updates every widget)', () {
      final tokens = [_hotp(), _totp()];

      expect(TokenState(tokens: tokens).lastlyUpdatedTokens, tokens);
    });

    test('removing a token reports no updated tokens', () {
      final state = TokenState(tokens: [_hotp(), _totp()]);

      expect(state.withoutToken(_hotp()).lastlyUpdatedTokens, isEmpty);
    });

    test('replacing a token reports exactly that token', () {
      final state = TokenState(tokens: [_hotp(counter: 1), _totp()]);
      final replaced = _hotp(counter: 2);

      expect(state.addOrReplaceToken(replaced).lastlyUpdatedTokens, [replaced]);
    });
  });
}
