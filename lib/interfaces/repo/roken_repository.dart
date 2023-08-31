import 'package:privacyidea_authenticator/model/tokens/token.dart';

abstract class TokenRepository {
  Future<List<Token>> saveOrReplaceTokens(List<Token> tokens);
  Future<List<Token>> loadTokens();
  Future<List<Token>> deleteTokens(List<Token> tokens);
}
