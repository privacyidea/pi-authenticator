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
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/send_otps_without_ssl_dialog.dart';

import '../../../../../tests_app_wrapper.dart';

void main() {
  group('SendOTPsWithoutSSLDialog - Suite', () {
    testWidgets('Displays warning icons and localized warning texts', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: SendOTPsWithoutSSLDialog()),
      );
      await tester.pump();

      final context = tester.element(find.byType(SendOTPsWithoutSSLDialog));
      final l10n = AppLocalizations.of(context)!;

      expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));

      expect(
        find.text(l10n.initialTokenAssignmentDialogSSLWarning1),
        findsOneWidget,
      );
      expect(
        find.text(l10n.initialTokenAssignmentDialogSSLWarning2),
        findsOneWidget,
      );
    });

    testWidgets('Warning texts use the correct warning color from theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: SendOTPsWithoutSSLDialog()),
      );
      await tester.pump();

      final warningText = tester.widget<Text>(find.textContaining('SSL'));

      expect(warningText.style?.color, const Color(0xFFFF9800));
    });

    testWidgets('Returns false when cancel is pressed', (tester) async {
      bool? result;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await SendOTPsWithoutSSLDialog.showDialog();
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SendOTPsWithoutSSLDialog));
      final l10n = AppLocalizations.of(context)!;

      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('Returns true when send is pressed', (tester) async {
      bool? result;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await SendOTPsWithoutSSLDialog.showDialog();
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SendOTPsWithoutSSLDialog));
      final l10n = AppLocalizations.of(context)!;

      await tester.tap(find.text(l10n.send));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('Returns null when dismissed by tapping outside', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await SendOTPsWithoutSSLDialog.showDialog();
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
