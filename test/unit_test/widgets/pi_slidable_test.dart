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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/slideable_action.dart';
import 'package:privacyidea_authenticator/widgets/pi_slidable.dart';

import '../../tests_app_wrapper.dart';

/// Helper to cleanly remove PiSlidable while keeping globalRef alive,
/// so the dispose postFrameCallback can safely use globalRef.
Future<void> cleanUpPiSlidable(WidgetTester tester) async {
  await tester.pumpWidget(const TestsAppWrapper(child: SizedBox()));
  await tester.pump();
}

void main() {
  group('PiSlidable Tests', () {
    testWidgets(
      'renders simple child without Slidable when actions are empty',
      (tester) async {
        await tester.pumpWidget(
          const TestsAppWrapper(
            child: PiSlidable(
              groupTag: 'tag',
              identifier: 'id',
              actions: [],
              child: Text('Base Child'),
            ),
          ),
        );
        expect(find.text('Base Child'), findsOneWidget);
        expect(find.byType(Slidable), findsNothing);
        await cleanUpPiSlidable(tester);
      },
    );
    testWidgets(
      'renders Slidable and stack correctly when actions are present',
      (tester) async {
        await tester.pumpWidget(
          const TestsAppWrapper(
            child: PiSlidable(
              groupTag: 'tag',
              identifier: 'id',
              actions: [FakeSlideableAction()],
              stack: [Text('Overlay Text')],
              child: Text('Base Child'),
            ),
          ),
        );
        expect(find.byType(Slidable), findsOneWidget);
        expect(find.text('Base Child'), findsOneWidget);
        expect(find.text('Overlay Text'), findsOneWidget);
        await cleanUpPiSlidable(tester);
      },
    );
    testWidgets('registers and unregisters controller in piSlidablesRef', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PiSlidable(
            groupTag: 'group',
            identifier: '1',
            actions: [FakeSlideableAction()],
            child: SizedBox(height: 100, width: 100),
          ),
        ),
      );
      await tester.pump();
      expect(globalRef!.read(piSlidablesRef).length, 1);
      await cleanUpPiSlidable(tester);
      expect(globalRef!.read(piSlidablesRef).length, 0);
    });
    testWidgets('uses correct ValueKey for Slidable', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: PiSlidable(
            groupTag: 'myGroup',
            identifier: 'myId',
            actions: [FakeSlideableAction()],
            child: SizedBox(),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('myGroup-myId')), findsOneWidget);
      await cleanUpPiSlidable(tester);
    });
  });
}

/// Concrete implementation of the abstract ConsumerSlideableAction for testing purposes.
class FakeSlideableAction extends ConsumerSlideableAction {
  const FakeSlideableAction({super.key});
  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) {
    return CustomSlidableAction(onPressed: (_) {}, child: const Text('Action'));
  }
}
