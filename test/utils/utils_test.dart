/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

void main() {
  _testDecodeSecretToUint8();
  _testCalculateHotpValue();
  _testInsertCharAt();
}

void _testInsertCharAt() {
  final String str = "ABCD";

  group("insertCharAt", () {
    test("Insert at start", () => expect("XABCD", insertCharAt(str, "X", 0)));

    test("Insert at end",
        () => expect("ABCDX", insertCharAt(str, "X", str.length)));

    test("Insert at end", () => expect("ABXCD", insertCharAt(str, "X", 2)));
  });
}

void _testCalculateHotpValue() {
  group("Calculate hotp values", () {
    group("different couters 6 digits", () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 1);
      HOTPToken token2 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 2);
      HOTPToken token8 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 8);

      test("OTP for counter == 0",
          () => expect(calculateHotpValue(token0), "814628"));

      test("OTP for counter == 1",
          () => expect(calculateHotpValue(token1), "533881"));

      test("OTP for counter == 2",
          () => expect(calculateHotpValue(token2), "720111"));

      test("OTP for counter == 8",
          () => expect(calculateHotpValue(token8), "963685"));
    });

    group("different couters 8 digits", () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 1);
      HOTPToken token2 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 2);
      HOTPToken token8 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode("secret"), Encodings.base32),
          counter: 8);

      test("OTP for counter == 0",
          () => expect(calculateHotpValue(token0), "31814628"));

      test("OTP for counter == 1",
          () => expect(calculateHotpValue(token1), "28533881"));

      test("OTP for counter == 2",
          () => expect(calculateHotpValue(token2), "31720111"));

      test("OTP for counter == 8",
          () => expect(calculateHotpValue(token8), "15963685"));
    });

    group("different algorithms 6 digits", () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("Secret"), Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA256,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("Secret"), Encodings.base32),
          counter: 0);
      HOTPToken token2 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA512,
          digits: 6,
          secret: encodeSecretAs(utf8.encode("Secret"), Encodings.base32),
          counter: 0);

      test("OTP for sha1", () => expect(calculateHotpValue(token0), "292574"));

      test(
          "OTP for sha256", () => expect(calculateHotpValue(token1), "203782"));

      test(
          "OTP for sha512", () => expect(calculateHotpValue(token2), "636350"));
    });

    group("different algorithms 8 digits", () {
      // We need to use different tokens here, because simply incrementing the
      // counter between all method calls leads to a race condition
      HOTPToken token0 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA1,
          digits: 8,
          secret: encodeSecretAs(utf8.encode("Secret"), Encodings.base32),
          counter: 0);
      HOTPToken token1 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA256,
          digits: 8,
          secret: encodeSecretAs(utf8.encode("Secret"), Encodings.base32),
          counter: 0);
      HOTPToken token2 = HOTPToken(
          label: null,
          issuer: null,
          algorithm: Algorithms.SHA512,
          digits: 8,
          secret: encodeSecretAs(utf8.encode("Secret"), Encodings.base32),
          counter: 0);

      test(
          "OTP for sha1", () => expect(calculateHotpValue(token0), "25292574"));

      test("OTP for sha256",
          () => expect(calculateHotpValue(token1), "25203782"));

      test("OTP for sha512",
          () => expect(calculateHotpValue(token2), "99636350"));
    });
  });
}

void _testDecodeSecretToUint8() {
  group("decodeSecretToUint8", () {
    test("Check null as secret", () {
      expect(() => decodeSecretToUint8(null, Encodings.none),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Check null as encoding", () {
      expect(() => decodeSecretToUint8("mySecret", null),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test non hex secret", () {
      expect(() => decodeSecretToUint8("oo", Encodings.hex),
          throwsA(TypeMatcher<FormatException>()));

      expect(() => decodeSecretToUint8("1Aö", Encodings.hex),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test hex secret", () {
      expect(decodeSecretToUint8("ABCD", Encodings.hex),
          Uint8List.fromList([171, 205]));

      expect(decodeSecretToUint8("FF8", Encodings.hex),
          Uint8List.fromList([15, 248]));
    });

    test("Test non base32 secret", () {
      expect(() => decodeSecretToUint8("p", Encodings.base32),
          throwsA(TypeMatcher<FormatException>()));

      expect(() => decodeSecretToUint8("AAAAAAöA", Encodings.base32),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test base32 secret", () {
      expect(decodeSecretToUint8("ABCD", Encodings.base32),
          Uint8List.fromList([0, 68]));

      expect(decodeSecretToUint8("DEG3", Encodings.base32),
          Uint8List.fromList([25, 13]));
    });

    test("Test utf-8 secret", () {
      expect(decodeSecretToUint8("ABCD", Encodings.none),
          Uint8List.fromList([65, 66, 67, 68]));

      expect(decodeSecretToUint8("DEG3", Encodings.none),
          Uint8List.fromList([68, 69, 71, 51]));
    });
  });
}
