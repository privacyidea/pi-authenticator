/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/helpers/hex_helper.dart';

/// Tests against frozen golden vectors.
void main() {
  group('encode golden vectors', () {
    test('all single bytes 0..255', () {
      for (var b = 0; b <= 255; b++) {
        final expected = b.toRadixString(16).padLeft(2, '0');
        expect(hexEncode([b]), expected, reason: 'byte $b');
      }
    });

    test('known multi-byte golden vectors', () {
      final cases = <(List<int>, String)>[
        ([], ''),
        ([0xde, 0xad, 0xbe, 0xef], 'deadbeef'),
        ([0xca, 0xfe, 0xba, 0xbe], 'cafebabe'),
        ([0, 0, 255, 255], '0000ffff'),
        ([1, 2, 3, 4, 5], '0102030405'),
        (
          [
            115,
            255,
            123,
            179,
            205,
            200,
            153,
            160,
            77,
            234,
            15,
            189,
            48,
            167,
            46,
            149,
            240,
            207,
            47,
            148,
            224,
            224,
            80,
            52,
            242,
            74,
            29,
            137,
            159,
            25,
            109,
            62,
            19,
            138,
            131,
            155,
          ],
          '73ff7bb3cdc899a04dea0fbd30a72e95f0cf2f94e0e05034f24a1d899f196d3e138a839b',
        ),
        (
          [
            22,
            155,
            95,
            167,
            136,
            223,
            135,
            84,
            182,
            39,
            184,
            136,
            94,
            125,
            148,
            136,
            212,
            7,
          ],
          '169b5fa788df8754b627b8885e7d9488d407',
        ),
        (
          [
            234,
            207,
            163,
            72,
            118,
            0,
            63,
            192,
            229,
            178,
            67,
            201,
            222,
            184,
            201,
            44,
            138,
          ],
          'eacfa34876003fc0e5b243c9deb8c92c8a',
        ),
      ];
      for (final (bytes, expected) in cases) {
        expect(hexEncode(bytes), expected, reason: '$bytes');
      }
    });

    test('non-byte integers throw FormatException ', () {
      for (final bad in [256, -1, 999, 0x100, -255, 100000]) {
        expect(() => hexEncode([bad]), throwsFormatException, reason: '$bad');
      }
    });
  });

  group('decode golden vectors', () {
    test('empty string', () {
      expect(hexDecode(''), <int>[]);
    });

    test('all 256 single-byte hex values', () {
      for (var b = 0; b <= 255; b++) {
        final hex = b.toRadixString(16).padLeft(2, '0');
        expect(hexDecode(hex), [b], reason: '$hex');
      }
    });

    test('case insensitivity', () {
      const expected = [0xde, 0xad, 0xbe, 0xef];
      expect(hexDecode('DeAdBeEf'), expected);
      expect(hexDecode('DEADBEEF'), expected);
    });

    test('frozen golden decode vectors', () {
      final cases = <(String, List<int>)>[
        (
          '8c3eEF 8 c3 14aE1cC14a8914c823edaF1c',
          [
            8,
            195,
            238,
            248,
            195,
            20,
            174,
            28,
            193,
            74,
            137,
            20,
            200,
            35,
            237,
            175,
            28,
          ],
        ),
        ('dC5Dc', [13, 197, 220]),
        ('0d086D5D9Ab6 0E018', [0, 208, 134, 213, 217, 171, 96, 224, 24]),
        (
          ' 3f0A B 2916650AA92 aF00 76',
          [63, 10, 178, 145, 102, 80, 170, 146, 175, 0, 118],
        ),
        ('Deb7c4E27BDd 0Df', [13, 235, 124, 78, 39, 189, 208, 223]),
        ('0608', [6, 8]),
        ('dCd6461', [13, 205, 100, 97]),
        (
          'da6Bb82B17F2BBeeD9CEfbd',
          [13, 166, 187, 130, 177, 127, 43, 190, 237, 156, 239, 189],
        ),
        (' 8 6558a', [134, 85, 138]),
        ('3bEf', [59, 239]),
        (' feE1 AAd04aaACB d14c', [254, 225, 170, 208, 74, 170, 203, 209, 76]),
        (' b36Dbb4b2 Ff6', [179, 109, 187, 75, 47, 246]),
        (
          ' AaAE4b97 4fDAc09DE68F',
          [170, 174, 75, 151, 79, 218, 192, 157, 230, 143],
        ),
      ];
      for (final (input, expected) in cases) {
        expect(hexDecode(input), expected, reason: '"$input"');
      }
    });

    test('odd length inputs are left padded', () {
      for (final (input, expected) in [
        ('f', [15]),
        ('abc', [10, 188]),
        ('deadb', [13, 234, 219]),
      ]) {
        expect(hexDecode(input), expected, reason: '"$input"');
      }
    });

    test('spaces are ignored', () {
      for (final (input, expected) in [
        ('de ad be ef', [0xde, 0xad, 0xbe, 0xef]),
        ('  0f  ', [15]),
        ('   ', <int>[]),
      ]) {
        expect(hexDecode(input), expected, reason: '"$input"');
      }
    });

    test('invalid characters throw FormatException ', () {
      for (final s in ['zz', 'gg', '0g', 'x1', '!!', '00zz', 'deadg0']) {
        expect(() => hexDecode(s), throwsFormatException, reason: '"$s"');
      }
    });
  });

  group('round trips', () {
    test('all 65536 byte pairs round trip', () {
      for (var a = 0; a <= 255; a++) {
        for (var b = 0; b <= 255; b++) {
          expect(hexDecode(hexEncode([a, b])), [a, b]);
        }
      }
    });

    test('fuzz 20000 random byte arrays round trip', () {
      final rng = Random(1);
      for (var i = 0; i < 20000; i++) {
        final bytes = List<int>.generate(
          rng.nextInt(64),
          (_) => rng.nextInt(256),
        );
        expect(hexDecode(hexEncode(bytes)), bytes, reason: '$bytes');
      }
    });
  });
}
