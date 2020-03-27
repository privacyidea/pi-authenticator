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

import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:test/test.dart';

void main() {
  _testGeneratePhoneChecksum();
  _testGenerateSalt();
  _testPbkdf2();
  _testRSASigning();
  _testSerializingRSAKeys();
}

void _testGeneratePhoneChecksum() {
  group('generatePhoneChecksum', () {
    // Test some inputs, verify with python:
    // ```
    //    import hashlib
    //    sha1 = hashlib.sha1()
    //
    //    myList = [1,0,2,9,3,8,4,7,5,6]
    //
    //    sha1.update(bytearray(myList))
    //
    //    print("[", end="")
    //    for i in range(sha1.digest_size):
    //
    //     if i is sha1.digest_size - 1:
    //       print(sha1.digest()[i], end="")
    //      else:
    //       print(sha1.digest()[i], end=", ")
    //
    //    print("]", end="")
    //
    //    import base64
    //
    //    print('\n')
    //    print(base64.b32encode(sha1.digest()[:4] + bytearray(myList)))
    // ```

    test(
        '1. SHA-1',
        () async => expect(await generateWrapper([0, 1, 2, 3, 4, 5, 6]),
            'NXEG6EIAAEBAGBAFAY'));

    test(
        '2. SHA-1',
        () async => expect(await generateWrapper([9, 8, 7, 6, 5, 4, 3, 2, 1]),
            'THKHQSYJBADQMBIEAMBAC'));
    test(
        '3. SHA-1',
        () async => expect(
            await generateWrapper([3, 5, 7, 2, 3, 4, 9, 1, 0, 4, 7, 3, 5, 6]),
            'TGEEJ7QDAUDQEAYEBEAQABAHAMCQM'));
    test(
        '4. SHA-1',
        () async => expect(
            await generateWrapper([9, 5, 8, 1, 7, 3]), '2DO4TDAJAUEACBYD'));
    test(
        '5. SHA-1',
        () async => expect(
            await generateWrapper([1, 0, 2, 9, 3, 8, 4, 7, 5, 6]),
            'ZOOALWIBAABASAYIAQDQKBQ'));
  });
}

/// Just a helper method to make tests shorter
Future<String> generateWrapper(List<int> l) async {
  return generatePhoneChecksum(phonePart: Uint8List.fromList(l));
}

void _testGenerateSalt() {
  group('generateSalt', () {
    test('Generate 5 bytes', () => expect(generateSalt(5).length, 5));
    test('Generate 1 bytes', () => expect(generateSalt(1).length, 1));
    test('Generate 7 bytes', () => expect(generateSalt(7).length, 7));
    test('Generate 33 bytes', () => expect(generateSalt(33).length, 33));
    test('Generate 42 bytes', () => expect(generateSalt(42).length, 42));
  });
}

