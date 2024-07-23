import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';

import '../interfaces/repo/container_repository.dart';
import '../model/states/token_container_state.dart';

class TokenContainerNotifier extends StateNotifier<TokenContainerState> {
  final TokenContainerStateRepository _repository;
  late Future<TokenContainerState> initState;
  final StateNotifierProviderRef _ref;
  final Mutex _repoMutex = Mutex();
  final Mutex _updateMutex = Mutex();

  TokenContainerNotifier({
    required StateNotifierProviderRef ref,
    required TokenContainerStateRepository repository,
    TokenContainerState? initState,
  })  : _repository = repository,
        _ref = ref,
        super(initState ?? TokenContainerState.uninitialized([])) {
    _init();
  }

  Future<void> _init() async {
    initState = _loadFromRepo();
    state = await initState;
  }

  Future<TokenContainerState> _loadFromRepo() async {
    await _repoMutex.acquire();
    final containerState = await _repository.loadContainerState();
    _repoMutex.release();
    return containerState;
  }

  Future<TokenContainerState> _saveToRepo(TokenContainerState state) async {
    await _repoMutex.acquire();
    final newState = await _repository.saveContainerState(state);
    _repoMutex.release();
    return newState;
  }

  Future<TokenContainerState> handleTokenState(TokenState tokenState) async {
    await _updateMutex.acquire();
    final localTokens = tokenState.tokens.maybePiTokens;
    final containerTokens = tokenState.containerTokens(state.serial);
    final localTokenTemplates = localTokens.toTemplates();
    final containerTokenTemplates = containerTokens.toTemplates();
    final newState = state.copyWith(localTokenTemplates: localTokenTemplates, syncedTokenTemplates: containerTokenTemplates);
    final savedState = await _saveToRepo(newState);
    _ref.read(tokenProvider.notifier).updateContainerTokens(savedState);
    state = savedState;
    _updateMutex.release();
    return savedState;
  }

  void addLocalTemplates(List<TokenTemplate> maybePiTokenTemplates) {}

  // Future<TokenContainerState> addToken(Token token) async {
  //   await _updateMutex.acquire();
  //   final newState = state.copyTransformInto<TokenContainerStateModified>(
  //     tokenTemplates: [...state.syncedTokenTemplates, TokenTemplate(data: token.toUriMap())],
  //   );
  //   final savedState = await _saveToRepo(newState);
  //   state = savedState;
  //   _updateMutex.release();
  //   return savedState;
  // }

  // Future<TokenContainerState> updateTemplates(List<TokenTemplate> updatedTemplates) async {
  //   await _updateMutex.acquire();
  //   final newState = state.copyTransformInto<TokenContainerStateSynced>(
  //     tokenTemplates: state.syncedTokenTemplates.map((oldToken) {
  //       final updatedToken = updatedTemplates.firstWhere(
  //         (newToken) => newToken.id == oldToken.id,
  //         orElse: () => oldToken,
  //       );
  //       return updatedToken;
  //     }).toList(),
  //   );
  //   final savedState = await _saveToRepo(newState);
  //   state = savedState;
  //   _updateMutex.release();
  //   return savedState;
  // }
}
