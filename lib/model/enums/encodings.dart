import 'dart:convert';
import 'package:base32/base32.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';

enum Encodings {
  none,
  base32,
  hex,
}

extension EncodingsExtension on Encodings {
  String encode(Uint8List data) => switch (this) {
        Encodings.none => utf8.decode(data),
        Encodings.base32 => base32.encode(data),
        Encodings.hex => HEX.encode(data),
      };

  String encodeAs(Encodings encoding, String data) => encoding.encode(decode(data));

  Uint8List decode(String string) => switch (this) {
        Encodings.none => utf8.encode(string),
        Encodings.base32 => Uint8List.fromList(base32.decode(string)),
        Encodings.hex => Uint8List.fromList(HEX.decode(string)),
      };

  bool isValidEncoding(String string) {
    try {
      decode(string);
      return true;
    } catch (_) {
      return false;
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

  bool isString(String value) {
    return value == name;
  }

  String get name => switch (this) {
        Encodings.none => 'none',
        Encodings.base32 => 'base32',
        Encodings.hex => 'hex',
      };

  static Encodings fromString(String value) {
    return switch (value) {
      'none' => Encodings.none,
      'base32' => Encodings.base32,
      'hex' => Encodings.hex,
      _ => throw ArgumentError('Unknown encoding: $value'),
    };
  }
}
