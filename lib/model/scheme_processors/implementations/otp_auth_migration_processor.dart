import '../../tokens/token.dart';
import '../scheme_processor_interface.dart';

class OtpAuthMigrationProcessor extends SchemeProcessor {
  OtpAuthMigrationProcessor();
  @override
  Set<String> supportedScheme = {'otpauth-migration'};
  @override
  Future<List<Token>?> process(Uri uri) async {}
}
