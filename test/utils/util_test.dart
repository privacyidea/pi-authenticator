// TODO add license for tests?

import 'dart:convert';

import 'package:matcher/matcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/util.dart';

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
