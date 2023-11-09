enum TokenTypes {
  HOTP,
  TOTP,
  PIPUSH,
  DAYPASSWORD,
}

extension TokenTypesExtension on TokenTypes {
  String get asString => switch (this) {
        TokenTypes.HOTP => 'HOTP',
        TokenTypes.TOTP => 'TOTP',
        TokenTypes.PIPUSH => 'PIPUSH',
        TokenTypes.DAYPASSWORD => 'DAYPASSWORD',
      };
  bool isString(String encoding) => encoding.toLowerCase() == asString.toLowerCase();
}
