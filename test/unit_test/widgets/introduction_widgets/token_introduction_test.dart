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
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import 'package:privacyidea_authenticator/widgets/focused_item_as_overlay.dart';
import 'package:privacyidea_authenticator/widgets/introduction_widgets/token_introduction.dart';

import '../../../tests_app_wrapper.dart';

class FakeIntroductionNotifier extends IntroductionNotifier {
  final IntroductionState _state;
  FakeIntroductionNotifier(this._state);

  @override
  Future<IntroductionState> build({required repo}) async => _state;
}

void main() {
  group('TokenIntroduction Tests', () {
    testWidgets('renders child when all introductions are completed', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            introductionNotifierProvider.overrideWith(
              () => FakeIntroductionNotifier(
                IntroductionState.withAllCompleted(),
              ),
            ),
          ],
          child: const TokenIntroduction(child: Text('Token Content')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Token Content'), findsOneWidget);
      expect(find.byType(FocusedItemAsOverlay), findsNothing);
    });

    testWidgets('renders child during loading state', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          overrides: [
            introductionNotifierProvider.overrideWith(
              () => FakeIntroductionNotifier(const IntroductionState()),
            ),
          ],
          child: const TokenIntroduction(child: Text('Loading Child')),
        ),
      );
      // Only pump once to catch loading state
      await tester.pump();

      expect(find.text('Loading Child'), findsOneWidget);
    });
  });
}
