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
import 'package:privacyidea_authenticator/widgets/status_bar.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('StatusBarOverlayEntry Tests', () {
    Widget wrapInStack(Widget child) {
      return TestsAppWrapper(child: Stack(children: [child]));
    }

    testWidgets('renders status text', (tester) async {
      await tester.pumpWidget(
        wrapInStack(
          StatusBarOverlayEntry(
            statusText: 'Success!',
            isError: false,
            onDismissed: (_) {},
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Success!'), findsOneWidget);
    });

    testWidgets('renders sub text when provided', (tester) async {
      await tester.pumpWidget(
        wrapInStack(
          StatusBarOverlayEntry(
            statusText: 'Main',
            statusSubText: 'Details here',
            isError: false,
            onDismissed: (_) {},
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Details here'), findsOneWidget);
    });

    testWidgets('does not render sub text when null', (tester) async {
      await tester.pumpWidget(
        wrapInStack(
          StatusBarOverlayEntry(
            statusText: 'Only Main',
            isError: false,
            onDismissed: (_) {},
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Only Main'), findsOneWidget);
    });

    testWidgets('uses Dismissible widget', (tester) async {
      await tester.pumpWidget(
        wrapInStack(
          StatusBarOverlayEntry(
            statusText: 'Dismissible test',
            isError: false,
            onDismissed: (_) {},
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('uses AnimatedPositioned for slide-in animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInStack(
          StatusBarOverlayEntry(
            statusText: 'Animated',
            isError: true,
            onDismissed: (_) {},
          ),
        ),
      );

      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });
  });
}
