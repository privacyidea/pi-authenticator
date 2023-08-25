import 'dart:async';
import 'dart:convert';
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
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';

import '../model/push_request.dart';
import '../model/states/token_state.dart';
import '../model/tokens/hotp_token.dart';
import '../model/tokens/push_token.dart';
import '../model/tokens/token.dart';
import '../utils/crypto_utils.dart';
import '../utils/customizations.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';
import '../utils/network_utils.dart';
import '../utils/parsing_utils.dart';
import '../utils/push_provider.dart';
import '../utils/storage_utils.dart';
import '../utils/utils.dart';
import '../utils/view_utils.dart';
import '../widgets/two_step_dialog.dart';

class TokenNotifier extends StateNotifier<TokenState> {
  TokenNotifier({TokenState? initialState})
      : super(
          initialState ?? const TokenState(),
        ) {
    _loadTokenList();
  }

  Future<void> _loadTokenList() async {
    List<Token> tokens = await StorageUtil.loadAllTokens();
    final pushTokens = tokens.whereType<PushToken>().where((element) => !element.isRolledOut).toList();
    state = TokenState(tokens: tokens);
    for (final pushToken in pushTokens) {
      rolloutPushToken(pushToken);
    }
  }

  void refreshTokens() async {
    List<Token> tokens = await StorageUtil.loadAllTokens();
    final rolledOutPushToken = tokens.whereType<PushToken>().where((element) => element.isRolledOut).toList();
    state = state.updateTokens(rolledOutPushToken);
  }

  Token? getTokenFromId(String id) {
    return state.tokens.firstWhereOrNull((element) => element.id == id);
  }

  void incrementCounter(HOTPToken token) {
    token = token.copyWith(counter: token.counter + 1);
    state = state.updateToken(token);
    StorageUtil.saveOrReplaceToken(token);
  }

  void addToken(Token token) {
    state = state.withToken(token);
    StorageUtil.saveOrReplaceToken(token);
  }

  void addTokens(List<Token> tokens) {
    state = state.withTokens(tokens);
    for (final token in tokens) {
      StorageUtil.saveOrReplaceToken(token);
    }
  }

  void removeToken(Token token) {
    state = state.withoutToken(token);
    StorageUtil.deleteToken(token);
  }

  void removeTokens(List<Token> tokens) {
    state = state.withoutTokens(tokens);
    for (final token in tokens) {
      StorageUtil.deleteToken(token);
    }
  }

  PushToken removePushTokenBySerial(String serial) {
    final token = state.tokens.firstWhere((element) => element is PushToken && element.serial == serial);
    state = state.withoutToken(token);
    return token as PushToken;
  }

  Token removeTokenById(String id) {
    final token = state.tokens.firstWhere((element) => element.id == id);
    state = state.withoutToken(token);
    return token;
  }

  List<Token> removeTokensByIds(List<String> ids) {
    final tempTokens = List<Token>.from(state.tokens);
    final tokensToRemove = tempTokens.where((element) => ids.contains(element.id)).toList();
    removeTokens(tokensToRemove);
    return tokensToRemove;
  }

  void updateToken(Token token) {
    state = state.updateToken(token);
    StorageUtil.saveOrReplaceToken(token);
  }

  void updateTokens(List<Token> updatedTokens) {
    state = state.updateTokens(updatedTokens);
    for (Token token in updatedTokens) {
      StorageUtil.saveOrReplaceToken(token);
    }
  }

  void addTokenFromOtpAuth({required String otpAuth, required BuildContext context}) async {
    Logger.info(
      'Try to handle otpAuth:',
      name: 'token_notifier.dart#addTokenFromOtpAuth',
      error: otpAuth,
    );

    try {
      Map<String, dynamic> uriMap = parseQRCodeToMap(otpAuth);

      if (is2StepURI(Uri.parse(otpAuth))) {
        // Calculate the whole secret.
        uriMap[URI_SECRET] = (await showDialog<Uint8List>(
          context: context,
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
        return;
      }

      if (newToken is PushToken && state.tokens.contains(newToken)) {
        showMessage(message: 'A token with the serial ${newToken.serial} already exists!', duration: const Duration(seconds: 2));
        return;
      }
      addToken(newToken);
      if (newToken is PushToken) {
        rolloutPushToken(newToken);
      }
    } on ArgumentError catch (e, s) {
      // Error while parsing qr code.
      Logger.warning('Malformed QR code:', name: 'main_screen.dart#_handleOtpAuth', error: e, stackTrace: s);

      showMessage(message: '${e.message}\n Please inform the creator of this qr code about the problem.', duration: const Duration(seconds: 8));
    }
  }

  Future<void> addPushRequestToToken(PushRequest pr) async {
    PushToken? token = state.tokens.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pr.serial && t.isRolledOut);

    if (token == null) {
      Logger.warning('The requested token does not exist or is not rolled out.', name: 'main_screen.dart#_handleIncomingChallenge', error: pr.serial);
    } else {
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
          ? await Legacy.verify(token.serial, signedData, signature)
          : verifyRSASignature(token.rsaPublicServerKey!, utf8.encode(signedData) as Uint8List, base32.decode(signature));

      if (!isVerified) {
        Logger.warning(
          'Validating incoming message failed.',
          name: 'main_screen.dart#_handleIncomingChallenge',
          error: 'Signature $signature does not match signed data: $signedData',
        );
        return;
      }
      Logger.info('Validating incoming message was successful.', name: 'main_screen.dart#_handleIncomingChallenge');

      if (token.knowsRequestWithId(pr.id)) {
        Logger.info(
          'The push request ${pr.id} already exists '
          'for the token with serial ${token.serial}',
          name: 'main_screen.dart#_handleIncomingChallenge',
        );
        return;
      }
      // Save the pending request.
      token = token.withPushRequest(pr);
      updateToken(token);
      Logger.info('Added push request ${pr.id} to token ${token.id}', name: 'main_screen.dart#_handleIncomingChallenge');
    }
  }

  void removePushRequest(PushRequest pushRequest) {
    Logger.info('Removing push request ${pushRequest.id}');
    PushToken? token = state.tokens.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pushRequest.serial);

    if (token == null) {
      Logger.warning('The requested token does not exist.', name: 'main_screen.dart#_handleIncomingChallenge', error: pushRequest.serial);
      return;
    }
    token = token.withoutPushRequest(pushRequest);
    updateToken(token);
    Logger.info('Removed push request ${pushRequest.id} from token ${token.id}', name: 'main_screen.dart#_handleIncomingChallenge');
  }

