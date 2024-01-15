import '../../model/tokens/token.dart';
import '../../utils/logger.dart';

import 'two_fas_import_file_processor.dart';

abstract class TokenImportProcessor {
  const TokenImportProcessor();

  Future<List<Token>> process({String? jsonString, Map<String, dynamic>? json, String? password});

  static final List<TokenImportProcessor> _processors = [
    const TwoFasImportFileProcessor(),
  ];

  static Future<List<Token>> processFile({String? jsonString, Map<String, dynamic>? json, String? password}) async {
    assert(jsonString != null || json != null);
    assert(jsonString == null || json == null);
    List<Token> tokens = [];
    for (TokenImportProcessor processor in _processors) {
      try {
        tokens.addAll(await processor.process(jsonString: jsonString, json: json, password: password));
        return tokens;
      } catch (e) {
        Logger.warning('Failed to process file with processor ${processor.runtimeType}',
            error: e, name: 'token_import_file_processor_interface.dart#processFile');
      }
    }
    return [];
  }

  /// This only ensures that the file has the correct format, not that the data itself is correct
  bool fileContentIsValid({String? jsonString, Map<String, dynamic>? json});

  /// Returns true if a password is required to decrypt the Tokens
  bool fileContentNeedsPassword({String? jsonString, Map<String, dynamic>? json});
}
