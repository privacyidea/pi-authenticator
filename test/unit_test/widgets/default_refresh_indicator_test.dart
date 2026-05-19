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
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/widgets/default_refresh_indicator.dart';

import '../../tests_app_wrapper.dart';

class _FakeTokenNotifier extends TokenNotifier {
  @override
  Future<TokenState> build({
    required firebaseUtils,
    required ioClient,
    required repo,
    required rsaUtils,
  }) async =>
      const TokenState(tokens: []);
}

class _FakeContainerNotifier extends TokenContainerNotifier {
  @override
  Future<TokenContainerState> build({
    required repo,
    required containerApi,
    required eccUtils,
  }) async =>
      const TokenContainerState(containerList: []);
}

void main() {
  group('DefaultRefreshIndicator Tests', () {
    testWidgets('renders child widget when no push tokens or containers exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            tokenProvider.overrideWith(() => _FakeTokenNotifier()),
            tokenContainerProvider.overrideWith(() => _FakeContainerNotifier()),
          ],
          child: const DefaultRefreshIndicator(
            child: Text('Content'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Content'), findsOneWidget);
    });
  });
}
