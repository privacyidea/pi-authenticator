import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_listeners/token_deep_link_listener.dart';

import 'deep_link_listener_test_helper.dart';

void main() {
  final harness = DeepLinkListenerHarness();
  setUp(harness.setUp);
  tearDown(harness.tearDown);
  final pumpHost = harness.pumpHost;
  final deliver = harness.deliver;
  final deliverError = harness.deliverError;

  group('TokenImportDeepLinkListener', () {
    testWidgets('forwards each link to TokenNotifier.handleLink', (
      tester,
    ) async {
      await pumpHost(
        tester,
        (_) => [TokenImportDeepLinkListener(provider: deeplinkProvider)],
      );

      await deliver(tester, Uri.parse('otpauth://hotp/one?secret=AA'));
      await deliver(
        tester,
        Uri.parse('otpauth://hotp/two?secret=BB'),
        fromInit: true,
      );

      expect(harness.tokenNotifier.handled, [
        Uri.parse('otpauth://hotp/one?secret=AA'),
        Uri.parse('otpauth://hotp/two?secret=BB'),
      ]);
      expect(
        harness.logOutput.contains(
          printer.Level.debug,
          '[TokenImportDeepLinkListener] Processing uri',
        ),
        isTrue,
      );
      expect(
        harness.logOutput.contains(printer.Level.debug, '(fromInit: true)'),
        isTrue,
      );
    });

    testWidgets(
      'a throwing handleLink is logged and the next link is still processed',
      (tester) async {
        await pumpHost(
          tester,
          (_) => [TokenImportDeepLinkListener(provider: deeplinkProvider)],
        );

        await deliver(tester, Uri.parse('otpauth://boom/one?secret=AA'));
        await deliver(tester, Uri.parse('otpauth://hotp/two?secret=BB'));

        expect(tester.takeException(), isNull);
        expect(harness.tokenNotifier.handled.map((e) => e.host), [
          'boom',
          'hotp',
        ]);
        expect(
          harness.logOutput.count(
            printer.Level.error,
            '[TokenImportDeepLinkListener] Failed to process uri',
          ),
          1,
        );
      },
    );

    testWidgets('does not call handleLink for the loading and error states', (
      tester,
    ) async {
      await pumpHost(
        tester,
        (_) => [TokenImportDeepLinkListener(provider: deeplinkProvider)],
      );

      await deliverError(tester);

      expect(harness.tokenNotifier.handled, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });
}
