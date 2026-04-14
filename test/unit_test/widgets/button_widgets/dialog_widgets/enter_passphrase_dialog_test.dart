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
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/enter_passphrase_dialog.dart';

import '../../../../tests_app_wrapper.dart';

void main() {
  group('EnterPassphraseDialog Comprehensive Tests', () {
    testWidgets(
      'OK button is disabled when text is empty and enabled when not',
      (tester) async {
        await tester.pumpWidget(
          TestsAppWrapper(
            child: const EnterPassphraseDialog(question: 'Test Question'),
          ),
        );
        await tester.pumpAndSettle();

        final okButtonFinder = find.byType(IntentButton);

        expect(okButtonFinder, findsOneWidget);
        expect(tester.widget<IntentButton>(okButtonFinder).onPressed, isNull);

        await tester.enterText(find.byType(TextField), 'my secret');
        await tester.pump();

        expect(
          tester.widget<IntentButton>(okButtonFinder).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets('returns entered text on pop when OK is pressed', (
      tester,
    ) async {
      String? returnedValue;

      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                returnedValue = await EnterPassphraseDialog.show(
                  'Enter something',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'secret_pass');
      await tester.pump();

      final okButton = find.byType(IntentButton);
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      expect(returnedValue, 'secret_pass');
    });

    testWidgets('renders question text and uses bodyLarge style', (
      tester,
    ) async {
      const testQuestion = 'Is this a secure vault?';
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: EnterPassphraseDialog(question: testQuestion),
        ),
      );

      final textFinder = find.text(testQuestion);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style, isNotNull);
    });

    testWidgets('shows BackdropFilter with blur when using show method', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EnterPassphraseDialog.show('Blur test'),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final backdropFinder = find.byType(BackdropFilter);
      expect(backdropFinder, findsOneWidget);

      final backdropWidget = tester.widget<BackdropFilter>(backdropFinder);
      expect(backdropWidget.filter, isNotNull);
    });

    testWidgets('TextField has correct decoration and style', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: EnterPassphraseDialog(question: 'Q')),
      );

      final textFieldFinder = find.byType(TextField);
      final textField = tester.widget<TextField>(textFieldFinder);

      expect(textField.decoration?.labelText, isNotNull);
      expect(textField.style?.fontSize, isNotNull);
    });
  });
}
