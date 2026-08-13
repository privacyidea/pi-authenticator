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
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/utils/helpers/mutex.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/localization_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../model/extensions/enums/push_token_rollout_state_extension.dart';
import '../../../../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../../interfaces/repo/token_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/biometric_push_key_status.dart';
import '../../../../model/enums/force_biometric_option.dart';
import '../../../../model/enums/push_app_biometric_level.dart';
import '../../../../model/enums/push_token_rollout_state.dart';
import '../../../../model/enums/token_import_type.dart';
import '../../../../model/enums/token_origin_source_type.dart';
import '../../../../model/processor_result.dart';
import '../../../../model/push_request/push_capabilities.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../../../model/tokens/hotp_token.dart';
import '../../../../model/tokens/otp_token.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../model/tokens/token.dart';
import '../../../../processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import '../../../../repo/secure_token_repository.dart';
import '../../../../views/import_tokens_view/pages/import_plain_tokens_page.dart';
import '../../../firebase_utils.dart';
import '../../../helpers/json_canonicalizer.dart';
import '../../../globals.dart';
import '../../../http_status_checker.dart';
import '../../../lock_auth.dart';
import '../../../logger.dart';
import '../../../privacyidea_io_client.dart';
import '../../../rsa_utils.dart';
import '../../../biometric_push_key_manager.dart';
import '../../../utils.dart';
import '../state_providers/status_message_provider.dart';
import 'settings_notifier.dart';

part 'token_notifier.g.dart';

final tokenProvider = tokenProviderOf(
  firebaseUtils: FirebaseUtils(),
  ioClient: const PrivacyideaIOClient(),
  rsaUtils: const RsaUtils(),
  repo: SecureTokenRepository(),
);

@Riverpod(keepAlive: true)
class TokenNotifier extends _$TokenNotifier with ResultHandler {
  static final Map<String, Timer> _hidingTimers = {};

  /// Lock the repo before any update (e.g. [repo.saveOrReplaceTokens]) and release it after the change is done (await or .then).
  final _repoMutex = Mutex();

  /// Lock the state before accessing it and release it after the change is done.
  final _stateMutex = Mutex();

  TokenNotifier({
    this._repoOverride,
    this._rsaUtilsOverride,
    this._ioClientOverride,
    this._firebaseUtilsOverride,
  });

  @override
  TokenRepository get repo => _repoOverride ?? super.repo;
  final TokenRepository? _repoOverride;

  @override
  RsaUtils get rsaUtils => _rsaUtilsOverride ?? super.rsaUtils;
  final RsaUtils? _rsaUtilsOverride;

  @override
  PrivacyideaIOClient get ioClient => _ioClientOverride ?? super.ioClient;
  final PrivacyideaIOClient? _ioClientOverride;

  @override
  FirebaseUtils get firebaseUtils =>
      _firebaseUtilsOverride ?? super.firebaseUtils;
  final FirebaseUtils? _firebaseUtilsOverride;

