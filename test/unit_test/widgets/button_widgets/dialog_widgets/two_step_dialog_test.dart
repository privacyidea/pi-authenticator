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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/two_step_dialog.dart';
import 'package:privacyidea_authenticator/widgets/widget_keys.dart';

import '../../../../tests_app_wrapper.dart';

void main() {
  group('GenerateTwoStepDialog & TwoStepDialog Tests', () {
    final Uint8List testPassword = Uint8List.fromList([1, 2, 3]);

    testWidgets('GenerateTwoStepDialog shows progress indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: GenerateTwoStepDialog(
            saltLength: 32,
            iterations: 100,
            keyLength: 32,
            password: testPassword,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('TwoStepDialog displays formatted checksum and blocks pop', (
      tester,
    ) async {
      const testChecksum = 'ABCDEFGH12345678';

      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) =>
                    const TwoStepDialog(phoneChecksum: testChecksum),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('ABCD EFGH'), findsOneWidget);
      expect(find.byKey(twoStepDialogContent), findsOneWidget);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);

      final dismissButton = find.byType(IntentButton);
      await tester.tap(dismissButton);
      await tester.pumpAndSettle();

      expect(find.byType(TwoStepDialog), findsNothing);
    });

    testWidgets('Dialogs handle long title fading', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: TwoStepDialog(phoneChecksum: '1234')),
      );

      final titleText = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(DefaultDialog),
              matching: find.byType(Text),
            )
            .first,
      );

      expect(titleText.overflow, TextOverflow.fade);
      expect(titleText.softWrap, isFalse);
    });
  });
}
