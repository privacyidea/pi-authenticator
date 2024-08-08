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
import 'scheme_processor_interface.dart';
import '../../utils/globals.dart';
import '../../utils/logger.dart';

import '../../model/tokens/container_credentials.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/credential_notifier.dart';

class ContainerCredentialsProcessor extends SchemeProcessor {
  @override
  Set<String> get supportedSchemes => {'container'}; // TODO: edit supportedSchemes to the real supported schemes
  List<String> get supportedHosts => ['credentials']; // TODO: edit supportedHosts to the real supported hosts

  const ContainerCredentialsProcessor();
  @override
  Future processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedHosts.contains(uri.host) || !supportedSchemes.contains(uri.scheme)) {
      return null;
    }
    final credential = ContainerCredential.fromUriMap(uri.queryParameters);
    Logger.warning('Adding credential to container', name: 'ContainerCredentialsProcessor');
    globalRef?.read(credentialsNotifierProvider.notifier).addCredential(credential);
  }
}
