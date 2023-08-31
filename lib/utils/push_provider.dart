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

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/state_notifiers/push_request_notifier.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import 'logger.dart';
import 'network_utils.dart';

/// This class bundles all logic that is needed to handle incomig PushRequests, e.g.,
/// firebase, polling, notifications.
class PushProvider {
  static PushProvider? _instance;
  bool _initialized = false;
  Timer? _pollTimer;
  PushRequestNotifier? pushSubscriber; // must be set before receiving push messages
  PushProvider._();
  FirebaseUtils? firebaseUtils;

  Future<void> initialize({required PushRequestNotifier pushSubscriber}) async {
    if (_initialized) return;
    _initialized = true;
    this.pushSubscriber = pushSubscriber;
    firebaseUtils = FirebaseUtils();
    await firebaseUtils!.initFirebase(
      foregroundHandler: _foregroundHandler,
      backgroundHandler: _backgroundHandler,
      updateFirebaseToken: _updateFirebaseToken,
    );
  }

  factory PushProvider({bool? pollingEnabled}) {
    _instance ??= PushProvider._();
    if (pollingEnabled != null) {
      _instance!._initStateAsync(pollingEnabled);
    }
    return _instance!;
  }

  // INITIALIZATIONS

  /// Handles asynchronous calls that should be triggered by `initState`.
  Future<void> _initStateAsync(bool pollingEnabled) async {
    if (pollingEnabled) {
      pollForChallenges();
    }
    _startOrStopPolling(pollingEnabled);
  }

