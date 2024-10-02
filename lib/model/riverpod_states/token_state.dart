/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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

import '../../utils/logger.dart';
import '../enums/push_token_rollout_state.dart';
import '../enums/token_origin_source_type.dart';
import '../token_template.dart';
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
  bool get hasPushTokens => pushTokens.isNotEmpty;
  bool get hasRolledOutPushTokens => pushTokens.any((element) => element.isRolledOut);

  List<PushToken> get pushTokensToRollOut =>
      pushTokens.where((element) => !element.isRolledOut && element.rolloutState == PushTokenRollOutState.rolloutNotStarted).toList();

  List<Token> get maybePiTokens => tokens.maybePiTokens;

  const TokenState({
    required this.tokens,
    List<Token>? lastlyUpdatedTokens,
    List<Token>? lastlyDeletedTokens,
  })  : lastlyUpdatedTokens = lastlyUpdatedTokens ?? tokens,
        lastlyDeletedTokens = lastlyDeletedTokens ?? const [];

  List<Token> get tokensNotInContainer {
    final tokensNotInContainer = tokens.maybePiTokens.where((token) => token.containerSerial != null).toList();
    Logger.debug('${tokensNotInContainer.length}/${tokens.length} tokens not in container');
    return tokensNotInContainer;
  }

  PushToken? getTokenBySerial(String serial) => pushTokens.firstWhereOrNull((element) => element.serial == serial);

  /// Maps the given tokens to the tokens that are already in the state.
  /// It ignores the id that is usually used to identify the token.
  /// Instead it uses the non-changeable values of the token to identify it.
  /// Like the secret, hash algorithm, serial and public server key for push tokens.
  Map<Token, Token?> getSameTokens(List<Token> tokens) {
    final sameTokensMap = <Token, Token?>{};
    final stateTokens = this.tokens;

    for (var token in tokens) {
      sameTokensMap[token] = stateTokens.firstWhereOrNull((element) => element.isSameTokenAs(token));
    }
    return sameTokensMap;
  }

  T? currentOf<T extends Token>(T token) => tokens.firstWhereOrNull((element) => element.isSameTokenAs(token)) as T?;
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

  List<Token> tokensInFolder(TokenFolder folder, {List<Type> only = const [], List<Type> exclude = const []}) =>
      tokens.inFolder(folder, only: only, exclude: exclude);

  List<Token> tokensWithoutFolder({List<Type> only = const [], List<Type> exclude = const []}) => tokens.withoutFolder(only: only, exclude: exclude);

  List<Token> containerTokens(String containerSerial) {
    final piTokens = tokens.piTokens;
    Logger.debug('PiTokens: ${piTokens}');
    final containerTokens = piTokens.ofContainer(containerSerial);
    Logger.debug('${containerTokens.length}/${piTokens.length} tokens with containerSerial: $containerSerial');
    return containerTokens;
  }
}

extension TokenListExtension on List<Token> {
  List<Token> get piTokens {
    final piTokens = where((token) => token.isPrivacyIdeaToken == true).toList();
    Logger.debug('${piTokens.length}/$length tokens with "isPrivacyIdeaToken == true"');
    return piTokens;
  }

  List<Token> get nonPiTokens {
    final nonPiTokens = where((token) => token.isPrivacyIdeaToken == false).toList();
    Logger.debug('${nonPiTokens.length}/$length tokens with "isPrivacyIdeaToken == false"');
    return nonPiTokens;
  }

  List<Token> get maybePiTokens {
    final maybePiTokens = where((token) => token.isPrivacyIdeaToken == null).toList();
    Logger.debug('${maybePiTokens.length}/$length tokens with "isPrivacyIdeaToken == null"');
    return maybePiTokens;
  }

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

  List<Token> ofContainer(String containerSerial) {
    final filtered = where((token) => token.origin?.source == TokenOriginSourceType.container && token.containerSerial == containerSerial).toList();
    Logger.debug('${filtered.length}/$length tokens with containerSerial: $containerSerial');
    return filtered;
  }

  List<TokenTemplate> toTemplates() {
    if (isEmpty) return [];
    final templates = <TokenTemplate>[];
    for (var token in this) {
      final template = token.toTemplate();
      if (template != null) templates.add(template);
    }
    return templates;
  }
}
