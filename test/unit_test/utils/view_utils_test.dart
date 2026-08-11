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
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

void main() {
  group('status messages with a stale ref', () {
    tearDown(() => globalRef = null);

    /// Pumps a widget tree, captures its ref and unmounts it again, so the
    /// returned ref belongs to an unmounted widget.
    Future<WidgetRef> pumpAndUnmount(WidgetTester tester) async {
      late WidgetRef ref;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, widgetRef, _) {
              ref = widgetRef;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(const SizedBox());
      return ref;
    }

    testWidgets('an unmounted ref throws when it is used directly', (
      tester,
    ) async {
      // Guards the premise of the tests below: this is what the fallback in
      // showErrorStatusMessage has to prevent.
      final staleRef = await pumpAndUnmount(tester);

      expect(() => staleRef.read(statusProvider), throwsStateError);
    });

    testWidgets('an unmounted ref is replaced by globalRef', (tester) async {
      final staleRef = await pumpAndUnmount(tester);

      late WidgetRef liveRef;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              liveRef = ref;
              globalRef = ref;
              return const SizedBox();
            },
          ),
        ),
      );

      showErrorStatusMessage(
        message: (l) => 'message',
        details: (l) => 'details',
        ref: staleRef,
      );

      final status = liveRef.read(statusProvider).current;
      expect(status, isNotNull);
      expect(status!.type, StatusMessageType.error);
    });

    testWidgets('a success message falls back to globalRef too', (
      tester,
    ) async {
      final staleRef = await pumpAndUnmount(tester);

      late WidgetRef liveRef;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              liveRef = ref;
              globalRef = ref;
              return const SizedBox();
            },
          ),
        ),
      );

      showSuccessStatusMessage(message: (l) => 'message', ref: staleRef);

      expect(
        liveRef.read(statusProvider).current?.type,
        StatusMessageType.success,
      );
    });

    testWidgets('nothing throws when no usable ref is available at all', (
      tester,
    ) async {
      final staleRef = await pumpAndUnmount(tester);
      globalRef = null;

      expect(
        () => showErrorStatusMessage(message: (l) => 'message', ref: staleRef),
        returnsNormally,
      );
      expect(
        () => showNeutralStatusMessage(message: (l) => 'message'),
        returnsNormally,
      );
    });
  });
}
