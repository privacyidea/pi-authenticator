/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

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

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';
import 'package:privacyidea_authenticator/model/enums/encodings.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/encodings_extension.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';

void main() {
  _testGeneratePhoneChecksum();
  _testPbkdf2();
  _testDecodeSecretToUint8();
  _testEncodeSecretAs();
  _testIsValidEncoding();
  _testDecodeHexString();
}

/// Deterministic pseudo random generator so the fuzz cases are reproducible.
int _lcg(int seed) => (seed * 1103515245 + 12345) & 0x7fffffff;

/// Just a helper method to make tests shorter
Future<String> generateWrapper(List<int> l) async {
  return generatePhoneChecksum(phonePart: Uint8List.fromList(l));
}

void _testGeneratePhoneChecksum() {
  group('generatePhoneChecksum', () {
    test(
      '1. SHA-1',
      () async => expect(
        await generateWrapper([0, 1, 2, 3, 4, 5, 6]),
        'NXEG6EIAAEBAGBAFAY',
      ),
    );
    test(
      '2. SHA-1',
      () async => expect(
        await generateWrapper([9, 8, 7, 6, 5, 4, 3, 2, 1]),
        'THKHQSYJBADQMBIEAMBAC',
      ),
    );
    test(
      '3. SHA-1',
      () async => expect(
        await generateWrapper([3, 5, 7, 2, 3, 4, 9, 1, 0, 4, 7, 3, 5, 6]),
        'TGEEJ7QDAUDQEAYEBEAQABAHAMCQM',
      ),
    );
    test(
      '4. SHA-1',
      () async =>
          expect(await generateWrapper([9, 5, 8, 1, 7, 3]), '2DO4TDAJAUEACBYD'),
    );
    test(
      '5. SHA-1',
      () async => expect(
        await generateWrapper([1, 0, 2, 9, 3, 8, 4, 7, 5, 6]),
        'ZOOALWIBAABASAYIAQDQKBQ',
      ),
    );
  });
}

void _testPbkdf2() {
  group('pbkdf2', () {
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
      164,
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
              46,
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
            64,
          ]),
        ),
        timeout: const Timeout(Duration(seconds: 60)),
      );

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
              4,
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
            135,
          ]),
        ),
        timeout: const Timeout(Duration(seconds: 60)),
      );

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
              164,
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
            168,
          ]),
        ),
        timeout: const Timeout(Duration(seconds: 60)),
      );

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
              164,
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
            221,
          ]),
        ),
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
            177,
          ]),
        ),
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
          ]),
        ),
        timeout: const Timeout(Duration(seconds: 60)),
      );

      test(
        'Salt 3',
        () async => expect(
          await pbkdf2(
            password: password,
            keyLength: keyLen,
            iterations: iterations,
            salt: Uint8List.fromList([
              1,
              2,
              3,
              4,
              5,
              6,
              7,
              8,
              9,
              1,
              2,
              3,
              4,
              5,
            ]),
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
            210,
          ]),
        ),
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
            46,
          ]),
        ),
        timeout: const Timeout(Duration(seconds: 60)),
      );
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
            132,
          ]),
        ),
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
            119,
          ]),
        ),
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
          ]),
        ),
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
            109,
          ]),
        ),
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
            253,
          ]),
        ),
        timeout: const Timeout(Duration(seconds: 60)),
      );
    });

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
          Uint8List.fromList([135]),
        ),
      );

      test(
        'Key lenght 5',
        () async => expect(
          await pbkdf2(
            password: password,
            keyLength: 5,
            iterations: iterations,
            salt: salt,
          ),
          Uint8List.fromList([135, 33, 148, 191, 86]),
        ),
      );
      test(
        'Key lenght 12',
        () async => expect(
          await pbkdf2(
            password: password,
            keyLength: 12,
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
          ]),
        ),
      );

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
            221,
          ]),
        ),
      );

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
            219,
          ]),
        ),
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
            83,
          ]),
        ),
        timeout: const Timeout(Duration(seconds: 60)),
      );
    });
  });
}

