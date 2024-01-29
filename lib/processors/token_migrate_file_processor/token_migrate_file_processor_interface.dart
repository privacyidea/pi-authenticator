import 'package:file_selector/file_selector.dart';
import 'package:privacyidea_authenticator/processors/token_migrate_file_processor/aegis_migrate_file_processor.dart';

import '../../model/tokens/token.dart';
import '../../utils/logger.dart';
import '../mixins/token_migrate_processor.dart';
import 'two_fas_migrate_file_processor.dart';

abstract class TokenMigrateFileProcessor with TokenMigrateProcessor {
  const TokenMigrateFileProcessor();

  @override

  /// data: [XFile] file
  /// args: [String] password
  Future<List<Token>> processTokenImport(dynamic data, {List<dynamic>? args}) async {
    if (data is! XFile) return [];
    return await processFile(file: data, password: args?.firstOrNull as String?);
  }

  Future<List<Token>> processFile({required XFile file, String? password});

  static final List<TokenMigrateFileProcessor> implementations = [
    const AegisImportFileProcessor(),
    const TwoFasFileImportProcessor(),
  ];

  static Future<List<Token>> processFileByAny({required XFile file, String? password}) async {
    List<Token> tokens = [];
    for (TokenMigrateFileProcessor processor in implementations) {
      try {
        tokens.addAll(await processor.processFile(file: file, password: password));
        return tokens;
      } catch (e) {
        Logger.warning('Failed to process file with processor ${processor.runtimeType}',
            error: e, name: 'token_import_file_processor_interface.dart#processFile');
      }
    }
    return [];
  }

  /// This only ensures that the file has the correct format, not that the data itself is correct
  Future<bool> fileIsValid({required XFile file});

  /// Returns true if a password is required to decrypt the Tokens
  Future<bool> fileNeedsPassword({required XFile file});
}
