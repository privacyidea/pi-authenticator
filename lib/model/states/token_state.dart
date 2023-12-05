import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';

import '../../utils/logger.dart';
import '../token_folder.dart';
import '../tokens/hotp_token.dart';
import '../tokens/push_token.dart';
import '../tokens/token.dart';

@immutable
class TokenState {
  final List<Token> tokens;

  List<OTPToken> get otpTokens => tokens.whereType<OTPToken>().toList();
  bool get hasOTPTokens => otpTokens.isNotEmpty;

  List<HOTPToken> get hotpTokens => tokens.whereType<HOTPToken>().toList();
  bool get hasHOTPTokens => hotpTokens.isNotEmpty;

  List<PushToken> get pushTokens => tokens.whereType<PushToken>().toList();
  bool get hasPushTokens => pushTokens.isNotEmpty;

  TokenState({List<Token> tokens = const []}) : tokens = List<Token>.from(tokens) {
    _sort(this.tokens);
  }
  TokenState repaceList({List<Token>? tokens}) => TokenState(tokens: tokens ?? this.tokens);

  static void _sort(List<Token> tokens) {
    tokens.sort((a, b) => (a.sortIndex ?? double.infinity).compareTo(b.sortIndex ?? double.infinity));
  }

  T? currentOf<T extends Token>(T token) => tokens.firstWhereOrNull((element) => element.id == token.id) as T?;

  TokenState withToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    newTokens.add(token);
    return TokenState(tokens: newTokens);
  }

  TokenState withTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    newTokens.addAll(tokens);
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

  // Add a token if it does not exist yet
  // Replace the token if it does exist
  TokenState addOrReplaceToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    final index = newTokens.indexWhere((element) => element.id == token.id);
    if (index == -1) {
      newTokens.add(token);
    } else {
      newTokens[index] = token;
    }
    return TokenState(tokens: newTokens);
  }

  // Replace the token if it does exist
  // Do nothing if it does not exist
  TokenState replaceToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    final index = newTokens.indexWhere((element) => element.id == token.id);
    if (index == -1) {
      Logger.warning('Tried to replace a token that does not exist.', name: 'token_state.dart#replaceToken');
      return this;
    }
    newTokens[index] = token;
    return TokenState(tokens: newTokens);
  }

  // replace all tokens where the id is the same
  // if the id is none, add it to the list
  TokenState addOrReplaceTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    for (var token in tokens) {
      final index = newTokens.indexWhere((element) => element.id == token.id);
      if (index == -1) {
        newTokens.add(token);
        continue;
      }
      newTokens[index] = token;
    }
    return TokenState(tokens: newTokens);
  }

  // Replace the tokens if it does exist
  // Do nothing if it does not exist
  TokenState replaceTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    for (var token in tokens) {
      final index = newTokens.indexWhere((element) => element.id == token.id);
      if (index == -1) {
        Logger.warning('Tried to replace a token that does not exist.', name: 'token_state.dart#replaceToken');
        continue;
      }
      newTokens[index] = token;
    }
    return TokenState(tokens: newTokens);
  }

  List<Token> tokensInFolder(TokenFolder folder, {List<Type>? only, List<Type>? exclude}) => tokens.where((token) {
        if (token.folderId != folder.folderId) {
          return false;
        }
        if (exclude != null && exclude.contains(token.runtimeType)) return false;
        if (only != null && !only.contains(token.runtimeType)) return false;
        return true;
      }).toList();

  List<Token> tokensWithoutFolder({List<Type>? only, List<Type>? exclude}) => tokens.where((token) {
        if (token.folderId != null) {
          return false;
        }
        if (exclude != null && exclude.contains(token.runtimeType)) return false;
        if (only != null && !only.contains(token.runtimeType)) return false;
        return true;
      }).toList();

  PushToken? tokenWithPushRequest() => tokens.whereType<PushToken>().firstWhereOrNull((token) => token.pushRequests.isNotEmpty);
}
