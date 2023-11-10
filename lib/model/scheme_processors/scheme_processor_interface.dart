import '../tokens/token.dart';
import 'implementations/otp_auth_migration_processor.dart';
import 'implementations/otp_auth_processor.dart';
import 'implementations/pia_processor.dart';

abstract class SchemeProcessor {
  SchemeProcessor();
  Set<String> get supportedScheme;
  Future<List<Token>?> process(Uri uri);

  static final List<SchemeProcessor> _processors = [
    OtpAuthProcessor(),
    PiaProcessor(),
    OtpAuthMigrationProcessor(),
  ];
  static Future<List<Token>?> processUri(Uri uri) async {
    for (SchemeProcessor processor in _processors) {
      if (processor.supportedScheme.contains(uri.scheme)) {
        return await processor.process(uri);
      }
    }
    return null;
  }
}