  Future<bool> rolloutPushToken(PushToken token) async {
    token = getTokenFromId(token.id) as PushToken? ?? token;
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
      showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutTokenExpired(token.label), duration: const Duration(seconds: 3));
      globalRef!.read(tokenProvider.notifier).removeToken(token);
      return false;
    }
    if (Platform.isIOS) {
      await dummyRequest(url: token.url!, sslVerify: token.sslVerify);
    }

    if (token.privateTokenKey == null) {
      updateToken(token.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPair));
      try {
        final keyPair = await generateRSAKeyPair();
        token = token.withPrivateTokenKey(keyPair.privateKey);
        token = token.withPublicTokenKey(keyPair.publicKey);
        updateToken(token);
        Logger.info('Updated token.${token.id}', name: 'token_widgets.dart#rolloutPushToken', error: keyPair.publicKey);
        checkNotificationPermission();
      } catch (e, s) {
        Logger.warning('Error while generating RSA key pair.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        updateToken(token.copyWith(rolloutState: PushTokenRollOutState.generatingRSAKeyPairFailed));
        return false;
      }
    }

    updateToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKey));
    try {
      // TODO What to do with poll only tokens if google-services is used?
      Response response = await doPost(sslVerify: token.sslVerify, url: token.url!, body: {
        'enrollment_credential': token.enrollmentCredentials,
        'serial': token.serial,
        'fbtoken': await PushProvider.getFBToken(),
        'pubkey': serializeRSAPublicKeyPKCS8(token.rsaPublicTokenKey!),
      });

      if (response.statusCode == 200) {
        updateToken(token.copyWith(rolloutState: PushTokenRollOutState.parsingResponse));
        try {
          RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
          token = token.withPublicServerKey(publicServerKey);
        } on FormatException catch (e, s) {
          showMessage(message: "Couldn't parsing RSA public key: ${e.message}", duration: const Duration(seconds: 3));
          Logger.warning('Error while parsing RSA public key.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
          updateToken(token.copyWith(rolloutState: PushTokenRollOutState.parsingResponseFailed));
          return false;
        } finally {
          Logger.info('Roll out successful', name: 'token_widgets.dart#rolloutPushToken', error: token);
          token = token.copyWith(isRolledOut: true, rolloutState: PushTokenRollOutState.rolloutComplete);
          updateToken(token);
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
        updateToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
        return false;
      }
    } catch (e, s) {
      if (e is PlatformException && e.code == FIREBASE_TOKEN_ERROR_CODE || e is SocketException || e is TimeoutException || e is FirebaseException) {
        Logger.warning('Connection error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutNoConnectionToServer(token.label),
          duration: const Duration(seconds: 3),
        );
        updateToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      } else if (e is HandshakeException) {
        Logger.warning('SSL error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutSSLHandshakeFailed,
          duration: const Duration(seconds: 3),
        );
        updateToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      } else {
        showMessage(
          message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorRollOutUnknownError(e),
          duration: const Duration(seconds: 3),
        );
        Logger.error('Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#rolloutPushToken', error: e, stackTrace: s);
        updateToken(token.copyWith(rolloutState: PushTokenRollOutState.sendRSAPublicKeyFailed));
      }
      return false;
    }
  }
}

Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
  Logger.info('Parsing rollout response, try to extract public_key.', name: 'token_widgets.dart#_parseRollOutResponse', error: response.body);

  try {
    String key = json.decode(response.body)['detail']['public_key'];
    key = key.replaceAll('\n', '');

    Logger.info('Extracting public key was successful.', name: 'token_widgets.dart#_parseRollOutResponse', error: key);

    return deserializeRSAPublicKeyPKCS1(key);
  } on FormatException catch (e) {
    throw FormatException('Response body does not contain RSA public key.', e);
  }
}
