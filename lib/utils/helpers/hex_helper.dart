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
import 'dart:typed_data';

/// Self contained replacement for the `hex` package (`HEX.encode`/`HEX.decode`).
const String _hexAlphabet = '0123456789abcdef';

/// Encodes [bytes] into a lowercase hexadecimal string.
///
/// Throws a [FormatException] if any element is not a single byte (0-255).
String hexEncode(List<int> bytes) {
  final buffer = StringBuffer();
  for (final part in bytes) {
    if (part & 0xff != part) {
      throw const FormatException('Non-byte integer detected');
    }
    buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return buffer.toString();
}

/// Decodes the hexadecimal string [hex] into its raw bytes.
///
/// Spaces are ignored, decoding is case insensitive and an odd length is left
/// padded with a leading zero. Throws a [FormatException] on any non-hex character.
List<int> hexDecode(String hex) {
  var str = hex.replaceAll(' ', '').toLowerCase();
  if (str.length % 2 != 0) {
    str = '0$str';
  }
  final result = Uint8List(str.length ~/ 2);
  for (var i = 0; i < result.length; i++) {
    final firstDigit = _hexAlphabet.indexOf(str[i * 2]);
    final secondDigit = _hexAlphabet.indexOf(str[i * 2 + 1]);
    if (firstDigit == -1 || secondDigit == -1) {
      throw FormatException('Non-hex character detected in $hex');
    }
    result[i] = (firstDigit << 4) + secondDigit;
  }
  return result;
}
