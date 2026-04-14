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
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_request_header.dart';

import '../../../../../../tests_app_wrapper.dart';

void main() {
  group('PushRequestHeader Comprehensive Tests', () {
    PushDefaultRequest createRequest({
      required String title,
      String serial = 'S123',
    }) => PushDefaultRequest(
      title: title,
      question: 'Q',
      nonce: 'n',
      serial: serial,
      signature: 'sig',
      expirationDate: DateTime(2026, 4, 14),
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
    );

    testWidgets('renders title when title is not "privacyIDEA"', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushRequestHeader(
            pushRequest: createRequest(title: 'Custom Title'),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('S123'), findsNothing);
    });

    testWidgets('renders serial when title is exactly "privacyIDEA"', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushRequestHeader(
            pushRequest: createRequest(
              title: 'privacyIDEA',
              serial: 'SERIAL-999',
            ),
          ),
        ),
      );

      expect(find.text('SERIAL-999'), findsOneWidget);
      expect(find.text('privacyIDEA'), findsNothing);
    });

    testWidgets('applies titleLarge style and center alignment', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushRequestHeader(
            pushRequest: createRequest(title: 'Style Test'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Style Test'));
      final centerWidget = tester.widget<Center>(find.byType(Center));

      expect(textWidget.textAlign, TextAlign.center);
      expect(centerWidget, isNotNull);
      expect(textWidget.style?.fontSize, isNotNull);
    });

    testWidgets(
      'handles extremely long titles/serials without overflow in center',
      (tester) async {
        final longTitle = 'VeryLongTitle' * 10;
        await tester.pumpWidget(
          TestsAppWrapper(
            child: PushRequestHeader(
              pushRequest: createRequest(title: longTitle),
            ),
          ),
        );

        expect(find.text(longTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
