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
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_configure.dart';

import '../../../tests_app_wrapper.mocks.dart';

void main() {
  group('HomeWidgetConfig & Builder Tests', () {
    late MockHomeWidgetUtils mockUtils;
    final lightTheme = ThemeData(
      listTileTheme: const ListTileThemeData(iconColor: Colors.blue),
    );
    final darkTheme = ThemeData(
      listTileTheme: const ListTileThemeData(iconColor: Colors.red),
    );
    const size = Size(64, 64);
    const baseKey = 'config_icon';

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

    testWidgets('HomeWidgetIcon renders with correct icon and color', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetIcon(
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.settings);
      expect(iconFinder, findsOneWidget);

      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, lightTheme.listTileTheme.iconColor);
      expect(iconWidget.size, 64.0);
    });

    testWidgets('HomeWidgetIcon size is constrained by the smaller dimension', (
      tester,
    ) async {
      const rectangularSize = Size(100, 40);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetIcon(
            theme: lightTheme,
            logicalSize: rectangularSize,
            utils: mockUtils,
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.settings));
      // min(100, 40) = 40
      expect(iconWidget.size, 40.0);
    });

    testWidgets('HomeWidgetConfigBuilder renders both themes correctly', (
      tester,
    ) async {
      final builder = HomeWidgetConfigBuilder(
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
            predicate((w) => w is HomeWidgetIcon && w.theme == darkTheme),
          ),
          key: '$baseKey${HomeWidgetUtils.keySuffixDark}',
          logicalSize: size,
        ),
      ).called(1);

      verify(
        mockUtils.renderFlutterWidget(
          argThat(
            predicate((w) => w is HomeWidgetIcon && w.theme == lightTheme),
          ),
          key: '$baseKey${HomeWidgetUtils.keySuffixLight}',
          logicalSize: size,
        ),
      ).called(1);
    });
  });
}
