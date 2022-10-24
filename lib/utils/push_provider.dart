/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';

import 'crypto_utils.dart';
import 'customizations.dart';
import 'identifiers.dart';
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

  static Future<String?> _initFirebase() async {
    await Firebase.initializeApp();

    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen(_incomingHandler);
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    try {
      String? firebaseToken = await getFBToken();

      if (firebaseToken != await StorageUtil.getCurrentFirebaseToken()) {
        _updateFirebaseToken(firebaseToken);
      }
    } on PlatformException catch (error, stacktrace) {
      if (error.code == FIREBASE_TOKEN_ERROR_CODE) {
        // ignore
      } else {
        String errormessage = error.message ?? 'no Error message';
        final SnackBar snackBar = SnackBar(
            content: Text(
                "Push cant be initialized, restart the app and try again" +
                    error.code +
                    'error message :' +
                    errormessage));
        snackbarKey.currentState?.showSnackBar(snackBar);
      }
    } on FirebaseException catch (error, stacktrace) {
      final SnackBar snackBar = SnackBar(
          content: Text(
              "Push cant be initialized, restart the app and try again" +
                  error.toString()));
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      if ((await StorageUtil.getCurrentFirebaseToken()) != newToken) {
        await StorageUtil.setNewFirebaseToken(newToken);
        _updateFirebaseToken(newToken);
      }
    });
  }

  /// Returns the current firebase token of the app / device. Throws a
  /// PlatformException with a custom error code if retrieving the firebase
  /// token failed. This may happen if, e.g., no network connection is available.
  static Future<String> getFBToken() async {
    String? firebaseToken = await FirebaseMessaging.instance.getToken();

    // Fall back to the last known firebase token
    if (firebaseToken == null) {
      firebaseToken = await StorageUtil.getCurrentFirebaseToken();
    }

    if (firebaseToken == null) {
      // This error should be handled in all cases, the user might be informed
      // in the form of a pop-up message.
      throw PlatformException(
          message:
              'Firebase token could not be retrieved, the only know cause of this is'
              ' that the firebase servers could not be reached.',
          code: FIREBASE_TOKEN_ERROR_CODE);
    }

    return firebaseToken;
  }

  static Future<bool> pollForChallenges(BuildContext context) async {
    // Get all push tokens
    List<PushToken> pushTokens = (await StorageUtil.loadAllTokens())
        .whereType<PushToken>()
        .where((t) =>
            t.isRolledOut &&
            t.url !=
                null) // Legacy tokens can not poll, because the url is missing!
        .toList();

    // Disable polling if no push tokens exist
    if (pushTokens.isEmpty) {
      log('No push token is available for polling, polling is disabled.',
          name: 'push_provider.dart#pollForChallenges');
      AppSettings.of(context).enablePolling = false;
      return false;
    }

    // Start request for each token
    for (PushToken p in pushTokens) {
      String timestamp = DateTime.now().toUtc().toIso8601String();

      // Legacy android tokens are signed differently
      String message = '${p.serial}|$timestamp';
      String signature = p.privateTokenKey == null
          ? await Legacy.sign(p.serial, message)
          : createBase32Signature(
              p.getPrivateTokenKey()!, utf8.encode(message) as Uint8List);

      Map<String, String> parameters = {
        'serial': p.serial,
        'timestamp': timestamp,
        'signature': signature,
      };

      try {
        Response response = await doGet(
            url: p.url!, parameters: parameters, sslVerify: p.sslVerify);

        if (response.statusCode == 200) {
          // The signature of this message must not be verified as each push
          // request gets verified independently.
          Map<String, dynamic> result = jsonDecode(response.body)['result'];
          List challengeList = result['value'].cast<Map<String, dynamic>>();

          for (Map<String, dynamic> challenge in challengeList) {
            _incomingHandler(RemoteMessage(data: challenge));
          }
        } else {
          // Error messages can only be distinguished by their text content,
          // not by their error code. This would make error handling complex.
        }
      } on ClientException catch (error) {
        final SnackBar snackBar = SnackBar(
            content: Text(
                "An error occured when polling for challanges \n ${error.toString()}"));
        snackbarKey.currentState?.showSnackBar(snackBar);

        log(
          'Polling push tokens not working, server can not be reached.',
          name: 'push_provider.dart#pollForChallenges',
        );
        return false;
      }
    }
    return true;
  }

  /// Checks if the firebase token was changed and updates it if necessary.
  static Future<void> updateFbTokenIfChanged() async {
    String? firebaseToken = await getFBToken();

    if (firebaseToken != null &&
        (await StorageUtil.getCurrentFirebaseToken()) != firebaseToken) {
      _updateFirebaseToken(firebaseToken);
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

    List<PushToken> tokenList = (await StorageUtil.loadAllTokens())
        .whereType<PushToken>()
        .where((t) => t.url != null)
        .toList();

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

      String signature = p.privateTokenKey == null
          ? await Legacy.sign(p.serial, message)
          : createBase32Signature(
              p.getPrivateTokenKey()!, utf8.encode(message) as Uint8List);

      Response response =
          await doPost(sslVerify: p.sslVerify!, url: p.url!, body: {
        'new_fb_token': firebaseToken,
        'serial': p.serial,
        'timestamp': timestamp,
        'signature': signature
      });

      if (response.statusCode == 200) {
        log('Updating firebase token for push token: ${p.serial} succeeded!',
            name: 'push_provider.dart#_updateFirebaseToken');
      } else {
        log('Updating firebase token for push token: ${p.serial} failed!',
            name: 'push_provider.dart#_updateFirebaseToken');
        allUpdated = false;
      }
    }

    if (allUpdated) {
      StorageUtil.setCurrentFirebaseToken(firebaseToken);
    }
  }
}
