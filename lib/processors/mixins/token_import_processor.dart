import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';

import '../scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';
import '../token_import_file_processor/token_import_file_processor_interface.dart';

mixin TokenImportProcessor<T, V> {
  static Set<TokenImportProcessor> implementations = {
    const GoogleAuthenticatorQrProcessor(),
    ...TokenImportFileProcessor.implementations,
  };

  Future<List<ProcessorResult<Token>>> processTokenMigrate(T data, {V args});
}
