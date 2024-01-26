import 'package:file_selector/file_selector.dart';

import '../../model/tokens/token.dart';
import '../../utils/logger.dart';
import 'two_fas_file_import_processor.dart';

abstract class TokenFileImportProcessor {
  const TokenFileImportProcessor();

  Future<List<Token>> process({required XFile file, String? password});

  static final List<TokenFileImportProcessor> _processors = [
    const TwoFasFileImportProcessor(),
  ];

  static Future<List<Token>> processFile({required XFile file, String? password}) async {
    List<Token> tokens = [];
    for (TokenFileImportProcessor processor in _processors) {
      try {
        tokens.addAll(await processor.process(file: file, password: password));
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
