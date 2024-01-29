import '../../model/tokens/token.dart';
import '../scheme_processors/token_scheme_processors/otp_auth_migration_processor.dart';
import '../token_migrate_file_processor/token_migrate_file_processor_interface.dart';

mixin TokenMigrateProcessor {
  static Set<TokenMigrateProcessor> implementations = {
    const OtpAuthMigrationProcessor(),
    ...TokenMigrateFileProcessor.implementations,
  };
  Future<List<Token>> processTokenImport(dynamic data, {List<dynamic>? args});
}
