import 'package:privacyidea_authenticator/model/extensions/enums/token_origin_source_type.dart';

import '../../../model/enums/token_origin_source_type.dart';
import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/token_import_origins.dart';
import 'otp_auth_processor.dart';

class FreeOtpPlusQrProcessor extends OtpAuthProcessor {
  const FreeOtpPlusQrProcessor();

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) => _processOtpAuth(uri);

  Future<List<ProcessorResult<Token>>> _processOtpAuth(Uri uri) async {
    final results = <ProcessorResult<Token>>[];

    final result = await super.processUri(uri);
    results.addAll(result);

    return results.map((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.qrScanImport.addOriginToToken(
          appName: TokenImportOrigins.freeOtpPlus.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: uri.toString(),
        ),
      );
    }).toList();
  }

  @override
  Set<String> get supportedSchemes => const OtpAuthProcessor().supportedSchemes;
}
