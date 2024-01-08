import 'dart:io';

import 'package:privacyidea_authenticator/model/tokens/token.dart';

import '../file_processor_interface.dart';

abstract class TokenImportFileProcessor extends FileProcessor {
  const TokenImportFileProcessor();

  @override
  Future<List<Token>> process(File file);

  static final List<TokenImportFileProcessor> _processors = [];

  static Future<List<Token>> processFile(File file) async {
    for (TokenImportFileProcessor processor in _processors) {
      if (processor.supportedFileTypes.contains(FileProcessor.typeOfFile(file))) {
        return await processor.process(file);
      }
    }
    return [];
  }
}
