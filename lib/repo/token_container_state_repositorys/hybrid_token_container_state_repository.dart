import 'package:privacyidea_authenticator/utils/errors.dart';

import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';
import '../../utils/logger.dart';

class HybridTokenContainerStateRepository<LocalRepo extends TokenContainerStateRepository, RemoteRepo extends TokenContainerStateRepository>
    implements TokenContainerStateRepository {
  final LocalRepo _localRepository;
  final RemoteRepo _remoteRepository;

  ///
  HybridTokenContainerStateRepository({
    required LocalRepo localRepository,
    required RemoteRepo remoteRepository,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository;

  @override
  Future<TokenContainerState> loadContainerState({bool isInitial = false}) async {
    TokenContainerState localState;
    TokenContainerState newState;

    try {
      localState = await _localRepository.loadContainerState();
    } catch (e) {
      return TokenContainerStateError(
        error: LocalizedException(
          unlocalizedMessage: 'Failed to load local container state',
          localizedMessage: (localization) => localization.failedToLoad('local container state'),
        ),
      );
    }
    try {
      newState = await _remoteRepository.saveContainerState(localState);
    } catch (e) {
      newState = localState.copyTransformInto<TokenContainerStateUnsynced>();
    }


    try {
      await _localRepository.saveContainerState(newState);
    } catch (e) {
      Logger.error('Failed to save synced state to local repository');
    }

    return newState;
  }

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState currentState) async {
    if (currentState is TokenContainerStateError) {
      Logger.warning('Cannot save error state to repository');
      return currentState;
    }
    TokenContainerState newState;

    try {
      newState = await _remoteRepository.saveContainerState(currentState);
    } catch (e) {
      Logger.warning('Failed to save state to remote repository: Changed to unsynced state');
      newState = currentState.copyTransformInto<TokenContainerStateUnsynced>();
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

  // Future<TokenContainerState> _merge({
  //   required TokenContainerState localState,
  //   required TokenContainerState remoteState,
  // }) async {
  //   List<TokenTemplate> localTemplates;
  //   List<TokenTemplate> remoteTemplates;
  //   if (localState is TokenContainerStateUninitialized) {
  //     // Uninitialized state is always overwritten by other states
  //     localTemplates = [];
  //   } else {
  //     localTemplates = localState.tokenTemplates;
  //   }
  //   if (remoteState is TokenContainerStateUninitialized) {
  //     // Uninitialized state is always overwritten by other states
  //     remoteTemplates = [];
  //   } else {
  //     remoteTemplates = remoteState.tokenTemplates ?? [];
  //   }

  //   final mergedTemplates = await _mergeTemplateLists(
  //     localTemplates: localTemplates,
  //     remoteTemplates: remoteTemplates,
  //   );

  //   final newSyncedState = TokenContainerStateSynced(
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
