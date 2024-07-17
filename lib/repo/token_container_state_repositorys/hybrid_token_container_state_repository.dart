import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/errors.dart';
import 'package:collection/collection.dart';

import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';
import '../../utils/logger.dart';

class HybridTokenContainerStateRepository<LocalRepo extends TokenContainerStateRepository, RemoteRepo extends TokenContainerStateRepository>
    implements TokenContainerStateRepository {
  final RemoteRepo _remoteRepository;
  final LocalRepo _localRepository;
  final LocalRepo _syncedRepository;

  HybridTokenContainerStateRepository({
    required RemoteRepo remoteRepository,
    required LocalRepo localRepository,
    required LocalRepo syncedRepository,
  })  : _remoteRepository = remoteRepository,
        _localRepository = localRepository,
        _syncedRepository = syncedRepository;

  @override
  Future<TokenContainerState> loadContainer({bool isInitial = false}) async {
    TokenContainerState? remoteState;
    TokenContainerState localState;
    TokenContainerState newState;
    try {
      localState = await _localRepository.loadContainer();
    } catch (e) {
      return TokenContainerStateError(
        error: LocalizedException(
          unlocalizedMessage: 'Failed to load local container state',
          localizedMessage: (localization) => localization.failedToLoad('local container state'),
        ),
        lastSyncedAt: null,
        containerId: '',
        description: '',
        type: '',
        tokenTemplates: [],
      );
    }
    try {
      remoteState = await _remoteRepository.loadContainer();
    } catch (e) {
      newState = localState.copyTransformInto<TokenContainerStateUnsynced>();
      return newState;
    }
    newState = _merge(localState, remoteState);
    if (newState is TokenContainerStateSynced) {
      try {
        await _syncedRepository.saveContainerState(newState);
      } catch (e) {
        Logger.error('Failed to save synced state to local repository');
      }
    }
    return newState;
  }

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async {
    if (containerState is TokenContainerStateError) {
      Logger.warning('Cannot save error state to repository');
      return containerState;
    }
    TokenContainerState remoteState;
    TokenContainerState newState;
    try {
      remoteState = await _remoteRepository.loadContainer();
    } catch (e) {
      newState = containerState.copyTransformInto<TokenContainerStateUnsynced>();
      return _localRepository.saveContainerState(newState);
    }
    newState = _merge(containerState, remoteState);
    try {
      await _remoteRepository.saveContainerState(newState);
    } catch (e) {
      newState = newState.copyTransformInto<TokenContainerStateUnsynced>();
    }
    await _localRepository.saveContainerState(newState);
    return newState;
  }

  TokenContainerState _merge(TokenContainerState localState, TokenContainerState remoteState) {
    if (localState is TokenContainerStateUninitialized) {
      // Uninitialized state is always overwritten by the other state
      return remoteState;
    }
    if (remoteState is TokenContainerStateUninitialized) {
      // Uninitialized state is always overwritten by the other state
      return localState;
    }
    for (var localTemplate in localState.tokenTemplates) {
      final remoteTemplate = remoteState.tokenTemplates.firstWhere((template) => template.id == localTemplate.id, orElse: () => localTemplate);
      if (remoteTemplate != localTemplate) {
        localTemplate.merge(remoteTemplate);
      }
    }
  }

  /// Merges local and remote token templates with the last synced state
  /// If both local and remote templates have changed, the remote changes are prioritized
  Future<TokenTemplate> _mergeTemplates(TokenTemplate local, TokenTemplate remote) async {
    assert(local.id == remote.id);
    final id = local.id;
    final syncedTemplates = (await _syncedRepository.loadContainer()).tokenTemplates;
    final synced = syncedTemplates.firstWhere((template) => template.id == id, orElse: () => TokenTemplate(data: {}));
    final remoteDifferences = _getTemplateDifferences(synced.data, remote.data);
    final localDifferences = _getTemplateDifferences(synced.data, local.data);
    final mergedData = synced.data
      ..addAll(localDifferences)
      ..addAll(remoteDifferences);
    return TokenTemplate(data: mergedData);
  }

  Map<String, dynamic> _getTemplateDifferences(Map<String, dynamic> snyced, Map<String, dynamic> newState) {
    final differences = <String, dynamic>{};
    for (var key in newState.keys) {
      if (snyced[key] != newState[key]) {
        differences[key] = newState[key];
      }
    }
    return differences;
  }
}