void _testPbkdf2() {
  // Output matchers generated with python:
  // ```
  //  from hashlib import pbkdf2_hmac
  //
  //  password = bytearray([1, 2, 3, 4, 5])
  //
  //  key = pbkdf2_hmac(
  //      hash_name = 'sha1',
  //      password = password.hex().encode('utf-8'),
  //      salt = bytearray([1, 2, 3, 4, 5, 6, 7, 8]),
  //      iterations = 10000,
  //      dklen = 55
  //  )
  //
  //  print("[", end="")
  //  for i in range(len(key)):
  //
  //  if i is len(key) - 1:
  //  print(key[i], end="")
  //  else:
  //  print(key[i], end=", ")
  //
  //  print("]", end="")
  // ```

  group('pbkfd2', () {
    Uint8List password = Uint8List.fromList([
      4,
      142,
      237,
      243,
      55,
      58,
      148,
      100,
      127,
      56,
      11,
      99,
      75,
      217,
      3,
      59,
      121,
      167,
      42,
      164
    ]);
    Uint8List salt = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
    int iterations = 10000;
    int keyLen = 20;

    group('Different passwords', () {
      test(
          'Pwd 1',
          () async => expect(
              await pbkdf2(
                password: Uint8List.fromList([
                  204,
                  142,
                  237,
                  243,
                  154,
                  5,
                  48,
                  206,
                  127,
                  56,
                  11,
                  156,
                  75,
                  217,
                  116,
                  59,
                  121,
                  67,
                  152,
                  46
                ]),
                keyLength: keyLen,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([
                105,
                176,
                234,
                116,
                177,
                125,
                213,
                148,
                111,
                87,
                172,
                184,
                141,
                16,
                185,
                208,
                250,
                127,
                212,
                64
              ])));

      test(
          'Pwd 2',
          () async => expect(
              await pbkdf2(
                password: Uint8List.fromList([
                  66,
                  142,
                  237,
                  243,
                  12,
                  5,
                  48,
                  206,
                  127,
                  56,
                  11,
                  99,
                  75,
                  217,
                  116,
                  59,
                  121,
                  167,
                  152,
                  4
                ]),
                keyLength: keyLen,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([
                11,
                157,
                107,
                247,
                204,
                194,
                23,
                69,
                211,
                238,
                200,
                86,
                38,
                234,
                99,
                227,
                247,
                44,
                220,
                135
              ])));

      test(
          'Pwd 3',
          () async => expect(
              await pbkdf2(
                password: Uint8List.fromList([
                  222,
                  142,
                  237,
                  243,
                  55,
                  5,
                  48,
                  0,
                  127,
                  56,
                  11,
                  99,
                  75,
                  217,
                  3,
                  59,
                  121,
                  167,
                  152,
                  164
                ]),
                keyLength: keyLen,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([
                57,
                88,
                51,
                7,
                80,
                51,
                239,
                58,
                125,
                6,
                80,
                79,
                80,
                62,
                16,
                0,
                255,
                245,
                137,
                168
              ])));

      test(
          'Pwd 4',
          () async => expect(
              await pbkdf2(
                password: Uint8List.fromList([
                  4,
                  142,
                  237,
                  243,
                  55,
                  58,
                  148,
                  100,
                  127,
                  56,
                  11,
                  99,
                  75,
                  217,
                  3,
                  59,
                  121,
                  167,
                  42,
                  164
                ]),
                keyLength: keyLen,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([
                135,
                33,
                148,
                191,
                86,
                136,
                13,
                50,
                14,
                0,
                188,
                246,
                48,
                26,
                209,
                229,
                68,
                239,
                111,
                221
              ])));
    });

    group('Different salts', () {
      test(
          'Salt 1',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: iterations,
                salt: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
              ),
              Uint8List.fromList([
                0,
                149,
                53,
                169,
                140,
                36,
                152,
                54,
                213,
                123,
                214,
                14,
                11,
                199,
                89,
                78,
                180,
                108,
                104,
                177
              ])));

      test(
          'Salt 2',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: iterations,
                salt: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
              ),
              Uint8List.fromList([
                135,
                33,
                148,
                191,
                86,
                136,
                13,
                50,
                14,
                0,
                188,
                246,
                48,
                26,
                209,
                229,
                68,
                239,
                111,
                221
              ])));
      test(
          'Salt 3',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: iterations,
                salt: Uint8List.fromList(
                    [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5]),
              ),
              Uint8List.fromList([
                29,
                98,
                40,
                192,
                122,
                52,
                24,
                18,
                189,
                124,
                119,
                99,
                251,
                64,
                81,
                75,
                149,
                176,
                77,
                210
              ])));
      test(
          'Salt 4',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: iterations,
                salt: Uint8List.fromList([42, 42, 42, 5, 6, 7, 8, 42]),
              ),
              Uint8List.fromList([
                196,
                70,
                123,
                140,
                14,
                167,
                102,
                50,
                223,
                223,
                120,
                158,
                35,
                10,
                215,
                202,
                117,
                26,
                85,
                46
              ])));
    });

    group('Different iterations', () {
      test(
          '100',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 100,
                salt: salt,
              ),
              Uint8List.fromList([
                126,
                248,
                52,
                21,
                94,
                28,
                200,
                201,
                165,
                237,
                0,
                31,
                10,
                157,
                59,
                76,
                63,
                189,
                247,
                132
              ])));

      test(
          '1000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 1000,
                salt: salt,
              ),
              Uint8List.fromList([
                70,
                150,
                241,
                120,
                152,
                55,
                135,
                238,
                232,
                88,
                94,
                42,
                245,
                251,
                156,
                76,
                165,
                128,
                102,
                119
              ])));

      test(
          '10 000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 10000,
                salt: salt,
              ),
              Uint8List.fromList([
                135,
                33,
                148,
                191,
                86,
                136,
                13,
                50,
                14,
                0,
                188,
                246,
                48,
                26,
                209,
                229,
                68,
                239,
                111,
                221
              ])));

      test(
          '100 000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 100000,
                salt: salt,
              ),
              Uint8List.fromList([
                60,
                246,
                237,
                212,
                183,
                224,
                78,
                28,
                204,
                190,
                27,
                137,
                164,
                163,
                80,
                89,
                21,
                81,
                244,
                109
              ])));

      test(
          '1 000 000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 1000000,
                salt: salt,
              ),
              Uint8List.fromList([
                25,
                39,
                153,
                115,
                182,
                177,
                160,
                241,
                96,
                198,
                31,
                79,
                145,
                109,
                102,
                47,
                205,
                167,
                246,
                253
              ])));
    }, timeout: Timeout(Duration(seconds: 60)));

    group('Different output lengths', () {
      test(
          'Key lenght 1',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: 1,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([135])));

      test(
          'Key lenght 5',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: 5,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([135, 33, 148, 191, 86])));
      test(
          'Key lenght 12',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: 12,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList(
                  [135, 33, 148, 191, 86, 136, 13, 50, 14, 0, 188, 246])));

      test(
          'Key lenght 20',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: 20,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([
                135,
                33,
                148,
                191,
                86,
                136,
                13,
                50,
                14,
                0,
                188,
                246,
                48,
                26,
                209,
                229,
                68,
                239,
                111,
                221
              ])));

      test(
          'Key lenght 33',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: 33,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([
                135,
                33,
                148,
                191,
                86,
                136,
                13,
                50,
                14,
                0,
                188,
                246,
                48,
                26,
                209,
                229,
                68,
                239,
                111,
                221,
                6,
                22,
                78,
                185,
                134,
                87,
                110,
                131,
                183,
                7,
                5,
                208,
                219
              ])));

      test(
          'Key lenght 55',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: 55,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([
                135,
                33,
                148,
                191,
                86,
                136,
                13,
                50,
                14,
                0,
                188,
                246,
                48,
                26,
                209,
                229,
                68,
                239,
                111,
                221,
                6,
                22,
                78,
                185,
                134,
                87,
                110,
                131,
                183,
                7,
                5,
                208,
                219,
                82,
                16,
                35,
                40,
                99,
                223,
                134,
                45,
                102,
                101,
                59,
                19,
                20,
                47,
                119,
                212,
                164,
                58,
                255,
                137,
                22,
                83
              ])));
    });
  });
}

