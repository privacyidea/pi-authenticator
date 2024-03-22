import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../mixins/token_import_processor.dart';
import '../scheme_processor_interface.dart';
import 'google_authenticator_qr_processor.dart';
import 'otp_auth_processor.dart';
import 'pia_processor.dart';

abstract class TokenImportSchemeProcessor with TokenImportProcessor<Uri, bool> implements SchemeProcessor {
  const TokenImportSchemeProcessor();
  static const Set<TokenImportSchemeProcessor> implementations = {
    OtpAuthProcessor(),
    GoogleAuthenticatorQrProcessor(),
    PiaProcessor(),
  };

  @override

  /// data: [Uri] uri
  /// args: [bool] fromInit
  Future<List<ProcessorResult<Token>>> processTokenMigrate(Uri data, {bool args = false}) => processUri(data, fromInit: args);

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false});

  static Future<List<ProcessorResult<Token>>?> processUriByAny(Uri uri) async {
    for (TokenImportSchemeProcessor processor in implementations) {
      if (processor.supportedSchemes.contains(uri.scheme)) {
        return await processor.processUri(uri);
      }
    }
    return null;
  }
}
