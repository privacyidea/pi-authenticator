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
import 'package:privacyidea_authenticator/repo/secure_push_request_repository.dart';
import 'package:privacyidea_authenticator/utils/pi_notifications.dart';

import '../l10n/app_localizations.dart';
import '../model/push_request.dart';
import '../model/tokens/push_token.dart';
import '../repo/secure_token_repository.dart';
import 'firebase_utils.dart';
import 'globals.dart';
import 'logger.dart';
import 'network_utils.dart';
import 'riverpod_providers.dart';
import 'rsa_utils.dart';
import 'utils.dart';

/// This class bundles all logic that is needed to handle incomig PushRequests, e.g.,
/// firebase, polling, notifications.
class PushProvider {
  static PushProvider? instance;
  // Needed for background handling
  static const _defaultPushRequestRepo = SecurePushRequestRepository();
  // Needed for background handling
  static const _defaultTokenRepo = SecureTokenRepository();

  bool pollingIsEnabled = false;
  Timer? _pollTimer;
  final List<Function(PushRequest)> _subscribers = [];

  FirebaseUtils _firebaseUtils;
  FirebaseUtils get firebaseUtils => _firebaseUtils;
  PrivacyIdeaIOClient _ioClient;
  PrivacyIdeaIOClient get ioClient => _ioClient;
  RsaUtils _rsaUtils;
  RsaUtils get rsaUtils => _rsaUtils;

