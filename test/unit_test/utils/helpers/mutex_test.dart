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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/helpers/mutex.dart';

/// Tests the self-implemented [Mutex] for correct mutual-exclusion behavior.
void main() {
  group('Mutex behavioral tests', () {
    test('isLocked transitions on acquire/release', () async {
      final m = Mutex();
      expect(m.isLocked, isFalse);
      await m.acquire();
      expect(m.isLocked, isTrue);
      m.release();
      expect(m.isLocked, isFalse);
    });

    test('release without a held lock throws StateError', () {
      final m = Mutex();
      expect(() => m.release(), throwsStateError);
    });

    test('acquire() is granted first-in-first-out', () async {
      final m = Mutex();
      final order = <int>[];
      final futures = <Future>[];
      for (var i = 0; i < 8; i++) {
        futures.add(() async {
          await m.acquire();
          order.add(i);
          await Future<void>.delayed(Duration.zero);
          m.release();
        }());
      }
      await Future.wait(futures);
      expect(order, [0, 1, 2, 3, 4, 5, 6, 7]);
    });

    test('protect() never lets two critical sections overlap', () async {
      final m = Mutex();
      var inside = 0;
      var maxInside = 0;
      final futures = <Future>[];
      for (var i = 0; i < 20; i++) {
        futures.add(
          m.protect(() async {
            inside++;
            if (inside > maxInside) maxInside = inside;
            await Future<void>.delayed(Duration.zero);
            inside--;
          }),
        );
      }
      await Future.wait(futures);
      expect(maxInside, 1);
      expect(inside, 0);
    });

    test(
      'protect() serializes non-atomic updates to a shared counter',
      () async {
        final m = Mutex();
        var counter = 0;
        final futures = <Future>[];
        for (var i = 0; i < 100; i++) {
          futures.add(
            m.protect(() async {
              final tmp = counter;
              await Future<void>.delayed(Duration.zero);
              counter = tmp + 1;
            }),
          );
        }
        await Future.wait(futures);
        expect(counter, 100);
      },
    );

    test('protect() releases the lock even when the section throws', () async {
      final m = Mutex();
      await expectLater(
        m.protect(() async => throw StateError('boom')),
        throwsStateError,
      );
      expect(m.isLocked, isFalse);
      // The mutex is still usable afterwards.
      await m.acquire();
      expect(m.isLocked, isTrue);
      m.release();
    });

    test('protect() returns the value of the critical section', () async {
      final m = Mutex();
      final result = await m.protect(() async => 42);
      expect(result, 42);
    });
  });
}
