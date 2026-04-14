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
import 'package:privacyidea_authenticator/model/push_request/push_requests.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';

import '../../../../../tests_app_wrapper.dart';
import '../../../../../tests_app_wrapper.mocks.dart';

void main() {
  late PushToken mockToken;
  late MockPushRequestNotifier mockNotifier;
  final testDate = DateTime(2026, 4, 14);
  final testUri = Uri.parse('https://example.com');

  setUp(() {
    mockToken = PushToken(serial: 'S1', id: 'ID1');
    mockNotifier = MockPushRequestNotifier();
  });

  Widget createWidgetUnderTest(PushRequest request) {
    return TestsAppWrapper(
      overrides: [pushRequestProvider.overrideWith(() => mockNotifier)],
      child: PushRequestDialog(pushRequest: request, token: mockToken),
    );
  }

  group('PushRequestDialog Factory Tests', () {
    testWidgets('mapping PushChoiceRequest', (tester) async {
      final request = PushChoiceRequest(
        title: 'Choice',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: testUri,
        sslVerify: true,
        possibleAnswers: ['A', 'B'],
      );

      await tester.pumpWidget(createWidgetUnderTest(request));

      final dynamic exception = tester.takeException();
      expect(exception, isNull);

      await tester.pump();
      expect(find.byType(PushChoiceDialog), findsOneWidget);
    });

    testWidgets('mapping PushDefaultRequest', (tester) async {
      final request = PushDefaultRequest(
        title: 'Default',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: testUri,
        sslVerify: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(request));
      await tester.pump();

      expect(find.byType(PushDefaultDialog), findsOneWidget);
    });

    testWidgets('mapping PushCodeToPhoneRequest', (tester) async {
      final request = PushCodeToPhoneRequest(
        title: 'Code',
        question: 'Q',
        nonce: 'N',
        serial: 'S',
        signature: 'Sig',
        expirationDate: testDate,
        uri: testUri,
        sslVerify: true,
        displayCode: '123',
      );

      await tester.pumpWidget(createWidgetUnderTest(request));
      await tester.pump();

      expect(find.byType(PushCodeToPhoneDialog), findsOneWidget);
    });
  });
}
