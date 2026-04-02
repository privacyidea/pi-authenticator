/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/status_colors.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_show_url_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../../tests_app_wrapper.dart';

TokenContainer createMockContainer({
  required String url,
  bool sslVerify = true,
}) {
  return TokenContainer.finalized(
    serial: 'PI_CON_TEST',
    issuer: 'privacyIDEA',
    nonce: 'nonce_123',
    timestamp: DateTime.now(),
    serverUrl: Uri.parse(url),
    ecKeyAlgorithm: EcKeyAlgorithm.prime256v1,
    hashAlgorithm: Algorithms.SHA256,
    sslVerify: sslVerify,
    publicClientKey: 'pub',
    privateClientKey: 'priv',
  );
}

void main() {
  const String testUrl = 'https://pi.example.com';
  group('ContainerShowContainerUrlDialog - Structural Tests', () {
    testWidgets('Displays the server URL in the content', (tester) async {
      final container = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(child: ContainerShowContainerUrlDialog(container)),
      );
      await tester.pumpAndSettle();
      final context = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final l10n = AppLocalizations.of(context)!;
      expect(
        find.text(l10n.showContainerUrlDialogContent(testUrl)),
        findsOneWidget,
      );
    });

    testWidgets('Displays cancel and ok buttons with correct labels', (
      tester,
    ) async {
      final container = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(child: ContainerShowContainerUrlDialog(container)),
      );
      await tester.pumpAndSettle();
      final context = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final l10n = AppLocalizations.of(context)!;
      expect(
        find.descendant(
          of: find.byType(DefaultDialog),
          matching: find.text(l10n.cancel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(DefaultDialog),
          matching: find.text(l10n.ok),
        ),
        findsOneWidget,
      );
    });
  });
  group('ContainerShowContainerUrlDialog - SSL Warning Logic', () {
    testWidgets('Does NOT show warning icons or text when sslVerify is true', (
      tester,
    ) async {
      final container = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(child: ContainerShowContainerUrlDialog(container)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      final context = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.showContainerUrlDialogSslWarning), findsNothing);
    });

    testWidgets(
      'Shows warning icons and warning text when sslVerify is false',
      (tester) async {
        final container = createMockContainer(url: testUrl, sslVerify: false);
        await tester.pumpWidget(
          TestsAppWrapper(child: ContainerShowContainerUrlDialog(container)),
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
        final context = tester.element(
          find.byType(ContainerShowContainerUrlDialog),
        );
        final l10n = AppLocalizations.of(context)!;
        expect(
          find.text(l10n.showContainerUrlDialogSslWarning),
          findsOneWidget,
        );
      },
    );

    testWidgets('Uses warning color from theme extension StatusColors', (
      tester,
    ) async {
      final container = createMockContainer(url: testUrl, sslVerify: false);
      await tester.pumpWidget(
        TestsAppWrapper(child: ContainerShowContainerUrlDialog(container)),
      );
      await tester.pumpAndSettle();
      final context = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final warningColor = Theme.of(context).extension<StatusColors>()!.warning;
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.warning_amber_rounded).first,
      );
      expect(icon.color, warningColor);
      final warningText = tester.widget<Text>(
        find.text(
          AppLocalizations.of(context)!.showContainerUrlDialogSslWarning,
        ),
      );
      expect(warningText.style?.color, warningColor);
    });
  });
  group('ContainerShowContainerUrlDialog - Interaction Tests', () {
    testWidgets('Returns false when cancel is pressed', (tester) async {
      bool? result;
      final container = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ContainerShowContainerUrlDialog.showDialog(
                  container,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await pumpUntilFindNWidgets(
        tester,
        find.byType(ContainerShowContainerUrlDialog),
        1,
      );
      await tester.pumpAndSettle();
      final context = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final cancelLabel = AppLocalizations.of(context)!.cancel;
      await tester.tap(find.text(cancelLabel));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('Returns true when OK is pressed', (tester) async {
      bool? result;
      final container = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ContainerShowContainerUrlDialog.showDialog(
                  container,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await pumpUntilFindNWidgets(
        tester,
        find.byType(ContainerShowContainerUrlDialog),
        1,
      );
      await tester.pumpAndSettle();
      final context = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final okLabel = AppLocalizations.of(context)!.ok;
      await tester.tap(find.text(okLabel));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('Dialog is not dismissible by tapping the barrier', (
      tester,
    ) async {
      final container = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  ContainerShowContainerUrlDialog.showDialog(container),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await pumpUntilFindNWidgets(
        tester,
        find.byType(ContainerShowContainerUrlDialog),
        1,
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(ContainerShowContainerUrlDialog), findsOneWidget);
    });
  });
  group('ContainerShowContainerUrlDialog - Layout Tests', () {
    testWidgets('Title alignment changes based on sslVerify', (tester) async {
      final containerOk = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(child: ContainerShowContainerUrlDialog(containerOk)),
      );
      await tester.pumpAndSettle();
      final contextOk = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final titleTextOk = AppLocalizations.of(
        contextOk,
      )!.showContainerUrlDialogTitle;
      final Row titleRowOk = tester.widget(
        find
            .ancestor(of: find.text(titleTextOk), matching: find.byType(Row))
            .first,
      );
      expect(titleRowOk.mainAxisAlignment, MainAxisAlignment.start);
      final containerWarn = createMockContainer(url: testUrl, sslVerify: false);
      await tester.pumpWidget(
        TestsAppWrapper(child: ContainerShowContainerUrlDialog(containerWarn)),
      );
      await tester.pumpAndSettle();
      final contextWarn = tester.element(
        find.byType(ContainerShowContainerUrlDialog),
      );
      final titleTextWarn = AppLocalizations.of(
        contextWarn,
      )!.showContainerUrlDialogTitle;
      final Row titleRowWarn = tester.widget(
        find
            .ancestor(of: find.text(titleTextWarn), matching: find.byType(Row))
            .first,
      );
      expect(titleRowWarn.mainAxisAlignment, MainAxisAlignment.spaceAround);
    });

    testWidgets('DialogAction intents are correctly mapped', (tester) async {
      final container = createMockContainer(url: testUrl);
      await tester.pumpWidget(
        TestsAppWrapper(child: ContainerShowContainerUrlDialog(container)),
      );
      await tester.pumpAndSettle();
      final defaultDialog = tester.widget<DefaultDialog>(
        find.byType(DefaultDialog),
      );
      expect(defaultDialog.actions[0].intent, ActionIntent.cancel);
      expect(defaultDialog.actions[1].intent, ActionIntent.confirm);
    });
  });
}
