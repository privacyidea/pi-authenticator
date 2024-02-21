import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:base32/base32.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:pointycastle/asymmetric/api.dart';
import '../model/enums/token_origin_source_type.dart';

import '../interfaces/repo/token_repository.dart';
import '../l10n/app_localizations.dart';
import '../model/enums/push_token_rollout_state.dart';
import '../model/push_request.dart';
import '../model/states/token_state.dart';
import '../model/tokens/hotp_token.dart';
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
  static final Map<String, Timer> _timers = {};
  late Future<TokenState> loadingRepo;
  late Future<List<Token>?> updatingTokens = Future(() => null);
  final TokenRepository _repo;
  final RsaUtils _rsaUtils;
  final LegacyUtils _legacy;
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
        _legacy = legacy ?? const LegacyUtils(),
        _ioClient = ioClient ?? const PrivacyIdeaIOClient(),
        _firebaseUtils = firebaseUtils ?? FirebaseUtils(),
        super(
          initialState ?? TokenState(),
        ) {
    _init();
  }

  Future<void> _init() async {
    await _loadFromRepo();
    await loadingRepo;
    Logger.info('TokenNotifier initialized.', name: 'token_notifier.dart#_init');
  }

  /////////////////////////////////////////////////////////////////////////////
  /////////////////////// Repository and Token Handling ///////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /// Always waits for other repo methods

  Future<List<Token>> _addOrReplaceTokens(List<Token> tokens) async {
    state = state.addOrReplaceTokens(tokens);
    await loadingRepo;
    loadingRepo = Future(() async {
      final failedTokens = await _repo.saveOrReplaceTokens(state.lastlyUpdatedTokens);
      if (failedTokens.isNotEmpty) {
        Logger.warning(
          'Saving tokens failed. Failed Tokens: ${failedTokens.length}',
          name: 'token_notifier.dart#_saveOrReplaceTokens',
        );
        final newState = state.addOrReplaceTokens(failedTokens);
        state = newState;
        return newState;
      }
      return state;
    });
    return (await loadingRepo).lastlyUpdatedTokens;
  }

  Future<List<Token>> _replaceTokens(List<Token> tokens) async {
    state = state.replaceTokens(tokens);
    await loadingRepo;
    loadingRepo = Future(() async {
      final failedTokens = await _repo.saveOrReplaceTokens(state.lastlyUpdatedTokens);
      if (failedTokens.isNotEmpty) {
        Logger.warning(
          'Saving tokens failed. Failed Tokens: ${failedTokens.length}',
          name: 'token_notifier.dart#_saveOrReplaceTokens',
        );
        final newState = state.addOrReplaceTokens(failedTokens);
        state = newState;
        return newState;
      }
      return state;
    });
    return (await loadingRepo).lastlyUpdatedTokens;
  }

  Future<bool> _removeToken(Token token) async {
    await loadingRepo;
    state = state.withoutToken(token);
    loadingRepo = Future(() async {
      final failedTokens = await _repo.deleteTokens([token]);
      if (failedTokens.isNotEmpty) {
        Logger.warning(
          'Deleting tokens failed. Failed Tokens: ${failedTokens.length}',
          name: 'token_notifier.dart#_deleteTokensRepo',
        );
        final newState = state.addOrReplaceTokens(failedTokens);
        state = newState;
        return newState;
      }
      return state;
    });
    final failedTokens = (await loadingRepo).lastlyUpdatedTokens;
    await _handlePushTokensIfExist();
    return failedTokens.isEmpty;
  }

  Future<TokenState> _loadFromRepo() async {
    log('_loadFromRepo');
    List<Token> tokens;
    loadingRepo = Future(
      () async {
        try {
          tokens = await _repo.loadTokens();
          TokenState newState = TokenState(tokens: tokens);
          state = newState;
          return newState;
        } catch (_) {
          return Future(() => state);
        }
      },
    );
    final newState = await loadingRepo;
    await _handlePushTokensIfExist();
    return newState;
  }

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Update Token Methods ///////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  /// Always waits for repo and other updating methods

  Future<T?> updateToken<T extends Token>(T token, T Function(T) updater) async {
    await updatingTokens;
    updatingTokens = Future(() async {
      await loadingRepo;
      final current = state.currentOf<T>(token);
      if (current == null) {
        Logger.warning('Tried to update a token that does not exist.', name: 'token_notifier.dart#updateToken');
        return null;
      }
      final updated = updater(current);
      return _replaceTokens([updated]);
    });
    return (await updatingTokens)?.whereType<T>().firstOrNull;
  }

  Future<List<T>> updateTokens<T extends Token>(List<T> tokens, T Function(T) updater) async {
    await updatingTokens;
    updatingTokens = Future(() async {
      await loadingRepo;
      List<T> updatedTokens = [];
      for (final token in tokens) {
        final current = state.currentOf<T>(token) ?? token;
        updatedTokens.add(updater(current));
      }
      await _replaceTokens(updatedTokens);
      return updatedTokens;
    });
    return (await updatingTokens)?.whereType<T>().toList() ?? [];
  }

  Future<void> incrementCounter(HOTPToken token) async {
    await updatingTokens;
    updatingTokens = Future(() async {
      await loadingRepo;
      token = state.currentOf(token)?.copyWith(counter: token.counter + 1) ?? token.copyWith(counter: token.counter + 1);
      return await _replaceTokens([token]);
    });
    await updatingTokens;
  }

  Future<void> hideToken(Token token) async {
    await updatingTokens;
    updatingTokens = Future(() async {
      await loadingRepo;
      token = state.currentOf(token)?.copyWith(isHidden: true) ?? token.copyWith(isHidden: true);
      return await _replaceTokens([token]);
    });
    await updatingTokens;
  }

  Future<bool> showToken(Token token) async {
    await updatingTokens;
    log('showToken');
    updatingTokens = Future(() async {
      final authenticated = await lockAuth(localizedReason: AppLocalizations.of(globalNavigatorKey.currentContext!)!.authenticateToShowOtp);
      log('authenticated: $authenticated');
      if (!authenticated) return null;
      await loadingRepo;
      token = state.currentOf(token)?.copyWith(isHidden: false) ?? token.copyWith(isHidden: false);
      log('token: $token');
      return _addOrReplaceTokens([token]);
    });
    final authenticated = (await updatingTokens)?.isNotEmpty ?? false;
    log('authenticated_2: $authenticated');
    _timers[token.id]?.cancel();
    _timers[token.id] = Timer(token.showDuration, () async {
      log('hideToken');
      await hideToken(token);
      log('hideToken_2');
    });
    return authenticated;
  }

  Future<bool> showTokenById(String tokenId) async {
    await updatingTokens;
    final token = getTokenFromId(tokenId);
    if (token != null) {
      return await showToken(token);
    }
    return false;
  }

  Future<void> addOrReplaceToken(Token token) async {
    await updatingTokens;
    updatingTokens = Future(() async {
      await loadingRepo;
      return _addOrReplaceTokens([token]);
    });
    await updatingTokens;
  }

  Future<void> addOrReplaceTokens(List<Token> updatedTokens) async {
    await updatingTokens;
    updatingTokens = Future(() async {
      await loadingRepo;
      return _addOrReplaceTokens(updatedTokens);
    });
    await updatingTokens;
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////// UI Interaction Methods //////////////////////////////
  /////// These methods are used to interact with the UI and the user. /////////
  //////////////////////////////////////////////////////////////////////////////
  /// Always waits for updating Functions to use the latest state

  Future<TokenState?> loadStateFromRepo() async {
    log("loadStateFromRepo");
    await updatingTokens;
    log("loadStateFromRepo_2");
    try {
      return await _loadFromRepo();
    } catch (_) {
      Logger.warning('Loading tokens from storage failed.', name: 'token_notifier.dart#loadStateFromRepo');
      return null;
    }
  }

  Future<bool> saveStateToRepo() async {
    await updatingTokens;
    _cancelTimers();
    try {
      await _repo.saveOrReplaceTokens(state.tokens);
      Logger.info('Saved ${state.tokens.length} Tokens to storage.', name: 'token_notifier.dart#saveStateToRepo');
      return true;
    } catch (_) {
      Logger.warning('Saving tokens to storage failed.', name: 'token_notifier.dart#saveStateToRepo');
      return false;
    }
  }

  Future<void> removeToken(Token token) async {
    await _removeToken(token);
  }

  Future<bool> addPushRequestToToken(PushRequest pr) async {
    await updatingTokens;
    PushToken? token = state.tokens.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pr.serial && t.isRolledOut);
    Logger.info('Adding push request to token', name: 'token_notifier.dart#addPushRequestToToken');
    if (token == null) {
      Logger.warning('The requested token does not exist or is not rolled out.', name: 'token_notifier.dart#addPushRequestToToken');
      return false;
    }
    String signature = pr.signature;
    String signedData = '${pr.nonce}|'
        '${pr.uri}|'
        '${pr.serial}|'
        '${pr.question}|'
        '${pr.title}|'
        '${pr.sslVerify ? '1' : '0'}';

    // Re-add url and sslverify to android legacy tokens:
    if (token.url == null) {
      token = await updateToken(token, (p0) => p0.copyWith(url: pr.uri, sslVerify: pr.sslVerify));
    }
    if (token == null) {
      Logger.warning('The requested token does not exist anymore', name: 'token_notifier.dart#addPushRequestToToken');
      return false;
    }

    bool isVerified = token.privateTokenKey == null
        ? await _legacy.verify(token.serial, signedData, signature)
        : _rsaUtils.verifyRSASignature(token.rsaPublicServerKey!, utf8.encode(signedData), base32.decode(signature));

    if (!isVerified) {
      Logger.warning(
        'Validating incoming message failed.',
        name: 'token_notifier.dart#addPushRequestToToken',
        error: 'Signature does not match signed data.',
      );
      return false;
    }
    Logger.info('Validating incoming message was successful.', name: 'token_notifier.dart#addPushRequestToToken');

    if (token.knowsRequestWithId(pr.id)) {
      Logger.info(
        'The push request already exists.',
        name: 'token_notifier.dart#addPushRequestToToken',
      );
      return false;
    }
    // Save the pending request.
    token = await updateToken(token, (p0) => p0.withPushRequest(pr)) ?? token;

    // Remove the request after it expires.
    int time = pr.expirationDate.difference(DateTime.now()).inMilliseconds;
    Future.delayed(Duration(milliseconds: time < 1 ? 1 : time), () async => globalRef?.read(tokenProvider.notifier).removePushRequest(pr));
    Logger.info('Added push request ${pr.id} to token ${token.id}', name: 'token_notifier.dart#addPushRequestToToken');

    return true;
  }

  Future<bool> removePushRequest(PushRequest pushRequest) async {
    await updatingTokens;
    Logger.info('Removing push request ${pushRequest.id}');
    PushToken? token = state.tokens.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pushRequest.serial);

    if (token == null) {
      Logger.warning('The requested token with serial "${pushRequest.serial}" does not exist.', name: 'token_notifier.dart#removePushRequest');
      return false;
    }
    token = await updateToken<PushToken>(token, (p0) => p0.withoutPushRequest(pushRequest)) ?? token;

    Logger.info('Removed push request from token ${token.id}', name: 'token_notifier.dart#removePushRequest');
    return true;
  }

  Future<bool> rolloutPushToken(PushToken token) async {
    await updatingTokens;
    token = (getTokenFromId(token.id)) as PushToken? ?? token;
    assert(token.url != null, 'Token url is null. Cannot rollout token without url.');
    Logger.info('Rolling out token "${token.id}"', name: 'token_notifier.dart#rolloutPushToken');
    if (token.isRolledOut) {
      Logger.info('Ignoring rollout request: Token "${token.id}" already rolled out.', name: 'token_notifier.dart#rolloutPushToken');
      return true;
    }
    if (token.rolloutState.rollOutInProgress) {
      Logger.info('Ignoring rollout request: Rollout of token "${token.id}" already started. Tokenstate: ${token.rolloutState} ',
          name: 'token_notifier.dart#rolloutPushToken');
      return false;
    }
    if (token.expirationDate?.isBefore(DateTime.now()) == true) {
      Logger.info('Ignoring rollout request: Token "${token.id}" is expired. ', name: 'token_notifier.dart#rolloutPushToken');

      if (globalNavigatorKey.currentContext != null) {
        globalRef?.read(statusMessageProvider.notifier).state = (
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutNotPossibleAnymore,
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorTokenExpired(token.label),
        );
      }
      _removeToken(token);
      return false;
    }

    if (token.privateTokenKey == null) {
      Logger.info('Updating rollout state of token "${token.id}" to generatingRSAKeyPair', name: 'token_notifier.dart#rolloutPushToken');
      token = await updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPair)) ?? token;
      Logger.info('Updated token "${token.id}"', name: 'token_notifier.dart#rolloutPushToken');
      try {
        final keyPair = await _rsaUtils.generateRSAKeyPair();
        token = token.withPrivateTokenKey(keyPair.privateKey);
        token = token.withPublicTokenKey(keyPair.publicKey);
        token = await updateToken(token, (p0) {
              p0 = p0.withPrivateTokenKey(keyPair.privateKey);
              return p0.withPublicTokenKey(keyPair.publicKey);
            }) ??
            token;
        Logger.info('Updated token "${token.id}"', name: 'token_notifier.dart#rolloutPushToken');
      } catch (e, s) {
        Logger.error('Error while generating RSA key pair.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
        token = await updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPairFailed)) ?? token;
        return false;
      }
    }

    token = await updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKey)) ?? token;
    if (!kIsWeb && Platform.isIOS) {
      Logger.warning('Triggering network access permission for token "${token.id}"', name: 'token_notifier.dart#rolloutPushToken');
      if (await _ioClient.triggerNetworkAccessPermission(url: token.url!, sslVerify: token.sslVerify) == false) {
        Logger.warning('Network access permission for token "${token.id}" failed.', name: 'token_notifier.dart#rolloutPushToken');
        updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
        return false;
      }
      Logger.warning('Network access permission for token "${token.id}" successful.', name: 'token_notifier.dart#rolloutPushToken');
    }
    try {
      // TODO What to do with poll only tokens if google-services is used?

      Logger.warning('SSLVerify: ${token.sslVerify}', name: 'token_notifier.dart#rolloutPushToken');
      Response response = await _ioClient.doPost(
        sslVerify: token.sslVerify,
        url: token.url!,
        body: {
          'enrollment_credential': token.enrollmentCredentials,
          'serial': token.serial,
          'fbtoken': await _firebaseUtils.getFBToken(),
          'pubkey': _rsaUtils.serializeRSAPublicKeyPKCS8(token.rsaPublicTokenKey!),
        },
      );

      if (response.statusCode == 200) {
        token = await updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.parsingResponse)) ?? token;
        try {
          RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
          token = await updateToken(token, (p0) => p0.withPublicServerKey(publicServerKey)) ?? token;
        } on FormatException catch (e, s) {
          showMessage(message: "Couldn't parsing RSA public key: ${e.message}", duration: const Duration(seconds: 3));

          Logger.warning('Error while parsing RSA public key.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
          token = await updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.parsingResponseFailed)) ?? token;
          return false;
        }
        Logger.info('Roll out successful', name: 'token_notifier.dart#rolloutPushToken');
        token = await updateToken(token, (p0) => p0.copyWith(isRolledOut: true, rolloutState: PushTokenRollOutState.rolloutComplete)) ?? token;
        checkNotificationPermission();

        return true;
      } else {
        Logger.warning('Post request on roll out failed.',
            name: 'token_notifier.dart#rolloutPushToken',
            error: 'Token: ${token.serial}\nStatus code: ${response.statusCode},\nURL:${response.request?.url}\nBody: ${response.body}');

        try {
          final message = response.body.isNotEmpty ? (json.decode(response.body)['result']?['error']?['message']) : '';
          globalRef?.read(statusMessageProvider.notifier).state = (
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutFailed(token.label),
            message,
          );
        } on FormatException {
          // Format Exception is thrown if the response body is not a valid json. This happens if the server is not reachable.

          globalRef?.read(statusMessageProvider.notifier).state = (
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutFailed(token.label),
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.statusCode(response.statusCode)
          );
        }

        token = await updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed)) ?? token;
        return false;
      }
    } catch (e, s) {
      token = await updateToken(token, (p0) => p0.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed)) ?? token;
      if (e is PlatformException && e.code == FIREBASE_TOKEN_ERROR_CODE || e is SocketException || e is TimeoutException || e is FirebaseException) {
        Logger.warning('Connection error: Roll out push token failed.', name: 'token_notifier.dart#rolloutPushToken', error: e, stackTrace: s);
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutNoConnectionToServer(token.label),
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

  /////////////////////////////////////////////////////////////////////////////
  //////////////////////// Add New Tokens Methods /////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /// Does not need to wait for updating functions because they doesn't depend on any state

  // The return value of a qrCode could be any object. In this case should be a String that is a valid URI.
  // If it is not a valid URI, the user will be informed.
  Future<void> handleQrCode(Object? qrCode) async {
    Uri uri;
    try {
      qrCode as String;
      uri = Uri.parse(qrCode);
    } catch (_) {
      showMessage(message: 'The scanned QR code is not a valid URI.', duration: const Duration(seconds: 3));
      return;
    }
    List<Token> tokens = await _tokensFromUri(uri);
    tokens = tokens.map((e) => TokenOriginSourceType.qrScan.addOriginToToken(token: e, data: qrCode)).toList();
    await addOrReplaceTokens(tokens);
    await _handlePushTokensIfExist();
  }

  Future<void> handleLink(Uri uri) async {
    List<Token> tokens = await _tokensFromUri(uri);
    tokens = tokens.map((e) => TokenOriginSourceType.link.addOriginToToken(token: e, data: uri.toString())).toList();
    await addOrReplaceTokens(tokens);
    await _handlePushTokensIfExist();
  }

  Future<List<Token>> _tokensFromUri(Uri uri) async {
    List<Token>? tokens;
    try {
      tokens = await TokenImportSchemeProcessor.processUriByAny(uri);
    } catch (_) {}
    return tokens ?? [];
  }

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Helper Methods /////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

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
    await loadingRepo;
    if (state.hasPushTokens == false || state.hasOTPTokens == false) {
      if (globalRef?.read(settingsProvider).hidePushTokens == true) {
        globalRef!.read(settingsProvider.notifier).setHidePushTokens(false);
      }
    }
    if (state.hasRolledOutPushTokens) {
      checkNotificationPermission();
    }
    for (final element in state.pushTokensToRollOut) {
      Logger.info('Handling push token "${element.id}"', name: 'token_notifier.dart#_handlePushTokensIfExist');
      await rolloutPushToken(element);
    }
  }

  Token? getTokenFromId(String id) {
    return state.tokens.firstWhereOrNull((element) => element.id == id);
  }

  void _cancelTimers() {
    for (final key in _timers.keys) {
      _timers[key]?.cancel();
    }
    _timers.clear();
  }
}
