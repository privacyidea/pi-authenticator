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

/// Self contained replacement for `const Uuid().v4()` of the `uuid` package.
final Random _random = Random.secure();

/// Generates a random RFC 4122 version 4 UUID as a lower case string.
String uuidV4() {
  final rnds = Uint8List(16);
  for (var i = 0; i < 16; i++) {
    rnds[i] = _random.nextInt(256);
  }

  // per 4.4, set bits for version and clockSeq high and reserved
  rnds[6] = (rnds[6] & 0x0f) | 0x40;
  rnds[8] = (rnds[8] & 0x3f) | 0x80;

  return _unparse(rnds);
}

/// Formats the 16 [bytes] as an `8-4-4-4-12` lower case hexadecimal UUID string.
String _unparse(Uint8List bytes) {
  final buffer = StringBuffer();
  for (var i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) {
      buffer.write('-');
    }
    buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
