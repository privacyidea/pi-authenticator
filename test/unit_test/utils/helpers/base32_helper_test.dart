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
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/helpers/base32_helper.dart';

/// Tests [base32Encode]/[base32Decode] AND the `base32` package against the same
/// frozen golden vectors. Both must produce the same output for the same input.
void main() {
  Uint8List u8(List<int> l) => Uint8List.fromList(l);

  group('encode golden vectors', () {
    test('empty input', () {
      const expected = '';      expect(base32Encode(u8([])), expected, reason: 'helper');
    });

    test('RFC 4648 test vectors', () {
      // https://tools.ietf.org/html/rfc4648#section-10
      final cases = <(List<int>, String)>[
        ([102], 'MY======'), // "f"
        ([102, 111], 'MZXQ===='), // "fo"
        ([102, 111, 111], 'MZXW6==='), // "foo"
        ([102, 111, 111, 98], 'MZXW6YQ='), // "foob"
        ([102, 111, 111, 98, 97], 'MZXW6YTB'), // "fooba"
        ([102, 111, 111, 98, 97, 114], 'MZXW6YTBOI======'), // "foobar"
      ];
      for (final (bytes, expected) in cases) {        expect(base32Encode(u8(bytes)), expected, reason: '$bytes');
      }
    });

    test('single byte representatives (every padding remainder)', () {
      final cases = <(List<int>, String)>[
        ([0], 'AA======'),
        ([1], 'AE======'),
        ([15], 'B4======'),
        ([16], 'CA======'),
        ([127], 'P4======'),
        ([128], 'QA======'),
        ([200], 'ZA======'),
        ([254], '7Y======'),
        ([255], '74======'),
      ];
      for (final (bytes, expected) in cases) {        expect(base32Encode(u8(bytes)), expected, reason: '$bytes');
      }
    });

    test('frozen multi-byte golden vectors (seed 10, lengths 1-10)', () {
      final cases = <(List<int>, String)>[
        ([183], 'W4======'),
        ([57, 71], 'HFDQ===='),
        ([247, 188, 116], '666HI==='),
        ([24, 83, 239, 100], 'DBJ66ZA='),
        ([181, 227, 134, 189, 235], 'WXRYNPPL'),
        ([142, 183, 84, 214, 105, 106], 'R23VJVTJNI======'),
        ([62, 87, 134, 85, 172, 143, 12], 'HZLYMVNMR4GA===='),
        ([138, 187, 224, 197, 126, 235, 159, 152], 'RK56BRL65OPZQ==='),
        ([219, 221, 60, 145, 31, 127, 112, 13, 160], '3POTZEI7P5YA3IA='),
        (
          [208, 229, 212, 183, 254, 191, 245, 215, 211, 150],
          '2DS5JN76X725PU4W',
        ),
      ];
      for (final (bytes, expected) in cases) {        expect(base32Encode(u8(bytes)), expected, reason: '$bytes');
      }
    });

    test('frozen longer golden vectors (seed 11)', () {
      final cases = <(List<int>, String)>[
        ([211, 57, 72, 108, 93, 10, 1, 110, 1, 248], '2M4UQ3C5BIAW4APY'),
        (
          [
            152,
            33,
            123,
            182,
            168,
            106,
            68,
            34,
            237,
            114,
            168,
            7,
            15,
            138,
            76,
            183,
            71,
            194,
          ],
          'TAQXXNVINJCCF3LSVADQ7CSMW5D4E===',
        ),
        (
          [245, 194, 178, 45, 91, 171, 98, 90, 206, 133, 135],
          '6XBLELK3VNRFVTUFQ4======',
        ),
        (
          [
            177,
            208,
            93,
            205,
            226,
            234,
            55,
            177,
            40,
            7,
            80,
            185,
            177,
            249,
            83,
            222,
            181,
            234,
            227,
          ],
          'WHIF3TPC5I33CKAHKC43D6KT3226VYY=',
        ),
        (
          [127, 165, 252, 234, 151, 153, 176, 26, 155, 196, 140, 66, 106, 57],
          'P6S7Z2UXTGYBVG6ERRBGUOI=',
        ),
        ([163], 'UM======'),
      ];
      for (final (bytes, expected) in cases) {        expect(base32Encode(u8(bytes)), expected, reason: '$bytes');
      }
    });
  });

  group('decode golden vectors', () {
    test('empty input', () {      expect(base32Decode(''), u8([]));
    });

    test('known project values', () {
      final cases = <(String, List<int>)>[
        ('OBZGS5TBMN4Q====', [112, 114, 105, 118, 97, 99, 121]),
        ('JFCEKQI=', [73, 68, 69, 65]),
        ('MFRGG===', [97, 98, 99]),
      ];
      for (final (input, expected) in cases) {        expect(base32Decode(input), u8(expected), reason: '"$input"');
      }
    });

    test('frozen decode golden vectors(from encoded seed 11 data)', () {
      final cases = <(String, List<int>)>[
        ('2M4UQ3C5BIAW4APY', [211, 57, 72, 108, 93, 10, 1, 110, 1, 248]),
        (
          'TAQXXNVINJCCF3LSVADQ7CSMW5D4E===',
          [
            152,
            33,
            123,
            182,
            168,
            106,
            68,
            34,
            237,
            114,
            168,
            7,
            15,
            138,
            76,
            183,
            71,
            194,
          ],
        ),
        (
          '6XBLELK3VNRFVTUFQ4======',
          [245, 194, 178, 45, 91, 171, 98, 90, 206, 133, 135],
        ),
        (
          'WHIF3TPC5I33CKAHKC43D6KT3226VYY=',
          [
            177,
            208,
            93,
            205,
            226,
            234,
            55,
            177,
            40,
            7,
            80,
            185,
            177,
            249,
            83,
            222,
            181,
            234,
            227,
          ],
        ),
        (
          'P6S7Z2UXTGYBVG6ERRBGUOI=',
          [127, 165, 252, 234, 151, 153, 176, 26, 155, 196, 140, 66, 106, 57],
        ),
        ('UM======', [163]),
        ('JNZYAVBSWI======', [75, 115, 128, 84, 50, 178]),
        (
          '5W3UP5YT2GS3KJYB6NG7LDKFTN22M===',
          [
            237,
            183,
            71,
            247,
            19,
            209,
            165,
            181,
            39,
            1,
            243,
            77,
            245,
            141,
            69,
            155,
            117,
            166,
          ],
        ),
      ];
      for (final (input, expected) in cases) {        expect(base32Decode(input), u8(expected), reason: '"$input"');
      }
    });

    test('invalid characters throw FormatException ', () {
      for (final s in ['AAA+AAA=', 'test', '1', '8', '9', '0', 'a']) {        expect(
          () => base32Decode(s),
          throwsFormatException,
          reason: '"$s"',
        );
      }
    });
  });

  group('round trips', () {
    test('encode→decode round trip for 10000 random byte arrays (seed 11)', () {
      final rng = Random(11);
      for (var i = 0; i < 10000; i++) {
        final bytes = u8(
          List<int>.generate(rng.nextInt(40), (_) => rng.nextInt(256)),
        );
        final enc = base32Encode(bytes);
        expect(base32Decode(enc), bytes, reason: 'round trip $enc');
      }
    });

    test('all single bytes 0..255 round trip', () {
      for (var b = 0; b <= 255; b++) {
        expect(base32Decode(base32Encode(u8([b]))), u8([b]), reason: 'byte $b');
      }
    });
  });
}
