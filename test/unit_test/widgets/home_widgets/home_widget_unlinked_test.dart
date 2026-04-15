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
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_otp.dart';

import '../../../tests_app_wrapper.mocks.dart';

void main() {
  group('HomeWidgetOtp & Builder Tests', () {
    late MockHomeWidgetUtils mockUtils;

    final lightTheme = ThemeData.light().copyWith(
      extensions: [
        ExtendedTextTheme(
          tokenTile: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          tokenTileSubtitle: const TextStyle(color: Colors.grey),
        ),
      ],
    );

    const size = Size(300, 150);
    const baseKey = 'otp_widget';

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

    testWidgets('HomeWidgetOtp formats short OTP with a space', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetOtp(
            otp: '123456', // 6 digits -> length <= 10
            issuer: 'NetKnights',
            label: 'User',
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
          ),
        ),
      );

      // (6 / 2).ceil() = 3 -> Inserts space after 3rd char
      expect(find.text('123 456'), findsOneWidget);
      expect(find.text('NetKnights:User'), findsOneWidget);
    });

    testWidgets('HomeWidgetOtp formats long OTP with a newline', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetOtp(
            otp: '123456789012', // 12 digits -> length > 10
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
          ),
        ),
      );

      // (12 / 2).ceil() = 6 -> Inserts \n after 6th char
      expect(find.text('123456\n789012'), findsOneWidget);
    });

    testWidgets('HomeWidgetOtp handles empty issuer or label correctly', (
      tester,
    ) async {
      // Only Issuer
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetOtp(
            otp: '111222',
            issuer: 'OnlyIssuer',
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
          ),
        ),
      );
      expect(find.text('OnlyIssuer'), findsOneWidget);
      expect(find.textContaining(':'), findsNothing);

      // Only Label
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetOtp(
            otp: '111222',
            label: 'OnlyLabel',
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
          ),
        ),
      );
      expect(find.text('OnlyLabel'), findsOneWidget);
    });

    testWidgets(
      'HomeWidgetOtpBuilder handles null values and propagates data',
      (tester) async {
        final builder = HomeWidgetOtpBuilder(
          otp: '654321',
          lightTheme: lightTheme,
          darkTheme: ThemeData.dark(),
          logicalSize: size,
          homeWidgetKey: baseKey,
          utils: mockUtils,
        );

        final widget = builder.getWidget();
        expect(widget.issuer, '');
        expect(widget.label, '');
        expect(widget.otp, '654321');
      },
    );

    testWidgets('UI uses correct ThemeExtension styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWidgetOtp(
            otp: '123456',
            issuer: 'Test',
            theme: lightTheme,
            logicalSize: size,
            utils: mockUtils,
          ),
        ),
      );

      final otpText = tester.widget<Text>(find.text('123 456'));
      final subtitleText = tester.widget<Text>(find.text('Test'));

      final extension = lightTheme.extension<ExtendedTextTheme>()!;
      expect(otpText.style, extension.tokenTile);
      expect(subtitleText.style, extension.tokenTileSubtitle);
    });
  });
}
