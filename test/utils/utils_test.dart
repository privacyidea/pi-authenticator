/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

void main() {
  _testDecodeSecretToUint8();
  _testcalculateOtpValue();
  _testInsertCharAt();
}

void _testInsertCharAt() {
  final String str = 'ABCD';

  group('insertCharAt', () {
    test('Insert at start', () => expect('XABCD', insertCharAt(str, 'X', 0)));

    test('Insert at end', () => expect('ABCDX', insertCharAt(str, 'X', str.length)));

    test('Insert at end', () => expect('ABXCD', insertCharAt(str, 'X', 2)));
  });
}

void _testcalculateOtpValue() {
  group('Calculate hotp values', () {
    group('different couters 6 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 1);
      HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 2);
      HOTPToken token8 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 8);

      test('OTP for counter == 0', () => expect(token0.calculateOtpValue(), '814628'));

      test('OTP for counter == 1', () => expect(token1.calculateOtpValue(), '533881'));

      test('OTP for counter == 2', () => expect(token2.calculateOtpValue(), '720111'));

      test('OTP for counter == 8', () => expect(token8.calculateOtpValue(), '963685'));
    });

    group('different couters 8 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 1);
      HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 2);
      HOTPToken token8 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('secret') as Uint8List, Encodings.base32),
          counter: 8);

      test('OTP for counter == 0', () => expect(token0.calculateOtpValue(), '31814628'));

      test('OTP for counter == 1', () => expect(token1.calculateOtpValue(), '28533881'));

      test('OTP for counter == 2', () => expect(token2.calculateOtpValue(), '31720111'));

      test('OTP for counter == 8', () => expect(token8.calculateOtpValue(), '15963685'));
    });

    group('different algorithms 6 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0);
      HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA512,
          digits: 6,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0);

      test('OTP for sha1', () => expect(token0.calculateOtpValue(), '292574'));

      test('OTP for sha256', () => expect(token1.calculateOtpValue(), '203782'));

      test('OTP for sha512', () => expect(token2.calculateOtpValue(), '636350'));
    });

    group('different algorithms 8 digits', () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA256,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0);
      HOTPToken token2 = HOTPToken(
          id: '',
          label: '',
          issuer: '',
          algorithm: Algorithms.SHA512,
          digits: 8,
          secret: encodeSecretAs(utf8.encode('Secret') as Uint8List, Encodings.base32),
          counter: 0);

      test('OTP for sha1', () => expect(token0.calculateOtpValue(), '25292574'));

      test('OTP for sha256', () => expect(token1.calculateOtpValue(), '25203782'));

      test('OTP for sha512', () => expect(token2.calculateOtpValue(), '99636350'));
    });
  });
}

void _testDecodeSecretToUint8() {
  group('decodeSecretToUint8', () {
    test('Test non hex secret', () {
      expect(() => decodeSecretToUint8('oo', Encodings.hex), throwsA(TypeMatcher<FormatException>()));

      expect(() => decodeSecretToUint8('1Aö', Encodings.hex), throwsA(TypeMatcher<FormatException>()));
    });

    test('Test hex secret', () {
      expect(decodeSecretToUint8('ABCD', Encodings.hex), Uint8List.fromList([171, 205]));

      expect(decodeSecretToUint8('FF8', Encodings.hex), Uint8List.fromList([15, 248]));
    });

    test('Test non base32 secret', () {
      expect(() => decodeSecretToUint8('p', Encodings.base32), throwsA(TypeMatcher<FormatException>()));

      expect(() => decodeSecretToUint8('AAAAAAöA', Encodings.base32), throwsA(TypeMatcher<FormatException>()));
    });

    test('Test base32 secret', () {
      expect(decodeSecretToUint8('ABCD', Encodings.base32), Uint8List.fromList([0, 68]));

      expect(decodeSecretToUint8('DEG3', Encodings.base32), Uint8List.fromList([25, 13]));
    });

    test('Test utf-8 secret', () {
      expect(decodeSecretToUint8('ABCD', Encodings.none), Uint8List.fromList([65, 66, 67, 68]));

      expect(decodeSecretToUint8('DEG3', Encodings.none), Uint8List.fromList([68, 69, 71, 51]));
    });
  });
}
