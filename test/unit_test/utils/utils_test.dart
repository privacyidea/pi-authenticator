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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

void main() {
  group('insertCharAt', () {
    test('inserts character at position', () {
      expect(insertCharAt('ABCD', ' ', 2), 'AB CD');
    });

    test('inserts at start', () {
      expect(insertCharAt('ABCD', '_', 0), '_ABCD');
    });

    test('inserts at end', () {
      expect(insertCharAt('ABCD', '_', 4), 'ABCD_');
    });
  });

  group('splitPeriodically', () {
    test('splits every 1 character', () {
      expect(splitPeriodically('ABCD', 1), 'A B C D');
    });

    test('splits every 2 characters', () {
      expect(splitPeriodically('ABCD', 2), 'AB CD');
    });

    test('splits every 3 characters', () {
      expect(splitPeriodically('ABCDEF', 3), 'ABC DEF');
    });

    test('returns original for period < 1', () {
      expect(splitPeriodically('ABCD', 0), 'ABCD');
      expect(splitPeriodically('ABCD', -1), 'ABCD');
    });

    test('handles empty string', () {
      expect(splitPeriodically('', 2), '');
    });
  });

  group('getErrorMessageFromResponse', () {
    // getErrorMessageFromResponse requires http Response, tested indirectly
  });

  group('removeIllegalFilenameChars', () {
    test('removes illegal characters', () {
      expect(removeIllegalFilenameChars('file<>:name'), 'filename');
    });

    test('removes all illegal chars', () {
      expect(removeIllegalFilenameChars('a<b>c:d"e/f\\g|h?i*j'), 'abcdefghij');
    });

    test('keeps legal characters', () {
      expect(
        removeIllegalFilenameChars('valid_file-name.txt'),
        'valid_file-name.txt',
      );
    });

    test('handles empty string', () {
      expect(removeIllegalFilenameChars(''), '');
    });
  });

  group('doesThrow', () {
    test('returns true when function throws', () {
      expect(doesThrow(() => throw Exception('error')), isTrue);
    });

    test('returns false when function does not throw', () {
      expect(doesThrow(() => 42), isFalse);
    });
  });

  group('tryJsonDecode', () {
    test('returns decoded JSON for valid input', () {
      final result = tryJsonDecode('{"key": "value"}');
      expect(result, isA<Map>());
      expect(result['key'], 'value');
    });

    test('returns null for invalid JSON', () {
      expect(tryJsonDecode('not json'), isNull);
    });

    test('returns list for array JSON', () {
      final result = tryJsonDecode('[1, 2, 3]');
      expect(result, isA<List>());
      expect(result.length, 3);
    });
  });

  group('bigIntToByteData / byteDataToBigInt', () {
    test('round-trips correctly', () {
      final original = BigInt.from(12345678);
      final data = bigIntToByteData(original);
      final result = byteDataToBigInt(data);
      expect(result, original);
    });

    test('handles zero', () {
      final original = BigInt.zero;
      final data = bigIntToByteData(original);
      expect(data.lengthInBytes, 0);
    });

    test('handles large value', () {
      final original = BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16);
      final data = bigIntToByteData(original);
      final result = byteDataToBigInt(data);
      expect(result, original);
    });
  });

  group('bigIntToBytes / bytesToBigInt', () {
    test('round-trips correctly', () {
      final original = BigInt.from(256);
      final bytes = bigIntToBytes(original);
      final result = bytesToBigInt(bytes);
      expect(result, original);
    });

    test('handles single byte', () {
      final original = BigInt.from(255);
      final bytes = bigIntToBytes(original);
      expect(bytes.length, 1);
      expect(bytes[0], 255);
      expect(bytesToBigInt(bytes), original);
    });

    test('handles multi-byte', () {
      final original = BigInt.from(0x1234);
      final bytes = bigIntToBytes(original);
      expect(bytesToBigInt(bytes), original);
    });
  });
}
