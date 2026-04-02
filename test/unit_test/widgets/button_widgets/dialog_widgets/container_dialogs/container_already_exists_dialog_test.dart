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
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/enums/ec_key_algorithm.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/container_widget.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/container_dialogs/container_already_exists_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../../tests_app_wrapper.dart';

TokenContainerUnfinalized createMockUnfinalized({required String serial}) {
  return TokenContainerUnfinalized(
    serial: serial,
    issuer: 'privacyIDEA',
    ttl: const Duration(minutes: 5),
    nonce: 'nonce_123',
    timestamp: DateTime.now(),
    serverUrl: Uri.parse('https://example.com'),
    ecKeyAlgorithm: EcKeyAlgorithm.prime256v1,
    hashAlgorithm: Algorithms.SHA256,
    sslVerify: true,
  );
}

TokenContainer createMockFinalized({required String serial}) {
  return TokenContainer.finalized(
    serial: serial,
    issuer: 'privacyIDEA',
    nonce: 'nonce_456',
    timestamp: DateTime.now(),
    serverUrl: Uri.parse('https://example.com'),
    ecKeyAlgorithm: EcKeyAlgorithm.prime256v1,
    hashAlgorithm: Algorithms.SHA256,
    sslVerify: true,
    publicClientKey: 'pub',
    privateClientKey: 'priv',
  );
}

class FakeTokenContainerNotifier extends TokenContainerNotifier {
  final List<TokenContainer> _initialData;
  FakeTokenContainerNotifier([this._initialData = const []]);

  @override
  Future<TokenContainerState> build({
    required TokenContainerApi containerApi,
    required EccUtils eccUtils,
    required TokenContainerRepository repo,
  }) async => TokenContainerState(containerList: _initialData);
}

void main() {
  final unfinalized1 = createMockUnfinalized(serial: 'serial_1');
  final unfinalized2 = createMockUnfinalized(serial: 'serial_2');
  final existing1 = createMockFinalized(serial: 'serial_1');
  final existing2 = createMockFinalized(serial: 'serial_2');

  group('ContainerAlreadyExistsDialog - Fixed Enterprise Suite', () {
    testWidgets('Initialization fails on empty list (Assertion)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: ContainerAlreadyExistsDialog([])),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('Shows first container information correctly', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenContainerProvider.overrideWith(
              () => FakeTokenContainerNotifier([existing1]),
            ),
          ],
          child: ContainerAlreadyExistsDialog([unfinalized1]),
        ),
      );

      await pumpUntilFindNWidgets(tester, find.byType(DefaultDialog), 1);
      await tester.pumpAndSettle();

      expect(find.byType(ContainerWidget), findsOneWidget);
      expect(find.textContaining('serial_1'), findsOneWidget);
    });

    testWidgets('Dismissing the only container returns empty list', (
      tester,
    ) async {
      List<TokenContainerUnfinalized>? result;

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenContainerProvider.overrideWith(
              () => FakeTokenContainerNotifier([existing1]),
            ),
          ],
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ContainerAlreadyExistsDialog.showDialog([
                  unfinalized1,
                ]);
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));

      await pumpUntilFindNWidgets(tester, find.byType(DefaultDialog), 1);
      await tester.pumpAndSettle();

      final dismissBtn = find.byWidgetPredicate(
        (w) => w is IntentButton && w.intent == ActionIntent.cancel,
      );

      expect(dismissBtn, findsOneWidget);
      await tester.tap(dismissBtn);
      await tester.pumpAndSettle();

      expect(result, isEmpty);
      expect(find.byType(ContainerAlreadyExistsDialog), findsNothing);
    });

    testWidgets('Replacing the only container returns it in the list', (
      tester,
    ) async {
      List<TokenContainerUnfinalized>? result;

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenContainerProvider.overrideWith(
              () => FakeTokenContainerNotifier([existing1]),
            ),
          ],
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ContainerAlreadyExistsDialog.showDialog([
                  unfinalized1,
                ]);
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await pumpUntilFindNWidgets(tester, find.byType(DefaultDialog), 1);
      await tester.pumpAndSettle();

      final replaceBtn = find.byWidgetPredicate(
        (w) => w is IntentButton && w.intent == ActionIntent.destructive,
      );

      await tester.tap(replaceBtn);
      await tester.pumpAndSettle();

      expect(result?.length, 1);
      expect(result?.first.serial, 'serial_1');
    });

    testWidgets('Sequential processing of multiple containers (Mix)', (
      tester,
    ) async {
      List<TokenContainerUnfinalized>? result;
      final input = [unfinalized1, unfinalized2];

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenContainerProvider.overrideWith(
              () => FakeTokenContainerNotifier([existing1, existing2]),
            ),
          ],
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ContainerAlreadyExistsDialog.showDialog(input);
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await pumpUntilFindNWidgets(tester, find.byType(DefaultDialog), 1);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is IntentButton && w.intent == ActionIntent.destructive,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('serial_2'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is IntentButton && w.intent == ActionIntent.cancel,
        ),
      );
      await tester.pumpAndSettle();

      expect(result?.length, 1);
      expect(result?.first.serial, 'serial_1');
    });

    testWidgets(
      'Renders SizedBox.shrink when container disappears from provider',
      (tester) async {
        await tester.pumpWidget(
          TestsAppWrapper(
            overrides: [
              tokenContainerProvider.overrideWith(
                () => FakeTokenContainerNotifier([]),
              ),
            ],
            child: ContainerAlreadyExistsDialog([unfinalized1]),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.byType(DefaultDialog), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      },
    );

    testWidgets('State persists through parent rebuilds', (tester) async {
      final input = [unfinalized1, unfinalized2];
      final notifier = FakeTokenContainerNotifier([existing1, existing2]);

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [tokenContainerProvider.overrideWith(() => notifier)],
          child: ContainerAlreadyExistsDialog(input),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(ContainerAlreadyExistsDialog),
      );
      expect(state.unhandledContainers.length, 2);

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [tokenContainerProvider.overrideWith(() => notifier)],
          child: ContainerAlreadyExistsDialog(input),
        ),
      );

      expect(state.unhandledContainers.length, 2);
    });
  });
}
