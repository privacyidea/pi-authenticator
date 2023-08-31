import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:base32/base32.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:pointycastle/asymmetric/api.dart';
import '../utils/firebase_utils.dart';
import '../utils/network_utils.dart';
import '../utils/qr_parser.dart';
import '../utils/rsa_utils.dart';

import '../model/push_request.dart';
import '../model/states/token_state.dart';
import '../model/tokens/hotp_token.dart';
import '../model/tokens/push_token.dart';
import '../model/tokens/token.dart';
import '../utils/customizations.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';
import '../utils/riverpod_providers.dart';
import '../utils/storage_utils.dart';
import '../utils/utils.dart';
import '../utils/view_utils.dart';
import '../widgets/two_step_dialog.dart';

class TokenNotifier extends StateNotifier<TokenState> {
  late final Future<void> isInitialized;
  final TokenRepository _repo;
  final QrParser _qrParser;
  final RsaUtils _rsaUtils;
  final LegacyUtils _legacy;
  final CustomIOClient _ioClient;
  final FirebaseUtils _firebaseUtils;

  TokenNotifier({
    TokenState? initialState,
    TokenRepository? repository,
    QrParser? qrParser,
    RsaUtils? rsaUtils,
    LegacyUtils? legacy,
    CustomIOClient? ioClient,
    FirebaseUtils? firebaseUtils,
  })  : _rsaUtils = rsaUtils ?? const RsaUtils(),
        _qrParser = qrParser ?? const QrParser(),
        _repo = repository ?? const TokenRepository(),
        _legacy = legacy ?? const LegacyUtils(),
        _ioClient = ioClient ?? const CustomIOClient(),
        _firebaseUtils = firebaseUtils ?? FirebaseUtils(),
        super(
          initialState ?? TokenState(),
        ) {
    isInitialized = Future(() => _loadTokenList());
  }

  Future<bool> _loadTokenList() async {
    List<Token> tokens;
    try {
      tokens = await _repo.loadAllTokens();
    } catch (_) {
      return false;
    }
    final pushTokens = tokens.whereType<PushToken>().where((element) => !element.isRolledOut).toList();
    state = TokenState(tokens: tokens);
    for (final pushToken in pushTokens) {
      rolloutPushToken(pushToken);
    }
    return true;
  }

  Future<bool> refreshRolledOutPushTokens() async {
    await isInitialized;
    List<Token> tokens;
    try {
      tokens = await _repo.loadAllTokens();
    } catch (_) {
      return false;
    }
    final rolledOutPushToken = tokens.whereType<PushToken>().where((element) => element.isRolledOut).toList();
    state = state.addOrReplaceTokens(rolledOutPushToken);
    return true;
  }

  Future<Token?> getTokenFromId(String id) async {
    await isInitialized;
    return state.tokens.firstWhereOrNull((element) => element.id == id);
  }

