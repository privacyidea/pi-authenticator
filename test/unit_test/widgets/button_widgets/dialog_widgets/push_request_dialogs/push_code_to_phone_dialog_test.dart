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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/push_request/push_code_to_phone_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_request_base_info.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_request_header.dart';

import '../../../../../tests_app_wrapper.dart';

void main() {
  final mockPushRequest = PushCodeToPhoneRequest(
    title: 'Login Verification',
    serial: 'PUSH789',
    question: 'Enter this code',
    nonce: 'n',
    signature: 's',
    uri: Uri.parse('https://pi.netknights.it'),
    sslVerify: true,
    displayCode: '123 456',
    expirationDate: DateTime.now().add(const Duration(minutes: 5)),
  );

  final mockToken = PushToken(serial: 'PUSH789', label: 'Work', id: 'id1');

  group('PushCodeToPhoneDialog - Suite', () {
    testWidgets('Renders all components correctly', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushCodeToPhoneDialog(
            pushRequest: mockPushRequest,
            token: mockToken,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PushRequestHeader), findsOneWidget);
      expect(find.byType(PushRequestBaseInfo), findsOneWidget);
      expect(find.text('123 456'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('Copy logic triggers snackbar and cooldown', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushCodeToPhoneDialog(
            pushRequest: mockPushRequest,
            token: mockToken,
          ),
        ),
      );
      await tester.pump();

      final theme = Theme.of(
        tester.element(find.byType(PushCodeToPhoneDialog)),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PushCodeToPhoneDialog)),
      )!;

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(find.text(l10n.otpValueCopiedMessage('123 456')), findsOneWidget);

      Icon icon = tester.widget(find.byIcon(Icons.copy));
      expect(icon.color, theme.disabledColor);

      await tester.pump(const Duration(seconds: 2));
      icon = tester.widget(find.byIcon(Icons.copy));
      expect(icon.color, theme.colorScheme.primary);
    });

    testWidgets('Done button interaction', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushCodeToPhoneDialog(
            pushRequest: mockPushRequest,
            token: mockToken,
          ),
        ),
      );
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(PushCodeToPhoneDialog)),
      )!;
      await tester.tap(find.text(l10n.done));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
