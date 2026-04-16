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
import 'package:privacyidea_authenticator/widgets/app_wrappers/state_observer.dart';

import '../../../tests_app_wrapper.dart';

void main() {
  group('StateObserver Tests', () {
    testWidgets('renders child widget with no listeners', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: StateObserver(child: Text('Observed Child')),
        ),
      );

      expect(find.text('Observed Child'), findsOneWidget);
    });

    testWidgets('renders child with empty listener lists', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: StateObserver(child: Text('Empty Listeners')),
        ),
      );

      expect(find.text('Empty Listeners'), findsOneWidget);
    });

    testWidgets('child can be a complex widget tree', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(
          child: StateObserver(
            child: Column(
              children: [Text('First'), Text('Second'), Text('Third')],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });
  });
}
