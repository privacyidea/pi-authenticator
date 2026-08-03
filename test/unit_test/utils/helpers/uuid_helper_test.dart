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
import 'package:privacyidea_authenticator/utils/helpers/uuid_helper.dart';

/// Tests [uuidV4] structural conformance to RFC 4122 version 4:
/// correct format, version/variant bits, and collision resistance.
void main() {
  final v4Regex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );
  const n = 50000;

  group('uuidV4 conforms to RFC 4122 v4', () {
    test('satisfies v4 format over $n samples', () {
      for (var i = 0; i < n; i++) {
        final mine = uuidV4();
        expect(v4Regex.hasMatch(mine), isTrue, reason: 'invalid: $mine');
        expect(mine.length, 36);
        expect(mine, mine.toLowerCase());
      }
    });

    test('version nibble is 4 and variant is one of 8/9/a/b', () {
      for (var i = 0; i < 20000; i++) {
        final u = uuidV4();
        expect(u[14], '4', reason: u);
        expect('89ab'.contains(u[19]), isTrue, reason: u);
        expect(u[8], '-');
        expect(u[13], '-');
        expect(u[18], '-');
        expect(u[23], '-');
      }
    });

    test('no collisions over $n samples', () {
      final set = <String>{};
      for (var i = 0; i < n; i++) {
        set.add(uuidV4());
      }
      expect(set.length, n);
    });
  });
}
