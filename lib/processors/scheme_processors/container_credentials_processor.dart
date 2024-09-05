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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/errors.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/credential_notifier.dart';
import '../../model/processor_result.dart';
import '../../utils/identifiers.dart';
import 'scheme_processor_interface.dart';
import '../../utils/logger.dart';

import '../../model/tokens/container_credentials.dart';

class ContainerCredentialsProcessor extends SchemeProcessor {
  static const resultHandlerType = TypeValidatorRequired<ContainerCredentialsNotifier>();
  static const scheme = 'pia';
  static const host = 'container';

  @override
  Set<String> get supportedSchemes => {scheme};

  const ContainerCredentialsProcessor();
  @override
  Future<List<ProcessorResult<ContainerCredential>>?> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) return null;
    if (uri.host != host) return null;

    try {
      final credential = ContainerCredential.fromUriMap(uri.queryParameters);
      Logger.info('Successfully parsed container credential', name: 'ContainerCredentialsProcessor#processUri');
      return [
        ProcessorResult.success(
          credential,
          resultHandlerType: resultHandlerType,
        )
      ];
    } on LocalizedArgumentError catch (e) {
      Logger.warning('Error while processing URI ${uri.scheme}', error: e.message, name: 'ContainerCredentialsProcessor#processUri');
      return [
        ProcessorResult.failed(
          e.localizedMessage(AppLocalizations.of(await globalContext)!),
          resultHandlerType: resultHandlerType,
        )
      ];
    }
  }
}