void _testRSASigning() {
  group('rsa signing and verifying', () {
    test('signature is valid', () async {
      var asymmetricKeyPair = await generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;
      RSAPrivateKey privateKey = asymmetricKeyPair.privateKey;

      String message = 'I am a signature.';

      var signature = createSignature(privateKey, utf8.encode(message));

      expect(
          true, validateSignature(publicKey, utf8.encode(message), signature));
    });

    test('signature is invalid', () async {
      var asymmetricKeyPair = await generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;
      RSAPrivateKey privateKey = asymmetricKeyPair.privateKey;

      String message = 'I am a signature.';

      var signature = createSignature(privateKey, utf8.encode(message));

      expect(
          false,
          validateSignature(
              publicKey,
              utf8.encode('I am not the signature you are looking for.'),
              signature));
    });

    test('signature is invalid because of flipped parameters', () async {
      var asymmetricKeyPair = await generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;
      RSAPrivateKey privateKey = asymmetricKeyPair.privateKey;

      String message = 'I am a signature.';

      var signature = createSignature(privateKey, utf8.encode(message));

      expect(
          false, validateSignature(publicKey, signature, utf8.encode(message)));
    });
  });
}

void _testSerializingRSAKeys() {
  group('serialize rsa public keys', () {
    test('Converting key', () async {
      RSAPublicKey publicKey =
          RSAPublicKey(BigInt.from(431254), BigInt.from(32545));

      String base64String = convertPublicKeyToDER(publicKey);
      RSAPublicKey convertedKey = convertDERToPublicKey(base64String);

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    });

    test('Converting generated key', () async {
      var asymmetricKeyPair = await generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;

      String base64String = convertPublicKeyToDER(publicKey);
      RSAPublicKey convertedKey = convertDERToPublicKey(base64String);

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    });

    // TODO test with serialized key
  });

  group('Other format', () {
    test('Converting key', () async {
      RSAPublicKey publicKey =
          RSAPublicKey(BigInt.from(431254), BigInt.from(32545));

      String base64String = derComplicatedToString(publicKey);
      RSAPublicKey convertedKey = derComplicatedToKey(base64String);

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    });

    test('Converting generated key', () async {
      var asymmetricKeyPair = await generateRSAKeyPair();
      RSAPublicKey publicKey = asymmetricKeyPair.publicKey;

      String base64String = derComplicatedToString(publicKey);
      RSAPublicKey convertedKey = derComplicatedToKey(base64String);

      expect(publicKey.modulus, convertedKey.modulus);
      expect(publicKey.exponent, convertedKey.exponent);
    });

    test('parse working key', () async {
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

      expect(derComplicatedToString(derComplicatedToKey(serializedPublicKey)),
          serializedPublicKey);
    });
  });

  group('Formats should be interchangable', () {
    // TODO
  });
}
