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
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mutex/mutex.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/localization_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../model/extensions/enums/push_token_rollout_state_extension.dart';
import '../../../../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../../interfaces/repo/token_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/push_token_rollout_state.dart';
import '../../../../model/enums/token_import_type.dart';
import '../../../../model/enums/token_origin_source_type.dart';
import '../../../../model/processor_result.dart';
import '../../../../model/riverpod_states/token_state.dart';
import '../../../../model/tokens/hotp_token.dart';
import '../../../../model/tokens/otp_token.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../model/tokens/token.dart';
import '../../../../processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import '../../../../repo/secure_token_repository.dart';
import '../../../../views/import_tokens_view/pages/import_plain_tokens_page.dart';
import '../../../firebase_utils.dart';
import '../../../globals.dart';
import '../../../identifiers.dart';
import '../../../lock_auth.dart';
import '../../../logger.dart';
import '../../../privacyidea_io_client.dart';
import '../../../rsa_utils.dart';
import '../../../utils.dart';
import '../state_providers/status_message_provider.dart';
import 'settings_notifier.dart';

part 'token_notifier.g.dart';

final tokenProvider = tokenNotifierProviderOf(
  firebaseUtils: FirebaseUtils(),
  ioClient: const PrivacyideaIOClient(),
  rsaUtils: const RsaUtils(),
  repo: const SecureTokenRepository(),
);

@Riverpod(keepAlive: true)
class TokenNotifier extends _$TokenNotifier with ResultHandler {
  static final Map<String, Timer> _hidingTimers = {};
  late final Future<TokenState> initState;
  // final StateNotifierProviderRef ref;
  final _repoMutex = Mutex();
  final _stateMutex = Mutex();

  TokenNotifier({
    TokenRepository? repoOverride,
    RsaUtils? rsaUtilsOverride,
    PrivacyideaIOClient? ioClientOverride,
    FirebaseUtils? firebaseUtilsOverride,
  })  : _repoOverride = repoOverride,
        _rsaUtilsOverride = rsaUtilsOverride,
        _ioClientOverride = ioClientOverride,
        _firebaseUtilsOverride = firebaseUtilsOverride;

  @override
  TokenRepository get repo => _repo;
  late final TokenRepository _repo;
  final TokenRepository? _repoOverride;

  @override
  RsaUtils get rsaUtils => _rsaUtils;
  late final RsaUtils _rsaUtils;
  final RsaUtils? _rsaUtilsOverride;

  @override
  PrivacyideaIOClient get ioClient => _ioClient;
  late final PrivacyideaIOClient _ioClient;
  final PrivacyideaIOClient? _ioClientOverride;

  @override
  FirebaseUtils get firebaseUtils => _firebaseUtils;
  late final FirebaseUtils _firebaseUtils;
  final FirebaseUtils? _firebaseUtilsOverride;

