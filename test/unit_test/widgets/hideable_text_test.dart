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
import 'package:privacyidea_authenticator/widgets/hideable_text.dart';

void main() {
  group('HideableText Tests', () {
    const String testSecret = '123 456';
    const String bullet = '\u2022';

    testWidgets('shows plain text when isHidden is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HideableText(text: testSecret, isHidden: false)),
        ),
      );

      expect(find.text(testSecret), findsOneWidget);
    });

    testWidgets(
      'obfuscates text but keeps whitespaces by default when isHidden is true',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HideableText(text: testSecret, isHidden: true),
            ),
          ),
        );

        final expectedObfuscated =
            '$bullet$bullet$bullet $bullet$bullet$bullet';
        expect(find.text(expectedObfuscated), findsOneWidget);
        expect(find.text(testSecret), findsNothing);
      },
    );

    testWidgets(
      'obfuscates everything including whitespaces when replaceWhitespaces is true',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HideableText(
                text: testSecret,
                isHidden: true,
                replaceWhitespaces: true,
              ),
            ),
          ),
        );

        final expectedObfuscated = bullet * 7;
        expect(find.text(expectedObfuscated), findsOneWidget);
      },
    );

    testWidgets('uses custom replaceCharacter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HideableText(
              text: 'ABC',
              isHidden: true,
              replaceCharacter: 'X',
            ),
          ),
        ),
      );

      expect(find.text('XXX'), findsOneWidget);
    });

    testWidgets('applies monospace font style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HideableText(text: '123', isHidden: false)),
        ),
      );

      final Text textWidget = tester.widget(find.byType(Text));
      expect(textWidget.style?.fontFamily, 'monospace');
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}
