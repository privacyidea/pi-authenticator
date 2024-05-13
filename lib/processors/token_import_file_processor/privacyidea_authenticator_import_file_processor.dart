import 'dart:convert';

import 'package:file_selector/file_selector.dart';

import '../../model/encryption/token_encryption.dart';
import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/logger.dart';
import 'token_import_file_processor_interface.dart';
import 'two_fas_import_file_processor.dart';

class PrivacyIDEAAuthenticatorImportFileProcessor extends TokenImportFileProcessor {
  const PrivacyIDEAAuthenticatorImportFileProcessor();
  @override
  Future<bool> fileIsValid(XFile file) async {
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content);
      if (json['data'] != null && json['salt'] != null && json['iv'] != null && json['mac'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> fileNeedsPassword(XFile file) => Future.value(true);

  @override
  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password}) async {
    assert(password != null);

    try {
      final content = await file.readAsString();
      List<Token> tokens;
      try {
        tokens = await TokenEncryption.decrypt(encryptedTokens: content, password: password!);
      } catch (e) {
        throw BadDecryptionPasswordException('Invalid password');
      }
      final results = tokens.map((token) => ProcessorResultSuccess(token)).toList();
      return results;
    } catch (e) {
      Logger.error('Failed to process file', name: 'PrivacyIDEAAuthenticatorImportFileProcessor#processFile', error: e, stackTrace: StackTrace.current);
      return [ProcessorResultFailed<Token>(e.toString())];
    }
  }
}
