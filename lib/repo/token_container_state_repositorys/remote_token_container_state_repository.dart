import '../../api/token_container_api_endpoint.dart';
import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';

class RemoteTokenContainerStateRepository implements TokenContainerStateRepository {
  final TokenContainerApiEndpoint apiEndpoint;
  final String containerId;

  RemoteTokenContainerStateRepository({required this.apiEndpoint, required this.containerId});

  @override
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) {
    throw UnimplementedError();
  }

  @override
  Future<TokenContainerState> loadContainer() => _fetchContainerState();

  Future<TokenContainerState> _fetchContainerState() async => apiEndpoint.fetch(containerId);
}
