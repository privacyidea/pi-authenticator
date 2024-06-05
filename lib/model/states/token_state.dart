import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../utils/logger.dart';
import '../enums/push_token_rollout_state.dart';
import '../token_folder.dart';
import '../tokens/otp_token.dart';
import '../tokens/push_token.dart';
import '../tokens/token.dart';

@immutable
class TokenState {
  final List<Token> tokens;
  final List<Token> lastlyUpdatedTokens;

  List<OTPToken> get otpTokens => tokens.whereType<OTPToken>().toList();
  bool get hasOTPTokens => otpTokens.isNotEmpty;

  List<PushToken> get pushTokens => tokens.whereType<PushToken>().toList();
  bool get hasPushTokens => pushTokens.isNotEmpty;
  bool get hasRolledOutPushTokens => pushTokens.any((element) => element.isRolledOut);

  List<PushToken> get pushTokensToRollOut =>
      pushTokens.where((element) => !element.isRolledOut && element.rolloutState == PushTokenRollOutState.rolloutNotStarted).toList();

  TokenState({required List<Token> tokens, List<Token>? lastlyUpdatedTokens})
      : tokens = List<Token>.from(tokens),
        lastlyUpdatedTokens = List<Token>.from(lastlyUpdatedTokens ?? tokens);

  List<Token> get nonPiTokens => tokens.where((token) => token.isPrivacyIdeaToken == false).toList();

  PushToken? getTokenBySerial(String serial) => pushTokens.firstWhereOrNull((element) => element.serial == serial);

  /// Maps the given tokens to the tokens that are already in the state
  /// It ignores the id that is usually used to identify the token
  /// Instead it uses the non-changeable values of the token to identify it
  /// Like the secret and hash algorithm for OTP tokens, or the serial and public server key for push tokens
  Map<Token, Token?> getSameTokens(List<Token> tokens) {
    final sameTokensMap = <Token, Token?>{};
    final stateTokens = this.tokens;

    for (var token in tokens) {
      sameTokensMap[token] = stateTokens.firstWhereOrNull((element) => element.isSameTokenAs(token));
    }
    return sameTokensMap;
  }

  T? currentOf<T extends Token>(T token) => tokens.firstWhereOrNull((element) => element.id == token.id) as T?;
  T? currentOfId<T extends Token>(String id) => tokens.firstWhereOrNull((element) => element.id == id) as T?;

  TokenState withToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    newTokens.add(token);
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: [token]);
  }

  TokenState withTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    newTokens.addAll(tokens);
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: tokens);
  }

  // Removes the token from the State
  // Sets the lastlyUpdatedTokens to an empty list because no token was updated only removed
  TokenState withoutToken(Token token) {
    final newTokens = List<Token>.from(tokens);
    newTokens.removeWhere((element) => element.id == token.id);
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: const []);
  }

  TokenState withoutTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    newTokens.removeWhere((element) => tokens.any((token) => token.id == element.id));
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: const []);
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
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: [token]);
  }

  // Replace the token if it does exist
  // Do nothing if it does not exist
  (TokenState, bool) replaceToken(Token token) {
    final newTokens = tokens.toList();
    final index = newTokens.indexWhere((element) => element.id == token.id);
    if (index == -1) {
      Logger.warning('Tried to replace a token that does not exist.', name: 'token_state.dart#replaceToken');
      return (this, false);
    }
    newTokens[index] = token;
    return (TokenState(tokens: newTokens, lastlyUpdatedTokens: [token]), true);
  }

  // replace all tokens where the id is the same
  // if the id is none, add it to the list
  TokenState addOrReplaceTokens<T extends Token>(List<T> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    final updatedTokens = <Token>[];
    for (var token in tokens) {
      final index = newTokens.indexWhere((element) => element.id == token.id);
      if (index == -1) {
        newTokens.add(token);
        updatedTokens.add(token);
        continue;
      }
      newTokens[index] = token;
      updatedTokens.add(token);
    }
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: updatedTokens);
  }

  // Replace the tokens if it does exist
  // Do nothing if it does not exist
  (TokenState, List<T>) replaceTokens<T extends Token>(List<T> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    final updatedTokens = <T>[];
    final failedToReplace = <T>[];
    for (var token in tokens) {
      final index = newTokens.indexWhere((element) => element.id == token.id);
      if (index == -1) {
        Logger.warning('Tried to replace a token that does not exist.', name: 'token_state.dart#replaceToken');
        failedToReplace.add(token);
        continue;
      }
      newTokens[index] = token;
    }
    return (TokenState(tokens: newTokens, lastlyUpdatedTokens: updatedTokens), failedToReplace);
  }

  List<Token> tokensInFolder(TokenFolder folder, {List<Type> only = const [], List<Type> exclude = const []}) =>
      tokens.inFolder(folder, only: only, exclude: exclude);

  List<Token> tokensWithoutFolder({List<Type> only = const [], List<Type> exclude = const []}) => tokens.withoutFolder(only: only, exclude: exclude);
}

extension TokenListExtension on List<Token> {
  List<Token> inFolder(TokenFolder folder, {List<Type> only = const [], List<Type> exclude = const []}) => where((token) {
        if (token.folderId != folder.folderId) return false;
        if (exclude.contains(token.runtimeType)) return false;
        if (only.isNotEmpty && !only.contains(token.runtimeType)) return false;
        return true;
      }).toList();

  List<Token> withoutFolder({List<Type> only = const [], List<Type> exclude = const []}) => where((token) {
        if (token.folderId != null) return false;
        if (exclude.contains(token.runtimeType)) return false;
        if (only.isNotEmpty && !only.contains(token.runtimeType)) return false;
        return true;
      }).toList();
}
