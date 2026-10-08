import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/interfaces/riverpod/state_listeners/base_listeners/stream_notifier_listener.dart';
import 'package:privacyidea_authenticator/interfaces/riverpod/state_listeners/state_notifier_provider_listeners/deep_link_listener.dart';
import 'package:privacyidea_authenticator/model/deeplink.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';

import '../../../../utils/riverpod/state_listeners/deep_link_listener_test_helper.dart';

/// [DeepLinkListener] whose handler is injectable.
class _TestDeepLinkListener extends DeepLinkListener {
  const _TestDeepLinkListener({
    required super.provider,
    required super.onNewState,
  }) : super(listenerName: 'TestDeepLinkListener');
}

/// Same handler on the base class, which wraps the handler in a try/catch.
class _TestBaseListener
    extends BuildlessStreamNotifierListener<DeeplinkNotifier, DeepLink> {
  const _TestBaseListener({required super.provider, required super.onNewState})
    : super(listenerName: 'TestBaseListener');
}

void main() {
  final harness = DeepLinkListenerHarness();
  setUp(harness.setUp);
  tearDown(harness.tearDown);
  final pumpHost = harness.pumpHost;
  final deliver = harness.deliver;
  final deliverError = harness.deliverError;

  group('DeepLinkListener.buildListen', () {
    testWidgets(
      'calls onNewState after the frame for every delivered link, in order',
      (tester) async {
        final seen = <Uri>[];
        await pumpHost(
          tester,
          (_) => [
            _TestDeepLinkListener(
              provider: deeplinkProvider,
              onNewState: (ref, previous, next) {
                final value = next.value;
                if (value != null) seen.add(value.uri);
              },
            ),
          ],
        );

        await deliver(tester, Uri.parse('otpauth://hotp/one?secret=AA'));
        await deliver(tester, Uri.parse('otpauth://hotp/two?secret=BB'));

        expect(seen, [
          Uri.parse('otpauth://hotp/one?secret=AA'),
          Uri.parse('otpauth://hotp/two?secret=BB'),
        ]);
      },
    );

    testWidgets('hands over the previous state of the provider', (
      tester,
    ) async {
      final previousUris = <Uri?>[];
      await pumpHost(
        tester,
        (_) => [
          _TestDeepLinkListener(
            provider: deeplinkProvider,
            onNewState: (ref, previous, next) {
              if (next.value != null) previousUris.add(previous?.value?.uri);
            },
          ),
        ],
      );

      await deliver(tester, Uri.parse('otpauth://hotp/one?secret=AA'));
      await deliver(tester, Uri.parse('otpauth://hotp/two?secret=BB'));

      expect(previousUris, [null, Uri.parse('otpauth://hotp/one?secret=AA')]);
    });

    testWidgets('does not call onNewState before the frame has run', (
      tester,
    ) async {
      var calls = 0;
      await pumpHost(
        tester,
        (_) => [
          _TestDeepLinkListener(
            provider: deeplinkProvider,
            onNewState: (ref, previous, next) => calls++,
          ),
        ],
      );
      final callsAfterMount = calls;

      harness.links.add(DeepLink(Uri.parse('otpauth://hotp/one?secret=AA')));
      await tester.idle();
      expect(
        calls,
        callsAfterMount,
        reason: 'the handler is deferred to a post frame callback',
      );

      await tester.pump();
      await tester.pump();
      expect(calls, greaterThan(callsAfterMount));
    });

    testWidgets(
      'a throwing onNewState does not stop the next link from being processed',
      (tester) async {
        final seen = <Uri>[];
        await pumpHost(
          tester,
          (_) => [
            _TestDeepLinkListener(
              provider: deeplinkProvider,
              onNewState: (ref, previous, next) {
                final value = next.value;
                if (value == null) return;
                seen.add(value.uri);
                if (value.uri.host == 'boom')
                  throw StateError('onNewState failed');
              },
            ),
          ],
        );

        await deliver(tester, Uri.parse('otpauth://boom/one?secret=AA'));
        // Characterization: the exception is not swallowed by the listener but
        // handed to the framework. The flutter test binding collects it here.
        expect(tester.takeException(), isA<StateError>());
        await deliver(tester, Uri.parse('otpauth://hotp/two?secret=BB'));

        expect(seen, [
          Uri.parse('otpauth://boom/one?secret=AA'),
          Uri.parse('otpauth://hotp/two?secret=BB'),
        ]);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'BUG: a synchronously throwing onNewState is caught and logged by the listener',
      (tester) async {
        final seen = <Uri>[];
        await pumpHost(
          tester,
          (_) => [
            _TestDeepLinkListener(
              provider: deeplinkProvider,
              onNewState: (ref, previous, next) {
                final value = next.value;
                if (value == null) return;
                seen.add(value.uri);
                if (value.uri.host == 'boom')
                  throw StateError('onNewState failed');
              },
            ),
          ],
        );

        await deliver(tester, Uri.parse('otpauth://boom/one?secret=AA'));
        await deliver(tester, Uri.parse('otpauth://hotp/two?secret=BB'));

        expect(
          tester.takeException(),
          isNull,
          reason:
              'the base listener catches the error, the deep link listener must too',
        );
        expect(
          harness.logOutput.contains(
            printer.Level.error,
            'TestDeepLinkListener',
          ),
          isTrue,
        );
        expect(seen, hasLength(2));
      },
      // BUG: deep_link_listener.dart:41 DeepLinkListener.buildListen overrides the base listener without try/catch, so a throwing onNewState is an unhandled error instead of a logged one
      skip: true,
    );

    testWidgets(
      'the base listener catches and logs a throwing onNewState and keeps processing',
      (tester) async {
        // The behaviour DeepLinkListener should have as well.
        final seen = <Uri>[];
        await pumpHost(
          tester,
          (_) => [
            _TestBaseListener(
              provider: deeplinkProvider,
              onNewState: (ref, previous, next) {
                final value = next.value;
                if (value == null) return;
                seen.add(value.uri);
                if (value.uri.host == 'boom')
                  throw StateError('onNewState failed');
              },
            ),
          ],
        );

        await deliver(tester, Uri.parse('otpauth://boom/one?secret=AA'));
        await deliver(tester, Uri.parse('otpauth://hotp/two?secret=BB'));

        expect(tester.takeException(), isNull);
        expect(
          harness.logOutput.contains(printer.Level.error, 'TestBaseListener'),
          isTrue,
        );
        expect(seen, hasLength(2));
      },
    );

    testWidgets(
      'an error state of the provider reaches onNewState as AsyncError and later links still arrive',
      (tester) async {
        final states = <AsyncValue<DeepLink>>[];
        await pumpHost(
          tester,
          (_) => [
            _TestDeepLinkListener(
              provider: deeplinkProvider,
              onNewState: (ref, previous, next) => states.add(next),
            ),
          ],
        );

        await deliverError(tester);
        await deliver(tester, Uri.parse('otpauth://hotp/after?secret=AA'));

        expect(states.any((s) => s.hasError), isTrue);
        expect(
          states.last.value?.uri,
          Uri.parse('otpauth://hotp/after?secret=AA'),
        );
      },
    );
  });
}
