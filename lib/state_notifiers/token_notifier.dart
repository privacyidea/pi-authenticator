import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/hotp_token/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/totp_token/totp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/two_step_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:base32/base32.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TokenNotifier extends StateNotifier<List<Token>> {
  TokenNotifier({List<Token>? initialState})
      : super(
          initialState ?? <Token>[],
        ) {
    _loadTokenList();
  }

  void refreshTokens() {
    _loadTokenList();
  }

  Future<void> _loadTokenList() async {
    List<Token> tokens = await StorageUtil.loadAllTokens();
    _sortTokens(tokens);
    state = tokens;
  }

  // Sort the list by the sortIndex stored in localStorage
  void _sortTokens(List<Token> tokens) {
    tokens.sort((a, b) {
      if (a.sortIndex != null && b.sortIndex != null) {
        return a.sortIndex!.compareTo(b.sortIndex as int);
      }
      return -1;
    });
  }

  void incrementCounter(HOTPToken token) {
    final tempTokens = [...state];
    final index = tempTokens.indexWhere((element) => element.id == token.id);
    tempTokens[index] = token.withNextCounter();
    state = tempTokens;
    StorageUtil.saveOrReplaceToken(tempTokens[index]);
  }

  void addToken(Token token) {
    final tempTokens = [...state];
    tempTokens.add(token);
    _sortTokens(tempTokens);
    state = tempTokens;
    StorageUtil.saveOrReplaceToken(token);
  }

  void addTokens(List<Token> tokens) {
    final tempTokens = [...state];
    tempTokens.addAll(tokens);
    _sortTokens(tempTokens);
    state = tempTokens;
    for (final token in tokens) {
      StorageUtil.saveOrReplaceToken(token);
    }
  }

  void removeToken(Token token) {
    final tempTokens = [...state];
    tempTokens.remove(token);
    state = tempTokens;
    StorageUtil.deleteToken(token);
  }

  void removeTokens(List<Token> tokens) {
    final tempTokens = [...state];
    tempTokens.removeWhere((element) => tokens.contains(element));
    state = tempTokens;
    for (final token in tokens) {
      StorageUtil.deleteToken(token);
    }
  }

  PushToken removePushTokenBySerial(String serial) {
    final tempTokens = [...state];
    final token = tempTokens.firstWhere((element) => element is PushToken && element.serial == serial);
    removeToken(token);
    return token as PushToken;
  }

  Token removeTokenById(String id) {
    final tempTokens = [...state];
    final token = tempTokens.firstWhere((element) => element.id == id);
    removeToken(token);
    return token;
  }

  List<Token> removeTokensByIds(List<String> ids) {
    final tempTokens = [...state];
    final tokensToRemove = tempTokens.where((element) => ids.contains(element.id)).toList();
    removeTokens(tokensToRemove);
    return tokensToRemove;
  }

  void updateToken(Token token) {
    final tempTokens = [...state];
    final index = tempTokens.indexWhere((element) => element.id == token.id);
    tempTokens[index] = token;
    _sortTokens(tempTokens);
    state = tempTokens;
    StorageUtil.saveOrReplaceToken(token);
  }

  void updateTokens(List<Token> updatedTokens) {
    final tempTokens = [...state];
    for (final updatedToken in updatedTokens) {
      final index = tempTokens.indexWhere((oldToken) => oldToken.id == updatedToken.id);
      tempTokens[index] = updatedToken;
      StorageUtil.saveOrReplaceToken(updatedToken);
    }
    _sortTokens(tempTokens);
    for (final token in tempTokens) {
      Logger.warning('Sorted token ${token.label}: ${token.sortIndex}');
    }
    state = tempTokens;
  }

  void reorderToken(Token token, int newIndex) {
    final oldIndex = token.sortIndex;
    if (oldIndex == null) {
      Logger.warning("Can't reorder Token ${token.label}. It has no sortIndex.");
      return;
    }

    if (oldIndex == newIndex) return;
    //If the selected token moved down all other tokens between old and new index must decrease their sort index by 1 to move up
    //If the selected token moved up all other tokens between old and new index must increase their sort index by 1 to move down
    final selectedTokenMovedDown = newIndex > oldIndex;
    if (selectedTokenMovedDown) newIndex--;
    final reorderedTokens = <Token>[];
    for (int i = min(oldIndex, newIndex); i <= max(oldIndex, newIndex); i++) {
      final token = state[i];
      if (i == oldIndex) {
        Logger.info('Token ${token.label}: ${token.sortIndex} -> $newIndex');
        reorderedTokens.add(token.copyWith(sortIndex: newIndex));
        continue;
      }

      final newIndexThisToken = selectedTokenMovedDown ? i - 1 : i + 1;
      Logger.info('Token ${token.label}: ${token.sortIndex} -> $newIndexThisToken');
      reorderedTokens.add(token.copyWith(sortIndex: newIndexThisToken));
    }

    updateTokens(reorderedTokens);
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

      if (newToken is PushToken && state.contains(newToken)) {
        showMessage(message: 'A token with the serial ${newToken.serial} already exists!', duration: Duration(seconds: 2), context: context);
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

      showMessage(message: '${e.message}\n Please inform the creator of this qr code about the problem.', duration: Duration(seconds: 8), context: context);
    }
  }

  Future<void> addPushRequest(PushRequest pr) async {
    PushToken? token = state.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pr.serial && t.isRolledOut);

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
    PushToken? token = state.whereType<PushToken>().firstWhereOrNull((t) => t.serial == pushRequest.serial);

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
    String uuid = Uuid().v4();
    String type = uriMap[URI_TYPE];

    // Push token do not need any of the other parameters.
    if (equalsIgnoreCase(type, enumAsString(TokenTypes.PIPUSH))) {
      Uri? rolloutURL = uriMap[URI_ROLLOUT_URL];
      if (rolloutURL == null) {
        showMessage(message: "QR code did not contain rollout URL!", duration: Duration(seconds: 3), context: context);
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
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (e is PlatformException && e.code == FIREBASE_TOKEN_ERROR_CODE || e is SocketException) {
        Logger.warning('Connection error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#_rollOutToken', error: e);
        showMessage(
          context: context,
          message: AppLocalizations.of(context)?.errorRollOutNoNetworkConnection ?? "No network connection!",
          duration: Duration(seconds: 3),
        );
      } else {
        Logger.warning('Unknown error: Roll out push token [${token.serial}] failed.', name: 'token_widgets.dart#_rollOutToken', error: e);
        showMessage(
          context: context,
          message: AppLocalizations.of(context)!.errorRollOutUnknownError(e),
          duration: Duration(seconds: 3),
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
