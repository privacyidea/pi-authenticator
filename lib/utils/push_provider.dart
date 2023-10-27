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
import 'package:http/http.dart';

import '../l10n/app_localizations.dart';
import '../model/push_request.dart';
import '../model/tokens/push_token.dart';
import '../repo/secure_token_repository.dart';
import '../state_notifiers/push_request_notifier.dart';
import 'customizations.dart';
import 'firebase_utils.dart';
import 'logger.dart';
import 'network_utils.dart';
import 'riverpod_providers.dart';
import 'rsa_utils.dart';
import 'utils.dart';
import 'view_utils.dart';

/// This class bundles all logic that is needed to handle incomig PushRequests, e.g.,
/// firebase, polling, notifications.
class PushProvider {
  static PushProvider? instance;
  bool pollingIsEnabled = false;
  bool _initialized = false;
  Timer? _pollTimer;
  PushRequestNotifier? pushSubscriber; // must be set before receiving push messages
  FirebaseUtils? firebaseUtils;
  PrivacyIdeaIOClient _ioClient;
  RsaUtils _rsaUtils;
  PushProvider._({PrivacyIdeaIOClient? ioClient, RsaUtils? rsaUtils})
      : _ioClient = ioClient ?? const PrivacyIdeaIOClient(),
        _rsaUtils = rsaUtils ?? const RsaUtils();

  Future<void> initialize({required PushRequestNotifier pushSubscriber, required FirebaseUtils firebaseUtils}) async {
    if (_initialized) return;
    _initialized = true;
    this.firebaseUtils = firebaseUtils;
    this.pushSubscriber = pushSubscriber;
    await firebaseUtils.initFirebase(
      foregroundHandler: _foregroundHandler,
      backgroundHandler: _backgroundHandler,
      updateFirebaseToken: updateFirebaseToken,
    );
  }

  void setPollingEnabled(bool? enablePolling) {
    if (enablePolling == null) return;
    _startOrStopPolling(enablePolling);
    pollingIsEnabled = enablePolling;
  }

  factory PushProvider({
    bool? pollingEnabled,
    PrivacyIdeaIOClient? ioClient,
    RsaUtils? rsaUtils,
  }) {
    if (instance == null) {
      instance = PushProvider._(ioClient: ioClient, rsaUtils: rsaUtils);
    } else {
      if (ioClient != null) {
        instance!._ioClient = ioClient;
      }
      if (rsaUtils != null) {
        instance!._rsaUtils = rsaUtils;
      }
    }

    instance!.setPollingEnabled(pollingEnabled);

    return instance!;
  }

  // INITIALIZATIONS

