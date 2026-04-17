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
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/utils/object_validator/object_validators.dart'
    as ov;
import 'package:privacyidea_authenticator/utils/object_validator/object_validators.dart';

void main() {
  group('RequiredObjectValidator', () {
    test('string transforms valid value', () {
      expect(ov.Validators.string.transform('hello', 'field'), 'hello');
    });

    test('string throws on null', () {
      expect(
        () => ov.Validators.string.transform(null, 'field'),
        throwsA(anything),
      );
    });

    test('intType transforms string to int', () {
      expect(ov.Validators.intType.transform('42', 'field'), 42);
    });

    test('intType transforms int directly', () {
      expect(ov.Validators.intType.transform(42, 'field'), 42);
    });

    test('intType throws on null', () {
      expect(
        () => ov.Validators.intType.transform(null, 'field'),
        throwsA(anything),
      );
    });

    test('intType throws on invalid string', () {
      expect(
        () => ov.Validators.intType.transform('abc', 'field'),
        throwsA(anything),
      );
    });

    test('boolType transforms bool', () {
      expect(ov.Validators.boolType.transform(true, 'field'), true);
      expect(ov.Validators.boolType.transform(false, 'field'), false);
    });

    test('boolType transforms int', () {
      expect(ov.Validators.boolType.transform(1, 'field'), true);
      expect(ov.Validators.boolType.transform(0, 'field'), false);
    });

    test('boolType transforms string', () {
      expect(ov.Validators.boolType.transform('true', 'field'), true);
      expect(ov.Validators.boolType.transform('false', 'field'), false);
      expect(ov.Validators.boolType.transform('1', 'field'), true);
      expect(ov.Validators.boolType.transform('0', 'field'), false);
    });

    test('boolType throws on invalid string', () {
      expect(
        () => ov.Validators.boolType.transform('maybe', 'field'),
        throwsA(anything),
      );
    });

    test('algorithms transforms string', () {
      expect(
        ov.Validators.algorithms.transform('SHA1', 'field'),
        Algorithms.SHA1,
      );
      expect(
        ov.Validators.algorithms.transform('SHA256', 'field'),
        Algorithms.SHA256,
      );
      expect(
        ov.Validators.algorithms.transform('SHA512', 'field'),
        Algorithms.SHA512,
      );
    });

    test('algorithms throws on invalid string', () {
      expect(
        () => ov.Validators.algorithms.transform('INVALID', 'field'),
        throwsA(anything),
      );
    });

    test('isTypeOf checks correctly', () {
      final validator = RequiredObjectValidator<String>();
      expect(validator.isTypeOf('hello'), isTrue);
      expect(validator.isTypeOf(42), isFalse);
      expect(validator.isTypeOf(null), isFalse);
    });

    test('isTypeOf with transformer allows any non-null', () {
      expect(ov.Validators.intType.isTypeOf('42'), isTrue);
      expect(ov.Validators.intType.isTypeOf(null), isFalse);
    });

    test('otpPeriod valueIsAllowed rejects zero', () {
      expect(ov.Validators.otpPeriod.valueIsAllowed(0, 'field'), isFalse);
    });

    test('otpPeriod accepts positive values', () {
      expect(ov.Validators.otpPeriod.transform(30, 'field'), 30);
    });

    test('otpCounter accepts zero', () {
      expect(ov.Validators.otpCounter.transform(0, 'field'), 0);
    });

    test('optional returns OptionalObjectValidator', () {
      final optional = ov.Validators.string.optional();
      expect(optional, isA<OptionalObjectValidator<String>>());
    });

    test('withDefault returns DefaultObjectValidator', () {
      final withDefault = ov.Validators.string.withDefault('fallback');
      expect(withDefault, isA<DefaultObjectValidator<String>>());
    });
  });

  group('OptionalObjectValidator', () {
    test('returns null for null input', () {
      expect(ov.Validators.stringOptional.transform(null, 'field'), isNull);
    });

    test('transforms valid value', () {
      expect(ov.Validators.stringOptional.transform('hello', 'field'), 'hello');
    });

    test('returns null for invalid value', () {
      expect(ov.Validators.intOptional.transform('abc', 'field'), isNull);
    });

    test('isTypeOf allows null', () {
      expect(ov.Validators.stringOptional.isTypeOf(null), isTrue);
      expect(ov.Validators.stringOptional.isTypeOf('hello'), isTrue);
    });

    test('valueIsAllowed returns true for null', () {
      expect(
        ov.Validators.stringOptional.valueIsAllowed(null, 'field'),
        isTrue,
      );
    });

    test('optional of optional returns same', () {
      final opt = ov.Validators.stringOptional;
      expect(opt.optional(), same(opt));
    });

    test('withDefault returns DefaultObjectValidator', () {
      final withDefault = ov.Validators.stringOptional.withDefault('fallback');
      expect(withDefault, isA<DefaultObjectValidator<String>>());
      expect(withDefault.transform(null, 'field'), 'fallback');
    });
  });

  group('DefaultObjectValidator', () {
    test('returns default for null', () {
      expect(ov.Validators.stringSafe.transform(null, 'field'), '');
    });

    test('returns default for invalid value', () {
      final validator = ov.Validators.intType.withDefault(99);
      expect(validator.transform('abc', 'field'), 99);
    });

    test('transforms valid value', () {
      expect(ov.Validators.stringSafe.transform('hello', 'field'), 'hello');
    });

    test('boolSafeTrue defaults to true', () {
      expect(ov.Validators.boolSafeTrue.transform(null, 'field'), true);
    });

    test('boolSafeFalse defaults to false', () {
      expect(ov.Validators.boolSafeFalse.transform(null, 'field'), false);
    });

    test('otpPeriodSafe defaults to 30', () {
      expect(ov.Validators.otpPeriodSafe.transform(null, 'field'), 30);
    });

    test('otpDigitsSafe defaults to 6', () {
      expect(ov.Validators.otpDigitsSafe.transform(null, 'field'), 6);
    });

    test('otpCounterSafe defaults to 0', () {
      expect(ov.Validators.otpCounterSafe.transform(null, 'field'), 0);
    });

    test('isTypeOf allows null', () {
      expect(ov.Validators.stringSafe.isTypeOf(null), isTrue);
    });

    test('optional returns OptionalObjectValidator', () {
      final opt = ov.Validators.stringSafe.optional();
      expect(opt, isA<OptionalObjectValidator<String>>());
    });

    test('withDefault returns new DefaultObjectValidator', () {
      final newDefault = ov.Validators.stringSafe.withDefault('other');
      expect(newDefault.transform(null, 'field'), 'other');
    });
  });

  group('base32String', () {
    test('normalizes and validates valid base32', () {
      expect(
        ov.Validators.base32String.transform('JBSWY3DPEHPK3PXP', 'field'),
        'JBSWY3DPEHPK3PXP',
      );
    });

    test('normalizes lowercase to uppercase', () {
      expect(
        ov.Validators.base32String.transform('jbswy3dp', 'field'),
        'JBSWY3DP',
      );
    });

    test('removes spaces', () {
      expect(
        ov.Validators.base32String.transform('JBSW Y3DP', 'field'),
        'JBSWY3DP',
      );
    });

    test('rejects invalid base32', () {
      expect(
        () => ov.Validators.base32String.transform('!!!invalid!!!', 'field'),
        throwsA(anything),
      );
    });
  });

  group('base32ToBytes', () {
    test('converts base32 string to bytes', () {
      final result = ov.Validators.base32ToBytes.transform('JBSWY3DP', 'field');
      expect(result, isA<Uint8List>());
      expect(result.isNotEmpty, isTrue);
    });

    test('passes through Uint8List', () {
      final input = Uint8List.fromList([1, 2, 3]);
      final result = ov.Validators.base32ToBytes.transform(input, 'field');
      expect(result, input);
    });
  });

  group('duration validators', () {
    test('secondsDuration transforms int', () {
      final result = ov.Validators.secondsDuration.transform(60, 'field');
      expect(result, const Duration(seconds: 60));
    });

    test('secondsDuration transforms string', () {
      final result = ov.Validators.secondsDuration.transform('30', 'field');
      expect(result, const Duration(seconds: 30));
    });

    test('minutesDuration transforms int', () {
      final result = ov.Validators.minutesDuration.transform(5, 'field');
      expect(result, const Duration(minutes: 5));
    });

    test('secondsDurationOptional returns null for null', () {
      expect(
        ov.Validators.secondsDurationOptional.transform(null, 'field'),
        isNull,
      );
    });
  });

  group('uri validator', () {
    test('transforms string to Uri', () {
      final result = ov.Validators.uri.transform(
        'https://example.com',
        'field',
      );
      expect(result, Uri.parse('https://example.com'));
    });

    test('passes through Uri', () {
      final input = Uri.parse('https://example.com');
      expect(ov.Validators.uri.transform(input, 'field'), input);
    });

    test('uriOptional returns null for null', () {
      expect(ov.Validators.uriOptional.transform(null, 'field'), isNull);
    });
  });

  group('validate function', () {
    test('validates and returns transformed value', () {
      final result = validate(
        value: '42',
        validator: ov.Validators.intType,
        name: 'count',
      );
      expect(result, 42);
    });

    test('throws for null on required', () {
      expect(
        () => validate(
          value: null,
          validator: ov.Validators.string,
          name: 'name',
        ),
        throwsA(anything),
      );
    });

    test('returns default for null on default validator', () {
      final result = validate(
        value: null,
        validator: ov.Validators.stringSafe,
        name: 'name',
      );
      expect(result, '');
    });
  });

  group('validateMap function', () {
    test('validates a map of values', () {
      final result = validateMap<Object?>(
        map: {'name': 'Alice', 'age': '30'},
        validators: <String, BaseValidator<Object?>>{
          'name': ov.Validators.string,
          'age': ov.Validators.intToString,
        },
        name: 'user',
      );
      expect(result['name'], 'Alice');
      expect(result['age'], '30');
    });

    test('skips null values from optional validators', () {
      final result = validateMap<Object?>(
        map: {'name': 'Alice'},
        validators: <String, BaseValidator<Object?>>{
          'name': ov.Validators.string,
          'email': ov.Validators.stringOptional,
        },
        name: 'user',
      );
      expect(result.containsKey('name'), isTrue);
      expect(result.containsKey('email'), isFalse);
    });
  });
}
