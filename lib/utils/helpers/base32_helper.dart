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

/// Self contained replacement for the standard RFC 4648 part of the `base32`
/// package (`base32.encode`/`base32.decode`).
const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
final RegExp _base32Regex = RegExp(r'^[A-Z2-7=]+$');
final Map<String, int> _base32DecodeMap = {for (var i = 0; i < 32; i++) _base32Chars[i]: i};

/// Encodes [bytesList] into a padded, upper case RFC 4648 base32 string.
String base32Encode(Uint8List bytesList) {
  var i = 0;
  final count = (bytesList.length ~/ 5) * 5;
  var base32str = '';
  while (i < count) {
    final v1 = bytesList[i++];
    final v2 = bytesList[i++];
    final v3 = bytesList[i++];
    final v4 = bytesList[i++];
    final v5 = bytesList[i++];

    base32str += _base32Chars[v1 >> 3] +
        _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
        _base32Chars[(v2 >> 1) & 31] +
        _base32Chars[(v2 << 4 | v3 >> 4) & 31] +
        _base32Chars[(v3 << 1 | v4 >> 7) & 31] +
        _base32Chars[(v4 >> 2) & 31] +
        _base32Chars[(v4 << 3 | v5 >> 5) & 31] +
        _base32Chars[v5 & 31];
  }

  final remain = bytesList.length - count;
  if (remain == 1) {
    final v1 = bytesList[i];
    base32str += _base32Chars[v1 >> 3] + _base32Chars[(v1 << 2) & 31];
    base32str += '======';
  } else if (remain == 2) {
    final v1 = bytesList[i++];
    final v2 = bytesList[i];
    base32str += _base32Chars[v1 >> 3] +
        _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
        _base32Chars[(v2 >> 1) & 31] +
        _base32Chars[(v2 << 4) & 31];
    base32str += '====';
  } else if (remain == 3) {
    final v1 = bytesList[i++];
    final v2 = bytesList[i++];
    final v3 = bytesList[i];
    base32str += _base32Chars[v1 >> 3] +
        _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
        _base32Chars[(v2 >> 1) & 31] +
        _base32Chars[(v2 << 4 | v3 >> 4) & 31] +
        _base32Chars[(v3 << 1) & 31];
    base32str += '===';
  } else if (remain == 4) {
    final v1 = bytesList[i++];
    final v2 = bytesList[i++];
    final v3 = bytesList[i++];
    final v4 = bytesList[i];
    base32str += _base32Chars[v1 >> 3] +
        _base32Chars[(v1 << 2 | v2 >> 6) & 31] +
        _base32Chars[(v2 >> 1) & 31] +
        _base32Chars[(v2 << 4 | v3 >> 4) & 31] +
        _base32Chars[(v3 << 1 | v4 >> 7) & 31] +
        _base32Chars[(v4 >> 2) & 31] +
        _base32Chars[(v4 << 3) & 31];
    base32str += '=';
  }
  return base32str;
}

/// Decodes the RFC 4648 base32 string [input] into its raw bytes.
///
/// Returns an empty list for an empty input and throws a [FormatException] on
/// any character outside of the base32 alphabet.
Uint8List base32Decode(String input) {
  if (input.isEmpty) {
    return Uint8List(0);
  }

  final base32 = _pad(input);

  if (!_isValid(base32)) {
    throw const FormatException('Invalid Base32 characters');
  }

  var length = base32.indexOf('=');
  if (length == -1) {
    length = base32.length;
  }

  var i = 0;
  final count = length >> 3 << 3;
  final bytes = <int>[];
  while (i < count) {
    final v1 = _base32DecodeMap[base32[i++]] ?? 0;
    final v2 = _base32DecodeMap[base32[i++]] ?? 0;
    final v3 = _base32DecodeMap[base32[i++]] ?? 0;
    final v4 = _base32DecodeMap[base32[i++]] ?? 0;
    final v5 = _base32DecodeMap[base32[i++]] ?? 0;
    final v6 = _base32DecodeMap[base32[i++]] ?? 0;
    final v7 = _base32DecodeMap[base32[i++]] ?? 0;
    final v8 = _base32DecodeMap[base32[i++]] ?? 0;
    bytes.add((v1 << 3 | v2 >> 2) & 255);
    bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
    bytes.add((v4 << 4 | v5 >> 1) & 255);
    bytes.add((v5 << 7 | v6 << 2 | v7 >> 3) & 255);
    bytes.add((v7 << 5 | v8) & 255);
  }

  final remain = length - count;
  if (remain == 2) {
    final v1 = _base32DecodeMap[base32[i++]] ?? 0;
    final v2 = _base32DecodeMap[base32[i++]] ?? 0;
    bytes.add((v1 << 3 | v2 >> 2) & 255);
  } else if (remain == 4) {
    final v1 = _base32DecodeMap[base32[i++]] ?? 0;
    final v2 = _base32DecodeMap[base32[i++]] ?? 0;
    final v3 = _base32DecodeMap[base32[i++]] ?? 0;
    final v4 = _base32DecodeMap[base32[i++]] ?? 0;
    bytes.add((v1 << 3 | v2 >> 2) & 255);
    bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
  } else if (remain == 5) {
    final v1 = _base32DecodeMap[base32[i++]] ?? 0;
    final v2 = _base32DecodeMap[base32[i++]] ?? 0;
    final v3 = _base32DecodeMap[base32[i++]] ?? 0;
    final v4 = _base32DecodeMap[base32[i++]] ?? 0;
    final v5 = _base32DecodeMap[base32[i++]] ?? 0;
    bytes.add((v1 << 3 | v2 >> 2) & 255);
    bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
    bytes.add((v4 << 4 | v5 >> 1) & 255);
  } else if (remain == 7) {
    final v1 = _base32DecodeMap[base32[i++]] ?? 0;
    final v2 = _base32DecodeMap[base32[i++]] ?? 0;
    final v3 = _base32DecodeMap[base32[i++]] ?? 0;
    final v4 = _base32DecodeMap[base32[i++]] ?? 0;
    final v5 = _base32DecodeMap[base32[i++]] ?? 0;
    final v6 = _base32DecodeMap[base32[i++]] ?? 0;
    final v7 = _base32DecodeMap[base32[i++]] ?? 0;
    bytes.add((v1 << 3 | v2 >> 2) & 255);
    bytes.add((v2 << 6 | v3 << 1 | v4 >> 4) & 255);
    bytes.add((v4 << 4 | v5 >> 1) & 255);
    bytes.add((v5 << 7 | v6 << 2 | v7 >> 3) & 255);
  }
  return Uint8List.fromList(bytes);
}

bool _isValid(String b32str) {
  if (b32str.length % 2 != 0) {
    return false;
  }
  return _base32Regex.hasMatch(b32str);
}

String _pad(String base32) {
  final neededPadding = (8 - base32.length % 8) % 8;
  return base32.padRight(base32.length + neededPadding, '=');
}
