/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/widgets/status_bar.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('StatusBar Tests', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: StatusBar(child: Text('App Content'))),
      );

      expect(find.text('App Content'), findsOneWidget);
    });

    testWidgets('shows status message when statusProvider emits', (
      tester,
    ) async {
      late StatusNotifier notifier;

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            statusProvider.overrideWith((ref) {
              notifier = StatusNotifier();
              return notifier;
            }),
          ],
          child: const StatusBar(child: Text('Content')),
        ),
      );

      notifier.show((l10n) => 'Success message', isError: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Success message'), findsOneWidget);
    });

    testWidgets('shows error status message', (tester) async {
      late StatusNotifier notifier;

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            statusProvider.overrideWith((ref) {
              notifier = StatusNotifier();
              return notifier;
            }),
          ],
          child: const StatusBar(child: Text('Content')),
        ),
      );

      notifier.show((l10n) => 'Error occurred');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Error occurred'), findsOneWidget);
    });

    testWidgets('shows status message with details', (tester) async {
      late StatusNotifier notifier;

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            statusProvider.overrideWith((ref) {
              notifier = StatusNotifier();
              return notifier;
            }),
          ],
          child: const StatusBar(child: Text('Content')),
        ),
      );

      notifier.show((l10n) => 'Main message', details: (l10n) => 'Detail info');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Main message'), findsOneWidget);
      expect(find.text('Detail info'), findsOneWidget);
    });

    testWidgets('shows multiple status messages sequentially', (tester) async {
      late StatusNotifier notifier;

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            statusProvider.overrideWith((ref) {
              notifier = StatusNotifier();
              return notifier;
            }),
          ],
          child: const StatusBar(child: Text('Content')),
        ),
      );

      notifier.show((l10n) => 'First message', isError: false);
      notifier.show((l10n) => 'Second message', isError: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // First message should be shown
      expect(find.text('First message'), findsOneWidget);
    });
  });
}

class StatusBarOverlayEntryTest extends StatelessWidget {
  const StatusBarOverlayEntryTest({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox();
}
