import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interfaces/repo/container_repository.dart';
import '../model/states/token_container_state.dart';
import '../model/tokens/token.dart';

class TokenContainerNotifier extends StateNotifier<TokenContainerState> {
  final TokenContainerStateRepository _repository;
  final StateNotifierProviderRef _ref;

  TokenContainerNotifier({
    required StateNotifierProviderRef ref,
    required TokenContainerStateRepository repository,
    TokenContainerState? initState,
  })  : _repository = repository,
        _ref = ref,
        super(initState ?? TokenContainerState.uninitialized()) {
    _init();
  }

  Future<void> _init() async {
    throw UnimplementedError();
  }

  Future<void> loadContainerState() async {
    final containerState = await _repository.loadContainer();
    state = containerState;
  }

  Future<void> saveContainerState() async {
    await _repository.saveContainerState(state);
  }

  Future<TokenContainerState> updatedTokensIfContains(List<Token> lastlyUpdatedTokens) async {
    throw UnimplementedError();
  }
}
