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
import 'package:privacyidea_authenticator/model/enums/patch_note_type.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/patch_notes_dialog.dart';

import '../../../../tests_app_wrapper.dart';

void main() {
  group('PatchNotesDialog Comprehensive Tests', () {
    const v1 = Version(1, 0, 0);
    const v2 = Version(1, 1, 0);

    final Map<Version, Map<PatchNoteType, List<String>>> testNotes = {
      v1: {
        PatchNoteType.newFeature: ['Initial Release'],
      },
      v2: {
        PatchNoteType.newFeature: ['New Feature'],
        PatchNoteType.improvement: ['Better UI'],
        PatchNoteType.bugFix: ['Fixed Bug'],
      },
    };

    testWidgets('renders all versions and notes in descending order', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(child: PatchNotesDialog(newNotes: testNotes)),
      );

      expect(find.textContaining('1.1.0'), findsOneWidget);
      expect(find.textContaining('1.0.0'), findsOneWidget);

      expect(find.text('New Feature'), findsOneWidget);
      expect(find.text('Better UI'), findsOneWidget);
      expect(find.text('Fixed Bug'), findsOneWidget);

      final v1Finder = find.textContaining('1.0.0');
      final v2Finder = find.textContaining('1.1.0');
      expect(
        tester.getCenter(v2Finder).dy < tester.getCenter(v1Finder).dy,
        isTrue,
      );
    });

    testWidgets('OK button interaction and pop', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => PatchNotesDialog(newNotes: testNotes),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final okButton = find.byType(IntentButton);
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      expect(find.byType(PatchNotesDialog), findsNothing);
    });

    testWidgets('calculates and applies dynamic height', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: PatchNotesDialog(newNotes: {})),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, isNotNull);
    });

    testWidgets('structure contains SingleChildScrollView and Column', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(child: PatchNotesDialog(newNotes: testNotes)),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Column),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('renders divider only between version blocks', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(child: PatchNotesDialog(newNotes: testNotes)),
      );

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
