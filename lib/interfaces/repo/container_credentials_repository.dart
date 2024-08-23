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
import '../../model/riverpod_states/credentials_state.dart';
import '../../model/tokens/container_credentials.dart';

abstract class ContainerCredentialsRepository {
  Future<CredentialsState> saveCredential(ContainerCredential credential);
  Future<CredentialsState> saveCredentialsState(CredentialsState credentialsState);
  Future<CredentialsState> loadCredentialsState();
  Future<ContainerCredential?> loadCredential(String serial);
  Future<CredentialsState> deleteAllCredentials();
  Future<CredentialsState> deleteCredential(String serial);
}
