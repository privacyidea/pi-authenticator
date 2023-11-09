enum UriSchemes {
  otpauth,
  pia,
  otpauthMigration,
}

extension UriSchemesExtension on UriSchemes {
  String get name => switch (this) {
        UriSchemes.otpauth => 'otpauth',
        UriSchemes.pia => 'pia',
        UriSchemes.otpauthMigration => 'otpauth-migration',
      };
  UriSchemes fromName(String name) => switch (name) {
        'otpauth' => UriSchemes.otpauth,
        'pia' => UriSchemes.pia,
        'otpauth-migration' => UriSchemes.otpauthMigration,
        _ => throw Exception('Invalid UriSchemes name'),
      };
  bool isName(String name) => name.toLowerCase() == this.name.toLowerCase();
}
