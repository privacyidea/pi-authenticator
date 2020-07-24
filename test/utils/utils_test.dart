/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

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
  _testParseOtpAuth();
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

void _testParseOtpAuth() {
  group("parse otpauth uris: ", () {
    group("HOTP and TOTP", () {
      test("Test with wrong uri schema", () {
        expect(
            () => parseQRCodeToMap("http://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=SHA1&digits=6&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test with unknown type", () {
        expect(
            () => parseQRCodeToMap("otpauth://asdf/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=SHA1&digits=6&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test with missing type", () {
        expect(
            () => parseQRCodeToMap("otpauth:///ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=SHA1&digits=6&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test missing algorithm", () {
        Map<String, dynamic> map =
            parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&digits=6&period=30");
        expect(map[URI_ALGORITHM], "SHA1"); // This is the default value
      });

      test("Test unknown algorithm", () {
        expect(
            () => parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=BubbleSort&digits=6&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test missing digits", () {
        Map<String, dynamic> map =
            parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&period=30");
        expect(map[URI_DIGITS], 6); // This is the default value
      });

      // At least the library used to calculate otp values does not support other number of digits.
      test("Test invalid number of digits", () {
        expect(
            () => parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=SHA1&digits=66&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test invalid characters for digits", () {
        expect(
            () => parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=SHA1&digits=aA&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test missing secret", () {
        expect(
            () => parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test invalid secret", () {
        expect(
            () => parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=ÖÖ&issuer=ACME%20Co&algorithm=SHA1&digits=6"
                "&period=30"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      // TOTP specific
      test("Test missing period", () {
        Map<String, dynamic> map =
            parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=SHA1&digits=6");
        expect(map[URI_PERIOD], 30);
      });

      test("Test invalid characters for period", () {
        expect(
            () => parseQRCodeToMap("otpauth://totp/ACME%20Co:john@example.com?"
                "secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co"
                "&algorithm=SHA1&digits=6&period=aa"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test valid totp uri", () {
        Map<String, dynamic> map = parseQRCodeToMap(
            "otpauth://totp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ"
            "&issuer=ACME%20Co&algorithm=SHA512&digits=8&period=60");
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
            () => parseQRCodeToMap(
                "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ"
                "&issuer=ACME%20Co&algorithm=SHA256&digits=8"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test with invalid counter", () {
        expect(
            () => parseQRCodeToMap(
                "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ"
                "&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=aa"),
            throwsA(TypeMatcher<ArgumentError>()));
      });

      test("Test valid hotp uri", () {
        Map<String, dynamic> map = parseQRCodeToMap(
            "otpauth://hotp/Kitchen?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ"
            "&issuer=ACME%20Co&algorithm=SHA256&digits=8&counter=5");
        expect(map[URI_LABEL], "Kitchen");
        expect(map[URI_ALGORITHM], "SHA256");
        expect(map[URI_DIGITS], 8);
        expect(
            map[URI_SECRET],
            decodeSecretToUint8(
                "HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ", Encodings.base32));
        expect(map[URI_COUNTER], 5);
      });
    });

    group("2 Step Rollout", () {
      test("is2StepURI", () {
        expect(
            is2StepURI(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_salt=8&2step_output=20")),
            true);
        expect(
            is2StepURI(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_salt=8&2step_difficulty=10000")),
            true);
        expect(
            is2StepURI(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_output=20&2step_difficulty=10000")),
            true);
        expect(
            is2StepURI(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA&2step_salt=8")),
            true);

        expect(
            is2StepURI(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE&counter=1&digits=6&issuer=privacyIDEA")),
            false);
      });

      test("parse complete uri", () {
        Map<String, dynamic> uriMap = parseOtpAuth(Uri.parse(
            "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE"
            "&counter=1&digits=6&issuer=privacyIDEA&2step_salt=54"
            "&2step_output=42&2step_difficulty=12345"));

        expect(uriMap[URI_SALT_LENGTH], 54);
        expect(uriMap[URI_OUTPUT_LENGTH_IN_BYTES], 42);
        expect(uriMap[URI_ITERATIONS], 12345);
      });

      test("parse with default values", () {
        expect(
            parseOtpAuth(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE"
                "&counter=1&digits=6&issuer=privacyIDEA&2step_output=42"
                "&2step_difficulty=12345"))[URI_SALT_LENGTH],
            10);
        expect(
            parseOtpAuth(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE"
                "&counter=1&digits=6&issuer=privacyIDEA&2step_salt=54"
                "&2step_difficulty=12345"))[URI_OUTPUT_LENGTH_IN_BYTES],
            20);
        expect(
            parseOtpAuth(Uri.parse(
                "otpauth://hotp/OATH0001F662?secret=HDOMWJ5GEQQA6RR34RAP55QBVCX3E2RE"
                "&counter=1&digits=6&issuer=privacyIDEA&2step_salt=54"
                "&2step_output=42"))[URI_ITERATIONS],
            10000);
      });
    });

    group("Push Token", () {
      test("parse complete uri", () {
        // TODO Do these work on iOS?

        Map<String, dynamic> uriMap = parsePiAuth(Uri.parse(
            "otpauth://pipush/PIPU0001353C?url=https%3A//192.168.178.32/ttype/"
            "push&ttl=2&issuer=privacyIDEA"
            "&enrollment_credential=69ebdbd37a70dcd2dfd4d166cc5325158dc7befe"
            "&projectnumber=645909237054&projectid=lkfhgdf"
            "&appid=1%3A645909237054%3Aandroid%3A812605f9a33242a9"
            "&apikey=AIzaSyAGyFpiB9pUILcXKpfagENJCPqvvUWdiRk"
            "&appidios=AIzaSyAGyFpiB9pUILcXKpfagENJCPqvvUWdiRk"
            "&apikeyios=AIzaSyAGyFpiB9pUILcXKpfagENJCPqvvUWdiRk&v=1"
            "&serial=PIPU0001353C&sslverify=0"));

        expect(uriMap[URI_LABEL], "PIPU0001353C");
        expect(uriMap[URI_SERIAL], "PIPU0001353C");
        expect(uriMap[URI_TTL], 2);
        expect(uriMap[URI_ISSUER], "privacyIDEA");
        expect(uriMap[URI_ENROLLMENT_CREDENTIAL],
            "69ebdbd37a70dcd2dfd4d166cc5325158dc7befe");
        expect(uriMap[URI_PROJECT_NUMBER], "645909237054");
        expect(uriMap[URI_PROJECT_ID], "lkfhgdf");
        expect(uriMap[URI_APP_ID], "1:645909237054:android:812605f9a33242a9");
        expect(uriMap[URI_API_KEY], "AIzaSyAGyFpiB9pUILcXKpfagENJCPqvvUWdiRk");
        expect(uriMap[URI_SSL_VERIFY], false);
      });
    });
  });
}
