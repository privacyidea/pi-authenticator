import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/token_container_state_provider.dart';

import '../interfaces/api_endpoint.dart';
import '../model/states/token_container_state.dart';

class TokenContainerApiEndpoint implements ApiEndpioint<TokenContainerState, Credentials> {
  @override
  final Credentials credentials;

  const TokenContainerApiEndpoint({required this.credentials});

  @override
  Future<TokenContainerState> fetch() {
    throw UnimplementedError();
  }

  @override
  Future<void> save(TokenContainerState data) {
    throw UnimplementedError();
  }
}