  @override
  Future<TokenState> build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) async {
    return _stateMutex.protect(() => _loadStateFromRepo());
  }
  //   /*
  //   /////////////////////////////////////////////////////////////////////////////
  //   /////////////////////// Repository and Token Handling ///////////////////////
  //   /////////////////////////////////////////////////////////////////////////////
  //   /// Repository layer is always use _repoMutex for the latest state
  //   */

  /// Loads the tokens from the repository and returns them as a [TokenState].
  Future<TokenState> _loadStateFromRepo() async {
    final loadedTokens = await _repoMutex.protect(() => repo.loadTokens());
    final tokens = await _reconcileBiometricPushKeys(loadedTokens);
    return TokenState(tokens: tokens, lastlyUpdatedTokens: tokens);
  }

  Token? _currentTokenForWrite(TokenState currentState, Token incoming) =>
      currentState.currentOfId(incoming.id) ?? currentState.currentOf(incoming);

  Token _prepareTokenForWrite(Token incoming, Token? current) {
    if (incoming is PushToken && current is PushToken) {
      return incoming.withMonotonicBiometricStateFrom(current);
    }
    if (incoming is PushToken) {
      return incoming.withFailClosedBiometricLifecycle();
    }
    return incoming;
  }

  Future<void> _deleteNewlyInvalidatedNativeKey(
    Token? previous,
    Token written,
  ) async {
    if (written is! PushToken || !written.isBiometricKeyInvalidated) return;
    if (previous is PushToken && previous.isBiometricKeyInvalidated) return;
    try {
      await rsaUtils.deleteBiometricPushKey(written.id);
    } catch (error, stackTrace) {
      Logger.warning(
        'Could not remove a newly invalidated native Push key.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _deleteNativePushKey(Token token) async {
    if (token is! PushToken) return;
    try {
      await rsaUtils.deleteBiometricPushKey(token.id);
    } catch (error, stackTrace) {
      Logger.warning(
        'Could not remove native biometric Push key state.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool _hasSameContainerIdentityIgnoringId(Token first, Token second) {
    if (first.runtimeType != second.runtimeType) return false;
    final comparison = second.copyWith(
      id: '__container_identity__${second.id}',
    );
    return first.isSameTokenAs(comparison) == true;
  }

  bool _tightensPushAuthentication(Token? previous, Token candidate) {
    if (previous is! PushToken || candidate is! PushToken) return false;
    if (candidate.forceBiometricOption != ForceBiometricOption.biometric) {
      return false;
    }
    return previous.forceBiometricOption != ForceBiometricOption.biometric ||
        (previous.biometricLevel != PushAppBiometricLevel.strong &&
            candidate.biometricLevel == PushAppBiometricLevel.strong) ||
        (!previous.invalidateOnBiometricChange &&
            candidate.invalidateOnBiometricChange) ||
        (!previous.requiresBiometricKeyProtection &&
            candidate.requiresBiometricKeyProtection);
  }

  /// Adds a token and returns true if successful, false if not.
  /// Updates repo and state.
  Future<bool> _addOrReplaceToken(Token token) {
    return _stateMutex.protect(() async {
      final currentState = await future;
      final current = _currentTokenForWrite(currentState, token);
      if (current != null && current.id != token.id) {
        token = token.copyWith(id: current.id);
      }
      token = _prepareTokenForWrite(token, current);
      final success = await _repoMutex.protect(
        () => repo.saveOrReplaceToken(token),
      );
      if (!success) {
        Logger.warning('Saving token failed. Token: ${token.id}');
        return false;
      }
      state = AsyncValue.data(currentState.addOrReplaceToken(token));
      await _deleteNewlyInvalidatedNativeKey(current, token);
      return true;
    });
  }

  /// Adds a list of tokens and returns the tokens that could not be added or replaced.
  /// Updates repo and state.
  Future<List<Token>> _addOrReplaceTokens(List<Token> tokens) {
    return _stateMutex.protect(() async {
      final currentState = await future;
      final workingTokens = List<Token>.from(currentState.tokens);
      final previousById = <String, Token>{};
      for (var incoming in tokens) {
        final workingState = TokenState(tokens: workingTokens);
        final current = _currentTokenForWrite(workingState, incoming);
        if (current != null && current.id != incoming.id) {
          incoming = incoming.copyWith(id: current.id);
        }
        final prepared = _prepareTokenForWrite(incoming, current);
        if (current != null) {
          previousById.putIfAbsent(prepared.id, () => current);
        }
        final index = workingTokens.indexWhere((t) => t.id == prepared.id);
        if (index == -1) {
          workingTokens.add(prepared);
        } else {
          workingTokens[index] = prepared;
        }
      }
      tokens = workingTokens;
      if (tokens.isEmpty) {
        return [];
      }
      Logger.debug('Adding ${tokens.length} tokens.', verbose: true);
      final failedTokens = await _repoMutex.protect(
        () => repo.saveOrReplaceTokens(tokens),
      );
      if (failedTokens.isNotEmpty) {
        Logger.warning(
          'Saving tokens failed. Failed Tokens: ${failedTokens.length}',
        );
      }
      // Every token that is saved should not be in the failedTokens list
      final savedTokens = tokens
          .where((element) => !failedTokens.contains(element))
          .toList();
      // Add the saved tokens to the state
      Logger.info('Saved ${savedTokens.length} Tokens to storage.');
      state = AsyncValue.data(currentState.addOrReplaceTokens(savedTokens));
      for (final savedToken in savedTokens) {
        await _deleteNewlyInvalidatedNativeKey(
          previousById[savedToken.id],
          savedToken,
        );
      }
      Logger.debug('New State: ${(await future).tokens.length} Tokens');
      return failedTokens;
    });
  }

  /// Applies container responses to the latest local tokens without reviving
  /// records deleted while the network request was in flight. Existing tokens
  /// are rebased from server-authoritative template fields; local lifecycle,
  /// key material, UI placement, and Push state remain owned by the latest
  /// local record. Only [newTokens] may create a record.
  Future<List<Token>> applyContainerSync({
    required List<Token> updatedTokens,
    required List<Token> newTokens,
    List<Token> deletedTokens = const [],
    required Map<String, List<String>> checkedContainersByTokenId,
  }) async {
    var removedLastPushToken = false;
    final failed = await _stateMutex.protect(() async {
      final currentState = await future;
      final candidatesById = <String, Token>{};
      final previousById = <String, Token>{};
      final failedBeforeSaveById = <String, Token>{};
      final incomingIdAliases = <String, String>{};

      void mergeExisting(Token incoming, Token current) {
        final targetId = current.id;
        incomingIdAliases[incoming.id] = targetId;
        if (current.runtimeType != incoming.runtimeType) {
          Logger.warning(
            'Rejecting incompatible container token update ${incoming.id}.',
          );
          failedBeforeSaveById[targetId] = incoming;
          return;
        }
        final template = incoming.toTemplate();
        if (template == null) {
          Logger.warning(
            'Rejecting container token update without a stable template ${incoming.id}.',
          );
          failedBeforeSaveById[targetId] = incoming;
          return;
        }
        try {
          var merged = current.copyUpdateByTemplate(
            template.copyWith(additionalData: current.additionalData),
          );
          merged = merged.copyWith(
            id: targetId,
            containerSerial: () => incoming.containerSerial,
            origin: incoming.origin,
          );
          if (current is PushToken &&
              incoming is PushToken &&
              merged is PushToken) {
            merged = merged.copyWith(
              forceBiometricOption:
                  current.forceBiometricOption == ForceBiometricOption.biometric
                  ? current.forceBiometricOption
                  : incoming.forceBiometricOption ==
                        ForceBiometricOption.biometric
                  ? incoming.forceBiometricOption
                  : merged.forceBiometricOption,
              biometricLevel:
                  current.biometricLevel == PushAppBiometricLevel.strong
                  ? current.biometricLevel
                  : incoming.biometricLevel == PushAppBiometricLevel.strong
                  ? incoming.biometricLevel
                  : merged.biometricLevel,
              invalidateOnBiometricChange:
                  current.invalidateOnBiometricChange ||
                  incoming.invalidateOnBiometricChange ||
                  merged.invalidateOnBiometricChange,
            );
          }
          merged = _prepareTokenForWrite(merged, current);
          final original = currentState.currentOfId(targetId);
          if (original != null) {
            previousById.putIfAbsent(targetId, () => original);
          }
          candidatesById[targetId] = merged;
        } catch (error, stackTrace) {
          Logger.warning(
            'Rejecting invalid container token update ${incoming.id}.',
            error: error,
            stackTrace: stackTrace,
          );
          failedBeforeSaveById[targetId] = incoming;
        }
      }

      for (final incoming in updatedTokens) {
        // An update response may predate a local delete and re-enrollment.
        // Never target a different UUID merely because its serial matches.
        final current =
            candidatesById[incoming.id] ??
            currentState.currentOfId(incoming.id);
        if (current == null) {
          Logger.warning(
            'Skipping stale container token update ${incoming.id}.',
          );
          continue;
        }
        mergeExisting(incoming, current);
      }

      for (final incoming in newTokens) {
        final idCollision =
            candidatesById[incoming.id] ??
            currentState.currentOfId(incoming.id);
        if (idCollision != null &&
            !_hasSameContainerIdentityIgnoringId(idCollision, incoming)) {
          Logger.warning(
            'Rejecting new container token with colliding id ${incoming.id}.',
          );
          failedBeforeSaveById[incoming.id] = incoming;
          continue;
        }
        final current =
            idCollision ??
            candidatesById.values.firstWhereOrNull(
              (token) => token.isSameTokenAs(incoming) == true,
            ) ??
            currentState.tokens.firstWhereOrNull(
              (token) => token.isSameTokenAs(incoming) == true,
            );
        if (current != null) {
          Logger.warning(
            'Treating colliding new container token ${incoming.id} as an update.',
          );
          mergeExisting(incoming, current);
          continue;
        }
        final prepared = _prepareTokenForWrite(incoming, null);
        incomingIdAliases[incoming.id] = prepared.id;
        candidatesById[prepared.id] = prepared;
      }

      for (final entry in checkedContainersByTokenId.entries) {
        final targetId = incomingIdAliases[entry.key] ?? entry.key;
        final current = currentState.currentOfId(targetId);
        final candidate = candidatesById[targetId] ?? current;
        if (candidate == null) continue;
        if (current != null) {
          previousById.putIfAbsent(current.id, () => current);
        }
        candidatesById[targetId] = candidate.copyWith(
          checkedContainer: {
            ...candidate.checkedContainer,
            ...entry.value,
          }.toList(),
        );
      }

      final candidates = candidatesById.values
          .where((token) => !failedBeforeSaveById.containsKey(token.id))
          .toList();
      final failedTokens = candidates.isEmpty
          ? <Token>[]
          : await _repoMutex.protect(
              () => repo.saveOrReplaceTokens(candidates),
            );
      final failedIds = failedTokens.map((token) => token.id).toSet();
      final failedCandidates = candidates
          .where((token) => failedIds.contains(token.id))
          .toList();
      final savedById = {
        for (final token in candidates)
          if (!failedIds.contains(token.id)) token.id: token,
      };

      // If persistence of a stricter Push policy fails, do not leave the old,
      // weaker token usable in this process. Persist a terminal state in a
      // second, narrow write when possible; if even that fails, remove the old
      // record from storage. A final in-memory invalidation is the last-resort
      // fail-closed state for a completely unavailable secure store.
      final removedAfterFailedTighteningIds = <String>{};
      final inMemoryTerminalById = <String, PushToken>{};
      final terminalCleanupById = <String, PushToken>{};
      for (final candidate in failedCandidates.whereType<PushToken>()) {
        final previous = previousById[candidate.id];
        final becameInvalidated =
            previous is PushToken &&
            !previous.isBiometricKeyInvalidated &&
            candidate.isBiometricKeyInvalidated;
        if (!_tightensPushAuthentication(previous, candidate) &&
            !becameInvalidated) {
          continue;
        }
        final terminal = candidate.copyWith(
          privateTokenKey: () => null,
          biometricKeyStatus: BiometricPushKeyStatus.invalidated,
        );
        terminalCleanupById[terminal.id] = terminal;
        final terminalSaved = await _repoMutex.protect(
          () => repo.saveOrReplaceToken(terminal),
        );
        if (terminalSaved) {
          savedById[terminal.id] = terminal;
        } else if (previous != null &&
            await _repoMutex.protect(() => repo.deleteToken(previous))) {
          removedAfterFailedTighteningIds.add(previous.id);
        } else if (previous != null) {
          inMemoryTerminalById[terminal.id] = terminal;
        }
      }

      var nextState = currentState.addOrReplaceTokens(
        savedById.values.toList(),
      );
      if (removedAfterFailedTighteningIds.isNotEmpty) {
        nextState = nextState.withoutTokens(
          currentState.tokens
              .where(
                (token) => removedAfterFailedTighteningIds.contains(token.id),
              )
              .toList(),
        );
      }
      if (inMemoryTerminalById.isNotEmpty) {
        nextState = nextState.addOrReplaceTokens(
          inMemoryTerminalById.values.toList(),
        );
      }

      final updateFailures = <Token>[
        ...failedBeforeSaveById.values,
        ...failedCandidates,
      ];
      final deleteCandidatesById = <String, Token>{};
      if (updateFailures.isEmpty) {
        for (final incoming in deletedTokens) {
          final currentById = currentState.currentOfId(incoming.id);
          if (currentById != null &&
              !_hasSameContainerIdentityIgnoringId(currentById, incoming)) {
            Logger.warning(
              'Skipping stale container token deletion ${incoming.id}.',
            );
            continue;
          }
          final current = currentById;
          if (current == null || candidatesById.containsKey(current.id)) {
            continue;
          }
          deleteCandidatesById[current.id] = current;
        }
      }
      final deleteCandidates = deleteCandidatesById.values.toList();
      final failedDeletions = deleteCandidates.isEmpty
          ? <Token>[]
          : await _repoMutex.protect(() => repo.deleteTokens(deleteCandidates));
      final failedDeletionIds = failedDeletions
          .map((token) => token.id)
          .toSet();
      final deleted = deleteCandidates
          .where((token) => !failedDeletionIds.contains(token.id))
          .toList();
      if (deleted.isNotEmpty) {
        nextState = nextState.withoutTokens(deleted);
      }
      removedLastPushToken =
          deleted.any((token) => token is PushToken) &&
          nextState.pushTokens.isEmpty;

      state = AsyncValue.data(nextState);
      for (final token in deleted) {
        await _deleteNativePushKey(token);
      }
      for (final token in savedById.values) {
        await _deleteNewlyInvalidatedNativeKey(previousById[token.id], token);
      }
      for (final entry in terminalCleanupById.entries) {
        if (!savedById.containsKey(entry.key)) {
          await _deleteNativePushKey(entry.value);
        }
      }
      return <Token>[...updateFailures, ...failedDeletions];
    });
    // Firebase registration is shared by all Push tokens. Keep it while any
    // Push token remains; remove it best-effort only after the last one is gone.
    if (removedLastPushToken) {
      try {
        await firebaseUtils.deleteFirebaseToken();
      } catch (error, stackTrace) {
        Logger.warning(
          'Could not remove the unused Firebase token after container sync.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    await _handlePushTokensIfExist();
    return failed;
  }

  /// Removes a token and returns true if successful, false if not.
  Future<bool> _removeToken(Token token) async {
    final success = await _stateMutex.protect(() async {
      final currentState = await future;
      final current = currentState.currentOfId(token.id);
      if (current == null) return false;
      final deleted = await _repoMutex.protect(() => repo.deleteToken(current));
      if (!deleted) {
        Logger.warning('Deleting token failed. Token: ${token.id}');
        return false;
      }
      await _deleteNativePushKey(current);
      state = AsyncValue.data(currentState.withoutToken(current));
      return true;
    });
    if (!success) return false;
    await _handlePushTokensIfExist();
    return true;
  }

  /// Removes a list of tokens and returns the tokens that could not be removed.
  Future<List<Token>> _removeTokens(List<Token> tokens) async {
    if (tokens.isEmpty) return [];
    Logger.info('Removing ${tokens.length} tokens.');
    final failedTokens = await _stateMutex.protect(() async {
      final currentState = await future;
      final currentTokens = tokens
          .map((token) => currentState.currentOfId(token.id))
          .nonNulls
          .toList();
      final failedTokens = await _repoMutex.protect(
        () => repo.deleteTokens(currentTokens),
      );
      if (failedTokens.isNotEmpty) {
        Logger.warning(
          'Deleting tokens failed. Failed Tokens: ${failedTokens.length}',
        );
      }
      final failedIds = failedTokens.map((token) => token.id).toSet();
      final deletedTokens = currentTokens
          .where((element) => !failedIds.contains(element.id))
          .toList();
      for (final token in deletedTokens) {
        await _deleteNativePushKey(token);
      }
      state = AsyncValue.data(currentState.withoutTokens(deletedTokens));
      return failedTokens;
    });
    await _handlePushTokensIfExist();
    return failedTokens;
  }

  /// Loads the tokens from the repository sets it as the new state and returns the new(await future).
  Future<TokenState> _updateStateFromRepo() async {
    TokenState? newState;
    newState = await _stateMutex.protect(() async {
      try {
        final loadedTokens = await _repoMutex.protect(() => repo.loadTokens());
        final tokens = await _reconcileBiometricPushKeys(loadedTokens);
        final loadedState = TokenState(
          tokens: tokens,
          lastlyUpdatedTokens: tokens,
        );
        state = AsyncValue.data(loadedState);
        return loadedState;
      } catch (e) {
        Logger.error('Loading tokens from storage failed.', error: e);
        return null;
      }
    });
    if (newState == null) return (await future);
    await _handlePushTokensIfExist();
    return newState;
  }

  Future<List<Token>> _reconcileBiometricPushKeys(List<Token> tokens) async {
    if (!rsaUtils.supportsBiometricPushKeyProtection) return tokens;
    final reconciled = <Token>[];
    for (final token in tokens) {
      if (token is! PushToken || !token.requiresBiometricKeyProtection) {
        reconciled.add(token);
        continue;
      }
      try {
        // Local invalidation is terminal. In particular, a native key that was
        // created before the server tightened enrollment binding must never
        // revive the token merely because the platform still reports it as
        // protected. Remove any remaining native material defensively.
        if (token.isBiometricKeyInvalidated) {
          final terminalToken = token.copyWith(
            privateTokenKey: () => null,
            biometricKeyStatus: BiometricPushKeyStatus.invalidated,
          );
          var reconciledToken = token;
          if (!terminalToken.sameValuesAs(token)) {
            final saved = await _repoMutex.protect(
              () => repo.saveOrReplaceToken(terminalToken),
            );
            if (saved) {
              reconciledToken = terminalToken;
            } else {
              Logger.warning(
                'Could not persist terminal biometric Push key state.',
              );
            }
          }
          try {
            await rsaUtils.deleteBiometricPushKey(token.id);
          } catch (error, stackTrace) {
            Logger.warning(
              'Could not remove a terminally invalidated native Push key.',
              error: error,
              stackTrace: stackTrace,
            );
          }
          reconciled.add(reconciledToken);
          continue;
        }
        final nativeStatus = await rsaUtils.biometricPushKeyStatus(token.id);
        final PushToken updated;
        if (nativeStatus == RsaUtils.biometricKeyStatusInvalidated ||
            (token.biometricKeyStatus == BiometricPushKeyStatus.protected &&
                nativeStatus == RsaUtils.biometricKeyStatusUnprotected)) {
          updated = token.copyWith(
            privateTokenKey: () => null,
            biometricKeyStatus: BiometricPushKeyStatus.invalidated,
          );
        } else if (token.isRolledOut &&
            token.biometricKeyStatus == BiometricPushKeyStatus.unprotected &&
            nativeStatus == RsaUtils.biometricKeyStatusUnprotected) {
          // A deployed legacy token has no trustworthy enrollment baseline.
          // Binding it on first use would silently trust biometrics added after
          // the original token enrollment, so require a fresh enrollment.
          updated = token.copyWith(
            privateTokenKey: () => null,
            biometricKeyStatus: BiometricPushKeyStatus.invalidated,
          );
        } else if (nativeStatus == RsaUtils.biometricKeyStatusProtected) {
          updated = token.copyWith(
            privateTokenKey: () => null,
            biometricKeyStatus: BiometricPushKeyStatus.protected,
          );
        } else {
          updated = token;
        }
        if (!identical(updated, token) && !updated.sameValuesAs(token)) {
          final saved = await _repoMutex.protect(
            () => repo.saveOrReplaceToken(updated),
          );
          if (!saved) {
            Logger.warning(
              'Could not persist reconciled biometric Push key state.',
            );
            reconciled.add(token);
            continue;
          }
          await _deleteNewlyInvalidatedNativeKey(token, updated);
        }
        reconciled.add(updated);
      } catch (error, stackTrace) {
        Logger.warning(
          'Could not reconcile native biometric Push key state.',
          error: error,
          stackTrace: stackTrace,
        );
        reconciled.add(token);
      }
    }
    return reconciled;
  }

  Future<bool> _saveStateToRepo() => _stateMutex.protect(() async {
    final tokens = (await future).tokens;
    try {
      final failed = await _repoMutex.protect(
        () => repo.saveOrReplaceTokens(tokens),
      );
      return failed.isEmpty;
    } catch (e) {
      Logger.error('Saving tokens to storage failed.', error: e);
      return false;
    }
  });

  /*
  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Update Token Methods //////////////////////////////-
  //////////////////////////////////////////////////////////////////////////////
  /// Updating layer: Do not use any mutexes and do not update the state directly.
  /// To update the state use the methods from the repository layer.
  */

  /// Updates a token and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<T?> _updateToken<T extends Token>(
    T token,
    T Function(T) updater,
  ) async {
    return _stateMutex.protect(() async {
      final currentState = await future;
      final current = currentState.currentOfId<T>(token.id);
      if (current == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return null;
      }
      var updated = updater(current);
      updated = _prepareTokenForWrite(updated, current) as T;
      final saved = await _repoMutex.protect(
        () => repo.saveOrReplaceToken(updated),
      );
      if (!saved) {
        Logger.warning('Saving token failed. Token: ${updated.id}');
        return current;
      }
      state = AsyncValue.data(currentState.addOrReplaceToken(updated));
      await _deleteNewlyInvalidatedNativeKey(current, updated);
      return updated;
    });
  }

  /// Updates a list of tokens and returns the updated tokens if successful.
  /// Returns the old tokens if not and an empty list if the tokens does not exist.
  Future<List<T>> _updateTokens<T extends Token>(
    List<T> tokens,
    T Function(T) updater,
  ) async {
    if (tokens.isEmpty) return [];
    return _stateMutex.protect(() async {
      final currentState = await future;
      final previousById = <String, T>{};
      final updatedTokens = <T>[];
      for (final token in tokens) {
        final current = currentState.currentOfId<T>(token.id);
        if (current == null) continue;
        previousById[token.id] = current;
        updatedTokens.add(
          _prepareTokenForWrite(updater(current), current) as T,
        );
      }
      final failedToSave = await _repoMutex.protect(
        () => repo.saveOrReplaceTokens<T>(updatedTokens),
      );
      final savedTokens = updatedTokens
          .where((element) => !failedToSave.contains(element))
          .toList();
      state = AsyncValue.data(currentState.addOrReplaceTokens(savedTokens));
      for (final savedToken in savedTokens) {
        await _deleteNewlyInvalidatedNativeKey(
          previousById[savedToken.id],
          savedToken,
        );
      }
      final newState = await future;
      return newState.tokens
          .whereType<T>()
          .where((stateToken) => tokens.any((t) => t.id == stateToken.id))
          .toList();
    });
  }

  /// Applies only sortable placement fields to records that still exist.
  /// Delayed drag/post-frame snapshots must not recreate a deleted token or
  /// overwrite newer Push rollout, policy, Firebase, or key state.
  Future<List<Token>> updateTokenPlacements(List<Token> placements) {
    return _stateMutex.protect(() async {
      final currentState = await future;
      final updates = <Token>[];
      for (final placement in placements) {
        final current = currentState.currentOfId(placement.id);
        if (current == null || current.runtimeType != placement.runtimeType) {
          continue;
        }
        updates.add(
          current.copyWith(
            sortIndex: placement.sortIndex,
            folderId: () => placement.folderId,
          ),
        );
      }
      if (updates.isEmpty) return <Token>[];
      final failed = await _repoMutex.protect(
        () => repo.saveOrReplaceTokens(updates),
      );
      final failedIds = failed.map((token) => token.id).toSet();
      final saved = updates
          .where((token) => !failedIds.contains(token.id))
          .toList();
      state = AsyncValue.data(currentState.addOrReplaceTokens(saved));
      return failed;
    });
  }

  /// Runs a security-sensitive Push operation against the latest local token
  /// while holding the same state lock used by deletion, policy updates, and
  /// biometric invalidation.
  ///
  /// Keeping the lock through signing and the authenticated HTTP request makes
  /// those operations linearizable: a deletion or terminal invalidation either
  /// completes before this callback starts (and the token is not returned), or
  /// waits until the already-started request has finished. [persist] lets a
  /// native key migration update storage without trying to acquire this lock a
  /// second time.
  Future<R?> withCurrentPushTokenLease<R>(
    String tokenId,
    Future<R?> Function(
      PushToken token,
      Future<PushToken?> Function(PushToken proposed) persist,
      PushToken Function() current,
    )
    operation,
  ) {
    return _stateMutex.protect(() async {
      var currentState = await future;
      var currentToken = currentState.currentOfId<PushToken>(tokenId);
      if (currentToken == null) {
        Logger.warning(
          'Refusing a Push operation for a token that no longer exists.',
        );
        return null;
      }

      Future<PushToken?> persist(PushToken proposed) async {
        if (proposed.id != currentToken!.id) {
          Logger.warning('Refusing to change token identity inside a lease.');
          return null;
        }
        final previous = currentToken!;
        final prepared = _prepareTokenForWrite(proposed, previous) as PushToken;
        final saved = await _repoMutex.protect(
          () => repo.saveOrReplaceToken(prepared),
        );
        if (!saved) {
          Logger.warning(
            'Could not persist Push token state inside an operation lease.',
          );
          return null;
        }
        currentState = currentState.addOrReplaceToken(prepared);
        currentToken = prepared;
        state = AsyncValue.data(currentState);
        await _deleteNewlyInvalidatedNativeKey(previous, prepared);
        return prepared;
      }

      return operation(currentToken!, persist, () => currentToken!);
    });
  }

  /*
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////// UI Interaction Methods //////////////////////////////
  /////// These methods are used to interact with the UI and the user. /////////
  //////////////////////////////////////////////////////////////////////////////
  /// There is no need to use mutexes because the updating functions are always using the latest version of the updating tokens.
  */

  /// Adds a new token and returns true if successful, false if not.
  Future<bool> addNewToken(Token token) async {
    final success = await _addOrReplaceToken(token);
    await _handlePushTokensIfExist();
    return success;
  }

  /// Adds new tokens and returns the tokens that could not be added.
  Future<List<Token>> addNewTokens(List<Token> tokens) async {
    final failedTokens = await _addOrReplaceTokens(tokens);
    await _handlePushTokensIfExist();
    return failedTokens;
  }

  /// Adds or replaces a token and returns true if successful, false if not.
  Future<bool> addOrReplaceToken(Token token) => _addOrReplaceToken(token);

  /// Adds or replaces a list of tokens and returns the tokens that could not be added or replaced.
  Future<List<Token>> addOrReplaceTokens(List<Token> tokens) =>
      _addOrReplaceTokens(tokens)..then((value) => _handlePushTokensIfExist());

  /// Updates a token and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<T?> updateToken<T extends Token>(T token, T Function(T) updater) =>
      _updateToken(token, updater);

  /// Updates a list of tokens and returns the updated tokens if successful, the old tokens if not and an empty list if the tokens does not exist.
  Future<List<T>> updateTokens<T extends Token>(
    List<T> tokens,
    T Function(T) updater,
  ) => _updateTokens(tokens, updater);

  /// Increments the counter of a HOTPToken and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<HOTPToken?> incrementCounter(HOTPToken token) =>
      _updateToken(token, (p0) => p0.copyWith(counter: token.counter + 1));

  /// Hides a token and returns the updated token ifTok successful, the old token if not and null if the token does not exist.
  Future<T?> hideToken<T extends Token>(T token) =>
      _updateToken(token, (p0) => p0.copyWith(isHidden: true) as T);

  /// Shows a token and returns the updated token if successful, the old token if not and null if the token does not exist or the user is not authenticated.
  Future<T?> showToken<T extends OTPToken>(T token) async {
    final authenticated = await lockAuthWithSettingsRef(
      ref: ref,
      localization: ref.read(localizationProvider),
      reason: (localization) => localization.authenticateToShowOtp,
      forceBiometricOption: token.forceBiometricOption,
    );
    if (!authenticated) return null;
    final updated = await _updateToken(
      token,
      (p0) => p0.copyWith(isHidden: false) as T,
    );
    if (updated?.isHidden == false) {
      _hidingTimers[token.id]?.cancel();
      _hidingTimers[token.id] = Timer(token.showDuration, () async {
        await hideToken(token);
      });
    }
    return updated;
  }

  /// Shows a token and returns the updated token if successful, the old token if not and null if the token does not exist or the user is not authenticated.
  Future<OTPToken?> showTokenById(String tokenId) async {
    final token = await getTokenById(tokenId);
    if (token is! OTPToken) {
      Logger.warning('Tried to show a token that is not an OTPToken.');
      return Future.value();
    }
    return showToken(token);
  }

  Future<TokenState?> loadStateFromRepo() async {
    try {
      // Do not race the provider's initial build for the same state mutex.
      // The biometric reconciliation step is asynchronous, so callers may
      // otherwise enter _updateStateFromRepo while build() still owns it.
      await future;
      return await _updateStateFromRepo();
    } catch (_) {
      Logger.warning('Loading tokens from storage failed.');
      return null;
    }
  }

  Future<bool> saveStateToRepo() => _saveStateToRepo();

  /// Minimizing the app needs to cancel all timers and save the state to the repository.
  Future<bool> onMinimizeApp() {
    Logger.info('TokenNotifier: Preparing to minimize app.');
    _cancelTimers();
    return hideLockedTokens();
  }

  Future<bool> hideLockedTokens() async {
    final lockedTokens = <Token>[];
    for (var token in (await future).tokens) {
      if (token.isLocked && !token.isHidden) {
        lockedTokens.add(token);
      }
    }
    return (await updateTokens(
          lockedTokens,
          (p0) => p0.copyWith(isHidden: true),
        )).length ==
        lockedTokens.length;
  }

  /// Removes a token from the state and the repository.
  Future<void> removeToken(Token token) async {
    if (token is PushToken) {
      await _removePushToken(token);
      return;
    }
    await _removeToken(token);
  }

  /// Removes a list of tokens from the state and the repository.
  Future<void> removeTokens(List<Token> tokens) async {
    Logger.info('Removing ${tokens.length} tokens.');
    final pushTokens = tokens.whereType<PushToken>().toList();
    final otherTokens = tokens.where((token) => token is! PushToken).toList();
    await _removeTokens(otherTokens);
    for (var token in pushTokens) {
      await _removePushToken(token);
    }
  }

  Future<void> removeTokensBySerials(List<String> serials) async {
    final tokens = (await future).tokens
        .where((token) => serials.contains(token.serial))
        .toList();
    await removeTokens(tokens);
  }

  Future<bool> _removePushToken(PushToken token) async {
    if (token.fbToken == null) {
      return _removeToken(token);
    }
    try {
      await firebaseUtils.deleteFirebaseToken();
    } on SocketException {
      Logger.warning('Could not delete firebase token.');
      ref
          .read(statusProvider.notifier)
          .show(
            (localization) => localization.errorUnlinkingPushToken(token.label),
            details: (localization) => localization.checkYourNetwork,
          );
      return false;
    }
    final deleted = await _removeToken(token);
    if (deleted) {
      Logger.info('Push token "${token.id}" removed successfully.');
    } else {
      Logger.warning('Push token "${token.id}" could not be removed.');
    }
    final fbToken = await firebaseUtils.getFBToken();

    if (fbToken == null) {
      await _updateTokens((await future).pushTokens, (p0) => p0.copyWith());
      Logger.warning(
        'Could not update firebase token because no firebase token is available.',
      );
      ref
          .read(statusProvider.notifier)
          .show(
            (localization) =>
                localization.errorSynchronizationNoNetworkConnection,
            details: (localization) =>
                localization.syncFbTokenManuallyWhenNetworkIsAvailable,
          );
      return deleted;
    }

    final (notUpdated, _) =
        (await updateFirebaseTokens(
          tokens: (await future).pushTokens,
          firebaseToken: fbToken,
        )) ??
        (<PushToken>[], <PushToken>[]);
    await _updateTokens(notUpdated, (p0) => p0.copyWith());
    if (notUpdated.isNotEmpty) {
      Logger.warning(
        'Could not update firebase token for ${notUpdated.length} tokens.',
      );
      ref
          .read(statusProvider.notifier)
          .show(
            (localization) =>
                localization.errorSynchronizationNoNetworkConnection,
            details: (localization) =>
                localization.syncFbTokenManuallyWhenNetworkIsAvailable,
          );
    }
    return deleted;
  }

  Future<bool> rolloutPushToken(PushToken token) async {
    PushToken? pushToken = await getTokenById(token.id);
    if (pushToken == null) {
      Logger.warning('Tried to rollout a token that does not exist.');
      return false;
    }

    if (!await _isEligibleForRollout(pushToken)) return false;
    if (pushToken.isRolledOut) return true;

    Logger.info('Rolling out token "${pushToken.id}"');

    final hasProtectedPrivateKey =
        pushToken.biometricKeyStatus == BiometricPushKeyStatus.protected;
    final needsKeyPair =
        pushToken.publicTokenKey == null ||
        (!hasProtectedPrivateKey && pushToken.privateTokenKey == null);
    if (needsKeyPair) {
      if (hasProtectedPrivateKey) {
        Logger.error(
          'Protected Push token is missing its matching public key.',
        );
        await _updateToken(
          pushToken,
          (current) => current.copyWith(
            privateTokenKey: () => null,
            biometricKeyStatus: BiometricPushKeyStatus.invalidated,
          ),
        );
        ref
            .read(statusProvider.notifier)
            .show(
              (l) => l.biometricPushTokenInvalidTitle,
              details: (l) => l.biometricPushTokenInvalidBody,
            );
        return false;
      }
      pushToken = await _handleKeyGeneration(pushToken);
      if (pushToken == null) return false;
    }

    if (pushToken.requiresBiometricKeyProtection &&
        pushToken.biometricKeyStatus != BiometricPushKeyStatus.protected) {
      try {
        await rsaUtils.protectBiometricPushKey(pushToken);
        final protectedToken = pushToken.copyWith(
          privateTokenKey: () => null,
          biometricKeyStatus: BiometricPushKeyStatus.protected,
        );
        final persistedToken = await _updateToken(
          pushToken,
          (current) => current.copyWith(
            privateTokenKey: () => protectedToken.privateTokenKey,
            biometricKeyStatus: protectedToken.biometricKeyStatus,
          ),
        );
        if (persistedToken == null ||
            persistedToken.privateTokenKey != null ||
            persistedToken.biometricKeyStatus !=
                BiometricPushKeyStatus.protected) {
          Logger.error(
            'Protected Push key state could not be persisted; rollout stopped.',
          );
          ref
              .read(statusProvider.notifier)
              .show(
                (l) => l.errorRollOutFailed(pushToken!.label),
                details: (l) => l.biometricPushKeyPersistenceFailed,
              );
          return false;
        }
        pushToken = persistedToken;
      } on BiometricPushKeyException catch (error, stackTrace) {
        Logger.warning(
          'Could not protect Push key with strong biometrics.',
          error: error,
          stackTrace: stackTrace,
        );
        ref
            .read(statusProvider.notifier)
            .show(
              (l) => l.errorRollOutFailed(pushToken!.label),
              details: (l) => l.biometricStrongRequired,
            );
        return false;
      }
    }

    String? fbToken;
    if (pushToken.isPollOnly != true) {
      fbToken = await _getFirebaseToken(pushToken);
      if (fbToken == null) return false;
      final refreshed = await getTokenById<PushToken>(pushToken.id);
      if (refreshed == null || refreshed.isBiometricKeyInvalidated) {
        Logger.warning(
          'Push token disappeared or was invalidated during rollout.',
        );
        return false;
      }
      pushToken = refreshed;
    }

    if (!kIsWeb && Platform.isIOS) {
      if (!await _checkNetworkPermission(pushToken)) return false;
    }

    return await _executeServerRollout(pushToken, fbToken);
  }

  Future<bool> _isEligibleForRollout(PushToken token) async {
    assert(token.url != null, 'Token url is null.');

    if (token.isBiometricKeyInvalidated) {
      ref
          .read(statusProvider.notifier)
          .show(
            (l) => l.biometricPushTokenInvalidTitle,
            details: (l) => l.biometricPushTokenInvalidBody,
          );
      return false;
    }

    if (token.rolloutState.rollOutInProgress) {
      Logger.info('Rollout already in progress for "${token.id}".');
      return false;
    }

    if (token.expirationDate?.isBefore(DateTime.now()) == true) {
      Logger.info('Token "${token.id}" is expired.');
      ref
          .read(statusProvider.notifier)
          .show(
            (localization) => localization.errorRollOutNotPossibleAnymore,
            details: (localization) =>
                localization.errorTokenExpired(token.label),
          );
      await _removeToken(token);
      return false;
    }
    return true;
  }

  Future<PushToken?> _handleKeyGeneration(PushToken token) async {
    token =
        await _updateStatus(
          token,
          PushTokenRollOutState.generatingRSAKeyPair,
        ) ??
        token;
    try {
      final keyPair = await rsaUtils.generateRSAKeyPair();
      return await _updateToken(token, (p) {
        p = p.withPrivateTokenKey(keyPair.privateKey);
        return p.withPublicTokenKey(keyPair.publicKey);
      });
    } catch (e, s) {
      Logger.error(
        'Error while generating RSA key pair.',
        error: e,
        stackTrace: s,
      );
      await _updateStatus(
        token,
        PushTokenRollOutState.generatingRSAKeyPairFailed,
      );
      return null;
    }
  }

  Future<String?> _getFirebaseToken(PushToken token) async {
    await _updateStatus(token, PushTokenRollOutState.receivingFirebaseToken);
    try {
      return await firebaseUtils.getFBToken();
    } catch (e, s) {
      Logger.warning('Could not get firebase token.', error: e, stackTrace: s);
      ref
          .read(statusProvider.notifier)
          .show(
            (l) => l.errorRollOutFailed(token.label),
            details: (l) => l.checkYourNetwork,
          );
      await _updateStatus(token, PushTokenRollOutState.sendRSAPublicKeyFailed);
      return null;
    }
  }

  Future<bool> _checkNetworkPermission(PushToken token) async {
    Logger.warning('Triggering network access permission for "${token.id}"');
    final success = await ioClient.triggerNetworkAccessPermission(
      url: token.url!,
      sslVerify: token.sslVerify,
    );
    if (!success) {
      Logger.warning('Network access permission failed.');
      await _updateStatus(token, PushTokenRollOutState.sendRSAPublicKeyFailed);
      return false;
    }
    return true;
  }

  Future<bool> _executeServerRollout(PushToken token, String? fbToken) async {
    return await withCurrentPushTokenLease<bool>(token.id, (
          leasedToken,
          persist,
          current,
        ) async {
          if (leasedToken.isBiometricKeyInvalidated ||
              leasedToken.url == null ||
              leasedToken.publicTokenKey == null) {
            return false;
          }
          if (leasedToken.requiresBiometricKeyProtection &&
              leasedToken.biometricKeyStatus !=
                  BiometricPushKeyStatus.protected) {
            return false;
          }
          if (leasedToken.requiresBiometricPromptBeforeDartKeyUse) {
            final authenticated = await lockAuthWithSettingsRef(
              ref: ref,
              localization: ref.read(localizationProvider),
              reason: (l) => l.biometricPushKeyAuthReason,
              forceBiometricOption: leasedToken.forceBiometricOption,
            );
            if (!authenticated) return false;
          }

          final sending = await persist(
            leasedToken.copyWith(
              rolloutState: PushTokenRollOutState.sendRSAPublicKey,
            ),
          );
          if (sending == null) return false;
          try {
            final response = await ioClient.doPost(
              sslVerify: current().sslVerify,
              url: current().url!,
              body: {
                'enrollment_credential': current().enrollmentCredentials,
                'serial': current().serial,
                'fbtoken': fbToken ?? NoFirebaseUtils.NO_FIREBASE_TOKEN,
                'pubkey': rsaUtils.serializeRSAPublicKeyPKCS8(
                  current().rsaPublicTokenKey!,
                ),
                'capabilities': canonicalizeJson(appPushCapabilities.names),
              },
            );

            if (HttpStatusChecker.isError(response.statusCode)) {
              _showPushRolloutStatus(response, current().label);
              await persist(
                current().copyWith(
                  rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed,
                ),
              );
              return false;
            }

            final parsing = await persist(
              current().copyWith(
                rolloutState: PushTokenRollOutState.parsingResponse,
                fbToken: fbToken,
              ),
            );
            if (parsing == null) return false;

            final publicServerKey = await _parseRollOutResponse(response);
            final completed = await persist(
              current()
                  .withPublicServerKey(publicServerKey)
                  .copyWith(
                    isRolledOut: true,
                    rolloutState: PushTokenRollOutState.rolloutComplete,
                  ),
            );
            if (completed == null || !completed.isRolledOut) return false;
            checkNotificationPermission();
            return true;
          } catch (e, s) {
            Logger.error('Roll out failed.', error: e, stackTrace: s);
            ref
                .read(statusProvider.notifier)
                .show((loc) => loc.errorRollOutUnknownError(current().label));
            await persist(
              current().copyWith(
                rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed,
              ),
            );
            return false;
          }
        }) ??
        false;
  }

  Future<PushToken?> _updateStatus(
    PushToken token,
    PushTokenRollOutState state,
  ) async {
    final updated = await _updateToken(
      token,
      (p) => p.copyWith(rolloutState: state),
    );
    if (updated == null) {
      Logger.warning('Tried to update a token that does not exist.');
    }
    return updated;
  }

  final _updateFbTokenMutex = Mutex();

  Future<(List<PushToken>, List<PushToken>)?> updateAllFirebaseTokens({
    String? firebaseToken,
  }) async {
    return updateFirebaseTokens(
      tokens: (await future).pushTokens,
      firebaseToken: firebaseToken,
    );
  }

  /// This method attempts to update the fbToken for all PushTokens that can be
  /// updated. I.e. all tokens that know the url of their respective privacyIDEA
  /// server.
  /// If the fbToken is not provided, it will be fetched from the firebase instance.
  /// If the fbToken is not available, this method will return null.
  /// Returns a tuple of two lists. The first list contains all tokens that
  /// could not be updated. The second list contains all tokens that do not
  /// support updating the fbToken.
  ///
  /// This should only be used to attempt to update the fbToken automatically,
  /// as this can not be guaranteed to work. There is a manual option available
  /// through the settings also.
  Future<(List<PushToken>, List<PushToken>)?> updateFirebaseTokens({
    required List<PushToken> tokens,
    String? firebaseToken,
  }) async {
    if (tokens.isEmpty) {
      Logger.info('No tokens to update.');
      return null;
    }

    Logger.info('Updating firebase token for ${tokens.length} push tokens.');
    return _updateFbTokenMutex.protect(() async {
      final List<PushToken> failedTokens = [];
      final List<PushToken> unsupportedTokens = [];
      final pollOnlyTokens = tokens.where((t) => t.isPollOnly == true).toList();
      final notPollOnlyTokens = tokens
          .where((t) => t.isPollOnly != true)
          .toList();

      try {
        Logger.info('Updating firebase token if needed.');

        if (notPollOnlyTokens.isNotEmpty) {
          if (firebaseUtils.initializedFirebase == false) {
            await firebaseUtils.initializeApp();
          }
          firebaseToken ??= await firebaseUtils.getFBToken();
          if (firebaseToken == null) {
            failedTokens.addAll(notPollOnlyTokens);
          } else {
            for (final token in notPollOnlyTokens) {
              if (!token.isRolledOut || token.fbToken == firebaseToken) {
                // Skip if the token is not rolled out or the fbToken is already up to date
                continue;
              }
              if (token.url == null) {
                unsupportedTokens.add(token);
                continue;
              }
              final success = await updateFirebaseToken(token, firebaseToken!);
              if (!success) {
                failedTokens.add(token);
              }
            }
          }
        }

        if (pollOnlyTokens.isNotEmpty) {
          final noFbToken = await NoFirebaseUtils().getFBToken();
          for (final token in pollOnlyTokens) {
            if (token.url == null) {
              unsupportedTokens.add(token);
              continue;
            }
            final success = await updateFirebaseToken(token, noFbToken);
            if (!success) {
              failedTokens.add(token);
            }
          }
        }

        final allUpdated = failedTokens.isEmpty && unsupportedTokens.isEmpty;
        if (allUpdated && firebaseToken != null) {
          await firebaseUtils.setCurrentFirebaseToken(firebaseToken!);
        }
      } catch (e, s) {
        Logger.error(
          'Error while updating firebase token.',
          error: e,
          stackTrace: s,
        );
        return null;
      }
      return (failedTokens, unsupportedTokens);
    });
  }

  Future<bool> updateFirebaseToken(
    PushToken token,
    String firebaseToken,
  ) async {
    // POST /ttype/push HTTP/1.1
    //Host: example.com
    //
    //new_fb_token=<new firebase token>
    //serial=<tokenserial>element
    //timestamp=<timestamp>
    //signature=SIGNATURE(<new firebase token>|<tokenserial>|<timestamp>)
    Logger.info('Updating firebase token for push token "${token.serial}"');
    return await withCurrentPushTokenLease<bool>(token.id, (
          leasedToken,
          persist,
          current,
        ) async {
          if (!leasedToken.isRolledOut ||
              leasedToken.url == null ||
              leasedToken.isBiometricKeyInvalidated) {
            return false;
          }
          if (leasedToken.requiresBiometricPromptBeforeDartKeyUse) {
            final authenticated = await lockAuthWithSettingsRef(
              ref: ref,
              localization: ref.read(localizationProvider),
              reason: (l) => l.biometricPushKeyAuthReason,
              forceBiometricOption: leasedToken.forceBiometricOption,
            );
            if (!authenticated) return false;
          }
          final timestamp = DateTime.now().toUtc().toIso8601String();
          final message = '$firebaseToken|${leasedToken.serial}|$timestamp';
          String? signature;
          try {
            signature = await rsaUtils.trySignWithToken(
              leasedToken,
              message,
              onTokenChanged: (updated) async {
                final persisted = await persist(
                  current().copyWith(
                    privateTokenKey: () => updated.privateTokenKey,
                    biometricKeyStatus: updated.biometricKeyStatus,
                  ),
                );
                return persisted != null &&
                    persisted.privateTokenKey == updated.privateTokenKey &&
                    persisted.biometricKeyStatus == updated.biometricKeyStatus;
              },
            );
          } on BiometricPushKeyException catch (error) {
            if (error.isInvalidated) {
              ref
                  .read(statusProvider.notifier)
                  .show(
                    (l) => l.biometricPushTokenInvalidTitle,
                    details: (l) => l.biometricPushTokenInvalidBody,
                  );
            } else if (error.isStateNotPersisted) {
              ref
                  .read(statusProvider.notifier)
                  .show(
                    (l) => l.biometricPushKeyPersistenceFailedTitle,
                    details: (l) => l.biometricPushKeyPersistenceFailed,
                  );
            }
            return false;
          }
          if (signature == null || current().isBiometricKeyInvalidated) {
            Logger.error(
              'Cannot update firebase token for push token "${leasedToken.serial}". No valid signature is available.',
            );
            return false;
          }
          final response = await ioClient.doPost(
            url: current().url!,
            body: {
              'new_fb_token': firebaseToken,
              'serial': current().serial,
              'timestamp': timestamp,
              'signature': signature,
              // Not part of the signed message; older servers ignore it.
              'capabilities': canonicalizeJson(appPushCapabilities.names),
            },
            sslVerify: current().sslVerify,
          );
          if (HttpStatusChecker.isError(response.statusCode)) {
            Logger.warning('Updating firebase token for push token failed!');
            return false;
          }
          final persisted = await persist(
            current().copyWith(fbToken: firebaseToken),
          );
          if (persisted?.fbToken != firebaseToken) return false;
          Logger.info('Updating firebase token for push token succeeded!');
          return true;
        }) ??
        false;
  }

  /* ////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Add New Tokens Methods //////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  /// Does not need to wait for updating functions because they doesn't depend on any state */

  /// Handles a link and returns true if the link was handled, false if not.
  Future<bool> handleLink(Uri uri) async {
    final tokenResults = await TokenImportSchemeProcessor.processUriByAny(uri);
    if (tokenResults == null) return false; // Not a valid token link
    if (tokenResults.isEmpty) {
      return true; // Link was valid but contained no tokens
    }
    await handleProcessorResults(
      tokenResults,
      args: {'TokenOriginSourceType': TokenOriginSourceType.link},
    );
    return true; // Link was valid and contained tokens
  }

  @override
  Future<void> handleProcessorResult(
    ProcessorResult result, {
    Map<String, dynamic> args = const {},
  }) {
    if (result is ProcessorResult<Token>) {
      return handleProcessorResults([result], args: args);
    }
    return Future.value();
  }

  @override
  Future handleProcessorResults(
    List<ProcessorResult> results, {
    Map<String, dynamic> args = const {},
  }) async {
    final List<ProcessorResult<Token>> tokenResults = results
        .whereType<ProcessorResult<Token>>()
        .toList();
    if (tokenResults.isEmpty) return;
    final List<Token> resultTokens = tokenResults.getData();
    final stateTokens = (await future).tokens;
    final tokenOriginSourceType =
        (args['TokenOriginSourceType'] as TokenOriginSourceType?);
    var tokenImportType =
        (args['TokenImportType'] as TokenImportType?) ?? TokenImportType.qrScan;
    try {
      if (resultTokens.isNotEmpty &&
          (resultTokens.length > 1 ||
              stateTokens.any(
                (e) => resultTokens.first.isSameTokenAs(e) == true,
              ))) {
        _showImportTokensPage(
          tokenResults,
          tokenOriginSourceType!,
          tokenImportType,
        );
        return;
      }
    } catch (error, stackTrace) {
      Logger.error(
        'Error while processing QR code.',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
    final tokensWithSourceType = _addSourceType(
      resultTokens,
      tokenOriginSourceType,
    );
    addNewTokens(tokensWithSourceType);
  }

  /* /////////////////////////////////////////////////////////////////////////////
///////////////////////////// Helper Methods //////////////////////////////////-
///////////////////////////////////////////////////////////////////////////// */

  Future<void> _showImportTokensPage(
    List<ProcessorResult<Token>> tokenResults,
    TokenOriginSourceType tokenOriginSourceType,
    TokenImportType tokenImportType,
  ) async {
    final tokensToKeep = await Navigator.of(globalNavigatorKey.currentContext!)
        .push<List<Token>>(
          MaterialPageRoute<List<Token>>(
            builder: (context) => ImportPlainTokensPage(
              titleName: AppLocalizations.of(context)!.importTokens,
              processorResults: tokenResults,
              selectedType: tokenImportType,
            ),
          ),
        );
    if (tokensToKeep == null) return;
    final tokensWithSourceType = _addSourceType(
      tokensToKeep,
      tokenOriginSourceType,
    );
    await addNewTokens(tokensWithSourceType);
  }

  List<Token> _addSourceType(
    List<Token> tokens,
    TokenOriginSourceType? tokenOriginSourceType,
  ) => tokens
      .map(
        (e) => e.copyWith(
          origin:
              e.origin?.copyWith(source: tokenOriginSourceType) ??
              TokenOriginSourceType.unknown.toTokenOrigin(
                data: 'No Origindata available',
              ),
        ),
      )
      .toList();

  Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
    Logger.info('Parsing rollout response, try to extract public_key.');
    try {
      String key = json.decode(response.body)['detail']['public_key'];
      key = key.replaceAll('\n', '');

      Logger.info('Extracting public key was successful.');

      return rsaUtils.deserializeRSAPublicKeyPKCS1(key);
    } on FormatException catch (e) {
      throw FormatException(
        'Response body does not contain RSA public key.',
        e,
      );
    }
  }

  final _pushTokenHandlerMutex = Mutex();
  Future<void> _handlePushTokensIfExist() async {
    Logger.info('Handling push tokens if they exist.');
    await _pushTokenHandlerMutex.protect(() async {
      try {
        if ((await future).pushTokens.isEmpty) {
          if ((await ref.read(settingsProvider.future)).hidePushTokens ==
              true) {
            ref.read(settingsProvider.notifier).setHidePushTokens(false);
          }
          return;
        }
        final rolledOutPushNoFb = (await future).rolledOutPushTokens
            .where((element) => element.fbToken == null)
            .toList();
        if (rolledOutPushNoFb.isNotEmpty) {
          // If there is rolled out push tokens without fbToken, we need to update the firebase token for them.
          await updateFirebaseTokens(tokens: rolledOutPushNoFb);
        }
        if ((await future).hasRolledOutPushTokens) {
          checkNotificationPermission();
        }
        for (final element in (await future).pushTokensToRollOut) {
          Logger.info('Handling push token "${element.id}"');
          await rolloutPushToken(element);
        }
      } catch (e, s) {
        Logger.error(
          'Unexpected error while handling push tokens.',
          error: e,
          stackTrace: s,
        );
      }
    });
  }

  Future<T?> getTokenById<T extends Token>(String id) async {
    return (await future).tokens.whereType<T>().firstWhereOrNull(
      (element) => element.id == id,
    );
  }

  void _cancelTimers() {
    for (final key in _hidingTimers.keys) {
      _hidingTimers[key]?.cancel();
    }
    _hidingTimers.clear();
  }

  void _showPushRolloutStatus(Response response, String tokenLabel) {
    // Show more detailed error messages for specific status codes
    StatusMessage? statusMessage = switch (response.statusCode) {
      408 => StatusMessage(
        message: (l) => l.errorRollOutNoConnectionToServer(tokenLabel),
      ),
      525 => StatusMessage(
        message: (l) => l.errorRollOutSSLHandshakeFailed,
        details: (l) => l.checkServerCertificate,
      ),
      _ => null,
    };

    // If no specific status message was set, try to extract the error message from the response body
    // or fallback to a generic error message and the status code as details.
    if (statusMessage == null) {
      String? message;
      try {
        message = response.body.isNotEmpty
            ? (json.decode(response.body)['result']?['error']?['message'] ?? '')
            : '';
      } on FormatException {
        // Format Exception is thrown if the response body is not a valid json. This happens if the server is not reachable.
      }
      if (message == null || message.isEmpty) {
        statusMessage = StatusMessage(
          message: (localization) =>
              localization.errorRollOutFailed(tokenLabel),
          details: (localization) =>
              localization.statusCode(response.statusCode),
        );
      } else {
        final nonNullMessage = message;
        statusMessage = StatusMessage(
          message: (localization) =>
              localization.errorRollOutFailed(tokenLabel),
          details: (_) => nonNullMessage,
        );
      }
    }

    ref
        .read(statusProvider.notifier)
        .show(statusMessage.message, details: statusMessage.details);
  }
}
