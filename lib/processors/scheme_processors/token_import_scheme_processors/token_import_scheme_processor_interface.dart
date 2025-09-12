/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import 'package:privacyidea_authenticator/utils/object_validator.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../mixins/token_import_processor.dart';
import '../scheme_processor_interface.dart';
import 'google_authenticator_qr_processor.dart';
import 'otp_auth_processor.dart';
import 'pia_scheme_processor.dart';

abstract class TokenImportSchemeProcessor with TokenImportProcessor<Uri, bool> implements SchemeProcessor {
  static ObjectValidator<TokenNotifier> get resultHandlerType => TokenImportProcessor.resultHandlerType;
  const TokenImportSchemeProcessor();

  static Set<String> get allSupportedSchemes => {
    ...const OtpAuthProcessor().supportedSchemes,
    ...const GoogleAuthenticatorQrProcessor().supportedSchemes,
    ...const PiaSchemeProcessor().supportedSchemes,
  };

  static const Set<TokenImportSchemeProcessor> implementations = {OtpAuthProcessor(), GoogleAuthenticatorQrProcessor(), PiaSchemeProcessor()};

  @override
  /// data: [Uri] uri
  /// args: [bool] fromInit
  Future<List<ProcessorResult<Token>>?> processTokenMigrate(Uri data, {bool args = false}) => processUri(data, fromInit: args);

  @override
  Future<List<ProcessorResult<Token>>?> processUri(Uri uri, {bool fromInit = false});

  /// Tries to find a suitable processor for the given uri and process it.
  /// Returns null if no suitable processor was found.
  static Future<List<ProcessorResult<Token>>?> processUriByAny(Uri uri) async {
    for (TokenImportSchemeProcessor processor in implementations) {
      if (processor.supportedSchemes.contains(uri.scheme)) {
        return await processor.processUri(uri);
      }
    }
    return null;
  }
}
