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
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/api/interfaces/container_api.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_container_repository.dart';
import 'package:privacyidea_authenticator/model/enums/sync_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/ecc_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/buttons/rollover_container_tokens_button.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/intent_button.dart';

import '../../../../../tests_app_wrapper.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTokenContainerFinalized mockContainer;
  setUp(() {
    mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('test-serial-123');
  });
  Future<void> pumpButton(
    WidgetTester tester, {
    required SyncState state,
    bool containerExists = true,
  }) async {
    when(mockContainer.syncState).thenReturn(state);
    when(mockContainer.serial).thenReturn('test-serial-123');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenContainerProvider.overrideWith(
            () => _MockNotifier(containerExists ? mockContainer : null),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: RolloverContainerTokensButton(container: mockContainer),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('RolloverContainerTokensButton - SyncState Corners', () {
    testWidgets('should be enabled when state is notStarted', (tester) async {
      await pumpButton(tester, state: SyncState.notStarted);
      final button = tester.widget<IntentButton>(find.byType(IntentButton));
      expect(button.onPressed, isNotNull);
    });
    testWidgets('should be disabled when state is syncing', (tester) async {
      await pumpButton(tester, state: SyncState.syncing);
      final button = tester.widget<IntentButton>(find.byType(IntentButton));
      expect(button.onPressed, isNull);
    });
    testWidgets('should be enabled when state is completed', (tester) async {
      await pumpButton(tester, state: SyncState.completed);
      final button = tester.widget<IntentButton>(find.byType(IntentButton));
      expect(button.onPressed, isNotNull);
    });
    testWidgets('should be enabled when state is failed', (tester) async {
      await pumpButton(tester, state: SyncState.failed);
      final button = tester.widget<IntentButton>(find.byType(IntentButton));
      expect(button.onPressed, isNotNull);
    });
    testWidgets(
      'should be disabled if container is missing regardless of state',
      (tester) async {
        await pumpButton(
          tester,
          state: SyncState.notStarted,
          containerExists: false,
        );
        final button = tester.widget<IntentButton>(find.byType(IntentButton));
        expect(button.onPressed, isNull);
      },
    );
  });
  group('RolloverContainerTokensButton - Visual Corners', () {
    testWidgets('should use Stack with correct alignment', (tester) async {
      await pumpButton(tester, state: SyncState.notStarted);
      final stackFinder = find.descendant(
        of: find.byType(RolloverContainerTokensButton),
        matching: find.byType(Stack),
      );
      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.alignment, Alignment.center);
    });
  });
}

class _MockNotifier extends TokenContainerNotifier {
  final TokenContainerFinalized? _result;
  _MockNotifier(this._result);
  @override
  Future<TokenContainerState> build({
    required TokenContainerApi containerApi,
    required EccUtils eccUtils,
    required TokenContainerRepository repo,
  }) async {
    return TokenContainerState(containerList: _result != null ? [_result] : []);
  }
}
