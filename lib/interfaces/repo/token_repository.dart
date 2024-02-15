import '../../model/tokens/token.dart';

abstract class TokenRepository {
  Future<List<Token>> saveOrReplaceTokens(List<Token> tokens);
  Future<List<Token>> loadTokens();

  //Returns the tokens that were not deleted
  Future<List<Token>> deleteTokens(List<Token> tokens);
}
