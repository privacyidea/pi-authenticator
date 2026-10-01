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
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/exception_errors/localized_argument_error.dart';
import 'package:privacyidea_authenticator/utils/object_validator/object_validators.dart';

LocalizedArgumentError _catch(void Function() fn) {
  try {
    fn();
  } on LocalizedArgumentError catch (e) {
    return e;
  }
  fail('Expected a LocalizedArgumentError');
}

void main() {
  final en = AppLocalizationsEn();

  group('default invalid message', () {
    test('uses the argument order parameter, type, value', () {
      final validator = RequiredObjectValidator<int>();
      final e = _catch(
        () => validate(value: 'abc', validator: validator, name: 'counter'),
      );
      expect(
        e.localizedMessage(en),
        'The String “abc“ is not valid for “counter“',
      );
      expect(e.name, 'counter');
      expect(e.invalidValue, 'abc');
    });

    test('works for a non-string wrong type', () {
      final e = _catch(
        () => validate(value: 5, validator: Validators.string, name: 'label'),
      );
      expect(e.localizedMessage(en), 'The int “5“ is not valid for “label“');
    });

    test('null value for a required validator', () {
      final e = _catch(
        () => validate(value: null, validator: Validators.string, name: 'x'),
      );
      expect(e.localizedMessage(en), 'The Null “null“ is not valid for “x“');
    });
  });

  group('invalidMessage / unallowedMessage', () {
    test('httpUri uses invalidHttpUrl for an unallowed scheme', () {
      final e = _catch(
        () => validate(
          value: 'ftp://example.com/x',
          validator: Validators.httpUri,
          name: 'url',
        ),
      );
      expect(e.localizedMessage(en), en.invalidHttpUrl);
    });

    test('invalid transform still uses the generic text', () {
      final validator = RequiredObjectValidator<Uri>(
        unallowedMessage: (l, _, _) => l.invalidHttpUrl,
      );
      final e = _catch(
        () => validate(value: 'abc', validator: validator, name: 'url'),
      );
      expect(e.localizedMessage(en), 'The String “abc“ is not valid for “url“');
    });

    test('custom invalidMessage is used for invalid transform', () {
      final validator = RequiredObjectValidator<int>(
        invalidMessage: (_, v, n) => 'custom $n $v',
      );
      final e = _catch(
        () => validate(value: 'abc', validator: validator, name: 'n'),
      );
      expect(e.localizedMessage(en), 'custom n abc');
    });

    test('optional() keeps the messages', () {
      final v = RequiredObjectValidator<int>(
        invalidMessage: (_, _, _) => 'inv',
        unallowedMessage: (_, _, _) => 'unal',
      ).optional();
      expect(v.invalidMessage, isNotNull);
      expect(v.unallowedMessage, isNotNull);
      final e = _catch(
        () => validate(
          value: "ftp://e.com",
          validator: Validators.httpUri.optional(),
          name: 'u',
        ),
      );
      expect(e.localizedMessage(en), en.invalidHttpUrl);
    });

    test('withDefault() keeps the messages', () {
      final v = Validators.httpUri.withDefault(Uri.parse('https://a.b'));
      expect(v.unallowedMessage, same(Validators.httpUri.unallowedMessage));
      final fromOptional = Validators.httpUri.optional().withDefault(
        Uri.parse('https://a.b'),
      );
      expect(
        fromOptional.unallowedMessage,
        same(Validators.httpUri.unallowedMessage),
      );
      final e = _catch(
        () => validate(value: 'ftp://example.com/x', validator: v, name: 'u'),
      );
      expect(e.localizedMessage(en), en.invalidHttpUrl);
    });

    test('optional() on httpUri throws with unallowedMessage', () {
      final e = _catch(
        () => validate(
          value: 'ftp://example.com/x',
          validator: Validators.httpUri.optional(),
          name: 'u',
        ),
      );
      expect(e.localizedMessage(en), en.invalidHttpUrl);
    });
  });

  group('validate throws unallowed error', () {
    test('otpPeriod 0 throws LocalizedArgumentError', () {
      final e = _catch(
        () =>
            validate(value: 0, validator: Validators.otpPeriod, name: 'period'),
      );
      expect(e.localizedMessage(en), 'The int “0“ is not valid for “period“');
    });

    test('allowed value passes', () {
      expect(
        validate(value: 30, validator: Validators.otpPeriod, name: 'period'),
        30,
      );
    });
  });
}
