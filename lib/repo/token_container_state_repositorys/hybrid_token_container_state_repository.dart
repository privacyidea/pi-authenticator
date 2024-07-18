import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/errors.dart';
import 'package:collection/collection.dart';

import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';
import '../../utils/logger.dart';

class HybridTokenContainerStateRepository<LocalRepo extends TokenContainerStateRepository, RemoteRepo extends TokenContainerStateRepository>
    implements TokenContainerStateRepository {
  final LocalRepo _localRepository;
  final LocalRepo _syncedRepository;
  final RemoteRepo? _remoteRepository;

  HybridTokenContainerStateRepository({
    required LocalRepo localRepository,
    required LocalRepo syncedRepository,
    required RemoteRepo? remoteRepository,
  })  :
        _localRepository = localRepository,
        _syncedRepository = syncedRepository,
        _remoteRepository = remoteRepository;

  @override
  Future<TokenContainerState> loadContainerState({bool isInitial = false}) async {
    TokenContainerState? remoteState;
    TokenContainerState lastSyncedState;
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
        lastSyncedAt: null,
        containerId: '',
        description: '',
        type: '',
        tokenTemplates: [],
      );
    }
    try {
      remoteState = await _remoteRepository?.loadContainerState();
      lastSyncedState = await _syncedRepository.loadContainerState();
    } catch (e) {
      newState = localState.copyTransformInto<TokenContainerStateUnsynced>();
      return newState;
    }
    newState = await _merge(
      localState: localState,
      remoteState: remoteState,
      lastSyncedState: lastSyncedState,
    );
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
  Future<TokenContainerState> saveContainerState(TokenContainerState newLocalState) async {
    if (newLocalState is TokenContainerStateError) {
      Logger.warning('Cannot save error state to repository');
      return newLocalState;
    }
    TokenContainerState? remoteState;
    TokenContainerState lastSyncedState;
    TokenContainerState newState;

    try {
      remoteState = await _remoteRepository?.loadContainerState();
      lastSyncedState = await _syncedRepository.loadContainerState();
    } catch (e) {
      newState = newLocalState.copyTransformInto<TokenContainerStateUnsynced>();
      return _localRepository.saveContainerState(newState);
    }
    newState = await _merge(
      localState: newLocalState,
      remoteState: remoteState,
      lastSyncedState: lastSyncedState,
    );
    try {
      await _remoteRepository?.saveContainerState(newState);
    } catch (e) {
      newState = newState.copyTransformInto<TokenContainerStateUnsynced>();
      await _localRepository.saveContainerState(newState);
      return newState;
    }
    await _syncedRepository.saveContainerState(newState);
    await _localRepository.saveContainerState(newState);
    return newState;
  }

  Future<TokenContainerState> _merge({
    required TokenContainerState localState,
    required TokenContainerState? remoteState,
    required TokenContainerState lastSyncedState,
  }) async {
    List<TokenTemplate> localTemplates;
    List<TokenTemplate> remoteTemplates;
    List<TokenTemplate> syncedTemplates;
    if (localState is TokenContainerStateUninitialized) {
      // Uninitialized state is always overwritten by other states
      localTemplates = [];
    } else {
      localTemplates = localState.tokenTemplates;
    }
    if (remoteState is TokenContainerStateUninitialized) {
      // Uninitialized state is always overwritten by other states
      remoteTemplates = [];
    } else {
      remoteTemplates = remoteState?.tokenTemplates ?? [];
    }
    if (lastSyncedState is TokenContainerStateUninitialized) {
      // Uninitialized state is always overwritten by other states
      syncedTemplates = [];
    } else {
      syncedTemplates = lastSyncedState.tokenTemplates;
    }

    final mergedTemplates = await _mergeTemplateLists(
      localTemplates: localTemplates,
      remoteTemplates: remoteTemplates,
      syncedTemplates: syncedTemplates,
    );

    final newSyncedState = TokenContainerStateSynced(
      lastSyncedAt: DateTime.now(),
      containerId: localState.containerId,
      description: localState.description,
      type: '', // TODO: Implement type
      tokenTemplates: mergedTemplates,
    );
    return newSyncedState;
  }

  Future<List<TokenTemplate>> _mergeTemplateLists({
    required List<TokenTemplate> localTemplates,
    required List<TokenTemplate> remoteTemplates,
    required List<TokenTemplate> syncedTemplates,
  }) async {
    final mergedTemplates = <TokenTemplate>[];

    // Add all templates that are in the synced state
    for (var syncedTemplate in syncedTemplates) {
      final localTemplateIndex = localTemplates.indexWhere((template) => template.id == syncedTemplate.id);
      final localTemplate = localTemplateIndex != -1 ? localTemplates.removeAt(localTemplateIndex) : null;
      final remoteTemplateIndex = remoteTemplates.indexWhere((template) => template.id == syncedTemplate.id);
      final remoteTemplate = remoteTemplateIndex != -1 ? remoteTemplates.removeAt(remoteTemplateIndex) : null;

      mergedTemplates.add(await _mergeTemplates(localTemplate, remoteTemplate, syncedTemplate));
    }

    // Add all remaining local templates
    for (var localTemplate in localTemplates) {
      final remoteTemplateIndex = remoteTemplates.indexWhere((template) => template.id == localTemplate.id);
      final remoteTemplate = remoteTemplateIndex != -1 ? remoteTemplates.removeAt(remoteTemplateIndex) : null;

      mergedTemplates.add(await _mergeTemplates(localTemplate, remoteTemplate, null));
    }

    // Add all remaining remote templates
    mergedTemplates.addAll(remoteTemplates);

    return mergedTemplates;
  }

  /// Merges local and remote token templates with the last synced state
  /// If both local and remote templates have changed, the remote changes are prioritized
  Future<TokenTemplate> _mergeTemplates(TokenTemplate? local, TokenTemplate? remote, TokenTemplate? lastSynced) async {
    final id = local?.id ?? remote?.id ?? lastSynced?.id;
    assert(id != null, 'At least one template must be provided');
    assert((local == null || local.id == id) && (remote == null || remote.id == id) && (lastSynced == null || lastSynced.id == id),
        'All templates must have the same id');
    final mergedData = <String, dynamic>{};

    final lastSyncedData = lastSynced?.data ?? {};
    mergedData.addAll(lastSyncedData);
    final localData = local?.data ?? {};
    mergedData.addAll(localData);
    final remoteData = remote?.data ?? {};
    mergedData.addAll(remoteData);

    return TokenTemplate(data: mergedData);
  }

  @override
  Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId) async {
    final state = await loadContainerState();
    final template = state.tokenTemplates.firstWhereOrNull((template) => template.id == tokenTemplateId);
    return template;
  }

  @override
  Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate) async {
    final state = await loadContainerState();
    final templates = state.tokenTemplates;
    templates.removeWhere((template) => template.id == tokenTemplate.id);
    templates.add(tokenTemplate);
    final newState = state.copyWith(tokenTemplates: templates);
    final savedState = await saveContainerState(newState);
    return savedState.tokenTemplates.firstWhere((template) => template.id == tokenTemplate.id);
  }
}
