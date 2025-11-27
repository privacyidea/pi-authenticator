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
import 'package:mutex/mutex.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/model/extensions/token_list_extension.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/localization_notifier.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
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
import '../../../http_status_checker.dart';
import '../../../lock_auth.dart';
import '../../../logger.dart';
import '../../../privacyidea_io_client.dart';
import '../../../rsa_utils.dart';
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
    TokenRepository? repoOverride,
    RsaUtils? rsaUtilsOverride,
    PrivacyideaIOClient? ioClientOverride,
    FirebaseUtils? firebaseUtilsOverride,
  }) : _repoOverride = repoOverride,
       _rsaUtilsOverride = rsaUtilsOverride,
       _ioClientOverride = ioClientOverride,
       _firebaseUtilsOverride = firebaseUtilsOverride;

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
    await _stateMutex.acquire();
    final newState = await _loadStateFromRepo();
    _stateMutex.release();
    return newState;
  }
  //   /*
  //   /////////////////////////////////////////////////////////////////////////////
  //   /////////////////////// Repository and Token Handling ///////////////////////
  //   /////////////////////////////////////////////////////////////////////////////
  //   /// Repository layer is always use _repoMutex for the latest state
  //   */

  /// Loads the tokens from the repository and returns them as a [TokenState].
  Future<TokenState> _loadStateFromRepo() async {
    await _repoMutex.acquire();
    final tokens = await repo.loadTokens();
    final newState = TokenState(tokens: tokens, lastlyUpdatedTokens: tokens);
    _repoMutex.release();
    return newState;
  }

  /// Adds a token and returns true if successful, false if not.
  /// Updates repo and state.
  Future<bool> _addOrReplaceToken(Token token) async {
    await _repoMutex.acquire();
    final success = await repo.saveOrReplaceToken(token);
    _repoMutex.release();
    await _stateMutex.acquire();
    final currentId = (await future).currentOf(token)?.id;
    if (currentId != null) {
      token = token.copyWith(id: currentId);
    }
    if (!success) {
      Logger.warning('Saving token failed. Token: ${token.id}');
      _stateMutex.release();
      return false;
    }
    state = AsyncValue.data((await future).addOrReplaceToken(token));
    _stateMutex.release();
    return true;
  }

  /// Adds a list of tokens and returns the tokens that could not be added or replaced.
  /// Updates repo and state.
  Future<List<Token>> _addOrReplaceTokens(List<Token> tokens) async {
    await _stateMutex.acquire();
    tokens = [...tokens, ...(await future).tokens].filterDuplicates();
    if (tokens.isEmpty) {
      _stateMutex.release();
      return [];
    }
    Logger.debug('Adding ${tokens.length} tokens.', verbose: true);
    // We set currentState because the map function cant be async
    final currentState = await future;
    tokens = tokens.map((token) {
      final currentId = currentState.currentOf(token)?.id;
      if (currentId != null) return token.copyWith(id: currentId);
      return token;
    }).toList();
    await _repoMutex.acquire();
    final failedTokens = await repo.saveOrReplaceTokens(tokens);
    _repoMutex.release();
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
    state = AsyncValue.data((await future).addOrReplaceTokens(savedTokens));
    Logger.debug('New State: ${(await future).tokens.length} Tokens');
    _stateMutex.release();
    return [];
  }

  /// Replaces a token if it exists and returns true if successful, false if not.
  /// Updates repo and state.
  Future<bool> _replaceToken(Token token) async {
    await _stateMutex.acquire();
    final (newState, replaced) = (await future).replaceToken(token);
    if (!replaced) {
      Logger.warning('Tried to replace a token that does not exist.');
      _stateMutex.release();
      return false;
    }
    await _repoMutex.acquire();
    final saved = await repo.saveOrReplaceToken(token);
    _repoMutex.release();
    if (!saved) {
      Logger.warning('Saving token failed. Token: ${token.id}');
      _stateMutex.release();
      return false;
    }
    state = AsyncValue.data(newState);
    _stateMutex.release();
    return true;
  }

  /// Returns a list of tokens that could not be replaced
  /// Updates repo and state.
  Future<List<T>> _replaceTokens<T extends Token>(List<T> tokens) async {
    await _stateMutex.acquire();
    final failedToReplace = (await future).replaceTokens(tokens);
    if (failedToReplace.isNotEmpty) {
      Logger.warning('Failed to replace ${failedToReplace.length} tokens');
      _stateMutex.release();
      return failedToReplace;
    }
    tokens = tokens
        .where((element) => !failedToReplace.contains(element))
        .toList();
    await _repoMutex.acquire();
    final failedToSave = await repo.saveOrReplaceTokens<T>(tokens);
    _repoMutex.release();
    if (failedToSave.isNotEmpty) {
      Logger.warning('Failed to save ${failedToSave.length} tokens');
    }
    tokens = tokens
        .where((element) => !failedToSave.contains(element))
        .toList();
    state = AsyncValue.data((await future).addOrReplaceTokens(tokens));
    _stateMutex.release();
    return [];
  }

  /// Removes a token and returns true if successful, false if not.
  Future<bool> _removeToken(Token token) async {
    await _repoMutex.acquire();
    final success = await repo.deleteToken(token);
    _repoMutex.release();
    if (!success) {
      Logger.warning('Deleting token failed. Token: ${token.id}');
      return false;
    }
    await _stateMutex.acquire();
    state = AsyncValue.data((await future).withoutToken(token));
    _stateMutex.release();
    await _handlePushTokensIfExist();
    return true;
  }

  /// Removes a list of tokens and returns the tokens that could not be removed.
  Future<List<Token>> _removeTokens(List<Token> tokens) async {
    if (tokens.isEmpty) return [];
    Logger.info('Removing ${tokens.length} tokens.');
    await _repoMutex.acquire();
    final failedTokens = await repo.deleteTokens(tokens);
    _repoMutex.release();
    if (failedTokens.isNotEmpty) {
      Logger.warning(
        'Deleting tokens failed. Failed Tokens: ${failedTokens.length}',
      );
      return failedTokens;
    }
    tokens = tokens
        .where((element) => !failedTokens.contains(element))
        .toList();
    await _stateMutex.acquire();
    state = AsyncValue.data((await future).withoutTokens(tokens));
    _stateMutex.release();
    await _handlePushTokensIfExist();
    return [];
  }

  /// Loads the tokens from the repository sets it as the new state and returns the new(await future).
  Future<TokenState> _updateStateFromRepo() async {
    TokenState newState;

    try {
      await _stateMutex.acquire();
      List<Token> tokens;
      await _repoMutex.acquire();
      tokens = await repo.loadTokens();
      _repoMutex.release();
      newState = TokenState(tokens: tokens, lastlyUpdatedTokens: tokens);
      state = AsyncValue.data(newState);
      _stateMutex.release();
    } catch (e) {
      Logger.error('Loading tokens from storage failed.', error: e);
      _stateMutex.release();
      return (await future);
    }
    await _handlePushTokensIfExist();
    return newState;
  }

  Future<bool> _saveStateToRepo() async {
    try {
      await _repoMutex.acquire();
      await repo.saveOrReplaceTokens((await future).tokens);
      _repoMutex.release();
    } catch (e) {
      Logger.error('Saving tokens to storage failed.', error: e);
      return false;
    }
    return true;
  }

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
    final current = (await future).currentOf<T>(token);
    if (current == null) {
      Logger.warning('Tried to update a token that does not exist.');
      return null;
    }
    final updated = updater(current);
    final replaced = await _replaceToken(updated);
    return replaced ? updated : current;
  }

  /// Updates a list of tokens and returns the updated tokens if successful.
  /// Returns the old tokens if not and an empty list if the tokens does not exist.
  Future<List<T>> _updateTokens<T extends Token>(
    List<T> tokens,
    T Function(T) updater,
  ) async {
    if (tokens.isEmpty) return [];
    List<T> updatedTokens = [];
    for (final token in tokens) {
      final current = (await future).currentOf<T>(token) ?? token;
      updatedTokens.add(updater(current));
    }

    await _replaceTokens(updatedTokens);

    final newState = (await future);
    return newState.tokens
        .whereType<T>()
        .where((stateToken) => tokens.contains(stateToken))
        .toList();
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
    final authenticated = await lockAuth(
      localization: ref.read(localizationProvider),
      reason: (localization) => localization.authenticateToShowOtp,
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
      return Future.value(null);
    }
    return showToken(token);
  }

  Future<TokenState?> loadStateFromRepo() async {
    try {
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
    final otherTokens = tokens.whereType<Token>().toList();
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
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) =>
            localization.errorUnlinkingPushToken(token.label),
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
      await _updateTokens(
        (await future).pushTokens,
        (p0) => p0.copyWith(fbToken: null),
      );
      Logger.warning(
        'Could not update firebase token because no firebase token is available.',
      );
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) =>
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
    await _updateTokens(notUpdated, (p0) => p0.copyWith(fbToken: null));
    if (notUpdated.isNotEmpty) {
      Logger.warning(
        'Could not update firebase token for ${notUpdated.length} tokens.',
      );
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) =>
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

    assert(
      pushToken.url != null,
      'Token url is null. Cannot rollout token without url.',
    );
    Logger.info('Rolling out token "${pushToken.id}"');
    if (pushToken.isRolledOut) {
      Logger.info(
        'Ignoring rollout request: Token "${pushToken.id}" already rolled out.',
      );
      return true;
    }
    if (pushToken.rolloutState.rollOutInProgress) {
      Logger.info(
        'Ignoring rollout request: Rollout of token "${pushToken.id}" already started. Tokenstate: ${pushToken.rolloutState} ',
      );
      return false;
    }
    if (pushToken.expirationDate?.isBefore(DateTime.now()) == true) {
      Logger.info(
        'Ignoring rollout request: Token "${pushToken.id}" is expired. ',
      );

      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) => localization.errorRollOutNotPossibleAnymore,
        details: (localization) =>
            localization.errorTokenExpired(pushToken!.label),
      );

      await _removeToken(pushToken);
      return false;
    }

    if (pushToken.privateTokenKey == null) {
      Logger.info(
        'Updating rollout state of token "${pushToken.id}" to generatingRSAKeyPair',
      );
      pushToken = await _updateToken(
        pushToken,
        (p0) => p0.copyWith(
          rolloutState: PushTokenRollOutState.generatingRSAKeyPair,
        ),
      );
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
      Logger.info('Updated token "${pushToken.id}"');
      try {
        final keyPair = await rsaUtils.generateRSAKeyPair();
        pushToken = pushToken.withPrivateTokenKey(keyPair.privateKey);
        pushToken = pushToken.withPublicTokenKey(keyPair.publicKey);
        pushToken =
            await _updateToken(pushToken, (p0) {
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
        pushToken = await _updateToken(
          pushToken,
          (p0) => p0.copyWith(
            rolloutState: PushTokenRollOutState.generatingRSAKeyPairFailed,
          ),
        );
        return false;
      }
    }
    String? fbToken;
    if (pushToken.isPollOnly != true) {
      pushToken = await _updateToken(
        pushToken,
        (p0) => p0.copyWith(
          rolloutState: PushTokenRollOutState.receivingFirebaseToken,
        ),
      );
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
      try {
        fbToken = await firebaseUtils.getFBToken();
      } catch (e, s) {
        Logger.warning(
          'Could not get firebase token.',
          error: e,
          stackTrace: s,
        );
        showErrorStatusMessage(
          message: (l) => l.errorRollOutFailed(pushToken!.label),
          details: (l) => l.noFbToken,
        );
        pushToken = await _updateToken(
          pushToken,
          (p0) => p0.copyWith(
            rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed,
          ),
        );
        if (pushToken == null)
          Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
    }
    pushToken = await _updateToken(
      pushToken,
      (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKey),
    );
    if (pushToken == null) {
      Logger.warning('Tried to update a token that does not exist.');
      return false;
    }
    if (!kIsWeb && Platform.isIOS) {
      Logger.warning(
        'Triggering network access permission for token "${pushToken.id}"',
      );
      if (!await ioClient.triggerNetworkAccessPermission(
        url: pushToken.url!,
        sslVerify: pushToken.sslVerify,
      )) {
        Logger.warning(
          'Network access permission for token "${pushToken.id}" failed.',
        );
        _updateToken(
          pushToken,
          (p0) => p0.copyWith(
            rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed,
          ),
        );
        return false;
      }
      Logger.warning(
        'Network access permission for token "${pushToken.id}" successful.',
      );
    }
    Response response;
    try {
      // TODO What to do with poll only tokens if google-services is used?

      Logger.info('SSLVerify: ${pushToken.sslVerify}');
      response = await ioClient.doPost(
        sslVerify: pushToken.sslVerify,
        url: pushToken.url!,
        body: {
          'enrollment_credential': pushToken.enrollmentCredentials,
          'serial': pushToken.serial,
          'fbtoken': fbToken ?? NoFirebaseUtils.NO_FIREBASE_TOKEN,
          'pubkey': rsaUtils.serializeRSAPublicKeyPKCS8(
            pushToken.rsaPublicTokenKey!,
          ),
        },
      );
    } catch (e, s) {
      pushToken = await _updateToken(
        pushToken,
        (p0) => p0.copyWith(
          rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed,
        ),
      );
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
      ref.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) =>
            localization.errorRollOutUnknownError(pushToken!.label),
      );
      Logger.error('Roll out push token failed.', error: e, stackTrace: s);
      return false;
    }

    if (HttpStatusChecker.isError(response.statusCode)) {
      Logger.warning(
        'Post request on roll out failed.',
        error:
            'Token: ${pushToken.serial}\nStatus code: ${response.statusCode},\nURL:${response.request?.url}\nBody: ${response.body}',
      );
      _showPushRolloutStatus(response, pushToken.label);
      pushToken = await _updateToken(
        pushToken,
        (p0) => p0.copyWith(
          rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed,
        ),
      );
      return false;
    }
    pushToken = await _updateToken(
      pushToken,
      (p0) => p0.copyWith(
        rolloutState: PushTokenRollOutState.parsingResponse,
        fbToken: fbToken,
      ),
    );
    if (pushToken == null) {
      Logger.warning('Tried to update a token that does not exist.');
      return false;
    }
    try {
      RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
      pushToken = await _updateToken(
        pushToken,
        (p0) => p0.withPublicServerKey(publicServerKey),
      );
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
    } on FormatException catch (e, s) {
      Logger.error(
        'Error while parsing RSA public key.',
        error: e,
        stackTrace: s,
      );
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.');
        return false;
      }
      pushToken = await _updateToken(
        pushToken,
        (p0) => p0.copyWith(
          rolloutState: PushTokenRollOutState.parsingResponseFailed,
        ),
      );
      return false;
    }
    Logger.info('Roll out successful');
    pushToken = await _updateToken(
      pushToken,
      (p0) => p0.copyWith(
        isRolledOut: true,
        rolloutState: PushTokenRollOutState.rolloutComplete,
      ),
    );
    checkNotificationPermission();

    return true;
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
    await _updateFbTokenMutex.acquire();
    final List<PushToken> failedTokens = [];
    final List<PushToken> unsuportedTokens = [];
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
              unsuportedTokens.add(token);
              continue;
            }
            final success = await updateFirebaseToken(token, firebaseToken);
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
            unsuportedTokens.add(token);
            continue;
          }
          final success = await updateFirebaseToken(token, noFbToken);
          if (!success) {
            failedTokens.add(token);
          }
        }
      }

      final allUpdated = failedTokens.isEmpty && unsuportedTokens.isEmpty;
      if (allUpdated && firebaseToken != null) {
        await firebaseUtils.setCurrentFirebaseToken(firebaseToken);
      }
    } catch (e, s) {
      Logger.error(
        'Error while updating firebase token.',
        error: e,
        stackTrace: s,
      );
      _updateFbTokenMutex.release();
      return null;
    }
    _updateFbTokenMutex.release();
    return (failedTokens, unsuportedTokens);
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
    String timestamp = DateTime.now().toUtc().toIso8601String();
    String message = '$firebaseToken|${token.serial}|$timestamp';
    String? signature = await rsaUtils.trySignWithToken(token, message);
    if (signature == null) {
      Logger.error(
        'Cannot update firebase token for push token "${token.serial}". No signature available.',
      );
      return false;
    }
    Response response = await ioClient.doPost(
      url: token.url!,
      body: {
        'new_fb_token': firebaseToken,
        'serial': token.serial,
        'timestamp': timestamp,
        'signature': signature,
      },
      sslVerify: token.sslVerify,
    );
    if (HttpStatusChecker.isError(response.statusCode)) {
      Logger.warning('Updating firebase token for push token failed!');
      return false;
    }
    Logger.info('Updating firebase token for push token succeeded!');
    _updateToken(token, (p0) => p0.copyWith(fbToken: firebaseToken));
    return true;
  }

  /* ////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Add New Tokens Methods //////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  /// Does not need to wait for updating functions because they doesn't depend on any state */

  /// Handles a link and returns true if the link was handled, false if not.
  Future<bool> handleLink(Uri uri) async {
    final tokenResults = await TokenImportSchemeProcessor.processUriByAny(uri);
    if (tokenResults == null) return false; // Not a valid token link
    if (tokenResults.isEmpty)
      return true; // Link was valid but contained no tokens
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
                isPrivacyIdeaToken: null,
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
    await _pushTokenHandlerMutex.acquire();
    try {
      if ((await future).pushTokens.isEmpty) {
        if ((await ref.read(settingsProvider.future)).hidePushTokens == true) {
          ref.read(settingsProvider.notifier).setHidePushTokens(false);
        }
        _pushTokenHandlerMutex.release();
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
      _pushTokenHandlerMutex.release();
    } finally {}
    _pushTokenHandlerMutex.release();
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
      try {
        final String message = response.body.isNotEmpty
            ? (json.decode(response.body)['result']?['error']?['message'])
            : '';
        statusMessage = StatusMessage(
          message: (localization) =>
              localization.errorRollOutFailed(tokenLabel),
          details: (_) => message.toString(),
        );
      } on FormatException {
        // Format Exception is thrown if the response body is not a valid json. This happens if the server is not reachable.

        statusMessage = StatusMessage(
          message: (localization) =>
              localization.errorRollOutFailed(tokenLabel),
          details: (localization) =>
              localization.statusCode(response.statusCode),
        );
      }
    }
    ref.read(statusMessageProvider.notifier).state = statusMessage;
  }
}
