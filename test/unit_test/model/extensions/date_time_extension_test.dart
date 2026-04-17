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
import 'package:privacyidea_authenticator/model/extensions/date_time_extension.dart';

void main() {
  group('DateTimeX.validator', () {
    test('transforms DateTime through', () {
      final now = DateTime(2026, 4, 16, 12);
      final result = DateTimeX.validator.transform(now, 'field');
      expect(result, now);
    });

    test('transforms ISO string to DateTime', () {
      final result = DateTimeX.validator.transform(
        '2026-04-16T12:00:00.000',
        'field',
      );
      expect(result, DateTime(2026, 4, 16, 12));
    });

    test('transforms Unix timestamp (ms) to DateTime', () {
      final timestamp = DateTime(2026, 4, 16).millisecondsSinceEpoch;
      final result = DateTimeX.validator.transform(timestamp, 'field');
      expect(result, DateTime(2026, 4, 16));
    });

    test('throws on null', () {
      expect(
        () => DateTimeX.validator.transform(null, 'field'),
        throwsA(anything),
      );
    });

    test('throws on invalid type', () {
      expect(
        () => DateTimeX.validator.transform(3.14, 'field'),
        throwsA(anything),
      );
    });

    test('throws on invalid string', () {
      expect(
        () => DateTimeX.validator.transform('not-a-date', 'field'),
        throwsA(anything),
      );
    });
  });
}