void _testDecodeSecretToUint8() {
  group('decodeSecretToUint8', () {
    test('Test non hex secret', () {
      expect(() => Encodings.hex.decode('oo'), throwsFormatException);
      expect(() => Encodings.hex.decode('1Aö'), throwsFormatException);
    });

    test('Test hex secret', () {
      expect(Encodings.hex.decode('ABCD'), Uint8List.fromList([171, 205]));
      expect(Encodings.hex.decode('0FF8'), Uint8List.fromList([15, 248]));
    });

    test('Test non base32 secret', () {
      expect(() => Encodings.base32.decode('AAA+AAA='), throwsFormatException);
      expect(() => Encodings.base32.decode('AAAAAAöA'), throwsFormatException);
    });

    test('Test base32 secret', () {
      expect(
        Encodings.base32.decode('OBZGS5TBMN4Q===='),
        Uint8List.fromList([112, 114, 105, 118, 97, 99, 121]),
      );
      expect(
        Encodings.base32.decode('JFCEKQI='),
        Uint8List.fromList([73, 68, 69, 65]),
      );
    });

    test('Test utf-8 secret', () {
      expect(
        Encodings.none.decode('ABCD'),
        Uint8List.fromList([65, 66, 67, 68]),
      );
      expect(
        Encodings.none.decode('DEG3'),
        Uint8List.fromList([68, 69, 71, 51]),
      );
    });
  });
}

void _testEncodeSecretAs() {
  group('encodeSecretAs', () {
    test('Test hex secret', () {
      expect(Encodings.hex.encode(Uint8List.fromList([171, 205])), 'abcd');
      expect(Encodings.hex.encode(Uint8List.fromList([15, 248])), '0ff8');
    });

    test('Test base32 secret', () {
      expect(
        Encodings.base32.encode(
          Uint8List.fromList([112, 114, 105, 118, 97, 99, 121]),
        ),
        'OBZGS5TBMN4Q====',
      );
      expect(
        Encodings.base32.encode(Uint8List.fromList([73, 68, 69, 65])),
        'JFCEKQI=',
      );
    });

    test('Test utf-8 secret', () {
      expect(
        Encodings.none.encode(Uint8List.fromList([65, 66, 67, 68])),
        'ABCD',
      );
      expect(
        Encodings.none.encode(Uint8List.fromList([68, 69, 71, 51])),
        'DEG3',
      );
    });
  });
}

void _testIsValidEncoding() {
  group('isValidEncoding', () {
    group('valid encodings', () {
      test(
        'valid hex',
        () => expect(Encodings.hex.isValidEncoding('abcd'), true),
      );
      test(
        'valid base32',
        () =>
            expect(Encodings.base32.isValidEncoding('OBZGS5TBMN4Q===='), true),
      );
    });

    group('invalid encodings', () {
      test(
        'invalid hex',
        () => expect(Encodings.hex.isValidEncoding('RXYZ'), false),
      );
      test(
        'invalid base32',
        () => expect(Encodings.base32.isValidEncoding('????'), false),
      );
    });
  });
}

