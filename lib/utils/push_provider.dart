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

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';

import 'crypto_utils.dart';
import 'customizations.dart';
import 'identifiers.dart';
import 'logger.dart';
import 'network_utils.dart';

/// This class bundles all logic that is needed to handle PushTokens, e.g.,
/// firebase, polling, notifications.
class PushProvider {
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
      FirebaseMessaging.instance.requestPermission();
    } on FirebaseException catch (ex) {
      String errorMessage = ex.message ?? 'no error message';
      final SnackBar snackBar = SnackBar(content: Text("Firebase notification permission error! (" + errorMessage + ": " + ex.code));
      snackbarKey.currentState?.showSnackBar(snackBar);
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
        final SnackBar snackBar =
            SnackBar(content: Text("Push cant be initialized, restart the app and try again" + error.code + 'error message :' + errorMessage));
        snackbarKey.currentState?.showSnackBar(snackBar);
      }
    } on FirebaseException catch (error) {
      final SnackBar snackBar = SnackBar(content: Text("Push cant be initialized, restart the app and try again" + error.toString()));
      snackbarKey.currentState?.showSnackBar(snackBar);
    } catch (error) {
      final SnackBar snackBar = SnackBar(content: Text("Unknown error: ${error.toString()}" + error.toString()));
      snackbarKey.currentState?.showSnackBar(snackBar);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      if ((await StorageUtil.getCurrentFirebaseToken()) != newToken) {
        await StorageUtil.setNewFirebaseToken(newToken);
        // TODO what if this fails, when should a retry be attempted?
        try {
          _updateFirebaseToken(newToken);
        } catch (error) {
          final SnackBar snackBar = SnackBar(content: Text("Unknown error: ${error.toString()}" + error.toString()));
          snackbarKey.currentState?.showSnackBar(snackBar);
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
    } on FirebaseException catch (ex) {
      String errorMessage = ex.message ?? 'no error message';
      final SnackBar snackBar = SnackBar(content: Text("Unable to retrieve Firebase token! (" + errorMessage + ": " + ex.code + ")"));
      Logger.warning('Unable to retrieve Firebase token! (' + errorMessage + ': ' + ex.code + ')', name: 'push_provider.dart#getFBToken', error: ex);
      snackbarKey.currentState?.showSnackBar(snackBar);
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

  static Future<bool> pollForChallenges() async {
    Logger.info('Polling for challenges', name: 'push_provider.dart#pollForChallenges');
    // Get all push tokens
    List<PushToken> pushTokens = globalRef?.read(tokenProvider).whereType<PushToken>().where((t) => t.isRolledOut && t.url != null).toList() ?? [];

    // Disable polling if no push tokens exist
    if (pushTokens.isEmpty) {
      Logger.info('No push token is available for polling, polling is disabled.', name: 'push_provider.dart#pollForChallenges');
      globalRef?.read(settingsProvider.notifier).enablePolling();
      return false;
    }

    // Start request for each token
    for (PushToken p in pushTokens) {
      String timestamp = DateTime.now().toUtc().toIso8601String();

      String message = '${p.serial}|$timestamp';

      String? signature = await trySignWithToken(p, message);
      if (signature == null) {
        return false;
      }
      Map<String, String> parameters = {
        'serial': p.serial,
        'timestamp': timestamp,
        'signature': signature,
      };

      try {
        Response response = await getRequest(url: p.url!, parameters: parameters, sslVerify: p.sslVerify);

        if (response.statusCode == 200) {
          // The signature of this message must not be verified as each push
          // request gets verified independently.
          Map<String, dynamic> result = jsonDecode(response.body)['result'];
          List challengeList = result['value'].cast<Map<String, dynamic>>();

          for (Map<String, dynamic> challenge in challengeList) {
            Logger.info('Received challenge ${challenge['nonce']}', name: 'push_provider.dart#pollForChallenges');
            _incomingHandler(RemoteMessage(data: challenge));
          }
        } else {
          // Error messages can only be distinguished by their text content,
          // not by their error code. This would make error handling complex.
        }
      } catch (error) {
        final SnackBar snackBar = SnackBar(content: Text("An error occured when polling for challenges \n ${error.toString()}"));
        snackbarKey.currentState?.showSnackBar(snackBar);

        Logger.warning(
          'Polling push tokens not working, server can not be reached.',
          name: 'push_provider.dart#pollForChallenges',
          error: error,
        );
        return false;
      }
    }
    return true;
  }

  /// Checks if the firebase token was changed and updates it if necessary.
  static Future<void> updateFbTokenIfChanged() async {
    String? firebaseToken = await getFBToken();

    if (firebaseToken != null && (await StorageUtil.getCurrentFirebaseToken()) != firebaseToken) {
      try {
        _updateFirebaseToken(firebaseToken);
      } catch (error) {
        final SnackBar snackBar = SnackBar(content: Text("Unknown error: ${error.toString()}" + error.toString()));
        snackbarKey.currentState?.showSnackBar(snackBar);
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
      Response response = await postRequest(
          sslVerify: p.sslVerify!, url: p.url!, body: {'new_fb_token': firebaseToken, 'serial': p.serial, 'timestamp': timestamp, 'signature': signature});

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
