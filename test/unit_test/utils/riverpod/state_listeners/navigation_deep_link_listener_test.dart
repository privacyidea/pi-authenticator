import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/navigation_scheme_processors/navigation_scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_listeners/navigation_deep_link_listener.dart';

import 'deep_link_listener_test_helper.dart';

/// A navigation processor for the scheme `unit`; throws for the host `boom`.
class _FakeNavigationProcessor implements NavigationSchemeProcessor {
  final List<({Uri uri, bool fromInit, bool hadContext})> calls = [];

  @override
  Set<String> get supportedSchemes => {'unit'};

  @override
  Future<List<ProcessorResult<dynamic>>?> processUri(
    Uri uri, {
    BuildContext? context,
    bool fromInit = false,
  }) async {
    calls.add((uri: uri, fromInit: fromInit, hadContext: context != null));
    if (uri.host == 'boom') throw StateError('processUri failed');
    return null;
  }
}

void main() {
  final harness = DeepLinkListenerHarness();
  setUp(harness.setUp);
  tearDown(harness.tearDown);
  final pumpHost = harness.pumpHost;
  final deliver = harness.deliver;

  group('NavigationDeepLinkListener', () {
    late _FakeNavigationProcessor processor;
    late Set<NavigationSchemeProcessor> originalImplementations;

    setUp(() {
      processor = _FakeNavigationProcessor();
      originalImplementations = NavigationSchemeProcessor.implementations;
      NavigationSchemeProcessor.implementations = {
        ...originalImplementations,
        processor,
      };
    });

    tearDown(
      () => NavigationSchemeProcessor.implementations = originalImplementations,
    );

    testWidgets(
      'hands links of a supported scheme to the navigation processor with context and fromInit',
      (tester) async {
        await pumpHost(
          tester,
          (context) => [
            NavigationDeepLinkListener(
              provider: deeplinkProvider,
              context: context,
            ),
          ],
        );

        await deliver(tester, Uri.parse('unit://first'));
        await deliver(tester, Uri.parse('unit://second'), fromInit: true);

        expect(processor.calls.map((c) => c.uri), [
          Uri.parse('unit://first'),
          Uri.parse('unit://second'),
        ]);
        expect(processor.calls.map((c) => c.fromInit), [false, true]);
        expect(processor.calls.every((c) => c.hadContext), isTrue);
      },
    );

    testWidgets('does not call the processor for an unsupported scheme', (
      tester,
    ) async {
      await pumpHost(
        tester,
        (context) => [
          NavigationDeepLinkListener(
            provider: deeplinkProvider,
            context: context,
          ),
        ],
      );

      await deliver(tester, Uri.parse('otpauth://hotp/one?secret=AA'));

      expect(processor.calls, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'a throwing processor is logged and the next link is still processed',
      (tester) async {
        await pumpHost(
          tester,
          (context) => [
            NavigationDeepLinkListener(
              provider: deeplinkProvider,
              context: context,
            ),
          ],
        );

        await deliver(tester, Uri.parse('unit://boom'));
        await deliver(tester, Uri.parse('unit://after'));

        expect(tester.takeException(), isNull);
        expect(processor.calls.map((c) => c.uri.host), ['boom', 'after']);
        expect(
          harness.logOutput.count(
            printer.Level.error,
            '[NavigationDeepLinkListener] Failed to process uri: unit://boom',
          ),
          1,
        );
      },
    );
  });
}
