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
import 'package:privacyidea_authenticator/utils/globals.dart';

void main() {
  group('globalRef', () {
    tearDown(() => globalRef = null);

    testWidgets('is the ref of the widget that set it while it is mounted', (
      tester,
    ) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              globalRef = ref;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(globalRef, same(capturedRef));
    });

    testWidgets('is null after the widget that set it was unmounted', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              globalRef = ref;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(globalRef, isNotNull);

      await tester.pumpWidget(const SizedBox());

      expect(globalRef, isNull);
    });

    testWidgets('reading a provider through it does not throw after unmount', (
      tester,
    ) async {
      final counterProvider = Provider((ref) => 0);
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              globalRef = ref;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(const SizedBox());

      expect(() => globalRef?.read(counterProvider), returnsNormally);
    });
  });
}
