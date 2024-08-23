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
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/credential_notifier.dart';

import '../../model/processor_result.dart';
import '../../utils/identifiers.dart';
import 'scheme_processor_interface.dart';
import '../../utils/logger.dart';

import '../../model/tokens/container_credentials.dart';

class ContainerCredentialsProcessor extends SchemeProcessor {
  static const resultHandlerType = TypeMatcher<CredentialsNotifier>();
  static const scheme = 'pia';
  // static const hosts = {'container': _container};

  @override
  Set<String> get supportedSchemes => {scheme};

  const ContainerCredentialsProcessor();
  @override
  Future<List<ProcessorResult<ContainerCredential>>> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) {
      Logger.error('Unsupported scheme', name: 'ContainerCredentialsProcessor');
      return [];
    }
    final credential = ContainerCredential.fromUriMap(uri.queryParameters);
    Logger.warning('Adding credential to container', name: 'ContainerCredentialsProcessor');
    return [
      ProcessorResult.success(
        credential,
        resultHandlerType: resultHandlerType,
      )
    ];
  }

  // static Future<List<ProcessorResult<ContainerCredential>>> _container(Uri uri) async {
  //   try {
  //     final credential = ContainerCredential.fromUriMap(uri.queryParameters);
  //     Logger.info('Processing URI ${uri.scheme} succeded', name: 'PrivacyIDEAAuthenticatorQrProcessor#processUri');
  //     return [
  //       ProcessorResult.success(
  //         credential,
  //         resultHandlerType: resultHandlerType,
  //       )
  //     ];
  //   } catch (e) {
  //     Logger.error('Error while processing URI ${uri.scheme}', error: e, name: 'PrivacyIDEAAuthenticatorQrProcessor#processUri');
  //     return [
  //       ProcessorResult.failed(
  //         'Invalid URI',
  //         resultHandlerType: resultHandlerType,
  //       )
  //     ];
  //   }
  // }
}
