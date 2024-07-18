import 'package:privacyidea_authenticator/model/token_container.dart';

import '../../model/states/token_container_state.dart';

abstract class TokenContainerStateRepository {
  /// Save the container state to the repository
  /// Returns the state that was actually written
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState);

  /// Load the container state from the repository
  /// Returns the loaded state
  Future<TokenContainerState> loadContainerState();

  /// Save a token template to the repository
  /// Returns the template that was actually written
  Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate);

  /// Load a token template from the repository
  /// Returns the loaded template
  Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId);
}
