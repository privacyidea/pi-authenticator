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
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_action.dart';

import '../../../tests_app_wrapper.mocks.dart';

void main() {
  group('HomeWidgetAction & Builder Tests', () {
    late MockHomeWidgetUtils mockUtils;
    final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      listTileTheme: const ListTileThemeData(iconColor: Colors.black),
    );
    const size = Size(50, 50);
    const baseKey = 'action_btn';
    const testIcon = Icons.add;

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

    testWidgets('HomeWidgetAction renders correct color based on status', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetAction(
            icon: testIcon,
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
            aditionalSuffix: HomeWidgetUtils.keySuffixActive,
          ),
        ),
      );

      final activeIcon = tester.widget<Icon>(find.byIcon(testIcon));
      expect(activeIcon.color, lightTheme.listTileTheme.iconColor);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetAction(
            icon: testIcon,
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
            aditionalSuffix: HomeWidgetUtils.keySuffixInactive,
          ),
        ),
      );

      final inactiveIcon = tester.widget<Icon>(find.byIcon(testIcon));
      expect(inactiveIcon.color, isNot(lightTheme.listTileTheme.iconColor));
      expect(inactiveIcon.color, isNotNull);
    });

    testWidgets('HomeWidgetAction renders SizedBox for unknown suffix', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetAction(
            icon: testIcon,
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
            aditionalSuffix: 'unknown',
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('HomeWidgetActionBuilder renders 4 widgets (2 status x 2 themes)', (
      tester,
    ) async {
      final builder = HomeWidgetActionBuilder(
        icon: testIcon,
        lightTheme: lightTheme,
        darkTheme: ThemeData.dark(),
        logicalSize: size,
        homeWidgetKey: baseKey,
        utils: mockUtils,
      );

      await builder.renderFlutterWidgets(additionalSuffix: '_v1');

      verify(
        mockUtils.renderFlutterWidget(
          any,
          key:
              '${baseKey}_v1${HomeWidgetUtils.keySuffixActive}${HomeWidgetUtils.keySuffixDark}',
          logicalSize: size,
        ),
      ).called(1);

      verify(
        mockUtils.renderFlutterWidget(
          any,
          key:
              '${baseKey}_v1${HomeWidgetUtils.keySuffixActive}${HomeWidgetUtils.keySuffixLight}',
          logicalSize: size,
        ),
      ).called(1);

      verify(
        mockUtils.renderFlutterWidget(
          any,
          key:
              '${baseKey}_v1${HomeWidgetUtils.keySuffixInactive}${HomeWidgetUtils.keySuffixDark}',
          logicalSize: size,
        ),
      ).called(1);

      verify(
        mockUtils.renderFlutterWidget(
          any,
          key:
              '${baseKey}_v1${HomeWidgetUtils.keySuffixInactive}${HomeWidgetUtils.keySuffixLight}',
          logicalSize: size,
        ),
      ).called(1);
    });

    testWidgets('HomeWidgetAction size is capped by logicalSize', (
      tester,
    ) async {
      const smallSize = Size(20, 40);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetAction(
            icon: testIcon,
            theme: lightTheme,
            logicalSize: smallSize,
            utils: mockUtils,
            aditionalSuffix: HomeWidgetUtils.keySuffixActive,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(testIcon));
      expect(icon.size, 20.0);
    });
  });
}
