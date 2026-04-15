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
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/extended_text_theme.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_copied.dart';

import '../../../tests_app_wrapper.mocks.dart';

void main() {
  group('HomeWidgetCopied & Builder Tests', () {
    late MockHomeWidgetUtils mockUtils;

    // Setup themes with the required extension
    final lightTheme = ThemeData.light().copyWith(
      extensions: [
        ExtendedTextTheme(
          tokenTile: const TextStyle(color: Colors.blue, fontSize: 12),
        ),
      ],
    );
    final darkTheme = ThemeData.dark().copyWith(
      extensions: [
        ExtendedTextTheme(
          tokenTile: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      ],
    );

    const size = Size(100, 100);
    const baseKey = 'copied_notification';

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
      'HomeWidgetCopied renders correct text and applies ThemeExtension style',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: HomeWidgetCopied(
              theme: lightTheme,
              logicalSize: size,
              utils: mockUtils,
            ),
          ),
        );

        final textFinder = find.text('Password copied\nto Clipboard');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        final expectedStyle = lightTheme
            .extension<ExtendedTextTheme>()
            ?.tokenTile;

        expect(textWidget.style, expectedStyle);
        expect(textWidget.textAlign, TextAlign.center);

        // Verify layout constraints
        expect(find.byType(FittedBox), findsOneWidget);
        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, size.width);
        expect(sizedBox.height, size.height);
      },
    );

    testWidgets('HomeWidgetCopiedBuilder renders both versions', (
      tester,
    ) async {
      final builder = HomeWidgetCopiedBuilder(
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
            predicate((w) => w is HomeWidgetCopied && w.theme == darkTheme),
          ),
          key: '$baseKey${HomeWidgetUtils.keySuffixDark}',
          logicalSize: size,
        ),
      ).called(1);

      verify(
        mockUtils.renderFlutterWidget(
          argThat(
            predicate((w) => w is HomeWidgetCopied && w.theme == lightTheme),
          ),
          key: '$baseKey${HomeWidgetUtils.keySuffixLight}',
          logicalSize: size,
        ),
      ).called(1);
    });

    testWidgets('HomeWidgetCopied handles missing ThemeExtension gracefully', (
      tester,
    ) async {
      // Theme without extension
      final emptyTheme = ThemeData.light();

      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetCopied(
            theme: emptyTheme,
            logicalSize: size,
            utils: mockUtils,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style, isNull);
      expect(find.text('Password copied\nto Clipboard'), findsOneWidget);
    });
  });
}
