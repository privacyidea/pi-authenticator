import '../../model/tokens/token.dart';

abstract class TokenRepository {
  /// Returns the saved Token with the given id.
  Future<Token?> loadToken(String id);

  /// Returns all saved Tokens.
  Future<List<Token>> loadTokens();

  /// Returns true if the Token was saved successfully.
  Future<bool> saveOrReplaceToken(Token token);

  /// Returns the tokens that were not saved successfully.
  Future<List<T>> saveOrReplaceTokens<T extends Token>(List<T> tokens);

  /// Returns true if the Token was deleted successfully.
  Future<bool> deleteToken(Token token);

  /// Returns the tokens that were not deleted successfully.
  Future<List<T>> deleteTokens<T extends Token>(List<T> tokens);
}
