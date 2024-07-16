import '../../model/states/token_container_state.dart';

abstract class TokenContainerStateRepository {
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState);
  Future<TokenContainerState> loadContainer();
}
