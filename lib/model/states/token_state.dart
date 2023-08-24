import 'package:flutter/material.dart';

import '../token_folder.dart';
import '../tokens/token.dart';

@immutable
class TokenState {
  final List<Token> tokens;
  const TokenState({this.tokens = const <Token>[]});
  TokenState copyWith({List<Token>? tokens}) => TokenState(tokens: tokens ?? this.tokens);

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
    newTokens.removeWhere((element) => element.id == token.id);
    return TokenState(tokens: newTokens);
  }

  TokenState withoutTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    newTokens.removeWhere((element) => tokens.any((token) => token.id == element.id));
    return TokenState(tokens: newTokens);
  }

  // replace the token where the id is the same
  TokenState updateToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    final index = newTokens.indexWhere((element) => element.id == token.id);
    if (index == -1) {
      newTokens.add(token);
      return TokenState(tokens: newTokens);
    } else {
      newTokens[index] = token;
      _sort(newTokens);
      return TokenState(tokens: newTokens);
    }
  }

  // replace all tokens where the id is the same
  // if the id is none, add it to the list
  TokenState updateTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    for (var token in tokens) {
      final index = newTokens.indexWhere((element) => element.id == token.id);
      if (index == -1) {
        newTokens.add(token);
        continue;
      }
      newTokens[index] = token;
    }
    _sort(newTokens);
    return TokenState(tokens: newTokens);
  }

  List<Token> tokensInFolder(TokenFolder folder) => tokens.where((token) => token.folderId == folder.folderId).toList();
  List<Token> tokensWithoutFolder() => tokens.where((token) => token.folderId == null).toList();
}
