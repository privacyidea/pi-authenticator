import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_listeners/home_widget_deep_link_listener.dart';

import 'deep_link_listener_test_helper.dart';

void main() {
  final harness = DeepLinkListenerHarness();
  setUp(harness.setUp);
  tearDown(harness.tearDown);
  final pumpHost = harness.pumpHost;
  final deliver = harness.deliver;

  group('HomeWidgetDeepLinkListener', () {
    testWidgets('processes homewidget links and logs them with the fromInit flag', (
      tester,
    ) async {
      await pumpHost(
        tester,
        (_) => [HomeWidgetDeepLinkListener(provider: deeplinkProvider)],
      );

      await deliver(tester, Uri.parse('homewidget://show?widgetId=7'));
      await deliver(
        tester,
        Uri.parse('homewidget://copy?widgetId=8'),
        fromInit: true,
      );

      expect(
        harness.logOutput.contains(
          printer.Level.debug,
          '[HomeWidgetDeepLinkListener] Processing uri: homewidget://show?widgetId=7 (fromInit: false)',
        ),
        isTrue,
      );
      expect(
        harness.logOutput.contains(
          printer.Level.debug,
          '[HomeWidgetDeepLinkListener] Processing uri: homewidget://copy?widgetId=8 (fromInit: true)',
        ),
        isTrue,
      );
      expect(
        harness.logOutput.events.where((e) => e.level == printer.Level.error),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'links of an unknown host or scheme neither throw nor stop later links',
      (tester) async {
        await pumpHost(
          tester,
          (_) => [HomeWidgetDeepLinkListener(provider: deeplinkProvider)],
        );

        await deliver(tester, Uri.parse('homewidget://unknownhost?widgetId=7'));
        await deliver(tester, Uri.parse('otpauth://hotp/one?secret=AA'));
        await deliver(tester, Uri.parse('homewidget://show?widgetId=9'));

        expect(
          harness.logOutput.count(
            printer.Level.debug,
            '[HomeWidgetDeepLinkListener] Processing uri',
          ),
          3,
        );
        expect(
          harness.logOutput.contains(
            printer.Level.debug,
            'homewidget://show?widgetId=9',
          ),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
