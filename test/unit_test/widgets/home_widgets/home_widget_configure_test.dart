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
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_background.dart';

import '../../../tests_app_wrapper.mocks.dart';

void main() {
  group('HomeWidgetBackground & Builder Tests', () {
    late MockHomeWidgetUtils mockUtils;
    final lightTheme = ThemeData(scaffoldBackgroundColor: Colors.white);
    final darkTheme = ThemeData(scaffoldBackgroundColor: Colors.black);
    const size = Size(200, 100);
    const baseKey = 'bg_widget';

    setUp(() {
      mockUtils = MockHomeWidgetUtils();
      when(
        mockUtils.renderFlutterWidget(
          any,
          key: anyNamed('key'),
          logicalSize: anyNamed('logicalSize'),
        ),
      ).thenAnswer((_) async => null);
    });

    testWidgets(
      'HomeWidgetBackground renders with correct theme color and radius',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: HomeWidgetBackground(
              theme: lightTheme,
              logicalSize: size,
              utils: mockUtils,
            ),
          ),
        );

        final containerFinder = find.byType(Container);
        expect(containerFinder, findsOneWidget);

        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, lightTheme.scaffoldBackgroundColor);

        // Radius check: height (100) / 4 = 25
        expect(decoration.borderRadius, BorderRadius.circular(25));
        expect(container.constraints?.maxWidth, size.width);
        expect(container.constraints?.maxHeight, size.height);
      },
    );

    testWidgets(
      'HomeWidgetBackgroundBuilder renders light and dark backgrounds',
      (tester) async {
        final builder = HomeWidgetBackgroundBuilder(
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          logicalSize: size,
          homeWidgetKey: baseKey,
          utils: mockUtils,
        );

        await builder.renderFlutterWidgets();

        verify(
          mockUtils.renderFlutterWidget(
            argThat(
              predicate(
                (w) => w is HomeWidgetBackground && w.theme == darkTheme,
              ),
            ),
            key: '$baseKey${HomeWidgetUtils.keySuffixDark}',
            logicalSize: size,
          ),
        ).called(1);

        verify(
          mockUtils.renderFlutterWidget(
            argThat(
              predicate(
                (w) => w is HomeWidgetBackground && w.theme == lightTheme,
              ),
            ),
            key: '$baseKey${HomeWidgetUtils.keySuffixLight}',
            logicalSize: size,
          ),
        ).called(1);
      },
    );

    testWidgets('HomeWidgetBackground radius adapts to different height', (
      tester,
    ) async {
      const tallSize = Size(100, 200);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetBackground(
            theme: lightTheme,
            logicalSize: tallSize,
            utils: mockUtils,
          ),
        ),
      );

      final decoration =
          tester.widget<Container>(find.byType(Container)).decoration
              as BoxDecoration;

      // Radius check: 200 / 4 = 50
      expect(decoration.borderRadius, BorderRadius.circular(50));
    });
  });
}
