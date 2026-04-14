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
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_request_base_info.dart';

import '../../../../../../tests_app_wrapper.dart';

void main() {
  group('PushRequestBaseInfo Comprehensive Tests', () {
    PushDefaultRequest createRequest(String question) => PushDefaultRequest(
      title: 'T',
      question: question,
      nonce: 'n',
      serial: 's',
      signature: 'sig',
      expirationDate: DateTime(2026, 4, 14),
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
    );

    testWidgets('renders question with bodyLarge style and center alignment', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushRequestBaseInfo(
            pushRequest: createRequest('Styled Question'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled Question'));

      expect(textWidget.textAlign, TextAlign.center);
      expect(textWidget.style?.fontSize, isNotNull);
    });

    testWidgets('handles empty question string without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushRequestBaseInfo(pushRequest: createRequest('')),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles extremely long questions (overflow/layout check)', (
      tester,
    ) async {
      final longQuestion = 'Why? ' * 100;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: SingleChildScrollView(
            child: PushRequestBaseInfo(
              pushRequest: createRequest(longQuestion),
            ),
          ),
        ),
      );

      expect(find.text(longQuestion), findsOneWidget);
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('structure contains exactly one Column and one Text', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushRequestBaseInfo(
            pushRequest: createRequest('Structure Check'),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(PushRequestBaseInfo),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(PushRequestBaseInfo),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });
  });
}
