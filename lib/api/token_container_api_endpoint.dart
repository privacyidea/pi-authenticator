import '../interfaces/api_endpoint.dart';
import '../model/states/token_container_state.dart';

class TokenContainerApiEndpoint implements ApiEndpioint<TokenContainerState, String> {
  @override
  Future<TokenContainerState> fetch(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> save(TokenContainerState data) {
    throw UnimplementedError();
  }
}
