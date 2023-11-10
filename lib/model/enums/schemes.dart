// import 'package:privacyidea_authenticator/model/tokens/token.dart';

// enum UriSchemes {
//   otpauth,
//   pia,
//   otpauthmigration,
// }

// extension UriSchemesExtension on UriSchemes {
//   String get schemePrefix => switch (this) {
//         UriSchemes.otpauth => 'otpauth',
//         UriSchemes.pia => 'pia',
//         UriSchemes.otpauthmigration => 'otpauth-migration',
//       };
//   bool isScheme(String schemePrefix) => schemePrefix.toLowerCase() == this.schemePrefix.toLowerCase();

//   String get inString => switch (this) {
//         UriSchemes.otpauth => 'otpauth',
//         UriSchemes.pia => 'pia',
//         UriSchemes.otpauthmigration => 'otpauthmigration',
//       };
//   isString(String string) => string.toLowerCase() == inString.toLowerCase();

//   Type get uriContentType => switch (this) {
//         UriSchemes.otpauth => Token,
//         UriSchemes.pia => Token,
//         UriSchemes.otpauthmigration => List<Token>,
//       };
// }

// Map<String, UriSchemes> _schemeStringMap = {
//   UriSchemes.otpauth.inString: UriSchemes.otpauth,
//   UriSchemes.pia.inString: UriSchemes.pia,
//   UriSchemes.otpauthmigration.inString: UriSchemes.otpauthmigration,
// };
// Map<String, UriSchemes> _schemePrefixMap = {
//   UriSchemes.otpauth.schemePrefix: UriSchemes.otpauth,
//   UriSchemes.pia.schemePrefix: UriSchemes.pia,
//   UriSchemes.otpauthmigration.schemePrefix: UriSchemes.otpauthmigration,
// };

// UriSchemes? schemeFromString(String string) => _schemeStringMap[string];
// UriSchemes? schemeEnumFromString(String prefix) => _schemePrefixMap[prefix];
