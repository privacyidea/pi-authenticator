import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

import '../../../model/encryption/aes_encrypted.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/identifiers.dart';
import '../../../utils/logger.dart';
import '../file_processor_interface.dart';
import 'token_import_file_processor_interface.dart';

class TwoFasImportFileProcessor extends TokenImportFileProcessor {
  const TwoFasImportFileProcessor();
  @override
  Set<String> get supportedFileTypes => {'2fas'};
  @override
  Future<List<Token>> process(File file, {String password = ''}) async {
    if (supportedFileTypes.contains(FileProcessor.typeOfFile(file)) == false) return [];
    if (file.existsSync() == false) return [];

    final String fileContentJsonString = await file.readAsString();
    final Map<String, dynamic> fileContentJson = jsonDecode(fileContentJsonString);
    final List<Map<String, dynamic>> twoFasTokens = fileContentJson['services'] ?? [];
    if (fileContentJson['servicesEncrypted'] != null) {
      try {
        final decryptedTokens = await AESEncrypted.fromSingleEncryptedString(fileContentJson['servicesEncrypted']).decrypt(password) ?? '[]';
        twoFasTokens.addAll(jsonDecode(decryptedTokens));
      } catch (e) {
        dev.log('decryption failed');
      }
    }
    final List<Token> tokens = [];
    for (var twoFasToken in twoFasTokens) {
      tokens.add(Token.fromUriMap(_twoFasToUriMap(twoFasToken)));
    }
    return tokens;
  }
}

Map<String, dynamic> _twoFasToUriMap(Map<String, dynamic> twoFasToken) {
  final twoFasOTP = twoFasToken['otp'];
  return {
    URI_TYPE: twoFasOTP['tokenType'],
    URI_ISSUER: twoFasToken['name'],
    URI_SECRET: twoFasToken['secret'],
    URI_LABEL: twoFasOTP['label'],
    URI_DIGITS: twoFasOTP['digits'],
    URI_COUNTER: twoFasOTP['counter'],
  };
}
