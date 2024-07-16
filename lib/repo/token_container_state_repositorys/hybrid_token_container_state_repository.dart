import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';

class HybridTokenContainerStateRepository<LocalRepo extends TokenContainerStateRepository, RemoteRepo extends TokenContainerStateRepository>
    implements TokenContainerStateRepository {
  final RemoteRepo _remoteRepository;
  final LocalRepo _localRepository;

  HybridTokenContainerStateRepository({
    required RemoteRepo remoteRepository,
    required LocalRepo localRepository,
  })  : _remoteRepository = remoteRepository,
        _localRepository = localRepository;

  @override
  Future<TokenContainerState> loadContainer({bool isInitial = false}) async {
    final remoteState = await _remoteRepository.loadContainer();
    if (isInitial) return remoteState;
    final localState = await _localRepository.loadContainer();
    return _merge(localState, remoteState);
  }

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async {
    TokenContainerState remoteState;
    TokenContainerState newState;
    try {
      remoteState = await _remoteRepository.loadContainer();
    } catch (e) {
      newState = containerState.copyStateWith<TokenContainerStateUnsynced>();
      return _localRepository.saveContainerState(newState);
    }
    newState = _merge(containerState, remoteState);
    try {
      await _remoteRepository.saveContainerState(newState);
    } catch (e) {
      newState = newState.copyStateWith<TokenContainerStateUnsynced>();
    }
    await _localRepository.saveContainerState(newState);
    return newState;
  }

  TokenContainerState _merge(TokenContainerState localState, TokenContainerState remoteState) {
    throw UnimplementedError();
  }
}
