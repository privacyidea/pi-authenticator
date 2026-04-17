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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/validators.dart';

void main() {
  late Validators validators;
  late AppLocalizations localizations;

  setUp(() async {
    localizations = await AppLocalizations.delegate.load(const Locale('en'));
    validators = Validators(localizations);
  });

  group('password validation', () {
    test('returns error for null', () {
      expect(validators.password(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(validators.password(''), localizations.passwordCannotBeEmpty);
    });

    test('returns error for short password', () {
      expect(
        validators.password('Aa1!xyz'),
        localizations.passwordMustBeAtLeast8Characters,
      );
    });

    test('returns error for password with whitespace', () {
      expect(
        validators.password('Aa1! xyzz'),
        localizations.passwordCannotContainWhitespace,
      );
    });

    test('returns error for password without lowercase', () {
      expect(
        validators.password('AA11!!XY'),
        localizations.passwordMustContainLowercaseLetter,
      );
    });

    test('returns error for password without uppercase', () {
      expect(
        validators.password('aa11!!xy'),
        localizations.passwordMustContainUppercaseLetter,
      );
    });

    test('returns error for password without number', () {
      expect(
        validators.password('AAaa!!xy'),
        localizations.passwordMustContainNumber,
      );
    });

    test('returns error for password without special character', () {
      expect(
        validators.password('AAaa11xy'),
        localizations.passwordMustContainSpecialCharacter,
      );
    });

    test('returns null for valid password', () {
      expect(validators.password('Aa1!xyzz'), isNull);
    });

    test('returns null for complex valid password', () {
      expect(validators.password('P@ssw0rd!#'), isNull);
    });
  });

  group('confirmPassword validation', () {
    test('returns error when passwords do not match', () {
      expect(
        validators.confirmPassword('Aa1!xyzz', 'Aa1!xyyy'),
        localizations.passwordsDoNotMatch,
      );
    });

    test('returns null when passwords match', () {
      expect(validators.confirmPassword('Aa1!xyzz', 'Aa1!xyzz'), isNull);
    });

    test('returns null when both are null', () {
      expect(validators.confirmPassword(null, null), isNull);
    });

    test('returns error when one is null', () {
      expect(
        validators.confirmPassword('Aa1!xyzz', null),
        localizations.passwordsDoNotMatch,
      );
    });
  });
}
