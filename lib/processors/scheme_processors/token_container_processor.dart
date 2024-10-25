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
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../model/exception_errors/localized_argument_error.dart';
import '../../../../../../../utils/globals.dart';
import '../../model/processor_result.dart';
import '../../model/token_container.dart';
import '../../utils/logger.dart';
import '../../utils/object_validator.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'scheme_processor_interface.dart';

class TokenContainerProcessor extends SchemeProcessor {
  static const resultHandlerType = ObjectValidator<TokenContainerNotifier>();
  static const scheme = 'pia';
  static const host = 'container';

  @override
  Set<String> get supportedSchemes => {scheme};

  const TokenContainerProcessor();
  @override
  Future<List<ProcessorResult<TokenContainer>>?> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) return null;
    if (uri.host != host) return null;

    try {
      final container = TokenContainer.fromUriMap(uri.queryParameters);
      Logger.info('Successfully parsed container container');
      return [
        ProcessorResult.success(
          container,
          resultHandlerType: resultHandlerType,
        )
      ];
    } on LocalizedArgumentError catch (e) {
      Logger.warning('Error while processing URI ${uri.scheme}', error: e.message);
      return [
        ProcessorResult.failed(
          e.localizedMessage(AppLocalizations.of(await globalContext)!),
          resultHandlerType: resultHandlerType,
        )
      ];
    }
  }
}
