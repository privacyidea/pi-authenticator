import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/model/deeplink.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_listeners/token_container_deep_link_listener.dart';

import 'deep_link_listener_test_helper.dart';

void main() {
  final harness = DeepLinkListenerHarness();
  setUp(harness.setUp);
  tearDown(harness.tearDown);
  final pumpHost = harness.pumpHost;
  final deliver = harness.deliver;

  group('TokenContainerDeepLinkListener', () {
    final containerUri = Uri.parse(
      'pia://container/SMPH00067A2F?issuer=privacyIDEA',
    );

    testWidgets(
      'passes the processor results of a container link to the container notifier',
      (tester) async {
        await pumpHost(
          tester,
          (_) => [TokenContainerDeepLinkListener(provider: deeplinkProvider)],
        );

        await deliver(tester, containerUri);

        expect(harness.containerNotifier.handled, hasLength(1));
        expect(harness.containerNotifier.handled.single, hasLength(1));
        // the uri lacks required arguments, so the processor reports a failure instead of throwing
        expect(
          harness.containerNotifier.handled.single.single.isFailed,
          isTrue,
        );
      },
    );

    testWidgets('ignores links of other schemes and other hosts', (
      tester,
    ) async {
      await pumpHost(
        tester,
        (_) => [TokenContainerDeepLinkListener(provider: deeplinkProvider)],
      );

      await deliver(tester, Uri.parse('otpauth://hotp/one?secret=AA'));
      await deliver(tester, Uri.parse('pia://other/SMPH00067A2F'));

      expect(harness.containerNotifier.handled, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'BUG: a throwing handleProcessorResults is logged by the listener and the next link is still processed',
      (tester) async {
        harness.containerNotifier.throwOnHandle = true;
        await pumpHost(
          tester,
          (_) => [TokenContainerDeepLinkListener(provider: deeplinkProvider)],
        );

        await deliver(tester, containerUri);
        harness.containerNotifier.throwOnHandle = false;
        await deliver(
          tester,
          Uri.parse('pia://container/SMPH00067A2F2?issuer=privacyIDEA'),
        );

        expect(harness.containerNotifier.handled, hasLength(2));
        expect(
          tester.takeException(),
          isNull,
          reason: 'the error must not escape the listener',
        );
        expect(
          harness.logOutput.count(
            printer.Level.error,
            '[TokenContainerDeepLinkListener] Failed to process uri',
          ),
          1,
        );
      },
      // BUG: token_container_deep_link_listener.dart:40 handleProcessorResults is not awaited inside the try/catch, so its errors are neither caught nor logged by the listener (they escape as unhandled errors)
      skip: true,
    );

    testWidgets(
      'skips handleProcessorResults when the widget was unmounted while processing',
      (tester) async {
        await pumpHost(tester, (_) => const []);
        final staleRef = harness.lastRef;
        await tester.pumpWidget(const SizedBox());
        expect(staleRef.context.mounted, isFalse);

        final listener = TokenContainerDeepLinkListener(
          provider: deeplinkProvider,
        );
        listener.onNewState(staleRef, null, AsyncData(DeepLink(containerUri)));
        await tester.pump();
        await tester.pump();

        expect(harness.containerNotifier.handled, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'calls handleProcessorResults when the widget is still mounted (control for the unmounted case)',
      (tester) async {
        await pumpHost(tester, (_) => const []);
        expect(harness.lastRef.context.mounted, isTrue);

        final listener = TokenContainerDeepLinkListener(
          provider: deeplinkProvider,
        );
        listener.onNewState(
          harness.lastRef,
          null,
          AsyncData(DeepLink(containerUri)),
        );
        await tester.pump();
        await tester.pump();

        expect(harness.containerNotifier.handled, hasLength(1));
      },
    );
  });
}
