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
      await tester.pump();
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('Focus Tooltip'), findsOneWidget);
      expect(find.byType(TooltipContainer), findsOneWidget);
      await tester.tap(find.byType(GestureDetector).last);
      expect(completed, true);
    });
    testWidgets('timer stops after stability even with infinite animations', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: FocusedItemAsOverlay(
            isFocused: true,
            childIsMoving: true,
            tooltipWhenFocused: 'Stable Tooltip',
            onComplete: () {},
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump();
      for (int i = 0; i < 70; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.byType(TooltipContainer), findsOneWidget);
      await tester.pumpWidget(const TestsAppWrapper(child: SizedBox()));
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
      await tester.pumpWidget(const TestsAppWrapper(child: SizedBox()));
      await tester.pump();
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
