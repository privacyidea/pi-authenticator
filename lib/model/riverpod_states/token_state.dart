/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../../../../model/extensions/token_folder_extension.dart';
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
  final List<Token> lastlyDeletedTokens;

  List<OTPToken> get otpTokens => tokens.whereType<OTPToken>().toList();
  bool get hasOTPTokens => otpTokens.isNotEmpty;

  List<PushToken> get pushTokens => tokens.whereType<PushToken>().toList();

  List<PushToken> get pollOnlyPushTokens => pushTokens.where((element) => element.isPollOnly == true).toList();
  List<PushToken> get pushTokensNotPollOnly => pushTokens.where((element) => element.isPollOnly != true).toList();

  bool get hasPushTokens => pushTokens.isNotEmpty;
  bool get hasRolledOutPushTokens => pushTokens.any((element) => element.isRolledOut);

  bool get needsFirebase => pushTokens.any((element) => element.isPollOnly != true);

  List<PushToken> get pushTokensToRollOut =>
      pushTokens.where((element) => !element.isRolledOut && element.rolloutState == PushTokenRollOutState.rolloutNotStarted).toList();

  const TokenState({
    required this.tokens,
    List<Token>? lastlyUpdatedTokens,
    List<Token>? lastlyDeletedTokens,
  })  : lastlyUpdatedTokens = lastlyUpdatedTokens ?? tokens,
        lastlyDeletedTokens = lastlyDeletedTokens ?? const [];

  PushToken? getTokenBySerial(String serial) => pushTokens.firstWhereOrNull((element) => element.serial == serial);

  /// Maps the given tokens to the tokens that are already in the state.
  /// It ignores the id that is usually used to identify the token.
  /// Instead it uses the non-changeable values of the token to identify it.
  /// Like the secret, hash algorithm, serial and public server key for push tokens.
  Map<Token, Token?> getSameTokens(List<Token> tokens) {
    final sameTokensMap = <Token, Token?>{};
    final stateTokens = this.tokens;

    for (var token in tokens) {
      sameTokensMap[token] = stateTokens.firstWhereOrNull((element) => element.isSameTokenAs(token) == true);
    }
    return sameTokensMap;
  }

  T? currentOf<T extends Token>(T token) => tokens.firstWhereOrNull((element) => element.isSameTokenAs(token) == true) as T?;
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
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: const [], lastlyDeletedTokens: [token]);
  }

  TokenState withoutTokens(List<Token> tokens) {
    final newTokens = List<Token>.from(this.tokens);
    newTokens.removeWhere((element) => tokens.any((token) {
          Logger.debug('token.id ${token.id} == element.id ${element.id}');
          return token.id == element.id;
        }));
    return TokenState(tokens: newTokens, lastlyUpdatedTokens: const [], lastlyDeletedTokens: tokens);
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
  // Return the new state and a boolean = true if the token was replaced
  // Return the old state and a boolean = false if the token was not replaced
  (TokenState, bool) replaceToken(Token token) {
    final newTokens = tokens.toList();
    final index = newTokens.indexWhere((element) => element.id == token.id);
    if (index == -1) {
      Logger.warning('Tried to replace a token that does not exist.');
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
        Logger.warning('Tried to replace a token that does not exist.');
        failedToReplace.add(token);
        continue;
      }
      newTokens[index] = token;
    }
    return (TokenState(tokens: newTokens, lastlyUpdatedTokens: updatedTokens), failedToReplace);
  }

  List<Token> tokensInFolder([TokenFolder? folder]) => tokens.inFolder(folder);

  List<Token> tokensInNoFolder() => tokens.inNoFolder();

  List<Token> containerTokens(String containerSerial) {
    final piTokens = tokens.piTokens;
    Logger.debug('PiTokens: $piTokens');
    final containerTokens = piTokens.ofContainer(containerSerial);
    Logger.debug('${containerTokens.length}/${piTokens.length} tokens with containerSerial: $containerSerial');
    return containerTokens;
  }
}
