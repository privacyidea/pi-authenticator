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

import 'package:crypto/crypto.dart';

/// RFC 4226 / RFC 6238 computed independently of the app's OTP code, so a
/// test compares the app against the specification, not against itself.
String referenceHotp(List<int> secret, int counter, {int digits = 6}) {
  final message = ByteData(8)..setUint64(0, counter);
  final hash = Hmac(sha1, secret).convert(message.buffer.asUint8List()).bytes;
  final offset = hash.last & 0x0f;
  final binary =
      ((hash[offset] & 0x7f) << 24) |
      (hash[offset + 1] << 16) |
      (hash[offset + 2] << 8) |
      hash[offset + 3];
  var pow = 1;
  for (var i = 0; i < digits; i++) {
    pow *= 10;
  }
  return (binary % pow).toString().padLeft(digits, '0');
}

String referenceTotp(
  List<int> secret,
  DateTime time, {
  int period = 30,
  int digits = 6,
}) => referenceHotp(
  secret,
  time.millisecondsSinceEpoch ~/ 1000 ~/ period,
  digits: digits,
);

/// RFC 4648 base32 without padding, for secrets typed into the app.
String base32(List<int> bytes) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  final out = StringBuffer();
  var buffer = 0;
  var bits = 0;
  for (final byte in bytes) {
    buffer = (buffer << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      out.write(alphabet[(buffer >> (bits - 5)) & 31]);
      bits -= 5;
    }
  }
  if (bits > 0) out.write(alphabet[(buffer << (5 - bits)) & 31]);
  return out.toString();
}
