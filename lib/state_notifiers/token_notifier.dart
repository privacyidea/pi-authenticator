import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:mutex/mutex.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../interfaces/repo/token_repository.dart';
import '../l10n/app_localizations.dart';
import '../model/enums/push_token_rollout_state.dart';
import '../model/enums/token_origin_source_type.dart';
import '../model/extensions/enums/push_token_rollout_state_extension.dart';
import '../model/extensions/enums/token_origin_source_type.dart';
import '../model/processor_result.dart';
import '../model/states/token_state.dart';
import '../model/tokens/hotp_token.dart';
import '../model/tokens/otp_token.dart';
import '../model/tokens/push_token.dart';
import '../model/tokens/token.dart';
import '../processors/scheme_processors/token_import_scheme_processors/token_import_scheme_processor_interface.dart';
import '../repo/secure_token_repository.dart';
import '../utils/firebase_utils.dart';
import '../utils/globals.dart';
import '../utils/home_widget_utils.dart';
import '../utils/identifiers.dart';
import '../utils/lock_auth.dart';
import '../utils/logger.dart';
import '../utils/network_utils.dart';
import '../utils/riverpod_providers.dart';
import '../utils/rsa_utils.dart';
import '../utils/utils.dart';
import '../utils/view_utils.dart';

class TokenNotifier extends StateNotifier<TokenState> {
  static final Map<String, Timer> _hidingTimers = {};
  late final Future<TokenState> initState;
  final _loadingRepoMutex = Mutex();
  final _updatingTokensMutex = Mutex();
  final TokenRepository _repo;
  final RsaUtils _rsaUtils;
  final PrivacyIdeaIOClient _ioClient;
  final FirebaseUtils _firebaseUtils;

  TokenNotifier({
    TokenState? initialState,
    TokenRepository? repository,
    RsaUtils? rsaUtils,
    LegacyUtils? legacy,
    PrivacyIdeaIOClient? ioClient,
    FirebaseUtils? firebaseUtils,
    HomeWidgetUtils? homeWidgetUtils,
  })  : _rsaUtils = rsaUtils ?? const RsaUtils(),
        _repo = repository ?? const SecureTokenRepository(),
        _ioClient = ioClient ?? const PrivacyIdeaIOClient(),
        _firebaseUtils = firebaseUtils ?? FirebaseUtils(),
        super(
          initialState ?? TokenState(tokens: const [], lastlyUpdatedTokens: const []),
        ) {
    _init(initialState);
  }

  Future<void> _init(TokenState? initialState) async {
    initState = initialState != null ? Future.value(initialState) : _loadFromRepo();
    await initState;
    await hideLockedTokens();
    Logger.info('TokenNotifier initialized.', name: 'token_notifier.dart#_init');
  }

  /*
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////// Repository and Token Handling ///////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /// Repository layer is always use loadingRepoMutex for the latest state
  */

  /// Adds a token and returns true if successful, false if not.
  Future<bool> _addOrReplaceToken(Token token) async {
    await _loadingRepoMutex.acquire();
    final success = await _repo.saveOrReplaceToken(token);
    if (!success) {
      Logger.warning(
        'Saving token failed. Token: ${token.id}',
        name: 'token_notifier.dart#_addOrReplaceToken',
      );
      _loadingRepoMutex.release();
      return false;
    }
    state = state.addOrReplaceToken(token);
    _loadingRepoMutex.release();
    return true;
  }

  /// Adds a list of tokens and returns the tokens that could not be added or replaced.
  Future<List<Token>> _addOrReplaceTokens(List<Token> tokens) async {
    await _loadingRepoMutex.acquire();
    final failedTokens = await _repo.saveOrReplaceTokens(tokens);
    if (failedTokens.isNotEmpty) {
      Logger.warning(
        'Saving tokens failed. Failed Tokens: ${failedTokens.length}',
        name: 'token_notifier.dart#_saveOrReplaceTokens',
      );
      // Every token that is saved should not be in the failedTokens list
      final savedTokens = tokens.where((element) => !failedTokens.contains(element)).toList();
      state = state.addOrReplaceTokens(savedTokens);
      return failedTokens;
    }
    // [failedTokens] is empty, so every token was saved successfully and we dont need to filter the tokens
    state = state.addOrReplaceTokens(tokens);
    _loadingRepoMutex.release();
    return [];
  }

