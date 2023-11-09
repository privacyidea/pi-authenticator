enum Encodings {
  none,
  base32,
  hex,
}

extension EncodingsExtension on Encodings {
  String get asString => switch (this) {
        Encodings.none => 'none',
        Encodings.base32 => 'base32',
        Encodings.hex => 'hex',
      };
}
