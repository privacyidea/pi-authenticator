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
import 'package:privacyidea_authenticator/utils/helpers/json_canonicalizer.dart';

/// A single backslash, spelled out so the expectations below stay readable.
const String bs = r'\';

void main() {
  group('canonicalizeJson', () {
    // Reference vectors of the server side specification. The app has to be
    // byte identical with the server or no signature will ever match.
    test('matches the server reference vectors', () {
      expect(
        canonicalizeJson({'decline_reason': true}),
        '{"decline_reason":true}',
      );
      expect(
        canonicalizeJson({
          'capabilities': {'decline_reason': true},
          'nonce': 'ABC123',
        }),
        '{"capabilities":{"decline_reason":true},"nonce":"ABC123"}',
      );
      expect(
        canonicalizeJson({
          'decline_reason': {
            'values': ['cancelled', 'unknown_trigger'],
          },
        }),
        '{"decline_reason":{"values":["cancelled","unknown_trigger"]}}',
      );
    });

    test('sorts object keys ascending by utf-16 code unit', () {
      expect(
        canonicalizeJson({'b': true, 'A': false, 'a': true, 'B': false}),
        '{"A":false,"B":false,"a":true,"b":true}',
      );
      expect(
        canonicalizeJson({'ä': true, 'z': false, 'Z': false}),
        '{"Z":false,"z":false,"ä":true}',
      );
    });

    test('keeps the given order of list items', () {
      expect(canonicalizeJson(['b', 'a', 'c']), '["b","a","c"]');
      expect(canonicalizeJson(<Object>[]), '[]');
      expect(canonicalizeJson(<String, Object>{}), '{}');
    });

    test('escapes quotes and backslashes', () {
      expect(canonicalizeJson(r'a"b\c'), r'"a\"b\\c"');
    });

    test('escapes control characters', () {
      final shortEscapes = String.fromCharCodes([0x08, 0x09, 0x0a, 0x0c, 0x0d]);
      expect(canonicalizeJson(shortEscapes), r'"\b\t\n\f\r"');
      expect(
        canonicalizeJson(String.fromCharCodes([0x00, 0x01, 0x1f])),
        '"${bs}u0000${bs}u0001${bs}u001f"',
      );
      expect(canonicalizeJson(String.fromCharCode(0x20)), '" "');
    });

    test('leaves everything above the control characters as raw utf-8', () {
      expect(canonicalizeJson('äöü€😀'), '"äöü€😀"');
    });

    test('rejects values that have no unambiguous canonical form', () {
      expect(() => canonicalizeJson(null), throwsFormatException);
      expect(() => canonicalizeJson(1), throwsFormatException);
      expect(() => canonicalizeJson(1.5), throwsFormatException);
      expect(() => canonicalizeJson({'a': null}), throwsFormatException);
      expect(() => canonicalizeJson({'a': 1}), throwsFormatException);
      expect(() => canonicalizeJson([1]), throwsFormatException);
    });

    test('rejects object keys that are not strings', () {
      expect(() => canonicalizeJson({1: true}), throwsFormatException);
    });
  });
}
