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
import 'package:privacyidea_authenticator/widgets/pi_progress_circle.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('PiProgressCircle Tests', () {
    testWidgets('renders with default size and calculated strokeWidth', (
      tester,
    ) async {
      const double defaultSize = 30.0;
      const double expectedStroke = defaultSize / 8;

      await tester.pumpWidget(
        const TestsAppWrapper(child: PiProgressCircle(0.7)),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));

      expect(sizedBox.width, defaultSize);
      expect(sizedBox.height, defaultSize);
      expect(indicator.strokeWidth, expectedStroke);
      expect(indicator.strokeCap, StrokeCap.round);
    });

    testWidgets('sets active color to transparent when value is 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: PiProgressCircle(0.0)),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      // By default swapColors is false, so color is the activeColor
      expect(indicator.color, Colors.transparent);
    });

    testWidgets('swaps active and track colors when swapColors is true', (
      tester,
    ) async {
      // We use explicit colors to verify the swap logic
      const activeBase = Colors.red;

      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PiProgressCircle(
            0.5,
            swapColors: true,
            foregroundColor: activeBase,
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      // When swapped:
      // backgroundColor = activeColor (baseColor)
      // color = trackColor (mixed color)
      expect(indicator.backgroundColor, activeBase);
      expect(indicator.color, isNot(activeBase));
      expect(indicator.color, isNot(Colors.transparent));
    });

    testWidgets('uses custom strokeWidth and size', (tester) async {
      const double customSize = 50.0;
      const double customStroke = 2.0;

      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PiProgressCircle(
            0.5,
            size: customSize,
            strokeWidth: customStroke,
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.strokeWidth, customStroke);
    });

    testWidgets('handles semantics correctly', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PiProgressCircle(
            0.4,
            semanticsLabel: 'Loading',
            semanticsValue: '40',
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.semanticsLabel, 'Loading');
      expect(indicator.semanticsValue, '40');
    });
  });
}
