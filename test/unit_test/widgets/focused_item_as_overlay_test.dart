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
import 'package:privacyidea_authenticator/widgets/focused_item_as_overlay.dart';
import 'package:privacyidea_authenticator/widgets/tooltip_container.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('FocusedItemAsOverlay Tests', () {
    testWidgets('renders child normally when isFocused is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: FocusedItemAsOverlay(
            isFocused: false,
            tooltipWhenFocused: 'Tooltip',
            onComplete: () {},
            child: const Text('Normal Child'),
          ),
        ),
      );

      expect(find.text('Normal Child'), findsOneWidget);
      // BackdropFilter is part of the overlay, should not be there
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('shows overlay components when isFocused is true', (
      tester,
    ) async {
      bool completed = false;

      await tester.pumpWidget(
        TestsAppWrapper(
          child: FocusedItemAsOverlay(
            isFocused: true,
            tooltipWhenFocused: 'Focus Tooltip',
            onComplete: () => completed = true,
            child: const Text('Target Child'),
          ),
        ),
      );

      // We need to pump once to trigger addPostFrameCallback where overlay is inserted
      await tester.pump();

      // Check for backdrop blur
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Check for tooltip text
      expect(find.text('Focus Tooltip'), findsOneWidget);
      expect(find.byType(TooltipContainer), findsOneWidget);

      // Simulate tap on the full-screen detector to complete
      await tester.tap(find.byType(GestureDetector).last);
      expect(completed, true);
    });

    testWidgets('updates overlay when childIsMoving is true', (tester) async {
      // This test checks if the periodic timer for moving elements is active
      await tester.pumpWidget(
        TestsAppWrapper(
          child: FocusedItemAsOverlay(
            isFocused: true,
            childIsMoving: true,
            tooltipWhenFocused: 'Moving Tooltip',
            onComplete: () {},
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );

      await tester.pump();

      // Verify initial state
      expect(find.byType(TooltipContainer), findsOneWidget);

      // Advance time to trigger the periodic timer (16ms)
      await tester.pump(const Duration(milliseconds: 20));

      // The test passes if no exceptions occur during the overlay update cycle
      expect(find.byType(TooltipContainer), findsOneWidget);

      // Clean up timer
      await tester.pumpAndSettle();
    });

    testWidgets('disposes overlay when widget is removed', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: FocusedItemAsOverlay(
            isFocused: true,
            tooltipWhenFocused: 'Dispose Test',
            onComplete: () {},
            child: const Text('Target'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Replace widget with something else
      await tester.pumpWidget(const TestsAppWrapper(child: SizedBox()));

      // Overlay disposal happens in addPostFrameCallback
      await tester.pump();

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
