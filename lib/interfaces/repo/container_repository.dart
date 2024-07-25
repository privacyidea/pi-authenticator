
import '../../model/token_container.dart';

abstract class TokenContainerRepository {
  /// Save the container state to the repository
  /// Returns the state that was actually written
  Future<TokenContainer> saveContainerState(TokenContainer containerState);

  /// Load the container state from the repository
  /// Returns the loaded state
  Future<TokenContainer> loadContainerState();

  // /// Save a token template to the repository
  // /// Returns the template that was actually written
  // Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate);

  // /// Load a token template from the repository
  // /// Returns the loaded template
  // Future<TokenTemplate?> loadTokenTemplate(String tokenTemplateId);
}
