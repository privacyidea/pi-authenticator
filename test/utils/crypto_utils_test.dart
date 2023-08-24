/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

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
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

void main() {
  _testGeneratePhoneChecksum();
  _testPbkdf2();
  _testRSASigning();
  _testDecodeSecretToUint8();
  _testEncodeSecretAs();
  _testIsValidEncoding();
}

/// Just a helper method to make tests shorter
Future<String> generateWrapper(List<int> l) async {
  return generatePhoneChecksum(phonePart: Uint8List.fromList(l));
}

void _testGeneratePhoneChecksum() {
  group('generatePhoneChecksum', () {
    test('1. SHA-1', () async => expect(await generateWrapper([0, 1, 2, 3, 4, 5, 6]), 'NXEG6EIAAEBAGBAFAY'));
    test('2. SHA-1', () async => expect(await generateWrapper([9, 8, 7, 6, 5, 4, 3, 2, 1]), 'THKHQSYJBADQMBIEAMBAC'));
    test('3. SHA-1', () async => expect(await generateWrapper([3, 5, 7, 2, 3, 4, 9, 1, 0, 4, 7, 3, 5, 6]), 'TGEEJ7QDAUDQEAYEBEAQABAHAMCQM'));
    test('4. SHA-1', () async => expect(await generateWrapper([9, 5, 8, 1, 7, 3]), '2DO4TDAJAUEACBYD'));
    test('5. SHA-1', () async => expect(await generateWrapper([1, 0, 2, 9, 3, 8, 4, 7, 5, 6]), 'ZOOALWIBAABASAYIAQDQKBQ'));
  });
}

