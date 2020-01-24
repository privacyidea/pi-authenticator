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

import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

void main() {
  _testDecodeSecretToUint8();
  _testCalculateHotpValue();
  _testInsertCharAt();
  _testParseQRCodeToToken();
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
  // We need to use different tokens here, because simply incrementing the
  // counter between all method calls leads to a race condition
  HOTPToken token0 = HOTPToken(
      null, null, Algorithms.SHA1, 6, utf8.encode("secret"),
      counter: 0);
  HOTPToken token1 = HOTPToken(
      null, null, Algorithms.SHA1, 6, utf8.encode("secret"),
      counter: 1);
  HOTPToken token2 = HOTPToken(
      null, null, Algorithms.SHA1, 6, utf8.encode("secret"),
      counter: 2);
  HOTPToken token8 = HOTPToken(
      null, null, Algorithms.SHA1, 6, utf8.encode("secret"),
      counter: 8);

  group("calculateHotpValue", () {
    test("OTP for counter == 0",
        () => expect(calculateHotpValue(token0), "814628"));

    test("OTP for counter == 1",
        () => expect(calculateHotpValue(token1), "533881"));

    test("OTP for counter == 2",
        () => expect(calculateHotpValue(token2), "720111"));

    test("OTP for counter == 8",
        () => expect(calculateHotpValue(token8), "963685"));
  });
}

// TODO test getting right return values
void _testDecodeSecretToUint8() {
  group("decodeSecretToUint8", () {
    test("Check null as secret", () {
      expect(() => decodeSecretToUint8(null, Encodings.none),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Check null as encoding", () {
      expect(() => decodeSecretToUint8("mySecre", null),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test non hex secret", () {
      expect(() => decodeSecretToUint8("oo", Encodings.hex),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test non hex secret", () {
      expect(() => decodeSecretToUint8("1Aö", Encodings.hex),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test non base32 secret", () {
      expect(() => decodeSecretToUint8("p", Encodings.base32),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test non base32 secret", () {
      expect(() => decodeSecretToUint8("AAAAAAöA", Encodings.base32),
          throwsA(TypeMatcher<FormatException>()));
    });
  });
}

void _testParseQRCodeToToken() {
  group("parseQRCodeToToken", () {
    test("Test with wrong uri schema", () {
      expect(
          () => parseQRCodeToToken(
              "http://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test with unknown type", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://asdf/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test with missing type", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth:///ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    // It may be better if we just deal with not having a label.
//    test("Test with missing label", () {
//      expect(
//          () => parseQRCodeToToken(
//              "otpauth://totp/?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=5"),
//          throwsA(TypeMatcher<ArgumentError>()));
//    });

    test("Test missing algorithm", () {
      Map<String, dynamic> map = parseQRCodeToToken(
          "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&digits=6&period=30");
      expect(map[URI_ALGORITHM], "SHA1"); // This is the default value
    });

    test("Test unknown algorithm", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=BubbleSort&digits=6&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test missing digits", () {
      Map<String, dynamic> map = parseQRCodeToToken(
          "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&period=30");
      expect(map[URI_DIGITS], 6); // This is the default value
    });

    // At least the library used to calculate otp values does not support other number of digits.
    test("Test invalid number of digits", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=66&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test invalid characters for digits", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=aA&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test missing secret", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test invalid secret", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=ÖÖ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    // TOTP specific
    test("Test missing period", () {
      Map<String, dynamic> map = parseQRCodeToToken(
          "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6");
      expect(map[URI_PERIOD], 30);
    });

    test("Test invalid characters for period", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=aa"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test valid totp uri", () {
      Map<String, dynamic> map = parseQRCodeToToken(
          "otpauth://totp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA512&digits=8&period=60");
      expect(map[URI_LABEL], "Kitchen");
      expect(map[URI_ALGORITHM], "SHA512");
      expect(map[URI_DIGITS], 8);
      expect(
          map[URI_SECRET],
          decodeSecretToUint8(
              "HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ", Encodings.base32));
      expect(map[URI_PERIOD], 60);
    });

    // HOTP specific
    test("Test with missing counter", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test with invalid counter", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=aa"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test valid hotp uri", () {
      Map<String, dynamic> map = parseQRCodeToToken(
          "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=5");
      expect(map[URI_LABEL], "Kitchen");
      expect(map[URI_ALGORITHM], "SHA256");
      expect(map[URI_DIGITS], 8);
      expect(
          map[URI_SECRET],
          decodeSecretToUint8(
              "HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ", Encodings.base32));
      expect(map[URI_COUNTER], 5);
    });

    // TODO test parsing 2 step salt
    // TODO test default values
    // TODO test works with only one param set
  });
}
