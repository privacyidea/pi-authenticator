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
import 'package:mutex/mutex.dart';
import '../../utils/logger.dart';

import '../../api/token_container_api_endpoint.dart';
import '../../interfaces/repo/container_repository.dart';
import '../../model/token_container.dart';

class RemoteTokenContainerRepository implements TokenContainerRepository {
  final TokenContainerApiEndpoint apiEndpoint;
  final Mutex _m = Mutex();

  Future<TokenContainer> _protect(Future<TokenContainer> Function() f) async => _m.protect(f);

  RemoteTokenContainerRepository({required this.apiEndpoint});

  @override
  Future<TokenContainer> saveContainerState(TokenContainer containerState) async => await _saveContainerState(containerState);

  Future<TokenContainer> _saveContainerState(TokenContainer containerState) async {
    Logger.info('Saving container state', name: 'RemoteTokenContainerRepository');
    return await _protect(() async => (await apiEndpoint.sync(containerState)).copyTransformInto<TokenContainerSynced>());
  }

  @override
  Future<TokenContainer> loadContainerState() {
    Logger.info('Loading container state', name: 'RemoteTokenContainerRepository');
    return _fetchContainerState();
  }

  Future<TokenContainer> _fetchContainerState() async => await _protect(() async => await apiEndpoint.fetch());
}
