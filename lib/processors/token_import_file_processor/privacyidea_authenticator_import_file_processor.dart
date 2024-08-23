/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:convert';

import 'package:file_selector/file_selector.dart';

import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/encryption/token_encryption.dart';
import '../../utils/logger.dart';
import 'token_import_file_processor_interface.dart';
import 'two_fas_import_file_processor.dart';

class PrivacyIDEAAuthenticatorImportFileProcessor extends TokenImportFileProcessor {
  static get resultHandlerType => TokenImportFileProcessor.resultHandlerType;
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
      final results = tokens
          .map((token) => ProcessorResult.success(
                token,
                resultHandlerType: resultHandlerType,
              ))
          .toList();
      return results;
    } catch (e) {
      if (e is BadDecryptionPasswordException) rethrow;
      Logger.error('Failed to process file', name: 'PrivacyIDEAAuthenticatorImportFileProcessor#processFile', error: e, stackTrace: StackTrace.current);
      return [
        ProcessorResult.failed(
          e.toString(),
          resultHandlerType: resultHandlerType,
        )
      ];
    }
  }
}
