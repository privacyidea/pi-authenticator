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
        lastlyUpdatedTokens = List<Token>.from(lastlyUpdatedTokens ?? tokens) {
    _sort(this.tokens);
  }

  PushToken? getTokenBySerial(String serial) => pushTokens.firstWhereOrNull((element) => element.serial == serial);

  Map<Token, Token?> getTokensWithSameSectet(List<Token> tokens) {
    final tokensWithSameSectet = <Token, Token?>{};
    final stateTokens = this.tokens;
    List<OTPToken> otpTokens = tokens.whereType<OTPToken>().toList();
    Map<String, OTPToken> stateOtpTokens = {for (var e in stateTokens.whereType<OTPToken>()) (e).secret: e};
    List<PushToken> pushTokens = tokens.whereType<PushToken>().toList();
    Map<(String?, String?, String?), PushToken> statePushTokens = {
      for (var e in stateTokens.whereType<PushToken>()) (e.publicServerKey, e.privateTokenKey, e.publicTokenKey): e
    };

    for (var pushToken in pushTokens) {
      tokensWithSameSectet[pushToken] = statePushTokens[(pushToken.publicServerKey, pushToken.privateTokenKey, pushToken.publicTokenKey)];
    }
    for (var otpToken in otpTokens) {
      tokensWithSameSectet[otpToken] = stateOtpTokens[otpToken.secret];
    }

    return tokensWithSameSectet;
  }

  static void _sort(List<Token> tokens) {
    tokens.sort((a, b) => (a.sortIndex ?? double.infinity).compareTo(b.sortIndex ?? double.infinity));
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
}
