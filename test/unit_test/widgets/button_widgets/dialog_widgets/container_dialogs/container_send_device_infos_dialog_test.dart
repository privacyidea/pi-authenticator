import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_send_device_infos_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../../tests_app_wrapper.dart';

void main() {
  group('ContainerSendDeviceInfosDialog Tests (with Wrapper)', () {
    testWidgets('Dialog displays correct titles and content', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: ContainerSendDeviceInfosDialog()),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(ContainerSendDeviceInfosDialog),
      );
      final appLocalizations = AppLocalizations.of(context)!;

      expect(
        find.text(appLocalizations.containerRolloutSendDeviceInfoDialogTitle),
        findsOneWidget,
      );
      expect(
        find.text(appLocalizations.containerRolloutSendDeviceInfoDialogContent),
        findsOneWidget,
      );
      expect(find.text(appLocalizations.no), findsOneWidget);
      expect(find.text(appLocalizations.yes), findsOneWidget);
    });

    testWidgets('Clicking No returns false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ContainerSendDeviceInfosDialog.showDialog();
              },
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));

      await pumpUntilFindNWidgets(
        tester,
        find.byType(ContainerSendDeviceInfosDialog),
        1,
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(ContainerSendDeviceInfosDialog),
      );
      final noLabel = AppLocalizations.of(context)!.no;

      await tester.tap(find.text(noLabel));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.byType(ContainerSendDeviceInfosDialog), findsNothing);
    });

    testWidgets('Clicking Yes returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ContainerSendDeviceInfosDialog.showDialog();
              },
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await pumpUntilFindNWidgets(
        tester,
        find.byType(ContainerSendDeviceInfosDialog),
        1,
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(ContainerSendDeviceInfosDialog),
      );
      final yesLabel = AppLocalizations.of(context)!.yes;

      await tester.tap(find.text(yesLabel));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(ContainerSendDeviceInfosDialog), findsNothing);
    });

    testWidgets('Dialog is not dismissible by tapping barrier', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ContainerSendDeviceInfosDialog.showDialog(),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await pumpUntilFindNWidgets(
        tester,
        find.byType(ContainerSendDeviceInfosDialog),
        1,
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContainerSendDeviceInfosDialog), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(ContainerSendDeviceInfosDialog), findsOneWidget);
    });

    testWidgets('Verify DialogAction structure and intents', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: ContainerSendDeviceInfosDialog()),
      );
      await tester.pumpAndSettle();

      final defaultDialog = tester.widget<DefaultDialog>(
        find.byType(DefaultDialog),
      );

      expect(defaultDialog.actions.length, 2);

      expect(defaultDialog.actions[0].intent, ActionIntent.confirm);
      expect(defaultDialog.actions[1].intent, ActionIntent.confirm);
    });

    testWidgets('Verify button labels match localization', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: ContainerSendDeviceInfosDialog()),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(ContainerSendDeviceInfosDialog),
      );
      final l10n = AppLocalizations.of(context)!;

      expect(
        find.descendant(
          of: find.byType(DefaultDialog),
          matching: find.text(l10n.no),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: find.byType(DefaultDialog),
          matching: find.text(l10n.yes),
        ),
        findsOneWidget,
      );
    });
  });
}
