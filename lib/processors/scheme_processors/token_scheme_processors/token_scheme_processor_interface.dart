import '../../../model/tokens/token.dart';
import '../scheme_processor_interface.dart';
import 'otp_auth_migration_processor.dart';
import 'otp_auth_processor.dart';
import 'pia_processor.dart';

abstract class TokenSchemeProcessor implements SchemeProcessor {
  const TokenSchemeProcessor();
  static const Set<TokenSchemeProcessor> implementations = {
    OtpAuthProcessor(),
    OtpAuthMigrationProcessor(),
    PiaProcessor(),
  };

  @override
  Future<List<Token>> processUri(Uri uri, {bool fromInit = false});

  static Future<List<Token>?> processUriByAny(Uri uri) async {
    for (TokenSchemeProcessor processor in implementations) {
      if (processor.supportedSchemes.contains(uri.scheme)) {
        return await processor.processUri(uri);
      }
    }
    return null;
  }
}