void _testPbkdf2() {
  group('pbkdf2', () {
    Uint8List password = Uint8List.fromList([4, 142, 237, 243, 55, 58, 148, 100, 127, 56, 11, 99, 75, 217, 3, 59, 121, 167, 42, 164]);
    Uint8List salt = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
    int iterations = 10000;
    int keyLen = 20;

    group('Different passwords', () {
      test(
        'Pwd 1',
        () async => expect(
            await pbkdf2(
              password: Uint8List.fromList([204, 142, 237, 243, 154, 5, 48, 206, 127, 56, 11, 156, 75, 217, 116, 59, 121, 67, 152, 46]),
              keyLength: keyLen,
              iterations: iterations,
              salt: salt,
            ),
            Uint8List.fromList([105, 176, 234, 116, 177, 125, 213, 148, 111, 87, 172, 184, 141, 16, 185, 208, 250, 127, 212, 64])),
        timeout: const Timeout(Duration(seconds: 60)),
      );

      test(
        'Pwd 2',
        () async => expect(
            await pbkdf2(
              password: Uint8List.fromList([66, 142, 237, 243, 12, 5, 48, 206, 127, 56, 11, 99, 75, 217, 116, 59, 121, 167, 152, 4]),
              keyLength: keyLen,
              iterations: iterations,
              salt: salt,
            ),
            Uint8List.fromList([11, 157, 107, 247, 204, 194, 23, 69, 211, 238, 200, 86, 38, 234, 99, 227, 247, 44, 220, 135])),
        timeout: const Timeout(Duration(seconds: 60)),
      );

      test(
        'Pwd 3',
        () async => expect(
            await pbkdf2(
              password: Uint8List.fromList([222, 142, 237, 243, 55, 5, 48, 0, 127, 56, 11, 99, 75, 217, 3, 59, 121, 167, 152, 164]),
              keyLength: keyLen,
              iterations: iterations,
              salt: salt,
            ),
            Uint8List.fromList([57, 88, 51, 7, 80, 51, 239, 58, 125, 6, 80, 79, 80, 62, 16, 0, 255, 245, 137, 168])),
        timeout: const Timeout(Duration(seconds: 60)),
      );

      test(
        'Pwd 4',
        () async => expect(
            await pbkdf2(
              password: Uint8List.fromList([4, 142, 237, 243, 55, 58, 148, 100, 127, 56, 11, 99, 75, 217, 3, 59, 121, 167, 42, 164]),
              keyLength: keyLen,
              iterations: iterations,
              salt: salt,
            ),
            Uint8List.fromList([135, 33, 148, 191, 86, 136, 13, 50, 14, 0, 188, 246, 48, 26, 209, 229, 68, 239, 111, 221])),
        timeout: const Timeout(Duration(seconds: 60)),
      );
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
            Uint8List.fromList([0, 149, 53, 169, 140, 36, 152, 54, 213, 123, 214, 14, 11, 199, 89, 78, 180, 108, 104, 177])),
        timeout: const Timeout(Duration(seconds: 60)),
      );

      test(
        'Salt 2',
        () async => expect(
            await pbkdf2(
              password: password,
              keyLength: keyLen,
              iterations: iterations,
              salt: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
            ),
            Uint8List.fromList([135, 33, 148, 191, 86, 136, 13, 50, 14, 0, 188, 246, 48, 26, 209, 229, 68, 239, 111, 221])),
        timeout: const Timeout(Duration(seconds: 60)),
      );

      test(
        'Salt 3',
        () async => expect(
            await pbkdf2(
              password: password,
              keyLength: keyLen,
              iterations: iterations,
              salt: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5]),
            ),
            Uint8List.fromList([29, 98, 40, 192, 122, 52, 24, 18, 189, 124, 119, 99, 251, 64, 81, 75, 149, 176, 77, 210])),
        timeout: const Timeout(Duration(seconds: 60)),
      );

      test(
        'Salt 4',
        () async => expect(
            await pbkdf2(
              password: password,
              keyLength: keyLen,
              iterations: iterations,
              salt: Uint8List.fromList([42, 42, 42, 5, 6, 7, 8, 42]),
            ),
            Uint8List.fromList([196, 70, 123, 140, 14, 167, 102, 50, 223, 223, 120, 158, 35, 10, 215, 202, 117, 26, 85, 46])),
        timeout: const Timeout(Duration(seconds: 60)),
      );
    });

    group(
      'Different iterations',
      () {
        test(
          '100',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 100,
                salt: salt,
              ),
              Uint8List.fromList([126, 248, 52, 21, 94, 28, 200, 201, 165, 237, 0, 31, 10, 157, 59, 76, 63, 189, 247, 132])),
          timeout: const Timeout(Duration(seconds: 60)),
        );

        test(
          '1000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 1000,
                salt: salt,
              ),
              Uint8List.fromList([70, 150, 241, 120, 152, 55, 135, 238, 232, 88, 94, 42, 245, 251, 156, 76, 165, 128, 102, 119])),
          timeout: const Timeout(Duration(seconds: 60)),
        );

        test(
          '10 000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 10000,
                salt: salt,
              ),
              Uint8List.fromList([135, 33, 148, 191, 86, 136, 13, 50, 14, 0, 188, 246, 48, 26, 209, 229, 68, 239, 111, 221])),
          timeout: const Timeout(Duration(seconds: 60)),
        );

        test(
          '100 000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 100000,
                salt: salt,
              ),
              Uint8List.fromList([60, 246, 237, 212, 183, 224, 78, 28, 204, 190, 27, 137, 164, 163, 80, 89, 21, 81, 244, 109])),
          timeout: const Timeout(Duration(seconds: 60)),
        );

        test(
          '1 000 000',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: keyLen,
                iterations: 1000000,
                salt: salt,
              ),
              Uint8List.fromList([25, 39, 153, 115, 182, 177, 160, 241, 96, 198, 31, 79, 145, 109, 102, 47, 205, 167, 246, 253])),
          timeout: const Timeout(Duration(seconds: 60)),
        );
      },
    );

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
              Uint8List.fromList([135, 33, 148, 191, 86, 136, 13, 50, 14, 0, 188, 246])));

      test(
          'Key lenght 20',
          () async => expect(
              await pbkdf2(
                password: password,
                keyLength: 20,
                iterations: iterations,
                salt: salt,
              ),
              Uint8List.fromList([135, 33, 148, 191, 86, 136, 13, 50, 14, 0, 188, 246, 48, 26, 209, 229, 68, 239, 111, 221])));

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
            ])),
        timeout: const Timeout(Duration(seconds: 60)),
      );

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
            ])),
        timeout: const Timeout(Duration(seconds: 60)),
      );
    });
  });
}

