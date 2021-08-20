import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  _testSerializingRSAKeys();
  _testParseOtpAuth();
}

void _testSerializingRSAKeys() {
  group("Serialize RSA public keys", () {
    group('PKCS#1 format', () {
      test('Converting key', () async {
        RSAPublicKey publicKey =
            RSAPublicKey(BigInt.from(431254), BigInt.from(32545));

        String base64String = serializeRSAPublicKeyPKCS1(publicKey);
        RSAPublicKey convertedKey = deserializeRSAPublicKeyPKCS1(base64String);

        expect(publicKey.modulus, convertedKey.modulus);
        expect(publicKey.exponent, convertedKey.exponent);
      }, timeout: Timeout(Duration(seconds: 60)));

      test('Converting generated key', () async {
        var asymmetricKeyPair = await generateRSAKeyPair();
        RSAPublicKey publicKey = asymmetricKeyPair.publicKey;

        String base64String = serializeRSAPublicKeyPKCS1(publicKey);
        RSAPublicKey convertedKey = deserializeRSAPublicKeyPKCS1(base64String);

        expect(publicKey.modulus, convertedKey.modulus);
        expect(publicKey.exponent, convertedKey.exponent);
      }, timeout: Timeout(Duration(seconds: 60)));

      test('Parsing existing key', () async {
        String serializedPublicKey = "MIICCgKCAgEAtOE6hDrwB+9Quk5Ibp9DduUMAmQ"
            "i3KSn4pSZPrj4vhx9COenh+K6NtWFDwSPZcEOMk/s7GXsgAzdQvUVp4KpmBSAL3C"
            "XgwZrhG4DZWRvXhB4P0Toxz1McVnPvabriWqU1L3Jorca1bnlvaaYh9rywbBrxes"
            "IA4VUmfFoWHpn+HMdYp4g2UG1UeBIqBsgI4syPiwlEDW6sWTeSDcvQWTYGBsHMXf"
            "zqNGT6ONo5mTSGqI7F75+KtJdtWfNxOKC9pKXXDG8UlgkkhWu0N6sCu/1PEsDxrc"
            "pW7sKKrrB37J8jbEIOHzg67LgCWqFQMoBmIVRHlzQb5HKIswP10AmjJ7Mks0H1db"
            "jK0/ONnU4A9QzjM0ZQt3mvCe8gE0FwQa7CYv8o1OKItQaxPhqBvcLJqjjXc8iFwJ"
            "Qx5XsFU9jMJskQo+2pBBdW7oGRNqdyX0Zx36OQ48OaqbTciNT7oVQrIPd0oIiHjD"
            "LnwBvwn3y5HmvmczdFAs2gQSryJ2/tS/zxrT/OjcGK4JQGDzbjog4fz7kox0PnGg"
            "ssLfoonhflfpM5Om3vGePeqNnISTbA/yCH7X07dZf2BT5/41/OKzNjGzShFNwifb"
            "WBf1mlwUNh1Vuu+ZGdTQKisxI4G8k2dZrlTWkQqOmLebCE3L38jnh0Oek+Jl9fNm"
            "TcMl8sPWxB8lgGpUCAwEAAQ==";

        expect(
            serializeRSAPublicKeyPKCS1(
                deserializeRSAPublicKeyPKCS1(serializedPublicKey)),
            serializedPublicKey);
      }, timeout: Timeout(Duration(seconds: 60)));
    }, timeout: Timeout(Duration(seconds: 300)));

    group('PKCS#8 format', () {
      test('Converting key', () async {
        RSAPublicKey publicKey =
            RSAPublicKey(BigInt.from(431254), BigInt.from(32545));

        String base64String = serializeRSAPublicKeyPKCS8(publicKey);
        RSAPublicKey convertedKey = deserializeRSAPublicKeyPKCS8(base64String);

        expect(publicKey.modulus, convertedKey.modulus);
        expect(publicKey.exponent, convertedKey.exponent);
      }, timeout: Timeout(Duration(seconds: 60)));

      test('Converting generated key', () async {
        var asymmetricKeyPair = await generateRSAKeyPair();
        RSAPublicKey publicKey = asymmetricKeyPair.publicKey;

        String base64String = serializeRSAPublicKeyPKCS8(publicKey);
        RSAPublicKey convertedKey = deserializeRSAPublicKeyPKCS8(base64String);

        expect(publicKey.modulus, convertedKey.modulus);
        expect(publicKey.exponent, convertedKey.exponent);
      }, timeout: Timeout(Duration(seconds: 60)));

      test('Parse existing key', () async {
        String serializedPublicKey = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCA"
            "gEAwdxugfnlsrd3rwZsEvI8GzEF4BtGEK3+vXRWVv43Z0Itn9NAtN5TWYgUkI/1RdI"
            "ahWSZ8xM8vqza3Vb6SzI/vzw4O22TvFwNGDQcwIpxf/I0Iow+U/0uA0VFH2nPdyeJw"
            "eNjEFaPkIZEHSyJ0CUtNS2umXpx4IyUN2R9Xve4OddbUpfTFPDYdcOiqPn1IkVLan/"
            "t1fyEggabsk0Mdig+lK6JEd3keU1o9cOyHeiplOrmS5mNLV2Alz6Es+gvbvsMkXKvJ"
            "rZ3+f8eVvRMNUgS/UfgIgPflUvUgxhlDCmCs/brZeZMhrUbWN00URdrfRT3xdSmNUV"
            "10LPryk/l9quG8Phn8MKE1cKEEGWcBkuvF0v/f9DqMh6hsXea86oA//bYZM8Nb+mut"
            "EjXSAi5AJxfryci0MGbL5jZaO8a2yfx41f84forxMReBCATDQIzSagMK9Ixln/h/U2"
            "KZarenD6rB1rAd0pQLjXa9GMdfBJdImW3LYNpDaPuV/MPQOGRa851gCTf9Ha7rZl67"
            "ekTgwlEAskZOp6NQz8ZdCl4oc7gaTGjFttBmH1TZtKtkpuvhqXv3Ige6XCzBH40+HC"
            "nuwUCqJvPlKJHd/ikm2OfQS+BsPH8HDvrQGQyHyzBzV20oRfNGPIXVOXc9AEIJAPxB"
            "QYQE2aoTR+l7N4On4x59z8qU1UCAwEAAQ==";

        expect(
            serializeRSAPublicKeyPKCS8(
                deserializeRSAPublicKeyPKCS8(serializedPublicKey)),
            serializedPublicKey);
      }, timeout: Timeout(Duration(seconds: 60)));
    }, timeout: Timeout(Duration(seconds: 300)));
  }, timeout: Timeout(Duration(seconds: 300)));

  group("Serialize RSA private keys", () {
    test('Converting key', () async {
      RSAPrivateKey privateKey = (await generateRSAKeyPair()).privateKey;

      String base64String = serializeRSAPrivateKeyPKCS1(privateKey);
      RSAPrivateKey convertedKey = deserializeRSAPrivateKeyPKCS1(base64String);

      expect(privateKey.modulus, convertedKey.modulus);
      expect(privateKey.exponent, convertedKey.exponent);
      expect(privateKey.p, convertedKey.p);
      expect(privateKey.q, convertedKey.q);
    }, timeout: Timeout(Duration(seconds: 60)));
  }, timeout: Timeout(Duration(seconds: 300)));
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
        Map<String, dynamic> uriMap = parsePiAuth(Uri.parse(
            "otpauth://pipush/PIPU0001353C?url=https%3A//192.168.178.32/ttype/"
            "push"
            "&ttl=2"
            "&issuer=privacyIDEA"
            "&enrollment_credential=69fe"
            "&v=1"
            "&serial=PIPU0001353C"
            "&sslverify=0"));

        expect(uriMap[URI_LABEL], "PIPU0001353C");
        expect(uriMap[URI_SERIAL], "PIPU0001353C");
        expect(uriMap[URI_TTL], 2);
        expect(uriMap[URI_ISSUER], "privacyIDEA");
        expect(uriMap[URI_ENROLLMENT_CREDENTIAL], "69fe");
        expect(uriMap[URI_SSL_VERIFY], false);
      });
    });
  });
}
