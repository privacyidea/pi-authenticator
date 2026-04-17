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
import 'package:privacyidea_authenticator/model/exception_errors/localized_argument_error.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_exception.dart';

void main() {
  group('LocalizedException', () {
    test('stores unlocalized message', () {
      final ex = LocalizedException(
        localizedMessage: (_) => 'localized',
        unlocalizedMessage: 'Something went wrong',
      );
      expect(ex.unlocalizedMessage, 'Something went wrong');
    });

    test('toString includes unlocalized message', () {
      final ex = LocalizedException(
        localizedMessage: (_) => 'localized',
        unlocalizedMessage: 'error happened',
      );
      expect(ex.toString(), contains('error happened'));
    });

    test('implements Exception', () {
      final ex = LocalizedException(
        localizedMessage: (_) => 'localized',
        unlocalizedMessage: 'msg',
      );
      expect(ex, isA<Exception>());
    });
  });

  group('LocalizedArgumentError', () {
    test('stores invalidValue and name', () {
      final err = LocalizedArgumentError(
        localizedMessage: (l, v, n) => 'Invalid $v for $n',
        unlocalizedMessage: 'Invalid "abc" for "field"',
        invalidValue: 'abc',
        name: 'field',
      );
      expect(err.invalidValue, 'abc');
      expect(err.name, 'field');
    });

    test('message returns unlocalized message', () {
      final err = LocalizedArgumentError(
        localizedMessage: (l, v, n) => 'localized',
        unlocalizedMessage: 'unlocalized msg',
        invalidValue: 'val',
        name: 'name',
      );
      expect(err.message, 'unlocalized msg');
    });

    test('toString contains ArgumentError prefix', () {
      final err = LocalizedArgumentError(
        localizedMessage: (l, v, n) => 'localized',
        unlocalizedMessage: 'bad value',
        invalidValue: 'val',
        name: 'name',
      );
      expect(err.toString(), 'ArgumentError: bad value');
    });

    test('implements ArgumentError', () {
      final err = LocalizedArgumentError(
        localizedMessage: (l, v, n) => 'localized',
        unlocalizedMessage: 'msg',
        invalidValue: 'val',
        name: 'name',
      );
      expect(err, isA<ArgumentError>());
    });

    test('implements LocalizedException', () {
      final err = LocalizedArgumentError(
        localizedMessage: (l, v, n) => 'localized',
        unlocalizedMessage: 'msg',
        invalidValue: 'val',
        name: 'name',
      );
      expect(err, isA<LocalizedException>());
    });
  });
}