void _testRSASigning() {
  group(
    'RSA signing and verifying',
    () {
      test('Signature is valid', () async {
        var asymmetricKeyPair = await generateRSAKeyPair();
        RSAPublicKey publicKey = asymmetricKeyPair.publicKey;
        RSAPrivateKey privateKey = asymmetricKeyPair.privateKey;

        String message = 'I am a signature.';

        var signature = createRSASignature(privateKey, utf8.encode(message) as Uint8List);

        expect(true, verifyRSASignature(publicKey, utf8.encode(message) as Uint8List, signature));
      }, timeout: const Timeout(Duration(minutes: 5)));

      test('Signature is invalid', () async {
        var asymmetricKeyPair = await generateRSAKeyPair();
        RSAPublicKey publicKey = asymmetricKeyPair.publicKey;
        RSAPrivateKey privateKey = asymmetricKeyPair.privateKey;

        String message = 'I am a signature.';

        var signature = createRSASignature(privateKey, utf8.encode(message) as Uint8List);

        expect(false, verifyRSASignature(publicKey, utf8.encode('I am not the signature you are looking for.') as Uint8List, signature));
      }, timeout: const Timeout(Duration(minutes: 5)));
    },
  );
}

void _testDecodeSecretToUint8() {
  group('decodeSecretToUint8', () {
    test('Test non hex secret', () {
      expect(() => decodeSecretToUint8('oo', Encodings.hex), throwsFormatException);
      expect(() => decodeSecretToUint8('1Aö', Encodings.hex), throwsFormatException);
    });

    test('Test hex secret', () {
      expect(decodeSecretToUint8('ABCD', Encodings.hex), Uint8List.fromList([171, 205]));
      expect(decodeSecretToUint8('0FF8', Encodings.hex), Uint8List.fromList([15, 248]));
    });

    test('Test non base32 secret', () {
      expect(() => decodeSecretToUint8('p', Encodings.base32), throwsFormatException);
      expect(() => decodeSecretToUint8('AAAAAAöA', Encodings.base32), throwsFormatException);
    });

    test('Test base32 secret', () {
      expect(decodeSecretToUint8('OBZGS5TBMN4Q====', Encodings.base32), Uint8List.fromList([112, 114, 105, 118, 97, 99, 121]));
      expect(decodeSecretToUint8('JFCEKQI=', Encodings.base32), Uint8List.fromList([73, 68, 69, 65]));
    });

    test('Test utf-8 secret', () {
      expect(decodeSecretToUint8('ABCD', Encodings.none), Uint8List.fromList([65, 66, 67, 68]));
      expect(decodeSecretToUint8('DEG3', Encodings.none), Uint8List.fromList([68, 69, 71, 51]));
    });
  });
}

void _testEncodeSecretAs() {
  group('encodeSecretAs', () {
    test('Test hex secret', () {
      expect(encodeSecretAs(Uint8List.fromList([171, 205]), Encodings.hex), 'abcd');
      expect(encodeSecretAs(Uint8List.fromList([15, 248]), Encodings.hex), '0ff8');
    });

    test('Test base32 secret', () {
      expect(encodeSecretAs(Uint8List.fromList([112, 114, 105, 118, 97, 99, 121]), Encodings.base32), 'OBZGS5TBMN4Q====');
      expect(encodeSecretAs(Uint8List.fromList([73, 68, 69, 65]), Encodings.base32), 'JFCEKQI=');
    });

    test('Test utf-8 secret', () {
      expect(encodeSecretAs(Uint8List.fromList([65, 66, 67, 68]), Encodings.none), 'ABCD');
      expect(encodeSecretAs(Uint8List.fromList([68, 69, 71, 51]), Encodings.none), 'DEG3');
    });
  });
}

void _testIsValidEncoding() {
  group('isValidEncoding', () {
    group('valid encodings', () {
      test('valid hex', () => expect(isValidEncoding('abcd', Encodings.hex), true));
      test('valid base32', () => expect(isValidEncoding('OBZGS5TBMN4Q====', Encodings.base32), true));
    });

    group('invalid encodings', () {
      test('invalid hex', () => expect(isValidEncoding('RXYZ', Encodings.hex), false));
      test('invalid base32', () => expect(isValidEncoding('????', Encodings.base32), false));
    });
  });
}
