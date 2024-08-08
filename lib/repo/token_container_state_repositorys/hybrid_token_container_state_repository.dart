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
import '../../utils/errors.dart';

import '../../interfaces/repo/container_repository.dart';
import '../../model/token_container.dart';
import '../../utils/logger.dart';

class HybridTokenContainerRepository<LocalRepo extends TokenContainerRepository, RemoteRepo extends TokenContainerRepository>
    implements TokenContainerRepository {
  final LocalRepo _localRepository;
  final RemoteRepo _remoteRepository;

  HybridTokenContainerRepository({
    required LocalRepo localRepository,
    required RemoteRepo remoteRepository,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository;

  @override
  Future<TokenContainer> loadContainerState({bool isInitial = false}) async {
    Logger.warning('Loading container state', name: 'HybridTokenContainerRepository');
    TokenContainer localState;
    TokenContainer newState;

    try {
      localState = await _localRepository.loadContainerState();
    } catch (e) {
      Logger.warning('Failed to load local container state');
      return TokenContainer.error(
        error: LocalizedException(
          unlocalizedMessage: 'Failed to load local container state',
          localizedMessage: (localization) => localization.failedToLoad('local container state'),
        ),
      );
    }
    try {
      newState = await _remoteRepository.saveContainerState(localState);
    } catch (e) {
      newState = localState.copyTransformInto<TokenContainerUnsynced>();
    }

    try {
      await _localRepository.saveContainerState(newState);
    } catch (e) {
      Logger.error('Failed to save synced state to local repository', name: 'HybridTokenContainerRepository', error: e);
    }

    return newState;
  }

  @override
  Future<TokenContainer> saveContainerState(TokenContainer currentState) async {
    if (currentState is TokenContainerError) {
      Logger.warning('Cannot save error state to repository');
      return currentState;
    }
    TokenContainer newState;

    try {
      newState = await _remoteRepository.saveContainerState(currentState);
    } catch (e, s) {
      Logger.warning(
        'Failed to save state to remote repository: Changed to unsynced state',
        name: 'HybridTokenContainerRepository#saveContainerState',
        error: e,
        stackTrace: s,
      );
      newState = currentState.copyTransformInto<TokenContainerUnsynced>();
      return _localRepository.saveContainerState(newState);
    }

    try {
      newState = await _localRepository.saveContainerState(newState);
    } catch (e) {
      Logger.error('Failed to save state to local repository');
      return newState;
    }
    return newState;
  }

  // Future<TokenContainer> _merge({
  //   required TokenContainer localState,
  //   required TokenContainer remoteState,
  // }) async {
  //   List<TokenTemplate> localTemplates;
  //   List<TokenTemplate> remoteTemplates;
  //   if (localState is TokenContainerUninitialized) {
  //     // Uninitialized state is always overwritten by other states
  //     localTemplates = [];
  //   } else {
  //     localTemplates = localState.tokenTemplates;
  //   }
  //   if (remoteState is TokenContainerUninitialized) {
  //     // Uninitialized state is always overwritten by other states
  //     remoteTemplates = [];
  //   } else {
  //     remoteTemplates = remoteState.tokenTemplates ?? [];
  //   }

  //   final mergedTemplates = await _mergeTemplateLists(
  //     localTemplates: localTemplates,
  //     remoteTemplates: remoteTemplates,
  //   );

  //   final newSyncedState = TokenContainerSynced(
  //     lastSyncedAt: DateTime.now(),
  //     containerId: localState.containerId,
  //     description: localState.description,
  //     type: '', // TODO: Implement type
  //     tokenTemplates: mergedTemplates,
  //   );
  //   return newSyncedState;
  // }

  // Future<List<TokenTemplate>> _mergeTemplateLists({
  //   required List<TokenTemplate> localTemplates,
  //   required List<TokenTemplate> remoteTemplates,
  // }) async {
  //   final mergedTemplates = <TokenTemplate>[];

  //   // Add all remaining local templates
  //   for (var localTemplate in localTemplates) {
  //     final remoteTemplate = remoteTemplates.firstWhereOrNull((template) => template.id == localTemplate.id);
  //     if (remoteTemplate == null) {
  //       mergedTemplates.add(localTemplate);
  //       continue;
  //     }
  //     mergedTemplates.add(await _mergeTemplates(localTemplate, remoteTemplate));
  //   }

  //   // Add all remaining remote templates
  //   mergedTemplates.addAll(remoteTemplates);

  //   return mergedTemplates;
  // }

  /// Merges local and remote token templates with the last synced state
  /// If both local and remote templates have changed, the remote changes are prioritized
  // Future<TokenTemplate> _mergeTemplates(TokenTemplate local, TokenTemplate remote) async {
  //   assert(local.id == remote.id, 'Both templates must have the same id');
  //   final mergedData = <String, dynamic>{};

  //   print('------------------------------------------------------------------');
  //   print('Local: ${local.data}');
  //   mergedData.addAll(local.data);
  //   print('MergedData: $mergedData');
  //   print('------------------------------------------------------------------');
  //   print('Remote: ${remote.data}');
  //   mergedData.addAll(remote.data);
  //   print('MergedData: $mergedData');
  //   print('------------------------------------------------------------------');

  //   return TokenTemplate(data: mergedData);
  // }

  // @override
  // Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId) async {
  //   final state = await loadContainerState();
  //   final template = state.tokenTemplates.firstWhereOrNull((template) => template.id == tokenTemplateId);
  //   return template;
  // }

  // @override
  // Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate) async {
  //   final state = await loadContainerState();
  //   final templates = state.tokenTemplates;
  //   templates.removeWhere((template) => template.id == tokenTemplate.id);
  //   templates.add(tokenTemplate);
  //   final newState = state.copyWith(tokenTemplates: templates);
  //   final savedState = await saveContainerState(newState);
  //   return savedState.tokenTemplates.firstWhere((template) => template.id == tokenTemplate.id);
  // }
}
