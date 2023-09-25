/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import 'crypto_utils.dart';
import 'identifiers.dart';
import 'logger.dart';
import 'network_utils.dart';

/// This class bundles all logic that is needed to handle PushTokens, e.g.,
/// firebase, polling, notifications.
abstract class PushProvider {
  static late BackgroundMessageHandler _backgroundHandler;
  static late BackgroundMessageHandler _incomingHandler;

  static Future<void> initialize({
    required BackgroundMessageHandler handleIncomingMessage,
    required BackgroundMessageHandler backgroundMessageHandler,
  }) async {
    _incomingHandler = handleIncomingMessage;
    _backgroundHandler = backgroundMessageHandler;

    await _initFirebase();
  }

  static Future<void> _initFirebase() async {
    await Firebase.initializeApp();

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: false,
        badge: false,
        sound: false,
      );
    } on FirebaseException catch (e, s) {
      Logger.warning(
        'e.code: ${e.code}, '
        'e.message: ${e.message}, '
        'e.plugin: ${e.plugin},',
        name: 'push_provider.dart#_initFirebase',
        error: e,
        stackTrace: s,
      );
      String errorMessage = e.message ?? 'no error message';
      final SnackBar snackBar = SnackBar(
          content: Text(
        "Firebase notification permission error! ($errorMessage: ${e.code}",
      ));
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    }

    FirebaseMessaging.onMessage.listen(_incomingHandler);
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    try {
      String? firebaseToken = await getFBToken();

      if (firebaseToken != await StorageUtil.getCurrentFirebaseToken()) {
        _updateFirebaseToken(firebaseToken);
      }
    } on PlatformException catch (error) {
      if (error.code == FIREBASE_TOKEN_ERROR_CODE) {
        // ignore
      } else {
        String errorMessage = error.message ?? 'no error message';
        final SnackBar snackBar = SnackBar(
            content: Text(
          'Push cant be initialized, restart the app and try again. ${error.code}: $errorMessage',
          overflow: TextOverflow.fade,
          softWrap: false,
        ));
        globalSnackbarKey.currentState?.showSnackBar(snackBar);
      }
    } on FirebaseException catch (error) {
      final SnackBar snackBar = SnackBar(
          content: Text(
        "Push cant be initialized, restart the app and try again$error",
        overflow: TextOverflow.fade,
        softWrap: false,
      ));
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    } catch (error) {
      final SnackBar snackBar = SnackBar(
          content: Text(
        "Unknown error: $error",
        overflow: TextOverflow.fade,
        softWrap: false,
      ));
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      if ((await StorageUtil.getCurrentFirebaseToken()) != newToken) {
        await StorageUtil.setNewFirebaseToken(newToken);
        // TODO what if this fails, when should a retry be attempted?
        try {
          _updateFirebaseToken(newToken);
        } catch (error) {
          final SnackBar snackBar = SnackBar(
              content: Text(
            "Unknown error: $error",
            overflow: TextOverflow.fade,
            softWrap: false,
          ));
          globalSnackbarKey.currentState?.showSnackBar(snackBar);
        }
      }
    });
  }

  /// Returns the current firebase token of the app / device. Throws a
  /// PlatformException with a custom error code if retrieving the firebase
  /// token failed. This may happen if, e.g., no network connection is available.
  static Future<String?> getFBToken() async {
    String? firebaseToken;
    try {
      firebaseToken = await FirebaseMessaging.instance.getToken();
    } on FirebaseException catch (e, s) {
      String errorMessage = e.message ?? 'no error message';
      final SnackBar snackBar = SnackBar(
        content: Text(
          "Unable to retrieve Firebase token! ($errorMessage: ${e.code})",
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      );
      Logger.warning('Unable to retrieve Firebase token! ($errorMessage: ${e.code})', name: 'push_provider.dart#getFBToken', error: e, stackTrace: s);
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    }

    // Fall back to the last known firebase token
    if (firebaseToken == null) {
      firebaseToken = await StorageUtil.getCurrentFirebaseToken();
    } else {
      await StorageUtil.setNewFirebaseToken(firebaseToken);
    }

    if (firebaseToken == null) {
      // This error should be handled in all cases, the user might be informed
      // in the form of a pop-up message.
      throw PlatformException(
          message: 'Firebase token could not be retrieved, the only know cause of this is'
              ' that the firebase servers could not be reached.',
          code: FIREBASE_TOKEN_ERROR_CODE);
    }

    return firebaseToken;
  }

  static Future<String?> pollForChallenges({bool showMessageForEachToken = false}) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Logger.info('Tried to poll without any internet connection available.', name: 'push_provider.dart#pollForChallenges');
      return AppLocalizations.of(globalNavigatorKey.currentContext!)!.pollingFailNoNetworkConnection;
    }

    // Get all push tokens
    List<PushToken> pushTokens = globalRef?.read(tokenProvider).tokens.whereType<PushToken>().where((t) => t.isRolledOut && t.url != null).toList() ?? [];

    // Disable polling if no push tokens exist
    if (pushTokens.isEmpty && globalRef?.read(settingsProvider).enablePolling == true) {
      Logger.info('No push token is available for polling, polling is disabled.', name: 'push_provider.dart#pollForChallenges');
      globalRef?.read(settingsProvider.notifier).disablePolling();
      return null;
    }

    // Start request for each token
    Logger.info('Polling for challenges: ${pushTokens.length} Tokens', name: 'push_provider.dart#pollForChallenges');
    for (PushToken p in pushTokens) {
      pollForChallenge(p).then((errorMessage) {
        if (errorMessage != null && showMessageForEachToken) {
          Logger.warning(errorMessage, name: 'push_provider.dart#pollForChallenges');
          showMessage(message: errorMessage);
        }
      });
    }
    return null;
  }

  static Future<String?> pollForChallenge(PushToken token) async {
    String timestamp = DateTime.now().toUtc().toIso8601String();

    String message = '${token.serial}|$timestamp';

    String? signature = await trySignWithToken(token, message);
    if (signature == null) {
      Logger.warning('Polling push tokens failed because signing the message failed.', name: 'push_provider.dart#pollForChallenge');
      return null;
    }
    Map<String, String> parameters = {
      'serial': token.serial,
      'timestamp': timestamp,
      'signature': signature,
    };

    try {
      Response response = await doGet(url: token.url!, parameters: parameters, sslVerify: token.sslVerify);

      switch (response.statusCode) {
        case 200:
          // The signature of this message must not be verified as each push
          // request gets verified independently.
          Map<String, dynamic> result = jsonDecode(response.body)['result'];
          List challengeList = result['value'].cast<Map<String, dynamic>>();

          for (Map<String, dynamic> challenge in challengeList) {
            Logger.info('Received challenge ${challenge['nonce']}', name: 'push_provider.dart#pollForChallenge');
            _incomingHandler(RemoteMessage(data: challenge));
          }
          break;

        case 403:
          Logger.warning('Polling push token ${token.serial} failed with status code ${response.statusCode}',
              name: 'push_provider.dart#pollForChallenge', error: getErrorMessageFromResponse(response));
          return null;

        default:
          var error = getErrorMessageFromResponse(response);
          return "${AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorWhenPullingChallenges(token.serial)}\n$error";
      }
    } catch (e) {
      return "${AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorWhenPullingChallenges(token.serial)}\n${e.toString()}";
    }
    return null;
  }

  /// Checks if the firebase token was changed and updates it if necessary.
  static Future<void> updateFbTokenIfChanged() async {
    String? firebaseToken = await getFBToken();

    if (firebaseToken != null && (await StorageUtil.getCurrentFirebaseToken()) != firebaseToken) {
      try {
        _updateFirebaseToken(firebaseToken);
      } catch (error) {
        final SnackBar snackBar = SnackBar(
          content: Text(
            "Unknown error: $error",
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        );
        globalSnackbarKey.currentState?.showSnackBar(snackBar);
      }
    }
  }

  /// This method attempts to update the fbToken for all PushTokens that can be
  /// updated. I.e. all tokens that know the url of their respective privacyIDEA
  /// server. If the update fails for one or all tokens, this method does *not*
  /// give any feedback!.
  ///
  /// This should only be used to attempt to update the fbToken automatically,
  /// as this can not be guaranteed to work. There is a manual option available
  /// through the settings also.
  static void _updateFirebaseToken(String? firebaseToken) async {
    if (firebaseToken == null) {
      // Nothing to update here!
      return;
    }

    List<PushToken> tokenList = (await StorageUtil.loadAllTokens()).whereType<PushToken>().where((t) => t.url != null).toList();

    bool allUpdated = true;

    for (PushToken p in tokenList) {
      // POST /ttype/push HTTP/1.1
      //Host: example.com
      //
      //new_fb_token=<new firebase token>
      //serial=<tokenserial>element
      //timestamp=<timestamp>
      //signature=SIGNATURE(<new firebase token>|<tokenserial>|<timestamp>)

      String timestamp = DateTime.now().toUtc().toIso8601String();

      String message = '$firebaseToken|${p.serial}|$timestamp';
      // Because no context is available, trySignWithToken will fail without feedback for the user
      // Just like this whole function // TODO improve that?
      String? signature = await trySignWithToken(p, message);
      if (signature == null) {
        return;
      }
      Response response = await doPost(
          sslVerify: p.sslVerify, url: p.url!, body: {'new_fb_token': firebaseToken, 'serial': p.serial, 'timestamp': timestamp, 'signature': signature});

      if (response.statusCode == 200) {
        Logger.info('Updating firebase token for push token: ${p.serial} succeeded!', name: 'push_provider.dart#_updateFirebaseToken');
      } else {
        Logger.warning('Updating firebase token for push token: ${p.serial} failed!', name: 'push_provider.dart#_updateFirebaseToken');
        allUpdated = false;
      }
    }

    if (allUpdated) {
      StorageUtil.setCurrentFirebaseToken(firebaseToken);
    }
  }
}
