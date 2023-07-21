import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/token_category.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

@immutable
class TokenState {
  final List<Token> tokens;
  const TokenState({this.tokens = const <Token>[]});
  TokenState repaceList({List<Token>? tokens}) => TokenState(tokens: tokens ?? this.tokens);

  static _sort(List<Token> tokens) => tokens.sort((a, b) => (a.sortIndex ?? double.infinity).compareTo(b.sortIndex ?? double.infinity));

  TokenState withToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    newTokens.add(token);
    _sort(newTokens);
    return TokenState(tokens: newTokens);
  }

  TokenState withTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    newTokens.addAll(tokens);
    _sort(newTokens);
    return TokenState(tokens: newTokens);
  }

  TokenState withoutToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    newTokens.remove(token);
    return TokenState(tokens: newTokens);
  }

  TokenState withoutTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    newTokens.removeWhere((element) => tokens.contains(element));
    return TokenState(tokens: newTokens);
  }

  TokenState updateToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    newTokens[newTokens.indexWhere((element) => element.id == token.id)] = token;
    _sort(newTokens);
    return TokenState(tokens: newTokens);
  }

  TokenState updateTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    tokens.forEach((token) {
      final index = newTokens.indexWhere((element) => element.id == token.id);
      newTokens[index] = token;
    });
    _sort(newTokens);
    return TokenState(tokens: newTokens);
  }

  List<Token> tokensInCategory(TokenCategory category) => tokens.where((token) => token.categoryId == category.categoryId).toList();
}
