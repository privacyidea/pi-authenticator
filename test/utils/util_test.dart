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
  String qrCode =
      "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30";

  group("parseQRCodeToToken", () {
    test("Test with wrong uri schema", () {
      // TODO
    });

    test("Test with unknown type", () {
      // TODO
    });

    test("Test with missing type", () {
      // TODO
    });

    test("Test with unknown label", () {
      // TODO
    });

    test("Test with missing label", () {
      // TODO
    });

    test("Test missing algorithm", () {
      // TODO
    });

    test("Test unknown algorithm", () {
      // TODO
    });

    test("Test missing digits", () {
      // TODO
    });

    test("Test invalid digits", () {
      // TODO
    });

    test("Test missing secret", () {
      // TODO
    });

    test("Test invalid secret", () {
      // TODO
    });

    // TOTP specific
    test("Test missing period", () {
      // TODO
    });

    test("Test invalid period", () {
      // TODO
    });

    test("Test valid totp uri", () {
      // TODO
    });

    // HOTP specific
    test("Test with missing counter", () {
// TODO
    });

    test("Test with invalid counter", () {
// TODO
    });

    test("Test valid hotp uri", () {
      // TODO
    });
  });
}
