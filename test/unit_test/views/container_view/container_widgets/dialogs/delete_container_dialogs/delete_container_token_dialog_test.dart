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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_token_dialog.dart';

import '../../../../../../tests_app_wrapper.dart';
import '../../../../../../tests_app_wrapper.mocks.dart';

void main() {
  testWidgets('should return true when "Delete All" is pressed', (
    tester,
  ) async {
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('SERIAL-123');
    bool? result;

    await tester.pumpWidget(
      TestsAppWrapper(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteContainerTokenDialog.showDialog(
                    mockContainer,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(DeleteContainerTokenDialog),
    );
    final localizations = AppLocalizations.of(context)!;

    await tester.tap(find.text(localizations.deleteAllButtonText));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(DeleteContainerTokenDialog), findsNothing);
  });

  testWidgets('should return false when "Delete Only Container" is pressed', (
    tester,
  ) async {
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('SERIAL-123');
    bool? result;

    await tester.pumpWidget(
      TestsAppWrapper(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteContainerTokenDialog.showDialog(
                    mockContainer,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(DeleteContainerTokenDialog),
    );
    final localizations = AppLocalizations.of(context)!;

    await tester.tap(find.text(localizations.deleteOnlyContainerButtonText));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.byType(DeleteContainerTokenDialog), findsNothing);
  });

  testWidgets('should return null when closed via close button', (
    tester,
  ) async {
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('SERIAL-123');
    bool? result = false;

    await tester.pumpWidget(
      TestsAppWrapper(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteContainerTokenDialog.showDialog(
                    mockContainer,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.byType(DeleteContainerTokenDialog), findsNothing);
  });
}
