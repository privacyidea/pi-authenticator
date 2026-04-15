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
import 'package:privacyidea_authenticator/widgets/dot_indicator.dart';

void main() {
  group('DotIndicator Tests', () {
    testWidgets('renders with selected color in Light Mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          themeMode: ThemeMode.light,
          home: Scaffold(body: DotIndicator(isSelected: true)),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;

      // Expected selected color for Light Mode is black
      expect(decoration.color, Colors.black);
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('renders with unselected color in Light Mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          themeMode: ThemeMode.light,
          home: Scaffold(body: DotIndicator(isSelected: false)),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;

      // Expected unselected color for Light Mode is grey
      expect(decoration.color, Colors.grey);
    });

    testWidgets('renders with selected color in Dark Mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const Scaffold(body: DotIndicator(isSelected: true)),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;

      // Expected selected color for Dark Mode is white
      expect(decoration.color, Colors.white);
    });

    testWidgets('renders with unselected color in Dark Mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const Scaffold(body: DotIndicator(isSelected: false)),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;

      // Expected unselected color for Dark Mode is white38
      expect(decoration.color, Colors.white38);
    });

    testWidgets('animates color change', (tester) async {
      // Start as unselected
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DotIndicator(isSelected: false)),
        ),
      );

      // Rebuild as selected
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DotIndicator(isSelected: true))),
      );

      // Verify that color has not fully changed yet (mid-animation)
      await tester.pump(const Duration(milliseconds: 150));
      final containerMid = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decorationMid = containerMid.decoration as BoxDecoration;

      // Color should be an interpolated value, not final black/grey yet
      expect(decorationMid.color, isNot(Colors.black));
      expect(decorationMid.color, isNot(Colors.grey));

      // Wait for animation to finish
      await tester.pumpAndSettle();
      final containerFinal = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect((containerFinal.decoration as BoxDecoration).color, Colors.black);
    });
  });
}
