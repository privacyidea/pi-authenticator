import 'package:pointycastle/export.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:test/test.dart';

void main() {
  _testSerializingRSAKeys();
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

    // TODO Add test Key -> String
    // TODO Add test String -> Key
  }, timeout: Timeout(Duration(seconds: 300)));
}
