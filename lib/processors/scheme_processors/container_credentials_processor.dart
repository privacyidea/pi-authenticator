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

import '../../model/enums/algorithms.dart';
import '../../model/processor_result.dart';
import '../../utils/identifiers.dart';
import 'scheme_processor_interface.dart';
import '../../utils/logger.dart';

import '../../model/tokens/container_credentials.dart';

class ContainerCredentialsProcessor extends SchemeProcessor {
  static const resultHandlerType = TypeMatcher<ContainerCredentialsNotifier>();
  static const scheme = 'pia';
  static const host = 'container';

  @override
  Set<String> get supportedSchemes => {scheme};

  const ContainerCredentialsProcessor();
  @override
  Future<List<ProcessorResult<ContainerCredential>>?> processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedSchemes.contains(uri.scheme)) return null;
    if (uri.host != host) return null;

    // example: pia://container/SMPH00134123
    // ?issuer=privacyIDEA
    // &nonce=887197025f5fa59b50f33c15196eb97ee651a5d1
    // &time=2024-08-21T07%3A43%3A07.086670%2B00%3A00
    // &url=http://127.0.0.1:5000/container/register/initialize
    // &serial=SMPH00134123
    // &key_algorithm=secp384r1
    // &hash_algorithm=SHA256
    // &passphrase=Enter%20your%20passphrase

    final patameters = uri.queryParameters;

    final DateTime timeStamp;
    final Uri finalizationUrl;
    final EcKeyAlgorithm keyAlgorithm;
    final Algorithms hashAlgorithm;
    try {
      validateMap(patameters, {
        'issuer': const TypeMatcher<String>(),
        'nonce': const TypeMatcher<String>(),
        'time': const TypeMatcher<String>(),
        'url': const TypeMatcher<String>(),
        'serial': const TypeMatcher<String>(),
        'key_algorithm': const TypeMatcher<String>(),
        'hash_algorithm': const TypeMatcher<String>(),
        'passphrase': const TypeMatcher<String?>(),
      });
      timeStamp = DateTime.parse(patameters['time']!);
      finalizationUrl = Uri.parse(patameters['url']!);
      keyAlgorithm = EcKeyAlgorithm.values.byCurveName(patameters['key_algorithm']!);
      hashAlgorithm = Algorithms.values.byName(patameters['hash_algorithm']!);
    } catch (e) {
      Logger.warning('Error while processing URI ${uri.scheme}', error: e, name: 'ContainerCredentialsProcessor#processUri');
      return [
        ProcessorResult.failed(
          '(Invalid URI) Missing or invalid parameters: $e',
          resultHandlerType: resultHandlerType,
        )
      ];
    }

    final uriMap = <String, dynamic>{
      URI_ISSUER: patameters['issuer'],
      URI_NONCE: patameters['nonce'],
      URI_TIMESTAMP: timeStamp,
      URI_FINALIZATION_URL: finalizationUrl,
      URI_SERIAL: patameters['serial'],
      URI_KEY_ALGORITHM: keyAlgorithm,
      URI_HASH_ALGORITHM: hashAlgorithm,
      URI_PASSPHRASE: patameters['passphrase'],
    };

    final credential = ContainerCredential.fromUriMap(uriMap);
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
