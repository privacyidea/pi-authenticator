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
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../tests_app_wrapper.dart';

void main() {
  group('DefaultDialog Comprehensive Tests', () {
    testWidgets('renders title, content and close button', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: DefaultDialog(
            title: const Text('Dialog Title'),
            content: const Text('Dialog Content'),
            hasCloseButton: true,
          ),
        ),
      );

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Dialog Content'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('close button pops the navigator', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const DefaultDialog(hasCloseButton: true),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(DefaultDialog), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(DefaultDialog), findsNothing);
    });

    testWidgets('actions are sorted by intent priority', (tester) async {
      final actions = [
        DialogAction(label: 'Neutral', intent: ActionIntent.neutral),
        DialogAction(label: 'Destructive', intent: ActionIntent.destructive),
        DialogAction(label: 'Confirm', intent: ActionIntent.confirm),
      ];

      await tester.pumpWidget(
        TestsAppWrapper(child: DefaultDialog(actions: actions)),
      );

      final finders = [
        find.widgetWithText(IntentButton, 'Neutral'),
        find.widgetWithText(IntentButton, 'Destructive'),
        find.widgetWithText(IntentButton, 'Confirm'),
      ];

      for (final finder in finders) {
        expect(finder, findsOneWidget);
      }

      final List<(ActionIntent, double)> positionedIntents = finders.map((f) {
        final widget = tester.widget<IntentButton>(f);
        return (widget.intent, tester.getCenter(f).dx);
      }).toList();

      positionedIntents.sort((a, b) => a.$2.compareTo(b.$2));

      final sortedIntents = positionedIntents.map((e) => e.$1).toList();

      expect(sortedIntents.contains(ActionIntent.destructive), isTrue);
      expect(sortedIntents.contains(ActionIntent.confirm), isTrue);
      expect(sortedIntents.contains(ActionIntent.neutral), isTrue);
    });

    testWidgets('uses AppDimensions from theme extension', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: const DefaultDialog(title: Text('Dimensions Test')),
        ),
      );

      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      final shape = alertDialog.shape as RoundedRectangleBorder;

      expect(shape.side.width, isNotNull);
      expect(shape.borderRadius, isA<BorderRadius>());
    });

    testWidgets('handles missing title and content gracefully', (tester) async {
      await tester.pumpWidget(const TestsAppWrapper(child: DefaultDialog()));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrollable property is passed to AlertDialog', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: DefaultDialog(scrollable: true)),
      );

      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alertDialog.scrollable, isTrue);
    });
  });
}
