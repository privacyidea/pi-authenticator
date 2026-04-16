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
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/widgets/push_request_listener.dart';

import '../../tests_app_wrapper.dart';
import '../../tests_app_wrapper.mocks.dart';

class FakeTokenNotifierForPush extends TokenNotifier {
  final TokenState _state;
  FakeTokenNotifierForPush(this._state);

  @override
  Future<TokenState> build({
    required firebaseUtils,
    required ioClient,
    required repo,
    required rsaUtils,
  }) async => _state;
}

class FakePushRequestNotifier extends PushRequestNotifier {
  final PushRequestState _state;
  FakePushRequestNotifier(this._state);

  @override
  Future<PushRequestState> build({
    required rsaUtils,
    required ioClient,
    required pushProvider,
    required pushRepo,
  }) async => _state;
}

void main() {
  group('PushRequestListener Tests', () {
    setUp(() {
      PushProvider.instance = MockPushProvider();
      when(
        PushProvider.instance!.pollForChallenges(isManually: false),
      ).thenAnswer((_) async => true);
    });

    testWidgets('renders child when no push tokens exist', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenProvider.overrideWith(
              () => FakeTokenNotifierForPush(const TokenState(tokens: [])),
            ),
            pushRequestProvider.overrideWith(
              () => FakePushRequestNotifier(PushRequestState.empty()),
            ),
          ],
          child: const PushRequestListener(child: Text('Main Content')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('renders child when push tokens exist but no requests', (
      tester,
    ) async {
      final pushToken = PushToken(
        serial: 'PUSH001',
        id: 'push-id-1',
        label: 'Push Token',
        issuer: 'Test Issuer',
        isRolledOut: true,
      );

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenProvider.overrideWith(
              () => FakeTokenNotifierForPush(TokenState(tokens: [pushToken])),
            ),
            pushRequestProvider.overrideWith(
              () => FakePushRequestNotifier(PushRequestState.empty()),
            ),
          ],
          child: const PushRequestListener(child: Text('Main Content')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
    });
  });
}
