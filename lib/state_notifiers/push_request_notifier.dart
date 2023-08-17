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

import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';

class PushRequestNotifier extends StateNotifier<PushRequest?> {
  // Used for periodically polling for push challenges
  static Timer? _pollTimer;
  final bool pollingEnabled;

  PushRequestNotifier(super.state, {required this.pollingEnabled}) {
    _initStateAsync();
  }

  void _startOrStopPolling() {
    // Start polling if enabled and not already polling
    if (pollingEnabled && _pollTimer == null) {
      Logger.info('Polling is enabled.', name: 'main_screen.dart#_startPollingIfEnabled');
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => PushProvider.pollForChallenges());
      PushProvider.pollForChallenges();
      return;
    }
    // Stop polling if disabled and currently polling
    if (!pollingEnabled && _pollTimer != null) {
      Logger.info('Polling is disabled.', name: 'main_screen.dart#_startPollingIfEnabled');
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    // Do nothing if polling is enabled and already polling or disabled and not polling
    return;
  }

  // INITIALIZATIONS

  /// Handles asynchronous calls that should be triggered by `initState`.
  void _initStateAsync() async {
    await PushProvider.initialize(
      handleIncomingMessage: (RemoteMessage message) => _handleIncomingAuthRequest(message),
      backgroundMessageHandler: _firebaseMessagingBackgroundHandler,
    );

    if (pollingEnabled) {
      PushProvider.pollForChallenges();
    }
    _startOrStopPolling();
  }

  // FOREGROUND HANDLING
  Future<void> _handleIncomingAuthRequest(RemoteMessage message) async {
    Logger.info('Foreground message received.', name: 'main_screen.dart#_handleIncomingAuthRequest', error: message);
    await StorageUtil.protect(() async => _handleIncomingRequest(message));
  }

  // BACKGROUND HANDLING
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    Logger.info('Background message received.', name: 'main_screen.dart#_firebaseMessagingBackgroundHandler', error: message);
    await StorageUtil.protect(() async => _handleIncomingRequest(message, inBackground: true));
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<void> _handleIncomingRequest(RemoteMessage message, {bool inBackground = false}) async {
    Logger.warning('inBackground: $inBackground', name: 'main_screen.dart#_handleIncomingRequest');
    // Android and iOS use different keys for the tag.
    var tag = message.notification?.android;
    Logger.warning('tag: ${tag?.toMap().toString()}', name: 'main_screen.dart#_handleIncomingRequest');
    // tag ??= message.notification?.apple?.badge; //FIXME: Is this the tag for iOS?

    var data = message.data;
    Logger.info('Incoming push challenge.', name: 'main_screen.dart#_handleIncomingChallenge', error: data);
    Uri requestUri = Uri.parse(data['url']);

    Logger.warning('message: $data', name: 'main_screen.dart#_handleIncomingRequest');

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
    if (inBackground) {
      _addPushRequestToTokenInSecureStoreage(pushRequest);
      return;
    }
    globalRef?.read(pushRequestProvider.notifier).state = pushRequest;
    // Logger.info('Incoming push challenge for token with serial.', name: 'main_screen.dart#_handleIncomingChallenge', error: requestedSerial);
  }

  static void _addPushRequestToTokenInSecureStoreage(PushRequest pushRequest) async {
    Logger.info('Adding push request to token in secure storage.', name: 'main_screen.dart#_addPushRequestToTokenInSecureStoreage', error: pushRequest);
    var tokens = await StorageUtil.loadAllTokens();
    PushToken? token = tokens.firstWhereOrNull((token) => token is PushToken && token.serial == pushRequest.serial) as PushToken?;
    if (token == null) {
      Logger.warning('Token not found.', name: 'main_screen.dart#_addPushRequestToTokenInSecureStoreage', error: 'Serial: ${pushRequest.serial}');
      return;
    }
    final prList = token.pushRequests;
    prList.add(pushRequest);
    token = token.copyWith(pushRequests: prList);
    await StorageUtil.saveOrReplaceToken(token);
  }

  // ACTIONS
  void accept(PushRequest pushRequest) async {
    Logger.info('Approving push request.', name: 'main_screen.dart#approve', error: pushRequest);
    pushRequest = pushRequest.copyWith(accepted: true);
    final successfullyApproved = await handleReaction(pushRequest);
    if (successfullyApproved) {
      globalRef?.read(pushRequestProvider.notifier).state = pushRequest;
    }
  }

  void decline(PushRequest pushRequest) async {
    Logger.info('Denying push request.', name: 'main_screen.dart#deny', error: pushRequest);
    pushRequest = pushRequest.copyWith(accepted: false);
    final successfullyDenied = await handleReaction(pushRequest);
    if (successfullyDenied) {
      globalRef?.read(pushRequestProvider.notifier).state = pushRequest;
    }
  }

  Future<bool> handleReaction(PushRequest pushRequest) async {
    if (pushRequest.accepted == null) return false;

    final token = globalRef?.read(tokenProvider).tokens.firstWhereOrNull((token) => token is PushToken && token.serial == pushRequest.serial) as PushToken?;

    if (token == null) {
      Logger.warning('Token not found.', name: 'token_widgets.dart#handleReaction', error: 'Serial: ${pushRequest.serial}');
      return false;
    }

    Logger.info('Push auth request accepted=${pushRequest.accepted}, sending response to privacyidea',
        name: 'token_widgets.dart#handleReaction', error: 'Url: ${pushRequest.uri}');

    // signature ::=  {nonce}|{serial}[|decline]
    String msg = '${pushRequest.nonce}|${token.serial}';
    if (pushRequest.accepted! == false) {
      msg += '|decline';
    }
    String? signature = await trySignWithToken(token, msg);
    if (signature == null) {
      return false;
    }

    //    POST https://privacyideaserver/validate/check
    //    nonce=<nonce_from_request>
    //    serial=<serial>
    //    signature=<signature>
    //    decline=1 (optional)
    final Map<String, String> body = {
      'nonce': pushRequest.nonce,
      'serial': token.serial,
      'signature': signature,
    };
    if (pushRequest.accepted! == false) {
      body["decline"] = "1";
    }

    Response response = await postRequest(sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);
    if (response.statusCode != 200) {
      Logger.warning(
        'Sending push request response failed.',
        name: 'token_widgets.dart#handleReaction',
        error: 'Token: $token, Status code: ${response.statusCode}, Body: ${response.body}',
      );
      return false;
    }

    return true;
  }
}
