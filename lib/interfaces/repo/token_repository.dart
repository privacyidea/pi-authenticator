import '../../model/tokens/token.dart';

abstract class TokenRepository {
  Future<List<Token>> saveNewState(List<Token> tokens);
  Future<List<Token>> loadTokens();
  Future<List<Token>> deleteTokens(List<Token> tokens);
}
