// Original Code: https://github.com/johncallahan/otpauth_migration/blob/main/lib/otpauth_migration.dart Copyright © 2022 John R. Callahan
// Modified by Frank Merkel <frank.merkel@netknights.it>

import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';

import '../../../model/enums/token_origin_source_type.dart';
import '../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../proto/generated/GoogleAuthenticatorImport.pb.dart';
import '../../../utils/logger.dart';
import '../../../utils/token_import_origins.dart';
import 'otp_auth_processor.dart';
import 'token_import_scheme_processor_interface.dart';

class GoogleAuthenticatorQrProcessor extends TokenImportSchemeProcessor {
  const GoogleAuthenticatorQrProcessor();
  static const OtpAuthProcessor otpAuthProcessor = OtpAuthProcessor();

  @override
  Set<String> get supportedSchemes => {'otpauth-migration'};
  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) return [];
    final value = uri.toString();
    // check prefix "otpauth-migration://offline?data="
    // extract suffix - Base64 encode
    List<ProcessorResult<Token>> results = [];

    RegExp exp = RegExp(r"otpauth-migration\:\/\/offline\?data=(.*)$");
    final match = exp.firstMatch(value);
    final encodedUrl = match?.group(1);
    if (encodedUrl == null) return [];

    final encoded = Uri.decodeComponent(encodedUrl);
    var decoded = base64.decode(encoded);

    final gai = GoogleAuthenticatorImport.fromBuffer(decoded);
    Logger.warning("${gai.otpParameters.length} tokens found");
    for (var param in gai.otpParameters) {
      try {
        var base32string = base32.encode(Uint8List.fromList(param.secret));
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
          case GoogleAuthenticatorImport_DigitCount.DIGIT_COUNT_UNSPECIFIED:
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
        String type = "";
        String period = "";
        String counter = "";
        switch (param.type) {
          case GoogleAuthenticatorImport_OtpType.OTP_TYPE_UNSPECIFIED:
          case GoogleAuthenticatorImport_OtpType.OTP_TYPE_TOTP:
            type = "totp";
            period = "&period=30";
            break;
          case GoogleAuthenticatorImport_OtpType.OTP_TYPE_HOTP:
            type = "hotp";
            counter = "&counter=${param.counter}";
            break;
          default:
            type = "";
            break;
        }
        Logger.info("Processing $type token ${param.name}");
        final uri = Uri.parse("otpauth://$type/$name?secret=$base32string&issuer=$issuer$algorithm$digits$period$counter");
        results.addAll(await otpAuthProcessor.processUri(uri));
      } catch (e) {
        Logger.error(
          "Skipping token ${param.name} due to error: $e",
          name: "GoogleAuthenticatorQrProcessor#processUri",
          error: e,
          stackTrace: StackTrace.current,
        );
        results.add(ProcessorResultFailed(e.toString()));
        continue;
      }
    }

    final resultsWithOrigin = results.map((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.qrScanImport.addOriginToToken(
          appName: TokenImportOrigins.googleAuthenticator.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: base64.encode(decoded),
        ),
      );
    }).toList();
    return resultsWithOrigin;
  }
}
