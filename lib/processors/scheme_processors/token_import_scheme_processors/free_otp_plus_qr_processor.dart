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
import '../../../model/enums/token_origin_source_type.dart';
import '../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../model/processor_result.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/token_import_origins.dart';
import 'otp_auth_processor.dart';

class FreeOtpPlusQrProcessor extends OtpAuthProcessor {
  const FreeOtpPlusQrProcessor();

  @override
  Future<List<ProcessorResult<Token>>> processUri(Uri uri, {bool fromInit = false}) => _processOtpAuth(uri);

  Future<List<ProcessorResult<Token>>> _processOtpAuth(Uri uri) async {
    final results = (await super.processUri(uri)).toList();
    final resultsWithOrigin = results.map((t) {
      if (t is! ProcessorResultSuccess<Token>) return t;
      return ProcessorResultSuccess(
        TokenOriginSourceType.qrScanImport.addOriginToToken(
          appName: TokenImportOrigins.freeOtpPlus.appName,
          token: t.resultData,
          isPrivacyIdeaToken: false,
          data: uri.toString(),
        ),
      );
    }).toList();
    return resultsWithOrigin;
  }

  @override
  Set<String> get supportedSchemes => const OtpAuthProcessor().supportedSchemes;
}