void _testDecodeHexString() {
  group('decodeHexString', () {
    group('valid input', () {
      test('empty string returns empty bytes', () {
        expect(decodeHexString(''), isEmpty);
        expect(decodeHexString(''), isA<Uint8List>());
      });

      test('returns a Uint8List', () {
        expect(decodeHexString('00'), isA<Uint8List>());
        expect(decodeHexString('deadbeef'), isA<Uint8List>());
      });

      test('output length is half the input length', () {
        expect(decodeHexString('00').length, equals(1));
        expect(decodeHexString('0011').length, equals(2));
        expect(decodeHexString('001122334455').length, equals(6));
        expect(decodeHexString('a' * 200).length, equals(100));
      });

      test('single byte boundaries', () {
        expect(decodeHexString('00'), equals([0]));
        expect(decodeHexString('01'), equals([1]));
        expect(decodeHexString('0f'), equals([15]));
        expect(decodeHexString('10'), equals([16]));
        expect(decodeHexString('7f'), equals([127]));
        expect(decodeHexString('80'), equals([128]));
        expect(decodeHexString('a5'), equals([165]));
        expect(decodeHexString('fe'), equals([254]));
        expect(decodeHexString('ff'), equals([255]));
      });

      test('known multi byte vectors', () {
        expect(decodeHexString('deadbeef'), equals([0xde, 0xad, 0xbe, 0xef]));
        expect(decodeHexString('cafebabe'), equals([0xca, 0xfe, 0xba, 0xbe]));
        expect(
          decodeHexString('0011223344556677'),
          equals([0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77]),
        );
      });

      test('leading zeros are preserved, not collapsed', () {
        expect(decodeHexString('0000'), equals([0, 0]));
        expect(decodeHexString('0001'), equals([0, 1]));
        expect(decodeHexString('00ff00'), equals([0, 255, 0]));
      });

      test('all 256 byte values decode correctly', () {
        for (var b = 0; b <= 0xff; b++) {
          final hex = b.toRadixString(16).padLeft(2, '0');
          expect(
            decodeHexString(hex),
            equals([b]),
            reason: 'lowercase byte 0x$hex',
          );
        }
      });

      test('one long string covering every byte value in one call', () {
        final buffer = StringBuffer();
        final expected = <int>[];
        for (var b = 0; b <= 0xff; b++) {
          buffer.write(b.toRadixString(16).padLeft(2, '0'));
          expected.add(b);
        }
        expect(decodeHexString(buffer.toString()), equals(expected));
      });
    });

    group('case insensitivity', () {
      test('uppercase equals lowercase for every byte', () {
        for (var b = 0; b <= 0xff; b++) {
          final lower = b.toRadixString(16).padLeft(2, '0');
          expect(
            decodeHexString(lower.toUpperCase()),
            equals(decodeHexString(lower)),
            reason: 'byte 0x$lower',
          );
        }
      });

      test('mixed case within a single string', () {
        expect(decodeHexString('DeAdBeEf'), equals([0xde, 0xad, 0xbe, 0xef]));
        expect(decodeHexString('AbCdEf'), equals(decodeHexString('abcdef')));
      });
    });

    group('cross check against the hex package', () {
      test('decode(HEX.encode(bytes)) round trips', () {
        final samples = <List<int>>[
          [],
          [0],
          [255],
          [0, 127, 128, 255],
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
          List<int>.generate(256, (i) => i),
        ];
        for (final bytes in samples) {
          expect(
            decodeHexString(HEX.encode(bytes)),
            equals(bytes),
            reason: 'bytes $bytes',
          );
        }
      });

      test('matches HEX.decode for arbitrary hex strings', () {
        const inputs = [
          'deadbeef',
          'cafebabe0000ffff',
          '0123456789abcdef',
          'b8d26a05c93186c974b716c3',
        ];
        for (final input in inputs) {
          expect(
            decodeHexString(input),
            equals(HEX.decode(input)),
            reason: input,
          );
        }
      });
    });

    group('real Aegis vectors', () {
      // The exact hex fields used by the Aegis encrypted import (see
      // aegis_import_file_processor_test.dart), decoded during decryption.
      const slotNonce = 'b8d26a05c93186c974b716c3';
      const slotTag = '38c1f02d90831278c5780d656a8c520a';
      const slotSalt =
          'c31919d5a2906f2639a3422c15ff44d3e72285ea46b00a300974d9fb6cdaa0ed';
      const slotKey =
          '60f3ecfe9965767ba15352110c268e58025585e64b9c6c5b5caa6be48b5beb92';
      const headerNonce = '09f056410271f2c24a33d4c6';
      const headerTag = '30656df2f6a1adc0c83bca79ceea9cd6';

      test('decode to the expected byte lengths', () {
        expect(decodeHexString(slotNonce).length, equals(12));
        expect(decodeHexString(slotTag).length, equals(16));
        expect(decodeHexString(slotSalt).length, equals(32));
        expect(decodeHexString(slotKey).length, equals(32));
        expect(decodeHexString(headerNonce).length, equals(12));
        expect(decodeHexString(headerTag).length, equals(16));
      });

      test('agree with the hex package on every field', () {
        for (final field in [
          slotNonce,
          slotTag,
          slotSalt,
          slotKey,
          headerNonce,
          headerTag,
        ]) {
          expect(
            decodeHexString(field),
            equals(HEX.decode(field)),
            reason: field,
          );
        }
      });

      test('first and last bytes of a field are placed correctly', () {
        final salt = decodeHexString(slotSalt);
        expect(salt.first, equals(0xc3));
        expect(salt.last, equals(0xed));
      });
    });

    group('deterministic fuzzing', () {
      test('1000 pseudo random byte arrays round trip', () {
        var seed = 0x1234abcd;
        for (var iteration = 0; iteration < 1000; iteration++) {
          seed = _lcg(seed);
          final length = seed % 64;
          final bytes = <int>[];
          for (var i = 0; i < length; i++) {
            seed = _lcg(seed);
            bytes.add(seed & 0xff);
          }
          final encoded = HEX.encode(bytes);
          expect(
            decodeHexString(encoded),
            equals(bytes),
            reason: 'iteration $iteration, encoded "$encoded"',
          );
        }
      });
    });

    group('invalid input', () {
      test('odd length trips the length assertion', () {
        expect(() => decodeHexString('a'), throwsA(isA<AssertionError>()));
        expect(() => decodeHexString('abc'), throwsA(isA<AssertionError>()));
        expect(() => decodeHexString('deadb'), throwsA(isA<AssertionError>()));
      });

      test('non hexadecimal characters throw a FormatException', () {
        expect(() => decodeHexString('zz'), throwsFormatException);
        expect(() => decodeHexString('gg'), throwsFormatException);
        expect(() => decodeHexString('00zz'), throwsFormatException);
      });
    });
  });
}
