import '../../model/tokens/token.dart';
import '../scheme_processor_interface.dart';
import 'token_scheme_processors/otp_auth_migration_processor.dart';
import 'token_scheme_processors/otp_auth_processor.dart';
import 'token_scheme_processors/pia_processor.dart';

abstract class TokenSchemeProcessor implements SchemeProcessor {
  const TokenSchemeProcessor();
  static const Set<TokenSchemeProcessor> implementations = {
    OtpAuthProcessor(),
    OtpAuthMigrationProcessor(),
    PiaProcessor(),
  };

  @override
  Future<List<Token>?> process(Uri uri, {bool fromInit = false});

  static Future<List<Token>?> processUri(Uri uri) async {
    for (TokenSchemeProcessor processor in implementations) {
      if (processor.supportedSchemes.contains(uri.scheme)) {
        return await processor.process(uri);
      }
    }
    return null;
  }
}
