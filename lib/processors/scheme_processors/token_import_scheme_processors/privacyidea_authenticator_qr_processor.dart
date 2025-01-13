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
import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/encryption/token_encryption.dart';
import '../../../utils/logger.dart';
import 'token_import_scheme_processor_interface.dart';

class PrivacyIDEAAuthenticatorQrProcessor extends TokenImportSchemeProcessor {
  static get resultHandlerType => TokenImportSchemeProcessor.resultHandlerType;
  const PrivacyIDEAAuthenticatorQrProcessor();
  static const scheme = 'pia';
  static const host = 'qrbackup';

  @override
  Set<String> get supportedSchemes => {scheme};

  @override
  Future<List<ProcessorResult<Token>>?> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) return null;
    if (uri.host != host) return null;
    Logger.info('Processing URI with scheme: ${uri.scheme} and host: ${uri.host}');
    try {
      final token = TokenEncryption.fromExportUri(uri);
      Logger.info('Processing URI ${uri.scheme} succeded');
      return [
        ProcessorResult.success(
          token,
          resultHandlerType: resultHandlerType,
        )
      ];
    } catch (e) {
      Logger.error('Error while processing URI ${uri.scheme}', error: e);
      return [
        ProcessorResult.failed(
          (l) => l.invalidUrl,
          resultHandlerType: resultHandlerType,
        )
      ];
    }
  }
}
