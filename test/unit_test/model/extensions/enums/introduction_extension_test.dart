import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/introduction_extension.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/battery_optimization_provider.dart';

import '../../../../tests_app_wrapper.mocks.dart';

/// How [batteryOptimizationsIsDisabledProvider] behaves in a test.
enum _Battery { optimizationDisabled, optimizationActive, loading, error }

HOTPToken _hotp(int i) => HOTPToken(
  id: 'hotp$i',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret$i',
);

PushToken _push({bool rolledOut = true, String id = 'push'}) =>
    PushToken(serial: 'serial$id', id: id, isRolledOut: rolledOut);

IntroductionState _completed(Iterable<Introduction> values) =>
    IntroductionState(completedIntroductions: values.toSet());

/// Evaluates [intro] against [state] inside a real widget tree, so that the
/// [WidgetRef] watches real (overridden) providers.
///
/// [tokens] == null keeps the token provider in the loading state.
/// [hidePushTokens] == null keeps the settings provider in the loading state.
Future<bool> _isFulfilled(
  WidgetTester tester,
  Introduction intro,
  IntroductionState state, {
  List<Token>? tokens = const [],
  bool? hidePushTokens = false,
  _Battery battery = _Battery.optimizationDisabled,
}) async {
  final tokenRepo = MockTokenRepository();
  when(tokenRepo.loadTokens()).thenAnswer(
    (_) => tokens == null ? Completer<List<Token>>().future : Future.value(tokens),
  );
  final settingsRepo = MockSettingsRepository();
  when(settingsRepo.loadSettings()).thenAnswer(
    (_) => hidePushTokens == null
        ? Completer<SettingsState>().future
        : Future.value(SettingsState(hidePushTokens: hidePushTokens)),
  );

  bool? result;
  await tester.pumpWidget(
    ProviderScope(
      // A failing provider must not be retried (retries create timers).
      retry: (_, _) => null,
      overrides: [
        tokenProvider.overrideWith(() => TokenNotifier(repoOverride: tokenRepo)),
        settingsProvider.overrideWith(
          () => SettingsNotifier(repoOverride: settingsRepo),
        ),
        batteryOptimizationsIsDisabledProvider.overrideWith(
          (ref) => switch (battery) {
            _Battery.optimizationDisabled => Future.value(true),
            _Battery.optimizationActive => Future.value(false),
            _Battery.loading => Completer<bool>().future,
            _Battery.error => Future<bool>.error(StateError('no battery info')),
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Consumer(
          builder: (context, ref, _) {
            result = intro.isConditionFulfilled(ref, state);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  // Let the async providers finish (no real time passes) and rebuild.
  await tester.pump();
  await tester.pump();
  return result!;
}

void main() {
  group('IntroductionX.isConditionFulfilled', () {
    group('introductionScreen', () {
      testWidgets('is fulfilled while uncompleted', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.introductionScreen, _completed([])),
          isTrue,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.introductionScreen,
            _completed([Introduction.introductionScreen]),
          ),
          isFalse,
        );
      });
    });

    group('scanQrCode', () {
      testWidgets('is fulfilled while uncompleted, independent of other intros', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.scanQrCode, _completed([])),
          isTrue,
        );
        expect(
          await _isFulfilled(
            tester,
            Introduction.scanQrCode,
            _completed([Introduction.introductionScreen]),
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.scanQrCode,
            _completed([Introduction.scanQrCode]),
          ),
          isFalse,
        );
      });
    });

    group('addManually', () {
      testWidgets('needs scanQrCode completed', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.addManually, _completed([])),
          isFalse,
        );
        expect(
          await _isFulfilled(
            tester,
            Introduction.addManually,
            _completed([Introduction.scanQrCode]),
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.addManually,
            _completed([Introduction.scanQrCode, Introduction.addManually]),
          ),
          isFalse,
        );
      });
    });

    group('tokenSwipe', () {
      final ready = _completed([Introduction.scanQrCode, Introduction.addManually]);

      testWidgets('is fulfilled with a token and addManually completed', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.tokenSwipe, ready, tokens: [_hotp(1)]),
          isTrue,
        );
      });
      testWidgets('is not fulfilled without tokens', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.tokenSwipe, ready, tokens: []),
          isFalse,
        );
      });
      testWidgets('is not fulfilled while the tokens are loading', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.tokenSwipe, ready, tokens: null),
          isFalse,
        );
      });
      testWidgets('is not fulfilled without addManually completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.tokenSwipe,
            _completed([Introduction.scanQrCode]),
            tokens: [_hotp(1)],
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.tokenSwipe,
            _completed([
              Introduction.scanQrCode,
              Introduction.addManually,
              Introduction.tokenSwipe,
            ]),
            tokens: [_hotp(1)],
          ),
          isFalse,
        );
      });
    });

    group('editToken', () {
      testWidgets('needs tokenSwipe completed', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.editToken, _completed([])),
          isFalse,
        );
        expect(
          await _isFulfilled(
            tester,
            Introduction.editToken,
            _completed([Introduction.tokenSwipe]),
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.editToken,
            _completed([Introduction.tokenSwipe, Introduction.editToken]),
          ),
          isFalse,
        );
      });
    });

    group('lockToken', () {
      testWidgets('needs editToken completed', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.lockToken, _completed([])),
          isFalse,
        );
        expect(
          await _isFulfilled(
            tester,
            Introduction.lockToken,
            _completed([Introduction.editToken]),
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.lockToken,
            _completed([Introduction.editToken, Introduction.lockToken]),
          ),
          isFalse,
        );
      });
    });

    group('dragToken', () {
      final ready = _completed([Introduction.tokenSwipe]);

      testWidgets('is fulfilled with two tokens and tokenSwipe completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.dragToken,
            ready,
            tokens: [_hotp(1), _hotp(2)],
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled with a single token', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.dragToken, ready, tokens: [_hotp(1)]),
          isFalse,
        );
      });
      testWidgets('is not fulfilled while the tokens are loading', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.dragToken, ready, tokens: null),
          isFalse,
        );
      });
      testWidgets('is not fulfilled without tokenSwipe completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.dragToken,
            _completed([]),
            tokens: [_hotp(1), _hotp(2)],
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.dragToken,
            _completed([Introduction.tokenSwipe, Introduction.dragToken]),
            tokens: [_hotp(1), _hotp(2)],
          ),
          isFalse,
        );
      });
    });

    group('addFolder', () {
      final ready = _completed([Introduction.tokenSwipe, Introduction.dragToken]);
      final threeTokens = [_hotp(1), _hotp(2), _hotp(3)];

      testWidgets('is fulfilled with three tokens and dragToken completed', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.addFolder, ready, tokens: threeTokens),
          isTrue,
        );
      });
      testWidgets('is not fulfilled with two tokens', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.addFolder,
            ready,
            tokens: [_hotp(1), _hotp(2)],
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled while the tokens are loading', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.addFolder, ready, tokens: null),
          isFalse,
        );
      });
      testWidgets('is not fulfilled before dragToken was completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.addFolder,
            _completed([Introduction.tokenSwipe]),
            tokens: threeTokens,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.addFolder,
            _completed([
              Introduction.tokenSwipe,
              Introduction.dragToken,
              Introduction.addFolder,
            ]),
            tokens: threeTokens,
          ),
          isFalse,
        );
      });
    });

    group('pollForChallenges', () {
      final ready = _completed([Introduction.tokenSwipe]);

      testWidgets('is fulfilled with a rolled out push token and tokenSwipe completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            ready,
            tokens: [_push()],
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled if the push token is not rolled out', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            ready,
            tokens: [_push(rolledOut: false)],
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled without any push token', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            ready,
            tokens: [_hotp(1)],
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled while the tokens are loading', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            ready,
            tokens: null,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled without tokenSwipe completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            _completed([]),
            tokens: [_push()],
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            _completed([Introduction.tokenSwipe, Introduction.pollForChallenges]),
            tokens: [_push()],
          ),
          isFalse,
        );
      });
      testWidgets('waits while dragToken is still due (two tokens)', (tester) async {
        final tokens = [_push(), _hotp(1)];
        expect(
          await _isFulfilled(
            tester,
            Introduction.dragToken,
            ready,
            tokens: tokens,
          ),
          isTrue,
          reason: 'precondition: dragToken is due',
        );
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            ready,
            tokens: tokens,
          ),
          isFalse,
        );
      });
      testWidgets('is fulfilled after dragToken was completed (two tokens)', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            _completed([Introduction.tokenSwipe, Introduction.dragToken]),
            tokens: [_push(), _hotp(1)],
          ),
          isTrue,
        );
      });
      testWidgets('waits while addFolder is still due (three tokens)', (tester) async {
        final done = _completed([Introduction.tokenSwipe, Introduction.dragToken]);
        final tokens = [_push(), _hotp(1), _hotp(2)];
        expect(
          await _isFulfilled(tester, Introduction.addFolder, done, tokens: tokens),
          isTrue,
          reason: 'precondition: addFolder is due',
        );
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            done,
            tokens: tokens,
          ),
          isFalse,
        );
      });
      testWidgets('is fulfilled after addFolder was completed (three tokens)', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.pollForChallenges,
            _completed([
              Introduction.tokenSwipe,
              Introduction.dragToken,
              Introduction.addFolder,
            ]),
            tokens: [_push(), _hotp(1), _hotp(2)],
          ),
          isTrue,
        );
      });
    });

    group('hidePushTokens', () {
      final ready = _completed([Introduction.pollForChallenges]);

      testWidgets('is fulfilled when push tokens are hidden and pollForChallenges completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.hidePushTokens,
            ready,
            hidePushTokens: true,
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled while push tokens are not hidden', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.hidePushTokens,
            ready,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled while the settings are loading', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.hidePushTokens,
            ready,
            hidePushTokens: null,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled without pollForChallenges completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.hidePushTokens,
            _completed([]),
            hidePushTokens: true,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.hidePushTokens,
            _completed([Introduction.pollForChallenges, Introduction.hidePushTokens]),
            hidePushTokens: true,
          ),
          isFalse,
        );
      });
    });

    group('exportTokens', () {
      testWidgets('is fulfilled while uncompleted', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.exportTokens, _completed([])),
          isTrue,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.exportTokens,
            _completed([Introduction.exportTokens]),
          ),
          isFalse,
        );
      });
    });

    group('homeWidgetSetUp', () {
      testWidgets('is fulfilled while uncompleted, independent of other intros', (tester) async {
        expect(
          await _isFulfilled(tester, Introduction.homeWidgetSetUp, _completed([])),
          isTrue,
        );
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetSetUp,
            _completed([Introduction.exportTokens]),
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetSetUp,
            _completed([Introduction.homeWidgetSetUp]),
          ),
          isFalse,
        );
      });
    });

    group('homeWidgetBatteryOptimization', () {
      final ready = _completed([Introduction.homeWidgetSetUp]);

      testWidgets('is fulfilled if the battery optimization is still active', (tester) async {
        // The provider reports "is disabled": false means still optimized.
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetBatteryOptimization,
            ready,
            battery: _Battery.optimizationActive,
          ),
          isTrue,
        );
      });
      testWidgets('is not fulfilled if the battery optimization is already disabled', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetBatteryOptimization,
            ready,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled while the battery state is loading', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetBatteryOptimization,
            ready,
            battery: _Battery.loading,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled if the battery state cannot be determined', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetBatteryOptimization,
            ready,
            battery: _Battery.error,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled without homeWidgetSetUp completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetBatteryOptimization,
            _completed([]),
            battery: _Battery.optimizationActive,
          ),
          isFalse,
        );
      });
      testWidgets('is not fulfilled once completed', (tester) async {
        expect(
          await _isFulfilled(
            tester,
            Introduction.homeWidgetBatteryOptimization,
            _completed([
              Introduction.homeWidgetSetUp,
              Introduction.homeWidgetBatteryOptimization,
            ]),
            battery: _Battery.optimizationActive,
          ),
          isFalse,
        );
      });
    });

    testWidgets('no introduction is fulfilled if all are completed', (tester) async {
      for (final intro in Introduction.values) {
        expect(
          await _isFulfilled(
            tester,
            intro,
            IntroductionState.withAllCompleted(),
            tokens: [_push(), _hotp(1), _hotp(2)],
            hidePushTokens: true,
            battery: _Battery.optimizationActive,
          ),
          isFalse,
          reason: '$intro must not be shown again when it is completed',
        );
      }
    });

    testWidgets('IntroductionState.isConditionFulfilled delegates to the extension', (tester) async {
      bool? viaState;
      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Consumer(
              builder: (context, ref, _) {
                viaState = _completed([Introduction.scanQrCode])
                    .isConditionFulfilled(ref, Introduction.addManually);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(viaState, isTrue);
    });
  });

  group('IntroductionX.hintText', () {
    final localizations = AppLocalizationsEn();

    test('introductions without a text return the placeholder', () {
      for (final intro in [
        Introduction.introductionScreen,
        Introduction.exportTokens,
        Introduction.homeWidgetSetUp,
        Introduction.homeWidgetBatteryOptimization,
      ]) {
        expect(intro.hintText(localizations), 'Not implemented', reason: '$intro');
      }
    });

    test('all other introductions return their localized text', () {
      expect(Introduction.scanQrCode.hintText(localizations), localizations.introScanQrCode);
      expect(Introduction.addManually.hintText(localizations), localizations.introAddTokenManually);
      expect(Introduction.tokenSwipe.hintText(localizations), localizations.introTokenSwipe);
      expect(Introduction.editToken.hintText(localizations), localizations.introEditToken);
      expect(Introduction.lockToken.hintText(localizations), localizations.introLockToken);
      expect(Introduction.dragToken.hintText(localizations), localizations.introDragToken);
      expect(Introduction.addFolder.hintText(localizations), localizations.introAddFolder);
      expect(Introduction.pollForChallenges.hintText(localizations), localizations.introPollForChallenges);
      expect(Introduction.hidePushTokens.hintText(localizations), localizations.introHidePushTokens);
      for (final intro in Introduction.values) {
        expect(intro.hintText(localizations), isNotEmpty, reason: '$intro');
      }
    });
  });
}
