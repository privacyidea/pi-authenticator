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
import 'package:privacyidea_authenticator/utils/util.dart';

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
  HOTPToken token0 =
      HOTPToken(null, null, SHA1, 6, utf8.encode("secret"), counter: 0);
  HOTPToken token1 =
      HOTPToken(null, null, SHA1, 6, utf8.encode("secret"), counter: 1);
  HOTPToken token2 =
      HOTPToken(null, null, SHA1, 6, utf8.encode("secret"), counter: 2);
  HOTPToken token8 =
      HOTPToken(null, null, SHA1, 6, utf8.encode("secret"), counter: 8);

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
      expect(() => decodeSecretToUint8(null, NONE),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Check null as encoding", () {
      expect(() => decodeSecretToUint8("mySecre", null),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test with unknown encoding", () {
      expect(() => decodeSecretToUint8("mySecret", "thisIsNoBase"),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test("Test non hex secret", () {
      expect(() => decodeSecretToUint8("oo", HEX),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test non hex secret", () {
      expect(() => decodeSecretToUint8("1Aö", HEX),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test non base32 secret", () {
      expect(() => decodeSecretToUint8("p", BASE32),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test non base32 secret", () {
      expect(() => decodeSecretToUint8("AAAAAAöA", BASE32),
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
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test with unknown type", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://asdf/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test with missing type", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth:///ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test with missing label", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=5"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test missing algorithm", () {
      Token token = parseQRCodeToToken(
          "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&digits=6&period=30");
      expect(token.algorithm, SHA1); // This is the default value
    });

    test("Test unknown algorithm", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=BubbleSort&digits=6&period=30"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test missing digits", () {
      Token token = parseQRCodeToToken(
          "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=BubbleSort&period=30");
      expect(token.digits, 6); // This is the default value
    });

    test("Test invalid number of digits", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=66&period=30"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test invalid characters for digits", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=aA&period=30"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test missing secret", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test invalid secret", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=ÖÖ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
          throwsA(TypeMatcher<FormatException>()));
    });

    // TOTP specific
    test("Test missing period", () {
      TOTPToken token = parseQRCodeToToken(
          "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6");
      expect(token.period, 30);
    });

    test("Test invalid characters for period", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=aa"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test valid totp uri", () {
      TOTPToken token = parseQRCodeToToken(
          "otpauth://totp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA512&digits=8&period=60");
      expect(token.label, "Kitchen");
      expect(token.algorithm, SHA512);
      expect(token.digits, 8);
      expect(token.secret,
          decodeSecretToUint8("HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ", BASE32));
      expect(token.period, 60);
    });

    // HOTP specific
    test("Test with missing counter", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test with invalid counter", () {
      expect(
          () => parseQRCodeToToken(
              "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=aa"),
          throwsA(TypeMatcher<FormatException>()));
    });

    test("Test valid hotp uri", () {
      HOTPToken token = parseQRCodeToToken(
          "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=5");
      expect(token.label, "Kitchen");
      expect(token.algorithm, SHA256);
      expect(token.digits, 8);
      expect(token.secret,
          decodeSecretToUint8("HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ", BASE32));
      expect(token.counter, 5);
    });
  });
}
