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
import '../../../../interfaces/repo/container_repository.dart';
import '../../../logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../api/token_container_api_endpoint.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../../../model/token_container.dart';
import '../../../../repo/token_container_state_repositorys/hybrid_token_container_state_repository.dart';
import '../../../../repo/token_container_state_repositorys/remote_token_container_state_repository.dart';
import '../../../../repo/token_container_state_repositorys/secure_token_container_state_repository.dart.dart';
import '../../../../model/tokens/container_credentials.dart';
import 'token_notifier.dart';

part 'token_container_notifier.g.dart';

@riverpod
class TokenContainerNotifier extends _$TokenContainerNotifier {
  late final TokenContainerRepository _repository;
  final Mutex _stateMutex = Mutex(); // Mutex to protect the state from being accessed while still waiting for the newest state to be delivered
  final Mutex _repoMutex = Mutex(); // Mutex to protect the repository from being accessed while still waiting for the newest state to be delivered

  @override
  Future<TokenContainer> build({
    required ContainerCredential credential,
  }) async {
    Logger.info('New tokenContainerStateProvider created', name: 'TokenContainerNotifier#build');
    await _stateMutex.acquire();
    _repository = SecureTokenContainerRepository(containerId: credential.serial);
    // HybridTokenContainerRepository(
    // localRepository: SecureTokenContainerRepository(containerId: credential.serial),
    // remoteRepository: RemoteTokenContainerRepository(apiEndpoint: TokenContainerApiEndpoint(credential: credential)),
    // );
    final initialState = await _repository.loadContainerState();
    Logger.debug('Initial state: $initialState', name: 'TokenContainerNotifier#build');
    _stateMutex.release();
    return initialState;
  }

  Future<TokenContainer> _saveToRepo(TokenContainer state) async {
    await _repoMutex.acquire();
    final newState = await _repository.saveContainerState(state);
    _repoMutex.release();
    return newState;
  }

  Future<TokenContainer> _fetchFromRepo() async {
    await _repoMutex.acquire();
    final newState = await _repository.loadContainerState();
    _repoMutex.release();
    return newState;
  }

  Future<TokenContainer> handleTokenState(TokenState tokenState) async {
    await _stateMutex.acquire();
    final localTokens = tokenState.tokens.maybePiTokens;
    final oldState = state.value;
    if (oldState == null) throw Exception('TokenContainer is null');
    final containerTokens = tokenState.containerTokens(oldState.serial);
    final localTokenTemplates = localTokens.toTemplates();
    final containerTokenTemplates = containerTokens.toTemplates();
    final newState = oldState.copyWith(localTokenTemplates: localTokenTemplates, syncedTokenTemplates: containerTokenTemplates);
    final savedState = await _saveToRepo(newState);
    if (savedState is! TokenContainerSynced) {
      Logger.error('Failed to save state to repo', name: 'TokenContainerNotifier#handleTokenState');
      return savedState;
    }
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }

  /// Adds the given [maybePiTokenTemplates] to the localTokenTemplates of the container
  /// and saves the new state to the repository. The rpository decides waht to do with the new state.
  /// The saved state from the repo can contain the maybePiTokenTemplates or not.
  Future<TokenContainer> tryAddLocalTemplates(List<TokenTemplate> maybePiTokenTemplates) async {
    Logger.info(
      'Trying to add (${maybePiTokenTemplates.length}) local templates to container (${credential.serial}).',
      name: 'TokenContainerNotifier#tryAddLocalTemplates',
    );
    Logger.debug('Local templates (${maybePiTokenTemplates.length})', name: 'TokenContainerNotifier#tryAddLocalTemplates');
    await _stateMutex.acquire();
    final oldState = (await future);
    final newLocalTokenTemplates = [...maybePiTokenTemplates];
    final newState = oldState.copyWith(localTokenTemplates: newLocalTokenTemplates);
    final savedState = await _saveToRepo(newState);
    Logger.debug(
      'Saved TokenContainer: Synced(${savedState.syncedTokenTemplates.length}) | Local(${savedState.localTokenTemplates.length})',
      name: 'TokenContainerNotifier#tryAddLocalTemplates',
    );
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }

  Future<TokenContainer> handleDeletedTokenTemplates(List<TokenTemplate> deletedPiTokenTemplates) async {
    Logger.info(
      'Removing (${deletedPiTokenTemplates.length}) deleted token templates from container (${credential.serial}).',
      name: 'TokenContainerNotifier#handleDeletedTokenTemplates',
    );
    Logger.debug('Deleted token templates (${deletedPiTokenTemplates.length})', name: 'TokenContainerNotifier#handleDeletedTokenTemplates');
    await _stateMutex.acquire();
    final oldState = (await future);
    final newLocalTokenTemplates = oldState.localTokenTemplates.where((template) => !deletedPiTokenTemplates.contains(template)).toList();
    final newState = oldState.copyWith(localTokenTemplates: newLocalTokenTemplates);
    final savedState = await _saveToRepo(newState);
    Logger.debug(
      'Saved TokenContainer: Synced(${savedState.syncedTokenTemplates.length}) | Local(${savedState.localTokenTemplates.length})',
      name: 'TokenContainerNotifier#handleDeletedTokenTemplates',
    );
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }

  Future<TokenContainer> fetchTokens() async {
    await _stateMutex.acquire();
    final savedState = await _fetchFromRepo();
    Logger.debug(
      'Fetched TokenContainer: Synced(${savedState.syncedTokenTemplates.length}) | Local(${savedState.localTokenTemplates.length})',
      name: 'TokenContainerNotifier#tryAddLocalTemplates',
    );
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }

  Future<TokenContainer> sync() async {
    await _stateMutex.acquire();
    final savedState = await _fetchFromRepo();
    Logger.debug(
      'Fetched TokenContainer: Synced(${savedState.syncedTokenTemplates.length}) | Local(${savedState.localTokenTemplates.length})',
      name: 'TokenContainerNotifier#tryAddLocalTemplates',
    );
    await ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = AsyncValue.data(savedState);
    _stateMutex.release();
    return savedState;
  }
}