  PushProvider._({
    FirebaseUtils? firebaseUtils,
    PrivacyIdeaIOClient? ioClient,
    RsaUtils? rsaUtils,
  })  : _firebaseUtils = firebaseUtils ?? FirebaseUtils(),
        _ioClient = ioClient ?? const PrivacyIdeaIOClient(),
        _rsaUtils = rsaUtils ?? const RsaUtils() {
    _firebaseUtils.initFirebase(
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
    FirebaseUtils? firebaseUtils,
  }) {
    if (instance == null) {
      instance = PushProvider._(
        ioClient: ioClient,
        rsaUtils: rsaUtils,
        firebaseUtils: firebaseUtils,
      );
    } else {
      if (ioClient != null) {
        instance!._ioClient = ioClient;
      }
      if (rsaUtils != null) {
        instance!._rsaUtils = rsaUtils;
      }
      if (firebaseUtils != null) {
        instance!._firebaseUtils = firebaseUtils;
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

    Map<String, dynamic> data;
    try {
      data = _getAndValidateDataFromRemoteMessage(remoteMessage);
    } on ArgumentError catch (_) {
      Logger.info('Failed to parse push request data. Trying to poll for challenges.', name: 'push_provider.dart#_foregroundHandler');
      await pollForChallenges(isManually: true);
      return;
    }
    // Here we can be sure that the data is valid
    try {
      return _handleIncomingRequestForeground(data);
    } catch (e, s) {
      Logger.error(
        AppLocalizations.of(globalNavigatorKey.currentContext!)!.unexpectedError,
        name: 'push_provider.dart#_foregroundHandler',
        error: e,
        stackTrace: s,
      );
    }
  }

  // BACKGROUND HANDLING
  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Background message received.', name: 'push_provider.dart#_backgroundHandler');

    Map<String, dynamic> data;
    try {
      data = _getAndValidateDataFromRemoteMessage(remoteMessage);
    } on ArgumentError catch (_) {
      return;
    }
    // Here we can be sure that the data is valid
    final bool success;
    try {
      success = await _handleIncomingRequestBackground(data);
    } catch (e, s) {
      Logger.error('Something went wrong while handling the push request in the background.',
          name: 'push_provider.dart#_backgroundHandler', error: e, stackTrace: s);
      return;
    }
    if (!success) {
      Logger.warning('Handling the push request in the background failed.', name: 'push_provider.dart#_backgroundHandler');
      return;
    }
    // PiNotifications.show('Push request', 'A new push request has been received.');
    if (remoteMessage.notification == null) {
      PiNotifications.show(
        // AppLocalizations.of(globalNavigatorKey.currentContext!)!.notificationTitle,
        'Notification Title',
        // AppLocalizations.of(globalNavigatorKey.currentContext!)!.notificationBody,
        'Notification Body',
      );
    }
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  Future<void> _handleIncomingRequestForeground(Map<String, dynamic> data) async {
    Logger.info('Incoming push challenge.', name: 'push_provider.dart#_handleIncomingRequestForeground');
    PushRequest pushRequest = PushRequest.fromMessageData(data);
    Logger.info("PushRequest.possibleAnswers: ${pushRequest.possibleAnswers}", name: 'push_provider.dart#_handleIncomingRequestForeground');
    Logger.info('Parsing data of push request succeeded.', name: 'push_provider.dart#_handleIncomingRequestForeground');
    final pushToken = globalRef?.read(tokenProvider).getTokenBySerial(pushRequest.serial);
    if (pushToken == null) {
      Logger.warning('No token found for serial ${pushRequest.serial}.', name: 'push_provider.dart#_handleIncomingRequestForeground');
      return;
    }
    if (!await pushRequest.verifySignature(pushToken, rsaUtils: _rsaUtils)) {
      Logger.warning('Signature verification failed.', name: 'push_provider.dart#_handleIncomingRequestForeground');
      return;
    }
    Logger.info('Signature verification succeeded, notifying ${_subscribers.length} subscribers.', name: 'push_provider.dart#_handleIncomingRequestForeground');
    for (var subscriber in _subscribers) {
      subscriber(pushRequest);
    }
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<bool> _handleIncomingRequestBackground(Map<String, dynamic> data) async {
    Logger.info('Incoming push challenge.', name: 'push_provider.dart#_handleIncomingRequestBackground');
    PushRequest pushRequest = PushRequest.fromMessageData(data);
    final pushToken = (await _defaultTokenRepo.loadTokens()).whereType<PushToken>().firstWhereOrNull((t) => t.serial == pushRequest.serial);
    if (pushToken == null) {
      Logger.warning('No token found for serial ${pushRequest.serial}.', name: 'push_provider.dart#_handleIncomingRequestBackground');
      return false;
    }
    if (!await pushRequest.verifySignature(pushToken)) {
      Logger.warning('Signature verification failed.', name: 'push_provider.dart#_handleIncomingRequestBackground');
      return false;
    }

    try {
      await _defaultPushRequestRepo.add(pushRequest);
    } catch (e) {
      Logger.error('Could not save push request state.', name: 'push_provider.dart#_handleIncomingRequestBackground', error: e);
      return false;
    }
    return true;
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
    await globalRef?.read(tokenProvider.notifier).initState;
    List<PushToken> pushTokens = globalRef?.read(tokenProvider).tokens.whereType<PushToken>().where((t) => t.isRolledOut && t.url != null).toList() ?? [];
    // Disable polling if no push tokens exist
    if (pushTokens.isEmpty) {
      await globalRef?.read(settingsProvider.notifier).loadingRepo;
      if (globalRef?.read(settingsProvider).enablePolling == true) {
        Logger.info('No push token is available for polling, polling is disabled.', name: 'push_provider.dart#pollForChallenges');
        globalRef?.read(settingsProvider.notifier).setPolling(false);
      }
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
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
    if (instance == null) {
      Logger.warning('Polling push tokens failed. PushProvider is not initialized.', name: 'push_provider.dart#pollForChallenge');
      return;
    }
    String timestamp = DateTime.now().toUtc().toIso8601String();

    String message = '${token.serial}|$timestamp';

    RsaUtils rsaUtils = instance!._rsaUtils;
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

  Future<(List<PushToken>, List<PushToken>)?> updateFirebaseToken([String? firebaseToken]) async =>
      globalRef?.read(tokenProvider.notifier).updateFirebaseToken(firebaseToken);

  void unsubscribe(void Function(PushRequest pushRequest) newRequest) => _subscribers.remove(newRequest);
  void subscribe(void Function(PushRequest pushRequest) newRequest) => _subscribers.add(newRequest);
}

class PlaceholderPushProvider implements PushProvider {
  @override
  FirebaseUtils _firebaseUtils = FirebaseUtils();
  @override
  FirebaseUtils get firebaseUtils => _firebaseUtils;
  @override
  PrivacyIdeaIOClient _ioClient = const PrivacyIdeaIOClient();
  @override
  PrivacyIdeaIOClient get ioClient => _ioClient;
  @override
  RsaUtils _rsaUtils = const RsaUtils();
  @override
  RsaUtils get rsaUtils => _rsaUtils;
  @override
  Timer? _pollTimer;
  @override
  bool pollingIsEnabled = false;
  @override
  Future<void> _foregroundHandler(RemoteMessage remoteMessage) async {}
  @override
  List<Map<String, dynamic>> _getAndValidateDataFromResponse(Response response) => [];
  @override
  Future<void> _handleIncomingRequestForeground(Map<String, dynamic> data) async {}
  @override
  void _startOrStopPolling(bool pollingEnabled) {}
  @override
  List<Function(PushRequest p1)> get _subscribers => [];
  @override
  Future<void> pollForChallenge(PushToken token, {bool isManually = true}) async {}
  @override
  Future<void> pollForChallenges({required bool isManually}) async {}
  @override
  void setPollingEnabled(bool? enablePolling) {}
  @override
  void subscribe(void Function(PushRequest pushRequest) newRequest) {}
  @override
  void unsubscribe(void Function(PushRequest pushRequest) newRequest) {}

  @override
  Future<(List<PushToken>, List<PushToken>)?> updateFirebaseToken([String? firebaseToken]) => Future.value(null);
}
