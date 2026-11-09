import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/views/import_tokens_view/import_tokens_view.dart';

import '../../../tests_app_wrapper.dart';
import '../../../tests_app_wrapper.mocks.dart';

HOTPToken _token(String id) => HOTPToken(
  id: id,
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$id',
);

/// Pumps an app that already holds the [stored] tokens and whose token storage
/// fails for every token in [failing], and returns a ref into it.
Future<WidgetRef> _pumpApp(
  WidgetTester tester,
  Set<String> failing, {
  List<Token> stored = const [],
}) async {
  final repo = MockTokenRepository();
  when(repo.loadTokens()).thenAnswer((_) async => stored);
  when(repo.saveOrReplaceTokens(any)).thenAnswer(
    (invocation) async => (invocation.positionalArguments[0] as List<Token>)
        .where((t) => failing.contains(t.id))
        .toList(),
  );
  late WidgetRef ref;
  await tester.pumpWidget(
    TestsAppWrapper(
      overrides: [
        tokenProvider.overrideWith(() => TokenNotifier(repoOverride: repo)),
      ],
      child: Consumer(
        builder: (context, widgetRef, _) {
          ref = widgetRef;
          return const SizedBox();
        },
      ),
    ),
  );
  return ref;
}

void main() {
  group('saveImportedTokens', () {
    testWidgets('reports the tokens that could not be saved', (tester) async {
      final ref = await _pumpApp(tester, {'b'});

      final saved = await saveImportedTokens(ref, [_token('a'), _token('b')]);

      expect(saved, isTrue, reason: 'one of the two tokens was saved');
      final shown = ref.read(statusProvider).current;
      expect(shown, isNotNull);
      expect(shown!.message(AppLocalizationsEn()), AppLocalizationsEn().importFailedToken(1));
    });

    testWidgets('says nothing was saved when no token could be', (tester) async {
      final ref = await _pumpApp(tester, {'a'});

      expect(await saveImportedTokens(ref, [_token('a')]), isFalse);
    });

    testWidgets('shows no message when every token was saved', (tester) async {
      final ref = await _pumpApp(tester, {});

      expect(await saveImportedTokens(ref, [_token('a')]), isTrue);
      expect(ref.read(statusProvider).current, isNull);
    });

    testWidgets('ignores a stored token that fails to save again', (tester) async {
      final ref = await _pumpApp(tester, {'stored'}, stored: [_token('stored')]);

      expect(await saveImportedTokens(ref, [_token('a')]), isTrue);
      expect(ref.read(statusProvider).current, isNull);
    });

    testWidgets('counts only the imported tokens that could not be saved', (tester) async {
      final ref = await _pumpApp(
        tester,
        {'stored', 'a'},
        stored: [_token('stored')],
      );

      expect(await saveImportedTokens(ref, [_token('a')]), isFalse);
      final shown = ref.read(statusProvider).current;
      expect(shown, isNotNull);
      expect(shown!.message(AppLocalizationsEn()), AppLocalizationsEn().importFailedToken(1));
    });
  });
}
