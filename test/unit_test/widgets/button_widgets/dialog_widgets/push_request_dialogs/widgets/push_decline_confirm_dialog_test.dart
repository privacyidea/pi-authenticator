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
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/push_action_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialogs/widgets/push_decline_confirm_dialog.dart';

import '../../../../../../tests_app_wrapper.dart';

void main() {
  group('PushDeclineConfirmDialog Tests', () {
    testWidgets('renders dialog with correct title and question', (
      tester,
    ) async {
      bool declineCalled = false;
      bool discardCalled = false;

      await tester.pumpWidget(
        TestsAppWrapper(
          child: PushDeclineConfirmDialog(
            title: 'Test Title',
            expirationDate: DateTime(2026, 4, 14),
            onDecline: () async => declineCalled = true,
            onDiscard: () async => discardCalled = true,
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(PushActionButton), findsNWidgets(2));
      expect(declineCalled, isFalse);
      expect(discardCalled, isFalse);
    });

    testWidgets('clicking discard triggers callback and pops', (tester) async {
      bool discardCalled = false;

      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PushDeclineConfirmDialog.showDialogWidget(
                context: context,
                title: 'Discard Dialog',
                expirationDate: DateTime(2026, 4, 14),
                onDecline: () async {},
                onDiscard: () async => discardCalled = true,
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PushActionButton).first);
      await tester.pumpAndSettle();

      expect(discardCalled, isTrue);
      expect(find.byType(PushDeclineConfirmDialog), findsNothing);
    });

    testWidgets('clicking decline triggers destructive callback and pops', (
      tester,
    ) async {
      bool declineCalled = false;

      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PushDeclineConfirmDialog.showDialogWidget(
                context: context,
                title: 'Decline Dialog',
                expirationDate: DateTime(2026, 4, 14),
                onDecline: () async => declineCalled = true,
                onDiscard: () async {},
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final declineButtonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is PushActionButton &&
            widget.intent == ActionIntent.destructive,
      );

      await tester.tap(declineButtonFinder);
      await tester.pumpAndSettle();

      expect(declineCalled, isTrue);
      expect(find.byType(PushDeclineConfirmDialog), findsNothing);
    });
  });
}
