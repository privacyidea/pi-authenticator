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
import 'package:file_selector/file_selector.dart';

import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/logger.dart';
import '../mixins/token_import_processor.dart';
import 'aegis_import_file_processor.dart';
import 'two_fas_import_file_processor.dart';

abstract class TokenImportFileProcessor with TokenImportProcessor<XFile, String?> {
  static get resultHandlerType => TokenImportProcessor.resultHandlerType;
  const TokenImportFileProcessor();

  @override
  Future<List<ProcessorResult<Token>>> processTokenMigrate(XFile data, {String? args}) async {
    return processFile(data, password: args);
  }

  Future<List<ProcessorResult<Token>>> processFile(XFile file, {String? password});

  static final List<TokenImportFileProcessor> implementations = [
    const AegisImportFileProcessor(),
    const TwoFasAuthenticatorImportFileProcessor(),
  ];

  static Future<List<ProcessorResult<Token>>> processFileByAny({required XFile file, String? password}) async {
    final tokens = <ProcessorResult<Token>>[];
    for (TokenImportFileProcessor processor in implementations) {
      try {
        tokens.addAll(await processor.processFile(file, password: password));
        return tokens;
      } catch (e) {
        Logger.warning('Failed to process file with processor ${processor.runtimeType}',
            error: e, name: 'token_import_file_processor_interface.dart#processFile');
      }
    }
    return [];
  }

  /// This only ensures that the file has the correct format, not that the data itself is correct
  Future<bool> fileIsValid(XFile file);

  /// Returns true if a password is required to decrypt the Tokens
  Future<bool> fileNeedsPassword(XFile file);
}