  // FOREGROUND HANDLING
  Future<void> _foregroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Foreground message received.', name: 'push_provider.dart#_foregroundHandler');
    await SecureTokenRepository.protect(() async {
      try {
        return _handleIncomingRequestForeground(remoteMessage);
      } on TypeError catch (e, s) {
        final errorMessage = AppLocalizations.of(globalNavigatorKey.currentContext!)!.incomingAuthRequestError;
        showMessage(message: errorMessage);
        Logger.warning(errorMessage, name: 'push_provider.dart#_foregroundHandler', error: e, stackTrace: s);
      } catch (e, s) {
        final errorMessage = AppLocalizations.of(globalNavigatorKey.currentContext!)!.unexpectedError;
        Logger.error(errorMessage, name: 'push_provider.dart#_foregroundHandler', error: e, stackTrace: s);
      }
    });
  }

  // BACKGROUND HANDLING
  static Future<void> _backgroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Background message received.', name: 'push_provider.dart#_backgroundHandler');
    await SecureTokenRepository.protect(() async {
      try {
        return _handleIncomingRequestBackground(remoteMessage);
      } on TypeError catch (e, s) {
        final errorMessage = AppLocalizations.of(globalNavigatorKey.currentContext!)!.incomingAuthRequestError;
        Logger.warning(errorMessage, name: 'push_provider.dart#_backgroundHandler', error: e, stackTrace: s);
      } catch (e, s) {
        final errorMessage = AppLocalizations.of(globalNavigatorKey.currentContext!)!.unexpectedError;
        Logger.error(errorMessage, name: 'push_provider.dart#_backgroundHandler', error: e, stackTrace: s);
      }
    });
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  Future<void> _handleIncomingRequestForeground(RemoteMessage message) async {
    final data = message.data;
    Logger.info('Incoming push challenge.', name: 'push_provider.dart#_handleIncomingRequestForeground');
    Uri? requestUri = Uri.tryParse(data['url']);
    if (requestUri == null ||
        data['nonce'] == null ||
        data['serial'] == null ||
        data['signature'] == null ||
        data['title'] == null ||
        data['question'] == null) {
      Logger.warning('Could not parse url. Some required parameters are missing.', name: 'push_provider.dart#_handleIncomingRequestForeground');
      return;
    }

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

    Logger.info('Incoming push challenge for token with serial.', name: 'push_provider.dart#_handleIncomingChallenge');

    pushSubscriber?.newRequest(pushRequest);
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<void> _handleIncomingRequestBackground(RemoteMessage message) async {
    final data = message.data;
    Logger.info('Incoming push challenge.', name: 'push_provider.dart#_handleIncomingRequestBackground');
    Uri? requestUri = Uri.tryParse(data['url']);
    if (requestUri == null ||
        data['nonce'] == null ||
        data['serial'] == null ||
        data['signature'] == null ||
        data['title'] == null ||
        data['question'] == null) {
      Logger.warning('Could not parse url. Some required parameters are missing.', name: 'push_provider.dart#_handleIncomingRequestBackground');
      return;
    }

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

    Logger.info('Incoming push challenge for token with serial.', name: 'push_provider.dart#_handleIncomingRequestBackground');
    _addPushRequestToTokenInSecureStoreage(pushRequest);
  }

  static void _addPushRequestToTokenInSecureStoreage(PushRequest pushRequest) async {
    Logger.info('Adding push request to token in secure storage.', name: 'push_provider.dart#_addPushRequestToTokenInSecureStoreage');
    var tokens = await const SecureTokenRepository().loadTokens();
    PushToken? token = tokens.firstWhereOrNull((token) => token is PushToken && token.serial == pushRequest.serial) as PushToken?;
    if (token == null) {
      Logger.warning('Token not found.', name: 'push_provider.dart#_addPushRequestToTokenInSecureStoreage');
      return;
    }
    final prList = token.pushRequests;
    prList.add(pushRequest);
    token = token.copyWith(pushRequests: prList);
    await const SecureTokenRepository().saveOrReplaceTokens([token]);
  }

  void _startOrStopPolling(bool pollingEnabled) {
    // Start polling if enabled and not already polling
    if (pollingEnabled && _pollTimer == null) {
      Logger.info('Polling is enabled.', name: 'push_provider.dart#_startPollingIfEnabled');
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => pollForChallenges());
      pollForChallenges();
      return;
    }
    // Stop polling if it's disabled and currently polling
    if (!pollingEnabled && _pollTimer != null) {
      Logger.info('Polling is disabled.', name: 'push_provider.dart#_startPollingIfEnabled');
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
    if (pushTokens.isEmpty && globalRef?.read(settingsProvider).enablePolling == true) {
      Logger.info('No push token is available for polling, polling is disabled.', name: 'push_provider.dart#pollForChallenges');
      globalRef?.read(settingsProvider.notifier).setPolling(false);
      return null;
    }

    // Start request for each token
    Logger.info('Polling for challenges: ${pushTokens.length} Tokens', name: 'push_provider.dart#pollForChallenges');
    for (PushToken p in pushTokens) {
      pollForChallenge(p).then((errorMessage) {
        if (errorMessage != null && showMessageForEachToken) {
          Logger.warning(errorMessage, name: 'push_provider.dart#pollForChallenges');
          // TODO: Improve error message
          showMessage(message: errorMessage);
        }
      });
    }
    return null;
  }

  Future<String?> pollForChallenge(PushToken token) async {
    String timestamp = DateTime.now().toUtc().toIso8601String();

    String message = '${token.serial}|$timestamp';

    RsaUtils rsaUtils = instance == null ? PushProvider()._rsaUtils : instance!._rsaUtils;
    Logger.info(rsaUtils.runtimeType.toString(), name: 'push_provider.dart#pollForChallenge');
    String? signature = await rsaUtils.trySignWithToken(token, message);
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
      Response response = instance != null
          ? await instance!._ioClient.doGet(url: token.url!, parameters: parameters, sslVerify: token.sslVerify)
          : await const PrivacyIdeaIOClient().doGet(url: token.url!, parameters: parameters, sslVerify: token.sslVerify);

      switch (response.statusCode) {
        case 200:
          // The signature of this message must not be verified as each push
          // request gets verified independently.
          Map<String, dynamic> result = jsonDecode(response.body)['result'];
          List challengeList = result['value'].cast<Map<String, dynamic>>();

          for (Map<String, dynamic> challenge in challengeList) {
            Logger.info('Received challenge', name: 'push_provider.dart#pollForChallenge');
            _foregroundHandler(RemoteMessage(data: challenge));
          }
          break;

        case 403:
          Logger.warning('Polling push token failed with status code ${response.statusCode}',
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
    String? firebaseToken = await instance?.firebaseUtils?.getFBToken();

    if (firebaseToken != null && (await SecureTokenRepository.getCurrentFirebaseToken()) != firebaseToken) {
      try {
        await updateFirebaseToken(firebaseToken);
      } catch (error, stackTrace) {
        Logger.error('Could not update firebase token.', name: 'push_provider.dart#updateFbTokenIfChanged', error: error, stackTrace: stackTrace);
      }
    }
  }

  /// This method attempts to update the fbToken for all PushTokens that can be
  /// updated. I.e. all tokens that know the url of their respective privacyIDEA
  /// server.
  /// If the fbToken is not provided, it will be fetched from the firebase instance.
  /// If the fbToken is not available, this method will return null.
  /// Returns a tuple of two lists. The first list contains all tokens that
  /// could not be updated. The second list contains all tokens that do not
  /// support updating the fbToken.
  ///
  /// This should only be used to attempt to update the fbToken automatically,
  /// as this can not be guaranteed to work. There is a manual option available
  /// through the settings also.
  static Future<(List<PushToken>, List<PushToken>)?> updateFirebaseToken([String? firebaseToken]) async {
    firebaseToken ??= await instance?.firebaseUtils?.getFBToken();
    if (firebaseToken == null) {
      Logger.warning('Could not update firebase token because no firebase token is available.', name: 'push_provider.dart#_updateFirebaseToken');
      return null;
    }

    List<PushToken> tokenList = (await const SecureTokenRepository().loadTokens()).whereType<PushToken>().where((t) => t.url != null).toList();

    bool allUpdated = true;

    final List<PushToken> failedTokens = [];
    final List<PushToken> unsuportedTokens = [];

    for (PushToken p in tokenList) {
      if (p.url == null) {
        unsuportedTokens.add(p);
        continue;
      }
      // POST /ttype/push HTTP/1.1
      //Host: example.com
      //
      //new_fb_token=<new firebase token>
      //serial=<tokenserial>element
      //timestamp=<timestamp>
      //signature=SIGNATURE(<new firebase token>|<tokenserial>|<timestamp>)

      String timestamp = DateTime.now().toUtc().toIso8601String();
      String message = '$firebaseToken|${p.serial}|$timestamp';
      String? signature = await const RsaUtils().trySignWithToken(p, message);
      if (signature == null) {
        failedTokens.add(p);
        allUpdated = false;
        continue;
      }
      Response response = instance != null
          ? await instance!._ioClient.doPost(
              sslVerify: p.sslVerify, url: p.url!, body: {'new_fb_token': firebaseToken, 'serial': p.serial, 'timestamp': timestamp, 'signature': signature})
          : await const PrivacyIdeaIOClient().doPost(
              sslVerify: p.sslVerify, url: p.url!, body: {'new_fb_token': firebaseToken, 'serial': p.serial, 'timestamp': timestamp, 'signature': signature});

      if (response.statusCode == 200) {
        Logger.info('Updating firebase token for push token succeeded!', name: 'push_provider.dart#_updateFirebaseToken');
      } else {
        Logger.warning('Updating firebase token for push token failed!', name: 'push_provider.dart#_updateFirebaseToken');
        failedTokens.add(p);
        allUpdated = false;
      }
    }

    if (allUpdated) {
      SecureTokenRepository.setCurrentFirebaseToken(firebaseToken);
    }
    return (failedTokens, unsuportedTokens);
  }
}
