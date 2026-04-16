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
import 'package:privacyidea_authenticator/widgets/pulse_icon.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('PulseIcon Tests', () {
    testWidgets('renders child widget when pulsing', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PulseIcon(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.zero,
            child: Icon(Icons.add),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows FadeTransition and ScaleTransition when pulsing', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PulseIcon(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.zero,
            child: Icon(Icons.star),
          ),
        ),
      );

      final pulseIconFinder = find.byType(PulseIcon);
      expect(
        find.descendant(
          of: pulseIconFinder,
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: pulseIconFinder,
          matching: find.byType(ScaleTransition),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses Stack layout when pulsing', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PulseIcon(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.zero,
            child: Icon(Icons.notifications),
          ),
        ),
      );

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('animation progresses over time', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PulseIcon(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.zero,
            child: Icon(Icons.circle),
          ),
        ),
      );

      final pulseIconFinder = find.byType(PulseIcon);
      final fadeFinder = find.descendant(
        of: pulseIconFinder,
        matching: find.byType(FadeTransition),
      );

      final fadeTransition1 = tester.widget<FadeTransition>(fadeFinder);
      final opacity1 = fadeTransition1.opacity.value;

      await tester.pump(const Duration(milliseconds: 750));

      final fadeTransition2 = tester.widget<FadeTransition>(fadeFinder);
      final opacity2 = fadeTransition2.opacity.value;

      expect(opacity1, isNot(equals(opacity2)));
    });
  });
}
