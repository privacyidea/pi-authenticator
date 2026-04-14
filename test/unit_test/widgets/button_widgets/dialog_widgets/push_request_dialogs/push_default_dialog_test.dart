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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/push_request/push_default_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/push_action_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/push_request_dialog.dart';

import '../../../../../tests_app_wrapper.mocks.dart';

void main() {
  late PushDefaultRequest mockRequest;
  late PushToken mockToken;
  late MockPushRequestNotifier mockNotifier;

  setUp(() {
    mockRequest = PushDefaultRequest(
      title: 'Notifier Test',
      question: 'Trigger Notifier?',
      nonce: 'n',
      serial: 's',
      signature: 'sig',
      expirationDate: DateTime(2026, 4, 14),
      uri: Uri.parse('https://example.com'),
      sslVerify: true,
    );
    mockToken = PushToken(serial: 's', id: 'id');
    mockNotifier = MockPushRequestNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [pushRequestProvider.overrideWith(() => mockNotifier)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PushDefaultDialog(pushRequest: mockRequest, token: mockToken),
      ),
    );
  }

  group('PushDefaultDialog Logic Tests', () {
    testWidgets('dialog structure verification', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Column), findsAtLeast(1));

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Column &&
              widget.crossAxisAlignment == CrossAxisAlignment.stretch,
        ),
        findsAtLeast(1),
      );

      expect(find.byType(PushActionButton), findsNWidgets(2));
    });

    testWidgets('destructive intent on decline button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final declineButton = tester.widget<PushActionButton>(
        find.widgetWithText(PushActionButton, 'Decline'),
      );

      expect(declineButton.intent, ActionIntent.destructive);
    });

    testWidgets('dialog is not scrollable by default', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final dialog = tester.widget<DefaultDialog>(find.byType(DefaultDialog));
      expect(dialog.scrollable, isFalse);
    });
  });
}
