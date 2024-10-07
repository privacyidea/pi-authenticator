/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'dart:convert';

import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';

import '../../enums/encodings.dart';

extension EncodingsX on Encodings {
  String encode(Uint8List data) => switch (this) {
        Encodings.none => utf8.decode(data),
        Encodings.base32 => base32.encode(data),
        Encodings.hex => HEX.encode(data),
      };

  String encodeStringTo(Encodings encoding, String data) => encoding.encode(decode(data));

  Uint8List decode(String string) => switch (this) {
        Encodings.none => utf8.encode(string),
        Encodings.base32 => Uint8List.fromList(base32.decode(string.toUpperCase())),
        Encodings.hex => Uint8List.fromList(HEX.decode(string.toUpperCase())),
      };

  bool isValidEncoding(String string) {
    try {
      decode(string);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isInvalidEncoding(String string) {
    try {
      decode(string);
      return false;
    } catch (_) {
      return true;
    }
  }

  Uint8List? tryDecode(String string) {
    try {
      return decode(string);
    } catch (_) {
      return null;
    }
  }

  String? tryEncode(Uint8List data) {
    try {
      return encode(data);
    } catch (_) {
      return null;
    }
  }
}