  /// Replaces a token if it exists and returns true if successful, false if not.
  Future<bool> _replaceToken(Token token) async {
    await _loadingRepoMutex.acquire();
    final (newState, replaced) = state.replaceToken(token);
    if (!replaced) {
      Logger.warning('Tried to replace a token that does not exist.', name: 'token_notifier.dart#_replaceToken');
      _loadingRepoMutex.release();
      return false;
    }
    final saved = await _repo.saveOrReplaceToken(token);
    if (!saved) {
      Logger.warning(
        'Saving token failed. Token: ${token.id}',
        name: 'token_notifier.dart#_replaceToken',
      );
      _loadingRepoMutex.release();
      return false;
    }
    state = newState;
    _loadingRepoMutex.release();
    return true;
  }

  /// Returns a list of tokens that could not be replaced
  Future<List<T>> _replaceTokens<T extends Token>(List<T> tokens) async {
    await _loadingRepoMutex.acquire();
    final oldState = state;
    final (newState, failedToReplace) = state.replaceTokens(tokens);
    state = newState;
    for (var e in failedToReplace) {
      tokens.remove(e);
    }
    final failedToSave = await _repo.saveOrReplaceTokens<T>(tokens);
    if (failedToSave.isNotEmpty) {
      Logger.warning(
        'Saving tokens failed. Failed Tokens: ${failedToSave.length}',
        name: 'token_notifier.dart#_saveOrReplaceTokens',
      );
      final recovered = oldState.tokens.whereType<T>().where((oldToken) => failedToSave.contains(oldToken)).toList();
      state = state.addOrReplaceTokens<T>(recovered);
      _loadingRepoMutex.release();
      return failedToSave;
    }
    _loadingRepoMutex.release();
    return [];
  }

  /// Removes a token and returns true if successful, false if not.
  Future<bool> _removeToken(Token token) async {
    await _loadingRepoMutex.acquire();
    state = state.withoutToken(token);

    final success = await _repo.deleteToken(token);
    if (!success) {
      Logger.warning(
        'Deleting token failed. Token: ${token.id}',
        name: 'token_notifier.dart#_deleteTokensRepo',
      );
      state = state.addOrReplaceToken(token);
      _loadingRepoMutex.release();
      return false;
    }
    _loadingRepoMutex.release();
    _handlePushTokensIfExist();
    return true;
  }

  /// Loads the tokens from the repository sets it as the new state and returns the new state.
  Future<TokenState> _loadFromRepo() async {
    await _loadingRepoMutex.acquire();
    TokenState newState;
    try {
      List<Token> tokens;
      tokens = await _repo.loadTokens();
      newState = TokenState(tokens: tokens, lastlyUpdatedTokens: tokens);
      state = newState;
    } catch (e) {
      Logger.error(
        'Loading tokens from storage failed.',
        name: 'token_notifier.dart#_loadFromRepo',
        error: e,
      );
      _loadingRepoMutex.release();
      return state;
    }
    _loadingRepoMutex.release();
    _handlePushTokensIfExist();
    return newState;
  }

  Future<bool> _saveStateToRepo(TokenState state) async {
    await _loadingRepoMutex.acquire();
    try {
      await _repo.saveOrReplaceTokens(state.tokens);
    } catch (e) {
      Logger.error(
        'Saving tokens to storage failed.',
        name: 'token_notifier.dart#_saveStateToRepo',
        error: e,
      );
      _loadingRepoMutex.release();
      return false;
    }
    _loadingRepoMutex.release();
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
    await _updatingTokensMutex.acquire();
    await _loadingRepoMutex.acquire();
    _loadingRepoMutex.release();
    final current = state.currentOf<T>(token);
    if (current == null) {
      Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#updateToken');
      _updatingTokensMutex.release();
      return null;
    }
    final updated = updater(current);
    final replaced = await _replaceToken(updated);
    _updatingTokensMutex.release();
    return replaced ? updated : current;
  }

