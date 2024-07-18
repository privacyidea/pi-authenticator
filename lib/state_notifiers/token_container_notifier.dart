import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';

import '../interfaces/repo/container_repository.dart';
import '../model/states/token_container_state.dart';
import '../model/tokens/token.dart';

class TokenContainerNotifier extends StateNotifier<TokenContainerState> {
  final TokenContainerStateRepository _repository;
  late Future<TokenContainerState> initState;
  // final StateNotifierProviderRef _ref;
  final Mutex _repoMutex = Mutex();
  final Mutex _updateMutex = Mutex();

  TokenContainerNotifier({
    // required StateNotifierProviderRef ref,
    required TokenContainerStateRepository repository,
    TokenContainerState? initState,
  })  : _repository = repository,
        // _ref = ref,
        super(initState ?? TokenContainerState.uninitialized()) {
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

  Future<TokenContainerState> addToken(Token token) async {
    await _updateMutex.acquire();
    final newState = state.copyTransformInto(
      tokenTemplates: [...state.tokenTemplates, TokenTemplate(data: token.toUriMap())],
    );
    final savedState = await _saveToRepo(newState);
    state = savedState;
    _updateMutex.release();
    return savedState;
  }

  Future<TokenContainerState> updateTemplates(List<TokenTemplate> updatedTemplates) async {
    await _updateMutex.acquire();
    final newState = state.copyTransformInto<TokenContainerStateSynced>(
      tokenTemplates: state.tokenTemplates.map((oldToken) {
        final updatedToken = updatedTemplates.firstWhere(
          (newToken) => newToken.id == oldToken.id,
          orElse: () => oldToken,
        );
        return updatedToken;
      }).toList(),
    );
    final savedState = await _saveToRepo(newState);
    state = savedState;
    _updateMutex.release();
    return savedState;
  }
}


