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
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_hidden.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_otp.dart';

import '../../../tests_app_wrapper.mocks.dart';

void main() {
  group('HomeWidgetHidden & Builder Tests', () {
    late MockHomeWidgetUtils mockUtils;

    final lightTheme = ThemeData.light().copyWith(
      extensions: [ExtendedTextTheme(veilingCharacter: '*')],
    );

    const size = Size(200, 200);
    const baseKey = 'hidden_otp_widget';

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
      'HomeWidgetHidden masks OTP with character from ThemeExtension',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: HomeWidgetHidden(
              otpLength: 6,
              issuer: 'NetKnights',
              label: 'User',
              theme: lightTheme,
              logicalSize: size,
              utils: mockUtils,
            ),
          ),
        );

        // HomeWidgetHidden uses HomeWidgetOtp internally
        final otpWidgetFinder = find.byType(HomeWidgetOtp);
        expect(otpWidgetFinder, findsOneWidget);

        final otpWidget = tester.widget<HomeWidgetOtp>(otpWidgetFinder);

        // Verify masking: 6 * '*' = '******'
        expect(otpWidget.otp, '******');
        expect(otpWidget.issuer, 'NetKnights');
        expect(otpWidget.label, 'User');
      },
    );

    testWidgets(
      'HomeWidgetHidden uses default bullet if extension is missing',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: HomeWidgetHidden(
              otpLength: 4,
              theme: ThemeData.light(), // No extension
              logicalSize: size,
              utils: mockUtils,
            ),
          ),
        );

        final otpWidget = tester.widget<HomeWidgetOtp>(
          find.byType(HomeWidgetOtp),
        );

        // Default veiling character is '●'
        expect(otpWidget.otp, '●●●●');
      },
    );

    testWidgets('HomeWidgetHiddenBuilder passes data correctly to formWidget', (
      tester,
    ) async {
      final builder = HomeWidgetHiddenBuilder(
        otpLength: 8,
        issuer: 'Service',
        label: 'Account',
        lightTheme: lightTheme,
        darkTheme: ThemeData.dark(),
        logicalSize: size,
        homeWidgetKey: baseKey,
        utils: mockUtils,
      );

      final widget = builder.getWidget(isDark: false);

      expect(widget.otpLength, 8);
      expect(widget.issuer, 'Service');
      expect(widget.label, 'Account');
      expect(widget.theme, lightTheme);
    });

    testWidgets('HomeWidgetHiddenBuilder handles null issuer and label', (
      tester,
    ) async {
      final builder = HomeWidgetHiddenBuilder(
        otpLength: 6,
        lightTheme: lightTheme,
        darkTheme: ThemeData.dark(),
        logicalSize: size,
        homeWidgetKey: baseKey,
        utils: mockUtils,
      );

      final widget = builder.getWidget();

      expect(widget.issuer, '');
      expect(widget.label, '');
    });
  });
}
