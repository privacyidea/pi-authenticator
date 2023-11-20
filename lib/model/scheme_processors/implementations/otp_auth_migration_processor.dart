// Original Code: https://github.com/johncallahan/otpauth_migration/blob/main/lib/otpauth_migration.dart Copyright © 2022 John R. Callahan
// Modified by Frank Merkel <frank.merkel@netknights.it>

import 'otp_auth_processor.dart';
import '../../tokens/token.dart';
import '../scheme_processor_interface.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../proto/generated/GoogleAuthenticatorImport.pb.dart';

class OtpAuthMigrationProcessor extends SchemeProcessor {
  final OtpAuthProcessor otpAuthProcessor = OtpAuthProcessor();

  OtpAuthMigrationProcessor();
  @override
  Set<String> supportedScheme = {'otpauth-migration'};
  @override
  Future<List<Token>?> process(Uri uri) async {
    final value = uri.toString();
    // check prefix "otpauth-migration://offline?data="
    // extract suffix - Base64 encode
    List<Token> results = [];

    RegExp exp = RegExp(r"otpauth-migration\:\/\/offline\?data=(.*)$");
    final match = exp.firstMatch(value);
    final encodedUrl = match?.group(1);
    if (encodedUrl != null) {
      final encoded = Uri.decodeComponent(encodedUrl);
      var decoded = base64.decode(encoded);

      try {
        final gai = GoogleAuthenticatorImport.fromBuffer(decoded);

        for (var param in gai.otpParameters) {
          var base32 = _decodeBase32(param.secret);
          final name = Uri.encodeFull(param.name);
          final issuer = Uri.encodeComponent(param.issuer);
          String algorithm = "";
          switch (param.algorithm) {
            case GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA1:
              algorithm = "&algorithm=SHA1";
              break;
            case GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA256:
              algorithm = "&algorithm=SHA256";
              break;
            case GoogleAuthenticatorImport_Algorithm.ALGORITHM_SHA512:
              algorithm = "&algorithm=SHA512";
              break;
            case GoogleAuthenticatorImport_Algorithm.ALGORITHM_MD5:
              algorithm = "&algorithm=MD5";
              break;
            default:
              algorithm = "";
              break;
          }
          String digits = "";
          switch (param.digits) {
            case GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_SIX:
              digits = "&digits=6";
              break;
            case GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_EIGHT:
              digits = "&digits=8";
              break;
            default:
              digits = "";
              break;
          }
          final uri = Uri.parse("otpauth://totp/$name?secret=$base32&issuer=$issuer$algorithm$digits&period=30");
          results.addAll(await otpAuthProcessor.process(uri) ?? []);
        }

        return results;
      } catch (e) {
        return results;
      }
    } else {
      return [];
    }
  }

  static const List<String> _rfc3548 = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7"
  ];

  String _decodeBase32(List<int> s) {
    Uint8List ulist = s as Uint8List;
    String result = "";

    var i = 0;
    while (i < ulist.length) {
      var q0 = ulist[i] & 0xF8;
      q0 = q0 >> 3;
      result += _rfc3548[q0];

      var q1 = ulist[i++] & 0x07;
      q1 = q1 << 2;
      var temp = ulist[i] & 0xC0;
      temp = temp >> 6;
      q1 = q1 + temp;
      result += _rfc3548[q1];

      var q2 = ulist[i] & 0x3E;
      q2 = q2 >> 1;
      result += _rfc3548[q2];

      var q3 = ulist[i++] & 0x01;
      q3 = q3 << 4;
      temp = ulist[i] & 0xF0;
      temp = temp >> 4;
      q3 = q3 + temp;
      result += _rfc3548[q3];

      var q4 = ulist[i++] & 0x0F;
      q4 = q4 << 1;
      temp = ulist[i] & 0x80;
      temp = temp >> 7;
      q4 = q4 + temp;
      result += _rfc3548[q4];

      var q5 = ulist[i] & 0x7c;
      q5 = q5 >> 2;
      result += _rfc3548[q5];

      var q6 = ulist[i++] & 0x03;
      q6 = q6 << 3;
      temp = ulist[i] & 0xE0;
      temp = temp >> 5;
      q6 = q6 + temp;
      result += _rfc3548[q6];

      var q7 = ulist[i++] & 0x1F;
      result += _rfc3548[q7];
    }

    return result;
  }
}