  @override
  TokenState build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) {
    _repo = _repoOverride ?? repo;
    _rsaUtils = _rsaUtilsOverride ?? rsaUtils;
    _ioClient = _ioClientOverride ?? ioClient;
    _firebaseUtils = _firebaseUtilsOverride ?? firebaseUtils;
    _stateMutex.acquire();
    initState = _loadStateFromRepo().then((newState) {
      _stateMutex.release();
      return state = newState;
    });
    return const TokenState(tokens: [], lastlyUpdatedTokens: []);
  }
  //   /*
  //   /////////////////////////////////////////////////////////////////////////////
  //   /////////////////////// Repository and Token Handling ///////////////////////
  //   /////////////////////////////////////////////////////////////////////////////
  //   /// Repository layer is always use loadingRepoMutex for the latest state
  //   */

  Future<TokenState> _loadStateFromRepo() async {
    await _repoMutex.acquire();
    final tokens = await _repo.loadTokens();
    final newState = TokenState(tokens: tokens, lastlyUpdatedTokens: tokens);
    _repoMutex.release();
    return newState;
  }

  /// Adds a token and returns true if successful, false if not.
  Future<bool> _addOrReplaceToken(Token token) async {
    await _repoMutex.acquire();
    final success = await _repo.saveOrReplaceToken(token);
    final currentId = state.currentOf(token)?.id;
    if (currentId != null) {
      token = token.copyWith(id: currentId);
    }
    if (!success) {
      Logger.warning('Saving token failed. Token: ${token.id}');
      _repoMutex.release();
      return false;
    }
    state = state.addOrReplaceToken(token);
    _repoMutex.release();
    return true;
  }

  /// Adds a list of tokens and returns the tokens that could not be added or replaced.
  Future<List<Token>> _addOrReplaceTokens(List<Token> tokens) async {
    tokens = _filterDuplicates([...tokens, ...state.tokens]);
    if (tokens.isEmpty) return [];
    Logger.debug('Adding ${tokens.length} tokens.', verbose: true);
    await _repoMutex.acquire();
    tokens = tokens.map((token) {
      final currentId = state.currentOf(token)?.id;
      if (currentId != null) return token.copyWith(id: currentId);
      return token;
    }).toList();
    final failedTokens = await _repo.saveOrReplaceTokens(tokens);
    if (failedTokens.isNotEmpty) {
      Logger.warning('Saving tokens failed. Failed Tokens: ${failedTokens.length}');
    }
    // Every token that is saved should not be in the failedTokens list
    final savedTokens = tokens.where((element) => !failedTokens.contains(element)).toList();
    // Add the saved tokens to the state
    Logger.info('Saved ${savedTokens.length} Tokens to storage.');
    state = state.addOrReplaceTokens(savedTokens);

    Logger.debug('New State: ${state.tokens.length} Tokens');
    _repoMutex.release();
    return [];
  }

  /// Replaces a token if it exists and returns true if successful, false if not.
  Future<bool> _replaceToken(Token token) async {
    await _repoMutex.acquire();
    final (newState, replaced) = state.replaceToken(token);
    if (!replaced) {
      Logger.warning('Tried to replace a token that does not exist.');
      _repoMutex.release();
      return false;
    }
    final saved = await _repo.saveOrReplaceToken(token);
    if (!saved) {
      Logger.warning('Saving token failed. Token: ${token.id}');
      _repoMutex.release();
      return false;
    }
    state = newState;
    _repoMutex.release();
    return true;
  }

  /// Returns a list of tokens that could not be replaced
  Future<List<T>> _replaceTokens<T extends Token>(List<T> tokens) async {
    await _repoMutex.acquire();
    final oldState = state;
    final (newState, failedToReplace) = state.replaceTokens(tokens);
    state = newState;
    for (var e in failedToReplace) {
      tokens.remove(e);
    }
    final failedToSave = await _repo.saveOrReplaceTokens<T>(tokens);
    if (failedToSave.isNotEmpty) {
      Logger.warning('Saving tokens failed. Failed Tokens: ${failedToSave.length}');
      final recovered = oldState.tokens.whereType<T>().where((oldToken) => failedToSave.contains(oldToken)).toList();
      state = state.addOrReplaceTokens<T>(recovered);
      _repoMutex.release();
      return failedToSave;
    }
    _repoMutex.release();
    return [];
  }

  /// Removes a token and returns true if successful, false if not.
  Future<bool> _removeToken(Token token) async {
    await _repoMutex.acquire();
    state = state.withoutToken(token);

    final success = await _repo.deleteToken(token);
    if (!success) {
      Logger.warning('Deleting token failed. Token: ${token.id}');
      state = state.addOrReplaceToken(token);
      _repoMutex.release();
      return false;
    }
    _repoMutex.release();
    await _handlePushTokensIfExist();
    return true;
  }

  /// Removes a list of tokens and returns the tokens that could not be removed.
  Future<List<Token>> _removeTokens(List<Token> tokens) async {
    if (tokens.isEmpty) return [];
    Logger.info('Removing ${tokens.length} tokens.');
    await _repoMutex.acquire();
    final oldState = state;
    state = state.withoutTokens(tokens);

    final failedTokens = await _repo.deleteTokens(tokens);
    if (failedTokens.isNotEmpty) {
      Logger.warning('Deleting tokens failed. Failed Tokens: ${failedTokens.length}');
      final recoveredTokens = oldState.tokens.where((oldToken) => failedTokens.contains(oldToken)).toList();
      state = state.addOrReplaceTokens(recoveredTokens);
      _repoMutex.release();
      return failedTokens;
    }
    _repoMutex.release();
    await _handlePushTokensIfExist();
    return [];
  }

  /// Loads the tokens from the repository sets it as the new state and returns the new state.
  Future<TokenState> _loadFromRepo() async {
    await _repoMutex.acquire();
    TokenState newState;
    try {
      List<Token> tokens;
      tokens = await _repo.loadTokens();
      newState = TokenState(tokens: tokens, lastlyUpdatedTokens: tokens);
      state = newState;
    } catch (e) {
      Logger.error(
        'Loading tokens from storage failed.',
        error: e,
      );
      _repoMutex.release();
      return state;
    }
    _repoMutex.release();
    await _handlePushTokensIfExist();
    return newState;
  }

  Future<bool> _saveStateToRepo(TokenState state) async {
    await _repoMutex.acquire();
    try {
      await _repo.saveOrReplaceTokens(state.tokens);
    } catch (e) {
      Logger.error(
        'Saving tokens to storage failed.',
        error: e,
      );
      _repoMutex.release();
      return false;
    }
    _repoMutex.release();
    return true;
  }

  /*
  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Update Token Methods ///////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  /// Updating layer is always use updatingTokensMutex for the latest state
  */

  /// Updates a token and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<T?> _updateToken<T extends Token>(T token, T Function(T) updater) async {
    await _stateMutex.acquire();
    await _repoMutex.acquire();
    _repoMutex.release();
    final current = state.currentOf<T>(token);
    if (current == null) {
      Logger.warning('Tried to update a token that does not exist.');
      _stateMutex.release();
      return null;
    }
    final updated = updater(current);
    final replaced = await _replaceToken(updated);
    _stateMutex.release();
    return replaced ? updated : current;
  }

  /// Updates a list of tokens and returns the updated tokens if successful, the old tokens if not and an empty list if the tokens does not exist.
  Future<List<T>> _updateTokens<T extends Token>(List<T> tokens, T Function(T) updater) async {
    if (tokens.isEmpty) return [];
    await _stateMutex.acquire();
    final oldState = state;

    List<T> updatedTokens = [];
    for (final token in tokens) {
      final current = state.currentOf<T>(token) ?? token;
      updatedTokens.add(updater(current));
    }
    final failed = await _replaceTokens(updatedTokens);
    final recoveredTokens = oldState.tokens.whereType<T>().where((oldToken) => failed.contains(oldToken)).toList();

    // Merge the updated tokens with the recovered tokens, so the returned list has the same tokens as the repository.
    final mergedTokens = updatedTokens
        .map((updated) => recoveredTokens.firstWhere(
              (recoveredToken) => recoveredToken == updated,
              orElse: () => updated,
            ))
        .toList();
    _stateMutex.release();
    return mergedTokens;
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
  Future<List<Token>> addOrReplaceTokens(List<Token> tokens) => _addOrReplaceTokens(tokens);

  /// Updates a token and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<T?> updateToken<T extends Token>(T token, T Function(T) updater) => _updateToken(token, updater);

  /// Updates a list of tokens and returns the updated tokens if successful, the old tokens if not and an empty list if the tokens does not exist.
  Future<List<T>> updateTokens<T extends Token>(List<T> tokens, T Function(T) updater) => _updateTokens(tokens, updater);

  /// Increments the counter of a HOTPToken and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<HOTPToken?> incrementCounter(HOTPToken token) => _updateToken(token, (p0) => p0.copyWith(counter: token.counter + 1));

  /// Hides a token and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<T?> hideToken<T extends Token>(T token) => _updateToken(token, (p0) => p0.copyWith(isHidden: true) as T);

  /// Shows a token and returns the updated token if successful, the old token if not and null if the token does not exist or the user is not authenticated.
  Future<T?> showToken<T extends OTPToken>(T token) async {
    final authenticated = await lockAuth(
      localization: ref.read(localizationNotifierProvider),
      reason: (localization) => localization.authenticateToShowOtp,
    );
    if (!authenticated) return null;
    final updated = await _updateToken(token, (p0) => p0.copyWith(isHidden: false) as T);
    if (updated?.isHidden == false) {
      _hidingTimers[token.id]?.cancel();
      _hidingTimers[token.id] = Timer(token.showDuration, () async {
        await hideToken(token);
      });
    }
    return updated;
  }

  /// Shows a token and returns the updated token if successful, the old token if not and null if the token does not exist or the user is not authenticated.
  Future<Token?> showTokenById(String tokenId) {
    final token = getTokenById(tokenId);
    if (token == null) {
      Logger.warning('Tried to show a token that does not exist.');
      return Future.value(null);
    }
    if (token is! OTPToken) {
      Logger.warning('Tried to show a token that is not an OTPToken.');
      return Future.value(null);
    }
    return showToken(token);
  }

  Future<TokenState?> loadStateFromRepo() async {
    try {
      return await _loadFromRepo();
    } catch (_) {
      Logger.warning('Loading tokens from storage failed.');
      return null;
    }
  }

  Future<bool> saveStateToRepo() async {
    try {
      await _saveStateToRepo(state);
      Logger.info('Saved ${state.tokens.length} Tokens to storage.');
      return true;
    } catch (_) {
      Logger.error('Saving tokens to storage failed.');
      return false;
    }
  }

  /// Minimizing the app needs to cancel all timers and save the state to the repository.
  Future<bool> onMinimizeApp() {
    Logger.info('TokenNotifier: Preparing to minimize app.');
    _cancelTimers();
    return hideLockedTokens();
  }

  Future<bool> hideLockedTokens() async {
    final lockedTokens = <Token>[];
    for (var token in state.tokens) {
      if (token.isLocked && !token.isHidden) {
        lockedTokens.add(token);
      }
    }
    return (await updateTokens(lockedTokens, (p0) => p0.copyWith(isHidden: true))).length == lockedTokens.length;
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
    final otherTokens = tokens.whereType<Token>().toList();
    await _removeTokens(otherTokens);
    for (var token in pushTokens) {
      await _removePushToken(token);
    }
  }

  Future<void> removeTokensBySerials(List<String> serials) async {
    final tokens = state.tokens.where((token) => serials.contains(token.serial)).toList();
    await removeTokens(tokens);
  }

  Future<bool> _removePushToken(PushToken token) async {
    if (token.fbToken == null) {
      return _removeToken(token);
    }
    try {
      await _firebaseUtils.deleteFirebaseToken();
    } on SocketException {
      Logger.warning('Could not delete firebase token.');
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) => localization.errorUnlinkingPushToken(token.label),
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
    final fbToken = await _firebaseUtils.getFBToken();

    if (fbToken == null) {
      await _updateTokens(state.pushTokens, (p0) => p0.copyWith(fbToken: null));
      Logger.warning('Could not update firebase token because no firebase token is available.');
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) => localization.errorSynchronizationNoNetworkConnection,
        details: (localization) => localization.syncFbTokenManuallyWhenNetworkIsAvailable,
      );
      return deleted;
    }

    final (notUpdated, _) = (await updateFirebaseToken(fbToken)) ?? (<PushToken>[], <PushToken>[]);
    await _updateTokens(notUpdated, (p0) => p0.copyWith(fbToken: null));
    if (notUpdated.isNotEmpty) {
      Logger.warning('Could not update firebase token for ${notUpdated.length} tokens.');
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) => localization.errorSynchronizationNoNetworkConnection,
        details: (localization) => localization.syncFbTokenManuallyWhenNetworkIsAvailable,
      );
    }
    return deleted;
  }

  Future<bool> rolloutPushToken(PushToken token) async {
    PushToken? pushToken;
    pushToken = (getTokenById(token.id)) as PushToken?;
    if (pushToken == null) {
      Logger.warning('Tried to rollout a token that does not exist.');
      return false;
    }

    assert(pushToken.url != null, 'Token url is null. Cannot rollout token without url.');
    Logger.info('Rolling out token "${pushToken.id}"');
    if (pushToken.isRolledOut) {
      Logger.info('Ignoring rollout request: Token "${pushToken.id}" already rolled out.');
      return true;
    }
    if (pushToken.rolloutState.rollOutInProgress) {
      Logger.info('Ignoring rollout request: Rollout of token "${pushToken.id}" already started. Tokenstate: ${pushToken.rolloutState} ');
      return false;
    }
    if (pushToken.expirationDate?.isBefore(DateTime.now()) == true) {
      Logger.info('Ignoring rollout request: Token "${pushToken.id}" is expired. ');

      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) => localization.errorRollOutNotPossibleAnymore,
        details: (localization) => localization.errorTokenExpired(pushToken!.label),
      );

      await _removeToken(pushToken);
      return false;
    }

    if (pushToken.privateTokenKey == null) {
      Logger.info('Updating rollout state of token "${pushToken.id}" to generatingRSAKeyPair');
      pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPair));
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
      Logger.info('Updated token "${pushToken.id}"');
      try {
        final keyPair = await _rsaUtils.generateRSAKeyPair();
        pushToken = pushToken.withPrivateTokenKey(keyPair.privateKey);
        pushToken = pushToken.withPublicTokenKey(keyPair.publicKey);
        pushToken = await _updateToken(pushToken, (p0) {
              p0 = p0.withPrivateTokenKey(keyPair.privateKey);
              return p0.withPublicTokenKey(keyPair.publicKey);
            }) ??
            pushToken;
        Logger.info('Updated token "${pushToken.id}"');
      } catch (e, s) {
        Logger.error(
          'Error while generating RSA key pair.',
          error: e,
          stackTrace: s,
        );
        if (pushToken == null) {
          Logger.warning('Tried to update a token that does not exist.');
          return false;
        }
        pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPairFailed));
        return false;
      }
    }

    pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKey));
    if (pushToken == null) {
      Logger.warning('Tried to update a token that does not exist.');
      return false;
    }
    if (!kIsWeb && Platform.isIOS) {
      Logger.warning('Triggering network access permission for token "${pushToken.id}"');
      if (!await _ioClient.triggerNetworkAccessPermission(url: pushToken.url!, sslVerify: pushToken.sslVerify)) {
        Logger.warning('Network access permission for token "${pushToken.id}" failed.');
        _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
        return false;
      }
      Logger.warning('Network access permission for token "${pushToken.id}" successful.');
    }
    try {
      // TODO What to do with poll only tokens if google-services is used?

      Logger.warning('SSLVerify: ${pushToken.sslVerify}');
      final fbToken = await _firebaseUtils.getFBToken();
      Response response = await _ioClient.doPost(
        sslVerify: pushToken.sslVerify,
        url: pushToken.url!,
        body: {
          'enrollment_credential': pushToken.enrollmentCredentials,
          'serial': pushToken.serial,
          'fbtoken': fbToken,
          'pubkey': _rsaUtils.serializeRSAPublicKeyPKCS8(pushToken.rsaPublicTokenKey!),
        },
      );

      if (response.statusCode == 200) {
        pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.parsingResponse, fbToken: fbToken));
        if (pushToken == null) {
          Logger.warning('Tried to update a token that does not exist.');
          return false;
        }
        try {
          RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
          pushToken = await _updateToken(pushToken, (p0) => p0.withPublicServerKey(publicServerKey));
          if (pushToken == null) {
            Logger.warning('Tried to update a token that does not exist.');
            return false;
          }
        } on FormatException catch (e, s) {
          Logger.error('Error while parsing RSA public key.', error: e, stackTrace: s);
          if (pushToken == null) {
            Logger.warning('Tried to update a token that does not exist.');
            return false;
          }
          pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.parsingResponseFailed));
          return false;
        }
        Logger.info('Roll out successful');
        pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(isRolledOut: true, rolloutState: PushTokenRollOutState.rolloutComplete));
        checkNotificationPermission();

        return true;
      } else {
        Logger.warning(
          'Post request on roll out failed.',
          error: 'Token: ${pushToken.serial}\nStatus code: ${response.statusCode},\nURL:${response.request?.url}\nBody: ${response.body}',
        );

        try {
          final message = response.body.isNotEmpty ? (json.decode(response.body)['result']?['error']?['message']) : '';
          ref.read(statusMessageProvider.notifier).state = StatusMessage(
            message: (localization) => localization.errorRollOutFailed(pushToken!.label),
            details: message,
          );
        } on FormatException {
          // Format Exception is thrown if the response body is not a valid json. This happens if the server is not reachable.

          ref.read(statusMessageProvider.notifier).state = StatusMessage(
            message: (localization) => localization.errorRollOutFailed(pushToken!.label),
            details: (localization) => localization.statusCode(response.statusCode),
          );
        }

        pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
        return false;
      }
    } catch (e, s) {
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
      pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
      if (e is PlatformException && e.code == FIREBASE_TOKEN_ERROR_CODE || e is SocketException || e is TimeoutException || e is FirebaseException) {
        Logger.warning('Connection error: Roll out push token failed.', error: e, stackTrace: s);
        ref.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (localization) => localization.errorRollOutNoConnectionToServer(pushToken!.label),
        );
      } else if (e is HandshakeException) {
        Logger.warning('SSL error: Roll out push token failed.', error: e, stackTrace: s);
        ref.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (localization) => localization.errorRollOutSSLHandshakeFailed,
        );
      } else {
        ref.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (localization) => localization.errorRollOutUnknownError(pushToken!.label),
        );
        Logger.error('Roll out push token failed.', error: e, stackTrace: s);
      }
      return false;
    }
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
  Future<(List<PushToken>, List<PushToken>)?> updateFirebaseToken([String? firebaseToken]) async {
    Logger.info('Updating firebase token for all push tokens.');
    firebaseToken ??= await _firebaseUtils.getFBToken();
    if (firebaseToken == null) {
      Logger.warning('Could not update firebase token because no firebase token is available.');
      return null;
    }
    List<PushToken> tokenList = state.pushTokens.where((t) => t.isRolledOut && t.fbToken != firebaseToken).toList();
    Logger.info('Updating firebase token for ${tokenList.length} push tokens.');
    bool allUpdated = true;
    final List<PushToken> failedTokens = [];
    final List<PushToken> unsuportedTokens = [];

    for (PushToken p in tokenList) {
      if (p.url == null) {
        unsuportedTokens.add(p);
        continue;
      }
      // POST /ttype/push HTTP/1.1
      //Host: example.com
      //
      //new_fb_token=<new firebase token>
      //serial=<tokenserial>element
      //timestamp=<timestamp>
      //signature=SIGNATURE(<new firebase token>|<tokenserial>|<timestamp>)
      Logger.warning('Updating firebase token for push token "${p.serial}"');
      String timestamp = DateTime.now().toUtc().toIso8601String();
      String message = '$firebaseToken|${p.serial}|$timestamp';
      String? signature = await _rsaUtils.trySignWithToken(p, message);
      if (signature == null) {
        failedTokens.add(p);
        allUpdated = false;
        continue;
      }
      Response response = await _ioClient.doPost(
        url: p.url!,
        body: {'new_fb_token': firebaseToken, 'serial': p.serial, 'timestamp': timestamp, 'signature': signature},
        sslVerify: p.sslVerify,
      );
      if (response.statusCode == 200) {
        Logger.info('Updating firebase token for push token succeeded!');
        _updateToken(p, (p0) => p0.copyWith(fbToken: firebaseToken));
      } else {
        Logger.warning('Updating firebase token for push token failed!');
        failedTokens.add(p);
        allUpdated = false;
      }
    }

    if (allUpdated) {
      await _firebaseUtils.setCurrentFirebaseToken(firebaseToken);
    }
    return (failedTokens, unsuportedTokens);
  }

  /* ////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Add New Tokens Methods //////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  /// Does not need to wait for updating functions because they doesn't depend on any state */

  Future<void> handleLink(Uri uri) async {
    final tokenResults = await TokenImportSchemeProcessor.processUriByAny(uri);
    if (tokenResults == null) return;
    await handleProcessorResults(tokenResults, {'TokenOriginSourceType': TokenOriginSourceType.link});
  }

  @override
  Future<void> handleProcessorResult(ProcessorResult result, Map<String, dynamic> args) {
    if (result is ProcessorResult<Token>) {
      return handleProcessorResults([result], args);
    }
    return Future.value();
  }

  @override
  Future handleProcessorResults(List<ProcessorResult> results, Map<String, dynamic> args) async {
    final List<ProcessorResult<Token>> tokenResults = results.whereType<ProcessorResult<Token>>().toList();
    if (tokenResults.isEmpty) return;
    final List<Token> resultTokens = tokenResults.getData();
    final stateTokens = state.tokens;
    final tokenOriginSourceType = (args['TokenOriginSourceType'] as TokenOriginSourceType?);
    var tokenImportType = (args['TokenImportType'] as TokenImportType?) ?? TokenImportType.qrScan;
    try {
      if (resultTokens.length > 1 || stateTokens.any((e) => resultTokens.first.isSameTokenAs(e) == true)) {
        // Navigator.of(globalNavigatorKey.currentContext!).popUntil((route) => route.isFirst);
        _showImportTokensPage(tokenResults, tokenOriginSourceType!, tokenImportType);
        return;
      }
    } catch (error, stackTrace) {
      Logger.error('Error while processing QR code.', error: error, stackTrace: stackTrace);
      return;
    }
    final tokensWithSourceType = _addSourceType(resultTokens, tokenOriginSourceType);
    addNewTokens(tokensWithSourceType);
  }

