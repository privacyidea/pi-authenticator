import 'package:file_selector/file_selector.dart';

import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/logger.dart';
import '../mixins/token_import_processor.dart';
import 'aegis_import_file_processor.dart';
import 'two_fas_import_file_processor.dart';

abstract class TokenImportFileProcessor with TokenImportProcessor<XFile, String?> {
  const TokenImportFileProcessor();

  @override
  Future<List<ProcessorResult<Token>>> processTokenMigrate(XFile data, {String? args}) async {
    return processFile(file: data, password: args);
  }

  Future<List<ProcessorResult<Token>>> processFile({required XFile file, String? password});

  static final List<TokenImportFileProcessor> implementations = [
    const AegisImportFileProcessor(),
    const TwoFasFileImportProcessor(),
  ];

  static Future<List<ProcessorResult<Token>>> processFileByAny({required XFile file, String? password}) async {
    final tokens = <ProcessorResult<Token>>[];
    for (TokenImportFileProcessor processor in implementations) {
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