  /// Updates a list of tokens and returns the updated tokens if successful, the old tokens if not and an empty list if the tokens does not exist.
  Future<List<T>> _updateTokens<T extends Token>(List<T> tokens, T Function(T) updater) async {
    await _updatingTokensMutex.acquire();
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
    _updatingTokensMutex.release();
    return mergedTokens;
  }

  /*
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////// UI Interaction Methods //////////////////////////////
  /////// These methods are used to interact with the UI and the user. /////////
  //////////////////////////////////////////////////////////////////////////////
  /// There is no need to use mutexes because the updating functions are always using the latest version of the updating tokens.
  */

  /// Adds or replaces a token and returns true if successful, false if not.
  Future<bool> addOrReplaceToken(Token token) => _addOrReplaceToken(token);

  /// Adds or replaces a list of tokens and returns the tokens that could not be added or replaced.
  Future<List<Token>> addOrReplaceTokens(List<Token> tokens) => _addOrReplaceTokens(tokens);

  /// Updates a token and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<T?> updateToken<T extends Token>(T token, T Function(T) updater) async => _updateToken(token, updater);

  Future<List<T>> updateTokens<T extends Token>(List<T> tokens, T Function(T) updater) async => _updateTokens(tokens, updater);

  /// Increments the counter of a HOTPToken and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<HOTPToken?> incrementCounter(HOTPToken token) => _updateToken(token, (p0) => p0.copyWith(counter: token.counter + 1));

  /// Hides a token and returns the updated token if successful, the old token if not and null if the token does not exist.
  Future<T?> hideToken<T extends Token>(T token) => _updateToken(token, (p0) => p0.copyWith(isHidden: true) as T);

