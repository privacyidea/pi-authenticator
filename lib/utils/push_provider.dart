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

  static Map<String, dynamic> _getAndValidateDataFromRemoteMessage(RemoteMessage remoteMessage) {
    final Map<String, dynamic> data;
    try {
      data = remoteMessage.data;
      PushRequest.verifyData(data);
    } on ArgumentError catch (e) {
      Logger.warning('Could not parse push request data.', name: 'push_provider.dart#_getAndValidateDataFromRemoteMessage', error: e, verbose: true);
      rethrow;
    }
    return data;
  }

  List<Map<String, dynamic>> _getAndValidateDataFromResponse(Response response) {
    final List<Map<String, dynamic>> data;
    try {
      data = jsonDecode(response.body)['result']['value'].cast<Map<String, dynamic>>();
      for (Map<String, dynamic> dataUnit in data) {
        // The signature of this message must not be verified as each push
        // request gets verified independently.
        PushRequest.verifyData(dataUnit);
      }
    } on ArgumentError catch (e) {
      Logger.warning('Could not parse push request data.', name: 'push_provider.dart#_getAndValidateDataFromResponse', error: e, verbose: true);
      rethrow;
    }
    return data;
  }

  // FOREGROUND HANDLING
  Future<void> _foregroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Foreground message received.', name: 'push_provider.dart#_foregroundHandler');

    await SecureTokenRepository.protect(() async {
      Map<String, dynamic> data;
      try {
        data = _getAndValidateDataFromRemoteMessage(remoteMessage);
      } on ArgumentError catch (_) {
        Logger.info('Try requesting the challenge by polling.', name: 'push_provider.dart#_foregroundHandler');
        await pollForChallenges(isManually: true);
        return;
      }
      // Here we can be sure that the data is valid
      try {
        return _handleIncomingRequestForeground(data);
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
      Map<String, dynamic> data;
      try {
        data = _getAndValidateDataFromRemoteMessage(remoteMessage);
      } on ArgumentError catch (_) {
        return;
      }
      // Here we can be sure that the data is valid
      try {
        return _handleIncomingRequestBackground(data);
      } catch (e, s) {
        Logger.error('Something went wrong while handling the push request in the background.',
            name: 'push_provider.dart#_backgroundHandler', error: e, stackTrace: s);
      }
    });
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  Future<void> _handleIncomingRequestForeground(Map<String, dynamic> data) async {
    Logger.info('Incoming push challenge.', name: 'push_provider.dart#_handleIncomingRequestForeground');
    PushRequest pushRequest = PushRequest.fromMessageData(data);
    Logger.info('Incoming push challenge for token with serial.', name: 'push_provider.dart#_handleIncomingChallenge');
    pushSubscriber?.newRequest(pushRequest);
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<void> _handleIncomingRequestBackground(Map<String, dynamic> data) async {
    Logger.info('Incoming push challenge.', name: 'push_provider.dart#_handleIncomingRequestBackground');
    PushRequest pushRequest = PushRequest.fromMessageData(data);
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
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => pollForChallenges(isManually: false));
      pollForChallenges(isManually: false);
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

  Future<void> pollForChallenges({required bool isManually}) async {
    // Get all push tokens
    await globalRef?.read(tokenProvider.notifier).isLoading;
    List<PushToken> pushTokens = globalRef?.read(tokenProvider).tokens.whereType<PushToken>().where((t) => t.isRolledOut && t.url != null).toList() ?? [];

    // Disable polling if no push tokens exist
    if (pushTokens.isEmpty) {
      await globalRef?.read(settingsProvider.notifier).isLoading;
      if (globalRef?.read(settingsProvider).enablePolling == true) {
        Logger.info('No push token is available for polling, polling is disabled.', name: 'push_provider.dart#pollForChallenges');
        globalRef?.read(settingsProvider.notifier).setPolling(false);
      }
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (isManually) {
        Logger.info('Tried to poll without any internet connection available.', name: 'push_provider.dart#pollForChallenges');
        globalRef?.read(statusMessageProvider.notifier).state = (
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.pollingFailed,
          AppLocalizations.of(globalNavigatorKey.currentContext!)!.noNetworkConnection,
        );
      }
      return;
    }

    // Start request for each token
    Logger.info('Polling for challenges: ${pushTokens.length} Tokens', name: 'push_provider.dart#pollForChallenges');
    final List<Future<void>> futures = [];
    for (PushToken p in pushTokens) {
      futures.add(pollForChallenge(p, isManually: isManually));
    }
    await Future.wait(futures);
    return;
  }

  Future<void> pollForChallenge(PushToken token, {bool isManually = true}) async {
    String timestamp = DateTime.now().toUtc().toIso8601String();

    String message = '${token.serial}|$timestamp';

    RsaUtils rsaUtils = instance == null ? PushProvider()._rsaUtils : instance!._rsaUtils;
    Logger.info(rsaUtils.runtimeType.toString(), name: 'push_provider.dart#pollForChallenge');
    String? signature = await rsaUtils.trySignWithToken(token, message);
    if (signature == null) {
      globalRef?.read(statusMessageProvider.notifier).state = (
        AppLocalizations.of(globalNavigatorKey.currentContext!)!.pollingFailedFor(token.serial),
        AppLocalizations.of(globalNavigatorKey.currentContext!)!.couldNotSignMessage,
      );
      Logger.warning('Polling push tokens failed because signing the message failed.', name: 'push_provider.dart#pollForChallenge');
      return;
    }
    Map<String, String> parameters = {
      'serial': token.serial,
      'timestamp': timestamp,
      'signature': signature,
    };

    final Response response;

    try {
      response = instance != null
          ? await instance!._ioClient.doGet(url: token.url!, parameters: parameters, sslVerify: token.sslVerify)
          : await const PrivacyIdeaIOClient().doGet(url: token.url!, parameters: parameters, sslVerify: token.sslVerify);
    } catch (e) {
      globalRef?.read(statusMessageProvider.notifier).state = (
        AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorWhenPullingChallenges(token.serial),
        null,
      );
      return;
    }
    final List<Map<String, dynamic>> challengeList;
    switch (response.statusCode) {
      case 200:
        try {
          challengeList = _getAndValidateDataFromResponse(response);
        } catch (_) {
          if (isManually) {
            globalRef?.read(statusMessageProvider.notifier).state = (
              AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorWhenPullingChallenges(token.serial),
              AppLocalizations.of(globalNavigatorKey.currentContext!)!.pushRequestParseError,
            );
          }
          return;
        }

        // Everything is fine, we can just continue
        break;

      case 403:
        final error = getErrorMessageFromResponse(response);
        if (isManually) {
          globalRef?.read(statusMessageProvider.notifier).state = (
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.pollingFailedFor(token.serial),
            error ?? AppLocalizations.of(globalNavigatorKey.currentContext!)!.statusCode(response.statusCode),
          );
        }
        Logger.warning('Polling push token failed with status code ${response.statusCode}',
            name: 'push_provider.dart#pollForChallenge', error: getErrorMessageFromResponse(response));
        return;

      default:
        final error = getErrorMessageFromResponse(response);
        if (isManually) {
          globalRef?.read(statusMessageProvider.notifier).state = (
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.pollingFailedFor(token.serial),
            error ?? AppLocalizations.of(globalNavigatorKey.currentContext!)!.statusCode(response.statusCode),
          );
        }
        return;
    }
    Logger.info('Received ${challengeList.length} challenge(s) for ${token.label}', name: 'push_provider.dart#pollForChallenge');
    for (Map<String, dynamic> challengeData in challengeList) {
      _handleIncomingRequestForeground((challengeData));
    }
    return;
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
