import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:base32/base32.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import '../model/push_request.dart';
import '../model/states/token_state.dart';
import '../model/tokens/hotp_token.dart';
import '../model/tokens/push_token.dart';
import '../model/tokens/token.dart';
import '../model/tokens/totp_token.dart';
import '../utils/crypto_utils.dart';
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

  void refreshTokens() {
    _loadTokenList();
  }

  Future<void> _loadTokenList() async {
    List<Token> tokens = await StorageUtil.loadAllTokens();
    state = TokenState(tokens: tokens);
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
      Map<String, dynamic> qrParameterMap = parseQRCodeToMap(otpAuth);

      Token? newToken = await _buildTokenFromMap(uriMap: qrParameterMap, uri: Uri.parse(otpAuth), context: context);

      if (newToken == null) {
        Logger.warning(
          'Could not build token from qrParameterMap',
          name: 'token_notifier.dart#addTokenFromQRCode',
          error: qrParameterMap,
        );
        return;
      }

      if (newToken.pin != null && newToken.pin != false) {
        Logger.info(
          'New token has a pin. Locking token.',
          name: 'token_notifier.dart#token_notifier',
        );
        newToken = newToken.copyWith(isLocked: true);
      }

      if (newToken is PushToken && state.tokens.contains(newToken)) {
        showMessage(message: 'A token with the serial ${newToken.serial} already exists!', duration: const Duration(seconds: 2), context: context);
        return;
      }

      if (newToken is PushToken) {
        _rollOutToken(newToken, context);
      }

      addToken(newToken);
    } on ArgumentError catch (e) {
      // Error while parsing qr code.
      Logger.warning(
        'Malformed QR code:',
        name: 'main_screen.dart#_handleOtpAuth',
        error: e.stackTrace,
      );

      showMessage(
          message: '${e.message}\n Please inform the creator of this qr code about the problem.', duration: const Duration(seconds: 8), context: context);
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
      if (token.url == null || token.sslVerify == null) {
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
      final timeUntilExpiration = pr.expirationDate.difference(DateTime.now());
      Logger.warning('timeUntilExpiration: ${timeUntilExpiration.inMilliseconds} Milliseconds');
      Future.delayed(
        Duration(milliseconds: timeUntilExpiration.inMilliseconds),
        () => removePushRequest(pr),
      );
    }
  }

  void removePushRequest(PushRequest pushRequest) {
    Logger.warning('Removing push request ${pushRequest.id}');
    PushToken? token = state.tokens.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pushRequest.serial);

    if (token == null) {
      Logger.warning('The requested token does not exist.', name: 'main_screen.dart#_handleIncomingChallenge', error: pushRequest.serial);
      return;
    }
    token = token.withoutPushRequest(pushRequest);
    updateToken(token);
    Logger.info('Removed push request ${pushRequest.id} to token ${token.id}', name: 'main_screen.dart#_handleIncomingChallenge');
  }

  /// Builds and returns a token from a given map, that contains all necessary fields.
  Future<Token?> _buildTokenFromMap({required Map<String, dynamic> uriMap, required Uri uri, required BuildContext context}) async {
    String uuid = const Uuid().v4();
    String type = uriMap[URI_TYPE];

    // Push token do not need any of the other parameters.
    if (equalsIgnoreCase(type, enumAsString(TokenTypes.PIPUSH))) {
      Uri? rolloutURL = uriMap[URI_ROLLOUT_URL];
      if (rolloutURL == null) {
        showMessage(message: "QR code did not contain rollout URL!", duration: const Duration(seconds: 3), context: context);
        return null;
      }

      return PushToken(
          serial: uriMap[URI_SERIAL],
          label: uriMap[URI_LABEL],
          issuer: uriMap[URI_ISSUER],
          id: uuid,
          sslVerify: uriMap[URI_SSL_VERIFY],
          expirationDate: DateTime.now().add(Duration(minutes: uriMap[URI_TTL])),
          enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
          url: rolloutURL,
          pin: uriMap[URI_PIN],
          tokenImage: uriMap[URI_IMAGE]);
    }

    String label = uriMap[URI_LABEL];
    String algorithm = uriMap[URI_ALGORITHM];
    int digits = uriMap[URI_DIGITS];
    Uint8List secret = uriMap[URI_SECRET];
    String issuer = uriMap[URI_ISSUER];
    bool? pin = uriMap[URI_PIN];
    String? imageURL = uriMap[URI_IMAGE];

    if (is2StepURI(uri)) {
      // Calculate the whole secret.
      secret = (await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => TwoStepDialog(
          iterations: uriMap[URI_ITERATIONS],
          keyLength: uriMap[URI_OUTPUT_LENGTH_IN_BYTES],
          saltLength: uriMap[URI_SALT_LENGTH],
          password: secret,
        ),
      ))!;
    }

    // uri.host -> totp or hotp
    if (type == 'hotp') {
      return HOTPToken(
          label: label,
          issuer: issuer,
          id: uuid,
          algorithm: mapStringToAlgorithm(algorithm),
          digits: digits,
          secret: encodeSecretAs(secret, Encodings.base32),
          counter: uriMap[URI_COUNTER],
          pin: pin);
    } else if (type == 'totp') {
      return TOTPToken(
          label: label,
          issuer: issuer,
          id: uuid,
          algorithm: mapStringToAlgorithm(algorithm),
          digits: digits,
          imageURL: imageURL,
          secret: encodeSecretAs(secret, Encodings.base32),
          period: uriMap[URI_PERIOD],
          pin: pin);
    } else {
      throw ArgumentError.value(
          uri,
          'uri',
          'Building the token type '
              '[$type] is not a supported right now.');
    }
  }

  void _rollOutToken(PushToken token, BuildContext context) async {
    if (Platform.isIOS) {
      await dummyRequest(url: token.url!, sslVerify: token.sslVerify!);
    }

    if (token.privateTokenKey == null) {
      final keyPair = await generateRSAKeyPair();

      Logger.info(
        'Setting private key for token',
        name: 'token_widgets.dart#_rollOutToken',
        error: 'Token: $token, key: ${keyPair.privateKey}',
      );
      Logger.warning('Setting private key for token.$token', name: 'token_widgets.dart#_rollOutToken', error: keyPair.privateKey);
      token = token.withPrivateTokenKey(keyPair.privateKey);
      Logger.warning('Setting public key for token.$token', name: 'token_widgets.dart#_rollOutToken', error: keyPair.publicKey);
      token = token.withPublicTokenKey(keyPair.publicKey);
      Logger.warning('Set public and private key for token.$token', name: 'token_widgets.dart#_rollOutToken');
      updateToken(token);
      Logger.warning('Updated token.$token', name: 'token_widgets.dart#_rollOutToken', error: keyPair.publicKey);

      checkNotificationPermission();
    }

    try {
      // TODO What to do with poll only tokens if google-services is used?
      Response response = await postRequest(sslVerify: token.sslVerify!, url: token.url!, body: {
        'enrollment_credential': token.enrollmentCredentials,
        'serial': token.serial,
        'fbtoken': await PushProvider.getFBToken(),
        'pubkey': serializeRSAPublicKeyPKCS8(token.rsaPublicTokenKey!),
      });

      if (response.statusCode == 200) {
        RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
        token = token.withPublicServerKey(publicServerKey);

        Logger.info('Roll out successful', name: 'token_widgets.dart#_rollOutToken', error: token);

        token = token.copyWith(isRolledOut: true);
        updateToken(token);
      } else {
        Logger.warning('Post request on roll out failed.',
            name: 'token_widgets.dart#_rollOutToken',
            error: 'Token: ${token.serial}\nStatus code: ${response.statusCode},\nURL:${response.request?.url}\nBody: ${response.body}');
        showMessage(
          context: context,
          message: AppLocalizations.of(context)!.errorRollOutFailed(token.label, response.statusCode),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (e is PlatformException && e.code == FIREBASE_TOKEN_ERROR_CODE || e is SocketException) {
        Logger.warning('Connection error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#_rollOutToken', error: e);
        showMessage(
          context: context,
          message: AppLocalizations.of(context)?.errorRollOutNoNetworkConnection ?? "No network connection!",
          duration: const Duration(seconds: 3),
        );
      } else {
        Logger.warning('Unknown error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#_rollOutToken', error: e);
        showMessage(
          context: context,
          message: AppLocalizations.of(context)!.errorRollOutUnknownError(e),
          duration: const Duration(seconds: 3),
        );
      }
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