  /// Shows a token and returns the updated token if successful, the old token if not and null if the token does not exist or the user is not authenticated.
  Future<T?> showToken<T extends OTPToken>(T token) async {
    final authenticated = await lockAuth(localizedReason: AppLocalizations.of(globalNavigatorKey.currentContext!)!.authenticateToShowOtp);
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
      Logger.warning('Tried to show a token that does not exist.', name: 'token_notifier.dart#showTokenById');
      return Future.value(null);
    }
    if (token is! OTPToken) {
      Logger.warning('Tried to show a token that is not an OTPToken.', name: 'token_notifier.dart#showTokenById');
      return Future.value(null);
    }
    return showToken(token);
  }

  Future<TokenState?> loadStateFromRepo() async {
    try {
      return await _loadFromRepo();
    } catch (_) {
      Logger.warning('Loading tokens from storage failed.', name: 'token_notifier.dart#loadStateFromRepo');
      return null;
    }
  }

  Future<bool> saveStateToRepo() async {
    try {
      await _saveStateToRepo(state);
      Logger.info('Saved ${state.tokens.length} Tokens to storage.', name: 'token_notifier.dart#saveStateToRepo');
      return true;
    } catch (_) {
      Logger.error('Saving tokens to storage failed.', name: 'token_notifier.dart#saveStateToRepo');
      return false;
    }
  }

  /// Minimizing the app needs to cancel all timers and save the state to the repository.
  Future<bool> saveStateOnMinimizeApp() async {
    _cancelTimers();
    await hideLockedTokens();
    return _saveStateToRepo(state);
  }

  Future<List<Token>> hideLockedTokens() async {
    final hideLockedTokens = <Token>[];
    for (var token in state.tokens) {
      if (token.isLocked && !token.isHidden) {
        hideLockedTokens.add(token);
      }
    }
    return await updateTokens(hideLockedTokens, (p0) => p0.copyWith(isHidden: true));
  }

  Future<void> removeToken(Token token) async {
    if (token is PushToken) {
      await _removePushToken(token);
      return;
    }
    await _removeToken(token);
  }

  Future<void> _removePushToken(PushToken token) async {
    try {
      await _firebaseUtils.deleteFirebaseToken();
    } on SocketException {
      Logger.warning('Could not delete firebase token.', name: 'token_notifier.dart#_removePushToken');
      globalRef?.read(statusMessageProvider.notifier).state = (
        AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorUnlinkingPushToken(token.label),
        AppLocalizations.of(globalNavigatorKey.currentContext!)!.checkYourNetwork,
      );
    }

    _firebaseUtils.getFBToken().then((fbToken) async {
      if (fbToken == null) {
        await _updateTokens(state.pushTokens, (p0) => p0.copyWith(fbToken: null));
        Logger.warning('Could not update firebase token because no firebase token is available.', name: 'token_notifier.dart#_removePushToken');
        globalRef?.read(statusMessageProvider.notifier).state = (
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorSynchronizationNoNetworkConnection,
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.pleaseSyncManuallyWhenNetworkIsAvailable,
        );
      }
      final (notUpdated, _) = (await updateFirebaseToken(fbToken)) ?? (<PushToken>[], <PushToken>[]);
      await _updateTokens(notUpdated, (p0) => p0.copyWith(fbToken: null));
      return;
    });
    await _removeToken(token);
    Logger.info('Push token "${token.id}" removed successfully.', name: 'token_notifier.dart#_removePushToken');
  }

  Future<bool> rolloutPushToken(PushToken token) async {
    PushToken? pushToken;
    pushToken = (getTokenById(token.id)) as PushToken?;
    if (pushToken == null) {
      Logger.warning('Tried to rollout a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
      return false;
    }
    assert(pushToken.url != null, 'Token url is null. Cannot rollout token without url.');
    Logger.info('Rolling out token "${pushToken.id}"', name: 'token_notifier.dart#rolloutPushToken');
    if (pushToken.isRolledOut) {
      Logger.info('Ignoring rollout request: Token "${pushToken.id}" already rolled out.', name: 'token_notifier.dart#rolloutPushToken');
      return true;
    }
    if (pushToken.rolloutState.rollOutInProgress) {
      Logger.info('Ignoring rollout request: Rollout of token "${pushToken.id}" already started. Tokenstate: ${pushToken.rolloutState} ',
          name: 'token_notifier.dart#rolloutPushToken');
      return false;
    }
    if (pushToken.expirationDate?.isBefore(DateTime.now()) == true) {
      Logger.info('Ignoring rollout request: Token "${pushToken.id}" is expired. ', name: 'token_notifier.dart#rolloutPushToken');

      if (globalNavigatorKey.currentContext != null) {
        globalRef?.read(statusMessageProvider.notifier).state = (
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutNotPossibleAnymore,
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorTokenExpired(pushToken.label),
        );
      }
      await _removeToken(pushToken);
      return false;
    }

    if (pushToken.privateTokenKey == null) {
      Logger.info('Updating rollout state of token "${pushToken.id}" to generatingRSAKeyPair', name: 'token_notifier.dart#rolloutPushToken');
      pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPair));
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
        return false;
      }
      Logger.info('Updated token "${pushToken.id}"', name: 'token_notifier.dart#rolloutPushToken');
      try {
        final keyPair = await _rsaUtils.generateRSAKeyPair();
        pushToken = pushToken.withPrivateTokenKey(keyPair.privateKey);
        pushToken = pushToken.withPublicTokenKey(keyPair.publicKey);
        pushToken = await _updateToken(pushToken, (p0) {
              p0 = p0.withPrivateTokenKey(keyPair.privateKey);
              return p0.withPublicTokenKey(keyPair.publicKey);
            }) ??
            pushToken;
        Logger.info('Updated token "${pushToken.id}"', name: 'token_notifier.dart#rolloutPushToken');
      } catch (e, s) {
        Logger.error('Error while generating RSA key pair.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
        if (pushToken == null) {
          Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
          return false;
        }
        pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPairFailed));
        return false;
      }
    }

    pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKey));
    if (pushToken == null) {
      Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
      return false;
    }
    if (!kIsWeb && Platform.isIOS) {
      Logger.warning('Triggering network access permission for token "${pushToken.id}"', name: 'token_notifier.dart#rolloutPushToken');
      if (await _ioClient.triggerNetworkAccessPermission(url: pushToken.url!, sslVerify: pushToken.sslVerify) == false) {
        Logger.warning('Network access permission for token "${pushToken.id}" failed.', name: 'token_notifier.dart#rolloutPushToken');
        _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
        return false;
      }
      Logger.warning('Network access permission for token "${pushToken.id}" successful.', name: 'token_notifier.dart#rolloutPushToken');
    }
    try {
      // TODO What to do with poll only tokens if google-services is used?

      Logger.warning('SSLVerify: ${pushToken.sslVerify}', name: 'token_notifier.dart#rolloutPushToken');
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
          Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
          return false;
        }
        try {
          RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
          pushToken = await _updateToken(pushToken, (p0) => p0.withPublicServerKey(publicServerKey));
          if (pushToken == null) {
            Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
            return false;
          }
        } on FormatException catch (e, s) {
          showMessage(message: "Couldn't parsing RSA public key: ${e.message}", duration: const Duration(seconds: 3));

          Logger.warning('Error while parsing RSA public key.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
          if (pushToken == null) {
            Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
            return false;
          }
          pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.parsingResponseFailed));
          return false;
        }
        Logger.info('Roll out successful', name: 'token_notifier.dart#rolloutPushToken');
        pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(isRolledOut: true, rolloutState: PushTokenRollOutState.rolloutComplete));
        checkNotificationPermission();

        return true;
      } else {
        Logger.warning('Post request on roll out failed.',
            name: 'token_notifier.dart#rolloutPushToken',
            error: 'Token: ${pushToken.serial}\nStatus code: ${response.statusCode},\nURL:${response.request?.url}\nBody: ${response.body}');

        try {
          final message = response.body.isNotEmpty ? (json.decode(response.body)['result']?['error']?['message']) : '';
          globalRef?.read(statusMessageProvider.notifier).state = (
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutFailed(pushToken.label),
            message,
          );
        } on FormatException {
          // Format Exception is thrown if the response body is not a valid json. This happens if the server is not reachable.

          globalRef?.read(statusMessageProvider.notifier).state = (
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutFailed(pushToken.label),
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.statusCode(response.statusCode)
          );
        }

        pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
        return false;
      }
    } catch (e, s) {
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
        return false;
      }
      pushToken = await _updateToken(pushToken, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      if (pushToken == null) {
        Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#rolloutPushToken');
        return false;
      }
      if (e is PlatformException && e.code == FIREBASE_TOKEN_ERROR_CODE || e is SocketException || e is TimeoutException || e is FirebaseException) {
        Logger.warning('Connection error: Roll out push token failed.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutNoConnectionToServer(pushToken.label),
          duration: const Duration(seconds: 3),
        );
      } else if (e is HandshakeException) {
        Logger.warning('SSL error: Roll out push token failed.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutSSLHandshakeFailed,
          duration: const Duration(seconds: 3),
        );
      } else {
        if (globalNavigatorKey.currentContext != null) {
          showMessage(
            message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutUnknownError(e),
            duration: const Duration(seconds: 3),
          );
        }
        Logger.error('Roll out push token failed.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
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
    firebaseToken ??= await _firebaseUtils.getFBToken();
    if (firebaseToken == null) {
      Logger.warning('Could not update firebase token because no firebase token is available.', name: 'push_provider.dart#updateFirebaseToken');
      return null;
    }
    List<PushToken> tokenList = state.pushTokens.where((t) => t.isRolledOut && t.fbToken != firebaseToken).toList();
    Logger.info('Updating firebase token for ${tokenList.length} push tokens.', name: 'push_provider.dart#updateFirebaseToken');
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
      Logger.warning('Updating firebase token for push token "${p.serial}"', name: 'push_provider.dart#updateFirebaseToken');
      String timestamp = DateTime.now().toUtc().toIso8601String();
      String message = '$firebaseToken|${p.serial}|$timestamp';
      String? signature = await const RsaUtils().trySignWithToken(p, message);
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
        Logger.info('Updating firebase token for push token succeeded!', name: 'push_provider.dart#updateFirebaseToken');
        _updateToken(p, (p0) => p0.copyWith(fbToken: firebaseToken));
      } else {
        Logger.warning('Updating firebase token for push token failed!', name: 'push_provider.dart#updateFirebaseToken');
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

  /// The return value of a qrCode could be any object. In this case should be a String that is a valid URI.
  /// If it is not a valid URI, the user will be informed.
  Future<void> handleQrCode(Object? qrCode) async {
    Uri uri;
    try {
      qrCode as String;
      uri = Uri.parse(qrCode);
    } catch (_) {
      showMessage(message: 'The scanned QR code is not a valid URI.', duration: const Duration(seconds: 3));
      Logger.warning('Scanned Data: $qrCode', error: 'Scanned QR code is not a valid URI.', name: 'token_notifier.dart#handleQrCode');
      return;
    }
    List<Token> tokens = await _tokensFromUri(uri);
    tokens = tokens
        .map((e) => e.copyWith(
            origin: e.origin?.copyWith(source: TokenOriginSourceType.qrScan) ??
                TokenOriginSourceType.qrScan.toTokenOrigin(data: uri.toString(), isPrivacyIdeaToken: null)))
        .toList();
    await _addOrReplaceTokens(tokens);
    await _handlePushTokensIfExist();
  }

  Future<void> handleLink(Uri uri) async {
    List<Token> tokens = await _tokensFromUri(uri);
    tokens = tokens
        .map((e) => e.copyWith(
            origin: e.origin?.copyWith(source: TokenOriginSourceType.link) ??
                TokenOriginSourceType.link.toTokenOrigin(data: uri.toString(), isPrivacyIdeaToken: null)))
        .toList();
    await _addOrReplaceTokens(tokens);
    await _handlePushTokensIfExist();
  }

  Future<List<Token>> _tokensFromUri(Uri uri) async {
    try {
      final results = await TokenImportSchemeProcessor.processUriByAny(uri);
      return results?.whereType<ProcessorResultSuccess<Token>>().map((e) => e.resultData).toList() ?? [];
    } catch (error, stackTrace) {
      showMessage(message: 'The scanned QR code is not a valid URI.', duration: const Duration(seconds: 3));
      Logger.warning('Scanned Data: $uri', error: error, name: 'token_notifier.dart#handleQrCode', stackTrace: stackTrace);
      return [];
    }
  }

  /* /////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Helper Methods /////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////// */

  Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
    Logger.info('Parsing rollout response, try to extract public_key.', name: 'token_notifier.dart#_parseRollOutResponse');
    try {
      String key = json.decode(response.body)['detail']['public_key'];
      key = key.replaceAll('\n', '');

      Logger.info('Extracting public key was successful.', name: 'token_notifier.dart#_parseRollOutResponse');

      return _rsaUtils.deserializeRSAPublicKeyPKCS1(key);
    } on FormatException catch (e) {
      throw FormatException('Response body does not contain RSA public key.', e);
    }
  }

  Future<void> _handlePushTokensIfExist() async {
    final pushTokens = state.pushTokens;
    if (pushTokens.isNotEmpty || state.hasOTPTokens == false) {
      if (globalRef?.read(settingsProvider).hidePushTokens == true) {
        globalRef!.read(settingsProvider.notifier).setHidePushTokens(false);
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
      Logger.info('Handling push token "${element.id}"', name: 'token_notifier.dart#_handlePushTokensIfExist');
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
