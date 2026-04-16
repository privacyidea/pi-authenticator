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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/tokens/totp_token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/widgets/token_visibility_shield.dart';

import '../../tests_app_wrapper.dart';
import '../../tests_app_wrapper.mocks.dart';

class FakeTokenNotifierForShield extends TokenNotifier {
  final TokenState _state;
  FakeTokenNotifierForShield(this._state);

  @override
  Future<TokenState> build({
    required firebaseUtils,
    required ioClient,
    required repo,
    required rsaUtils,
  }) async => _state;
}

void main() {
  group('TokenVisibilityShield Tests', () {
    testWidgets('shows child when token is not locked', (tester) async {
      final token = TOTPToken(
        period: 30,
        id: 'test-id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
        isLocked: false,
      );

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenProvider.overrideWith(
              () => FakeTokenNotifierForShield(TokenState(tokens: [token])),
            ),
          ],
          child: TokenVisibilityShield(
            token: token,
            isHidden: true,
            child: const Text('OTP Value'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OTP Value'), findsOneWidget);
      expect(find.byIcon(Icons.remove_red_eye_outlined), findsNothing);
    });

    testWidgets('shows eye icon when token is locked and hidden', (
      tester,
    ) async {
      final token = TOTPToken(
        period: 30,
        id: 'test-id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
        pin: true,
      );

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenProvider.overrideWith(
              () => FakeTokenNotifierForShield(TokenState(tokens: [token])),
            ),
          ],
          child: TokenVisibilityShield(
            token: token,
            isHidden: true,
            child: const Text('OTP Value'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.remove_red_eye_outlined), findsOneWidget);
      expect(find.text('OTP Value'), findsNothing);
    });

    testWidgets('shows child when token is locked but not hidden', (
      tester,
    ) async {
      final token = TOTPToken(
        period: 30,
        id: 'test-id',
        algorithm: Algorithms.SHA1,
        digits: 6,
        secret: 'secret',
        pin: true,
      );

      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenProvider.overrideWith(
              () => FakeTokenNotifierForShield(TokenState(tokens: [token])),
            ),
          ],
          child: TokenVisibilityShield(
            token: token,
            isHidden: false,
            child: const Text('OTP Value'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OTP Value'), findsOneWidget);
      expect(find.byIcon(Icons.remove_red_eye_outlined), findsNothing);
    });
  });
}