  // FOREGROUND HANDLING
  Future<void> _foregroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Foreground message received.', name: 'main_screen.dart#_handleIncomingAuthRequest', error: remoteMessage.data);
    await TokenRepository.protect(() async {
      try {
        return _handleIncomingRequestForeground(remoteMessage);
      } catch (e, s) {
        final errorMessage = AppLocalizations.of(globalNavigatorKey.currentContext!)!.incomingAuthRequestError;
        Logger.error(errorMessage, name: 'main_screen.dart#_handleIncomingAuthRequest', error: remoteMessage.data, stackTrace: s);
      }
    });
  }

  // BACKGROUND HANDLING
  static Future<void> _backgroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Background message received.', name: 'main_screen.dart#_firebaseMessagingBackgroundHandler', error: remoteMessage.data);
    await TokenRepository.protect(() async {
      try {
        return _handleIncomingRequestBackground(remoteMessage);
      } catch (e, s) {
        final errorMessage = AppLocalizations.of(globalNavigatorKey.currentContext!)!.incomingAuthRequestError;
        Logger.error(errorMessage, name: 'main_screen.dart#_firebaseMessagingBackgroundHandler', error: remoteMessage.data, stackTrace: s);
      }
    });
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  Future<void> _handleIncomingRequestForeground(RemoteMessage message) async {
    var data = message.data;
    Logger.info('Incoming push challenge.', name: 'main_screen.dart#_handleIncomingChallenge', error: data);
    Uri requestUri = Uri.parse(data['url']);

    Logger.info('message: $data', name: 'main_screen.dart#_handleIncomingRequest');

    bool sslVerify = (int.tryParse(data['sslverify']) ?? 0) == 1;
    PushRequest pushRequest = PushRequest(
      title: data['title'],
      question: data['question'],
      uri: requestUri,
      nonce: data['nonce'],
      sslVerify: sslVerify,
      id: data['nonce'].hashCode,
      // FIXME This is not guaranteed to not lead to collisions, but they might be unlikely in this case.
      expirationDate: DateTime.now().add(
        const Duration(seconds: 120), // Push requests expire after 2 minutes.
      ),
      serial: data['serial'],
      signature: data['signature'],
    );

    Logger.info('Incoming push challenge for token with serial.', name: 'main_screen.dart#_handleIncomingChallenge', error: pushRequest.serial);

    pushSubscriber?.newRequest(pushRequest);
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<void> _handleIncomingRequestBackground(RemoteMessage message) async {
    var data = message.data;
    Logger.info('Incoming push challenge.', name: 'main_screen.dart#_handleIncomingChallenge', error: data);
    Uri requestUri = Uri.parse(data['url']);

    Logger.info('message: $data', name: 'main_screen.dart#_handleIncomingRequest');

    bool sslVerify = (int.tryParse(data['sslverify']) ?? 0) == 1;
    PushRequest pushRequest = PushRequest(
      title: data['title'],
      question: data['question'],
      uri: requestUri,
      nonce: data['nonce'],
      sslVerify: sslVerify,
      id: data['nonce'].hashCode,
      // FIXME This is not guaranteed to not lead to collisions, but they might be unlikely in this case.
      expirationDate: DateTime.now().add(
        const Duration(seconds: 120), // Push requests expire after 2 minutes.
      ),
      serial: data['serial'],
      signature: data['signature'],
    );

    Logger.info('Incoming push challenge for token with serial.', name: 'main_screen.dart#_handleIncomingChallenge', error: pushRequest.serial);
    _addPushRequestToTokenInSecureStoreage(pushRequest);
  }

  static void _addPushRequestToTokenInSecureStoreage(PushRequest pushRequest) async {
    Logger.info('Adding push request to token in secure storage.', name: 'main_screen.dart#_addPushRequestToTokenInSecureStoreage', error: pushRequest);
    var tokens = await const TokenRepository().loadAllTokens();
    PushToken? token = tokens.firstWhereOrNull((token) => token is PushToken && token.serial == pushRequest.serial) as PushToken?;
    if (token == null) {
      Logger.warning('Token not found.', name: 'main_screen.dart#_addPushRequestToTokenInSecureStoreage', error: 'Serial: ${pushRequest.serial}');
      return;
    }
    final prList = token.pushRequests;
    prList.add(pushRequest);
    token = token.copyWith(pushRequests: prList);
    await const TokenRepository().saveOrReplaceToken(token);
  }

  void _startOrStopPolling(bool pollingEnabled) {
    // Start polling if enabled and not already polling
    if (pollingEnabled && _pollTimer == null) {
      Logger.info('Polling is enabled.', name: 'main_screen.dart#_startPollingIfEnabled');
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => pollForChallenges());
      pollForChallenges();
      return;
    }
    // Stop polling if it's disabled and currently polling
    if (!pollingEnabled && _pollTimer != null) {
      Logger.info('Polling is disabled.', name: 'main_screen.dart#_startPollingIfEnabled');
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    // Do nothing if polling is enabled and already polling or disabled and not polling
    return;
  }

  Future<String?> pollForChallenges({bool showMessageForEachToken = false}) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Logger.info('Tried to poll without any internet connection available.', name: 'push_provider.dart#pollForChallenges');
      return AppLocalizations.of(globalNavigatorKey.currentContext!)!.pollingFailNoNetworkConnection;
    }

    // Get all push tokens
    List<PushToken> pushTokens = globalRef?.read(tokenProvider).tokens.whereType<PushToken>().where((t) => t.isRolledOut && t.url != null).toList() ?? [];

    // Disable polling if no push tokens exist
    if (pushTokens.isEmpty) {
      Logger.info('No push token is available for polling, polling is disabled.', name: 'push_provider.dart#pollForChallenges');
      globalRef?.read(settingsProvider.notifier).setPolling(false);
      return null;
    }

    // Start request for each token
    for (PushToken p in pushTokens) {
      pollForChallenge(p).then((errorMessage) {
        if (errorMessage != null && showMessageForEachToken) {
          showMessage(message: errorMessage);
        }
      });
    }
    return null;
  }

  Future<String?> pollForChallenge(PushToken token) async {
    String timestamp = DateTime.now().toUtc().toIso8601String();

    String message = '${token.serial}|$timestamp';

    String? signature = await const RsaUtils().trySignWithToken(token, message);
    if (signature == null) {
      Logger.warning('Polling push tokens failed because signing the message failed.', name: 'push_provider.dart#pollForChallenges');
      return null;
    }
    Map<String, String> parameters = {
      'serial': token.serial,
      'timestamp': timestamp,
      'signature': signature,
    };

    try {
      Response response = await const CustomIOClient().doGet(url: token.url!, parameters: parameters, sslVerify: token.sslVerify);

      if (response.statusCode == 200) {
        // The signature of this message must not be verified as each push
        // request gets verified independently.
        Map<String, dynamic> result = jsonDecode(response.body)['result'];
        List challengeList = result['value'].cast<Map<String, dynamic>>();

        for (Map<String, dynamic> challenge in challengeList) {
          Logger.info('Received challenge ${challenge['nonce']}', name: 'push_provider.dart#pollForChallenges');
          _foregroundHandler(RemoteMessage(data: challenge));
        }
      } else {
        var error = getErrorMessageFromResponse(response);
        Logger.warning('Polling push tokens failed with status code ${response.statusCode}', name: 'push_provider.dart#pollForChallenges');
        return "${AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorWhenPullingChallenges}\n$error";
      }
    } catch (e, s) {
      Logger.warning(
        'An error occured when polling for challenges',
        name: 'push_provider.dart#pollForChallenges',
        error: e,
        stackTrace: s,
      );
      return "${AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorWhenPullingChallenges}\n${e.toString()}";
    }
    return null;
  }

  /// Checks if the firebase token was changed and updates it if necessary.
  static Future<void> updateFbTokenIfChanged() async {
    String? firebaseToken = await PushProvider().firebaseUtils?.getFBToken();

    if (firebaseToken != null && (await TokenRepository.getCurrentFirebaseToken()) != firebaseToken) {
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

    List<PushToken> tokenList = (await const TokenRepository().loadAllTokens()).whereType<PushToken>().where((t) => t.url != null).toList();

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
      String? signature = await const RsaUtils().trySignWithToken(p, message);
      if (signature == null) {
        return;
      }
      Response response = await const CustomIOClient().doPost(
          sslVerify: p.sslVerify, url: p.url!, body: {'new_fb_token': firebaseToken, 'serial': p.serial, 'timestamp': timestamp, 'signature': signature});

      if (response.statusCode == 200) {
        Logger.info('Updating firebase token for push token: ${p.serial} succeeded!', name: 'push_provider.dart#_updateFirebaseToken');
      } else {
        Logger.warning('Updating firebase token for push token: ${p.serial} failed!', name: 'push_provider.dart#_updateFirebaseToken');
        allUpdated = false;
      }
    }

    if (allUpdated) {
      TokenRepository.setCurrentFirebaseToken(firebaseToken);
    }
  }
}