/* /////////////////////////////////////////////////////////////////////////////
///////////////////////////// Helper Methods ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////// */

  List<Token> _filterDuplicates(List<Token> tokens) {
    final uniqueTokens = <Token>[];
    for (var token in tokens) {
      if (!uniqueTokens.any((uniqureToken) => uniqureToken.isSameTokenAs(token) == true)) {
        uniqueTokens.add(token);
      }
    }
    return uniqueTokens;
  }

  Future<void> _showImportTokensPage(
    List<ProcessorResult<Token>> tokenResults,
    TokenOriginSourceType tokenOriginSourceType,
    TokenImportType tokenImportType,
  ) async {
    final tokensToKeep = await Navigator.of(globalNavigatorKey.currentContext!).push<List<Token>>(
      MaterialPageRoute<List<Token>>(
        builder: (context) => ImportPlainTokensPage(
          titleName: AppLocalizations.of(context)!.importTokens,
          processorResults: tokenResults,
          selectedType: tokenImportType,
        ),
      ),
    );
    if (tokensToKeep == null) return;
    final tokensWithSourceType = _addSourceType(tokensToKeep, tokenOriginSourceType);
    await addNewTokens(tokensWithSourceType);
  }

  List<Token> _addSourceType(List<Token> tokens, TokenOriginSourceType? tokenOriginSourceType) => tokens
      .map((e) => e.copyWith(
            origin: e.origin?.copyWith(source: tokenOriginSourceType) ??
                TokenOriginSourceType.unknown.toTokenOrigin(data: 'No Origindata available', isPrivacyIdeaToken: null),
          ))
      .toList();

  Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
    Logger.info('Parsing rollout response, try to extract public_key.');
    try {
      String key = json.decode(response.body)['detail']['public_key'];
      key = key.replaceAll('\n', '');

      Logger.info('Extracting public key was successful.');

      return _rsaUtils.deserializeRSAPublicKeyPKCS1(key);
    } on FormatException catch (e) {
      throw FormatException('Response body does not contain RSA public key.', e);
    }
  }

  Future<void> _handlePushTokensIfExist() async {
    Logger.info('Handling push tokens if they exist.');
    final pushTokens = state.pushTokens;
    if (pushTokens.isEmpty || state.pushTokens.isEmpty) {
      if ((await ref.read(settingsProvider.future)).hidePushTokens == true) {
        ref.read(settingsProvider.notifier).setHidePushTokens(false);
      }
    }
    if (pushTokens.firstWhereOrNull((element) => element.isRolledOut && element.fbToken == null) != null) {
      // If there is a push token without fbToken, then update the fbToken
      await updateFirebaseToken();
    }
    if (state.hasRolledOutPushTokens) {
      checkNotificationPermission();
    }
    for (final element in state.pushTokensToRollOut) {
      Logger.info('Handling push token "${element.id}"');
      await rolloutPushToken(element);
    }
  }

  Token? getTokenById(String id) {
    return state.tokens.firstWhereOrNull((element) => element.id == id);
  }

  void _cancelTimers() {
    for (final key in _hidingTimers.keys) {
      _hidingTimers[key]?.cancel();
    }
    _hidingTimers.clear();
  }
}
