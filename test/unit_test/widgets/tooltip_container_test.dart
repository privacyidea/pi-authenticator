/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:privacyidea_authenticator/widgets/tooltip_container.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('TooltipContainer Tests', () {
    testWidgets('renders tooltip text', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: TooltipContainer(
            'Hello Tooltip',
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            border: 2.0,
            textStyle: const TextStyle(fontSize: 14),
            onComplete: null,
          ),
        ),
      );

      expect(find.text('Hello Tooltip'), findsOneWidget);
    });

    testWidgets('calls onComplete when tapped', (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: TooltipContainer(
            'Tap Me',
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            border: 2.0,
            textStyle: const TextStyle(fontSize: 14),
            onComplete: () => completed = true,
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(completed, isTrue);
    });

    testWidgets('does not crash when onComplete is null and tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: TooltipContainer(
            'No callback',
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            border: 2.0,
            textStyle: const TextStyle(fontSize: 14),
            onComplete: null,
          ),
        ),
      );

      await tester.tap(find.text('No callback'));
      await tester.pump();
      expect(find.text('No callback'), findsOneWidget);
    });

    testWidgets('applies correct padding and margin', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: TooltipContainer(
            'Styled',
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            border: 3.0,
            textStyle: const TextStyle(fontSize: 20, color: Colors.red),
            onComplete: null,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, const EdgeInsets.all(16));
      expect(container.margin, const EdgeInsets.all(8));
    });

    testWidgets('applies text style', (tester) async {
      const style = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
      await tester.pumpWidget(
        TestsAppWrapper(
          child: TooltipContainer(
            'Styled Text',
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            border: 2.0,
            textStyle: style,
            onComplete: null,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Styled Text'));
      expect(text.style, style);
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('has rounded border decoration', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: TooltipContainer(
            'Border Test',
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            border: 2.0,
            textStyle: const TextStyle(),
            onComplete: null,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });
  });
}
