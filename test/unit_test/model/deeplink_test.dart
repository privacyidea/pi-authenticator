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
import 'package:privacyidea_authenticator/model/deeplink.dart';

void main() {
  group('DeepLink', () {
    test('constructs with uri', () {
      final uri = Uri.parse('https://example.com/token');
      final link = DeepLink(uri);
      expect(link.uri, uri);
      expect(link.fromInit, false);
    });

    test('constructs with fromInit', () {
      final uri = Uri.parse('otpauth://totp/Test');
      final link = DeepLink(uri, fromInit: true);
      expect(link.fromInit, true);
    });

    test('equality works for same values', () {
      final uri = Uri.parse('https://example.com');
      final a = DeepLink(uri, fromInit: true);
      final b = DeepLink(uri, fromInit: true);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal with different uri', () {
      final a = DeepLink(Uri.parse('https://a.com'));
      final b = DeepLink(Uri.parse('https://b.com'));
      expect(a, isNot(equals(b)));
    });

    test('not equal with different fromInit', () {
      final uri = Uri.parse('https://example.com');
      final a = DeepLink(uri, fromInit: true);
      final b = DeepLink(uri);
      expect(a, isNot(equals(b)));
    });

    test('toString returns readable representation', () {
      final uri = Uri.parse('https://example.com');
      final link = DeepLink(uri, fromInit: true);
      expect(link.toString(), contains('https://example.com'));
      expect(link.toString(), contains('fromInit: true'));
    });

    test('not equal to non-DeepLink', () {
      final link = DeepLink(Uri.parse('https://example.com'));
      // ignore: unrelated_type_equality_checks
      expect(link == 'not a deeplink', isFalse);
    });
  });
}