  Future<bool> incrementCounter(HOTPToken token) async {
    token = token.copyWith(counter: token.counter + 1);
    if (await _repo.saveOrReplaceToken(token)) {
      state = state.addOrReplaceToken(token);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeToken(Token token) async {
    await isInitialized;
    if (await _repo.deleteToken(token)) {
      state = state.withoutToken(token);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addOrReplaceToken(Token token) async {
    await isInitialized;
    if (await _repo.saveOrReplaceToken(token)) {
      state = state.addOrReplaceToken(token);
      return true;
    } else {
      return false;
    }
  }

  /// Returns all tokens that could not be saved.
  Future<List<Token>> addOrReplaceTokens(List<Token> updatedTokens) async {
    await isInitialized;
    final failedTokens = await _repo.saveOrReplaceTokens(updatedTokens);
    log('Updated tokens: $updatedTokens');
    log('Failed tokens: $failedTokens');
    for (var element in failedTokens) {
      updatedTokens.remove(element);
    }
    log('Updated tokens: $updatedTokens');
    state = state.addOrReplaceTokens(updatedTokens);
    return failedTokens;
  }

  Future<bool> addTokenFromOtpAuth({required String otpAuth}) async {
    await isInitialized;
    Logger.info(
      'Try to handle otpAuth:',
      name: 'token_notifier.dart#addTokenFromOtpAuth',
      error: otpAuth,
    );

    try {
      Map<String, dynamic> uriMap = _qrParser.parseQRCodeToMap(otpAuth);

      if (_qrParser.is2StepURI(Uri.parse(otpAuth))) {
        // Calculate the whole secret.
        uriMap[URI_SECRET] = (await showDialog<Uint8List>(
          context: globalNavigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (BuildContext context) => TwoStepDialog(
            iterations: uriMap[URI_ITERATIONS],
            keyLength: uriMap[URI_OUTPUT_LENGTH_IN_BYTES],
            saltLength: uriMap[URI_SALT_LENGTH],
            password: uriMap[URI_SECRET],
          ),
        ))!;
      }
      Token newToken;
      try {
        newToken = Token.fromUriMap(uriMap);
      } on FormatException catch (e) {
        Logger.warning('Error while parsing otpAuth.', name: 'token_notifier.dart#addTokenFromOtpAuth', error: e);
        showMessage(message: e.message, duration: const Duration(seconds: 3));
        return false;
      }

      if (newToken is PushToken && state.tokens.contains(newToken)) {
        showMessage(message: 'A token with the serial ${newToken.serial} already exists!', duration: const Duration(seconds: 2));
        return false;
      }
      final success = await addOrReplaceToken(newToken);
      if (success && newToken is PushToken) {
        rolloutPushToken(newToken);
      }
      return success;
    } on ArgumentError catch (e, s) {
      // Error while parsing qr code.
      Logger.warning('Malformed QR code:', name: 'main_screen.dart#_handleOtpAuth', error: e, stackTrace: s);
      showMessage(message: '${e.message}\n Please inform the creator of this qr code about the problem.', duration: const Duration(seconds: 8));
      return false;
    }
  }

  Future<bool> addPushRequestToToken(PushRequest pr) async {
    await isInitialized;
    PushToken? token = state.tokens.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pr.serial && t.isRolledOut);

    if (token == null) {
      Logger.warning('The requested token does not exist or is not rolled out.', name: 'main_screen.dart#_handleIncomingChallenge', error: pr.serial);
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
      token = token.copyWith(url: pr.uri, sslVerify: pr.sslVerify);
    }

    bool isVerified = token.privateTokenKey == null
        ? await _legacy.verify(token.serial, signedData, signature)
        : _rsaUtils.verifyRSASignature(token.rsaPublicServerKey!, utf8.encode(signedData) as Uint8List, base32.decode(signature));

    if (!isVerified) {
      Logger.warning(
        'Validating incoming message failed.',
        name: 'main_screen.dart#_handleIncomingChallenge',
        error: 'Signature $signature does not match signed data: $signedData',
      );
      return false;
    }
    Logger.info('Validating incoming message was successful.', name: 'main_screen.dart#_handleIncomingChallenge');

    if (token.knowsRequestWithId(pr.id)) {
      Logger.info(
        'The push request ${pr.id} already exists '
        'for the token with serial ${token.serial}',
        name: 'main_screen.dart#_handleIncomingChallenge',
      );
      return false;
    }
    // Save the pending request.
    token = token.withPushRequest(pr);
    if (!await addOrReplaceToken(token)) {
      Logger.warning('Could not add push request ${pr.id} to token ${token.id}', name: 'main_screen.dart#_handleIncomingChallenge');
      return false;
    }
    Logger.info('Added push request ${pr.id} to token ${token.id}', name: 'main_screen.dart#_handleIncomingChallenge');
    return true;
  }

  Future<bool> removePushRequest(PushRequest pushRequest) async {
    await isInitialized;
    Logger.info('Removing push request ${pushRequest.id}');
    PushToken? token = state.tokens.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pushRequest.serial);

    if (token == null) {
      Logger.warning('The requested token does not exist.', name: 'main_screen.dart#_handleIncomingChallenge', error: pushRequest.serial);
      return false;
    }
    token = token.withoutPushRequest(pushRequest);
    if (!await addOrReplaceToken(token)) {
      Logger.warning('Could not remove push request ${pushRequest.id} from token ${token.id}', name: 'main_screen.dart#_handleIncomingChallenge');
      return false;
    }
    Logger.info('Removed push request ${pushRequest.id} from token ${token.id}', name: 'main_screen.dart#_handleIncomingChallenge');
    return true;
  }

  Future<bool> rolloutPushToken(PushToken token) async {
    await isInitialized;
    token = (await getTokenFromId(token.id)) as PushToken? ?? token;
    assert(token.url != null, 'Token url is null. Cannot rollout token without url.');
    if (token.isRolledOut) return true;
    if (token.rolloutState != PushTokenRollOutState.rolloutNotStarted &&
        token.rolloutState != PushTokenRollOutState.generatingRSAKeyPairFailed &&
        token.rolloutState != PushTokenRollOutState.sendRSAPublicKeyFailed &&
        token.rolloutState != PushTokenRollOutState.parsingResponseFailed) {
      Logger.info('Ignoring rollout request: Rollout of token ${token.serial} already started. Tokenstate: ${token.rolloutState} ',
          name: 'token_widgets.dart#rolloutPushToken');
      return false;
    }
    if (token.expirationDate?.isBefore(DateTime.now()) == true) {
      Logger.info('Ignoring rollout request: Token ${token.serial} is expired. ', name: 'token_widgets.dart#rolloutPushToken');
      if (globalNavigatorKey.currentContext != null) {
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutTokenExpired(token.label),
          duration: const Duration(seconds: 3),
        );
      }
      globalRef?.read(tokenProvider.notifier).removeToken(token);
      return false;
    }
    if (Platform.isIOS) {
      await _ioClient.triggerNetworkAccessPermission(url: token.url!, sslVerify: token.sslVerify);
    }

    if (token.privateTokenKey == null) {
      addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPair));
      try {
        final keyPair = await _rsaUtils.generateRSAKeyPair();
        token = token.withPrivateTokenKey(keyPair.privateKey);
        token = token.withPublicTokenKey(keyPair.publicKey);
        addOrReplaceToken(token);
        Logger.info('Updated token.${token.id}', name: 'token_widgets.dart#rolloutPushToken', error: keyPair.publicKey);
        checkNotificationPermission();
      } catch (e, s) {
        Logger.warning('Error while generating RSA key pair.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPairFailed));
        return false;
      }
    }

    addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKey));
    try {
      // TODO What to do with poll only tokens if google-services is used?
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
        addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.parsingResponse));
        try {
          RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
          token = token.withPublicServerKey(publicServerKey);
        } on FormatException catch (e, s) {
          showMessage(message: "Couldn't parsing RSA public key: ${e.message}", duration: const Duration(seconds: 3));
          Logger.warning('Error while parsing RSA public key.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
          addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.parsingResponseFailed));
          return false;
        } finally {
          Logger.info('Roll out successful', name: 'token_widgets.dart#rolloutPushToken', error: token);
          token = token.copyWith(isRolledOut: true, rolloutState: PushTokenRollOutState.rolloutComplete);
          addOrReplaceToken(token);
        }
        return true;
      } else {
        Logger.warning('Post request on roll out failed.',
            name: 'token_widgets.dart#rolloutPushToken',
            error: 'Token: ${token.serial}\nStatus code: ${response.statusCode},\nURL:${response.request?.url}\nBody: ${response.body}');

        String? message;
        try {
          message = response.body.isNotEmpty ? (json.decode(response.body)['result']?['error']?['message']) : null;
        } on FormatException catch (_) {
          message = AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutNoConnectionToServer(token.label);
        }
        message = message != null ? '\n$message' : '';
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutFailed(token.label, response.statusCode) + message,
          duration: const Duration(seconds: 3),
        );
        addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
        return false;
      }
    } catch (e, s) {
      if (e is PlatformException && e.code == FIREBASE_TOKEN_ERROR_CODE || e is SocketException || e is TimeoutException || e is FirebaseException) {
        Logger.warning('Connection error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutNoConnectionToServer(token.label),
          duration: const Duration(seconds: 3),
        );
        addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      } else if (e is HandshakeException) {
        Logger.warning('SSL error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutSSLHandshakeFailed,
          duration: const Duration(seconds: 3),
        );
        addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      } else {
        if (globalNavigatorKey.currentContext != null) {
          showMessage(
            message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutUnknownError(e),
            duration: const Duration(seconds: 3),
          );
        }
        Logger.error('Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        addOrReplaceToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      }
      return false;
    }
  }

  Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
    await isInitialized;
    Logger.info('Parsing rollout response, try to extract public_key.', name: 'token_widgets.dart#_parseRollOutResponse', error: response.body);
    try {
      String key = json.decode(response.body)['detail']['public_key'];
      key = key.replaceAll('\n', '');

      Logger.info('Extracting public key was successful.', name: 'token_widgets.dart#_parseRollOutResponse', error: key);

      return _rsaUtils.deserializeRSAPublicKeyPKCS1(key);
    } on FormatException catch (e) {
      throw FormatException('Response body does not contain RSA public key.', e);
    }
  }
}
