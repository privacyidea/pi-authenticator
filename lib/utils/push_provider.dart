/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

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
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';

import '../../../../../../../repo/secure_push_request_repository.dart';
import '../../../../../../../utils/pi_notifications.dart';
import '../model/push_request.dart';
import '../model/tokens/push_token.dart';
import '../repo/secure_token_repository.dart';
import 'firebase_utils.dart';
import 'globals.dart';
import 'logger.dart';
import 'privacyidea_io_client.dart';
import 'riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'rsa_utils.dart';
import 'utils.dart';

/// This class bundles all logic that is needed to handle incomig PushRequests, e.g.,
/// firebase, polling, notifications.
class PushProvider {
  static PushProvider? instance;
  // Needed for background handling
  static final _defaultPushRequestRepo = SecurePushRequestRepository();
  // Needed for background handling
  static final _defaultTokenRepo = SecureTokenRepository();

  bool pollingIsEnabled = false;
  Timer? _pollTimer;
  final List<Function(PushRequest)> _subscribers = [];

  FirebaseUtils _firebaseUtils;
  FirebaseUtils get firebaseUtils => _firebaseUtils;

  PrivacyideaIOClient _ioClient;
  PrivacyideaIOClient get ioClient => _ioClient;
  RsaUtils _rsaUtils;
  RsaUtils get rsaUtils => _rsaUtils;

  PushProvider._({
    FirebaseUtils? firebaseUtils,
    PrivacyideaIOClient? ioClient,
    RsaUtils? rsaUtils,
  })  : _firebaseUtils = firebaseUtils ?? FirebaseUtils(),
        _ioClient = ioClient ?? const PrivacyideaIOClient(),
        _rsaUtils = rsaUtils ?? const RsaUtils();

  Future<void> initFirebase() async {
    Logger.info('PushProvider: Initializing Firebase');
    try {
      if (_firebaseUtils.initializedFirebase) {
        Logger.warning('PushProvider: Firebase already initialized.');
      } else {
        await _firebaseUtils.initializeApp();
      }
      if (_firebaseUtils.initializedHandler) {
        Logger.warning('PushProvider: Firebase handler already initialized.');
      } else {
        await _firebaseUtils.setupHandler(
          foregroundHandler: _foregroundHandler,
          backgroundHandler: _backgroundHandler,
          updateFirebaseToken: updateAllFirebaseTokens,
        );
      }
      Logger.info('PushProvider: Firebase initialized.');
    } on IOException catch (e, s) {
      if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
        Logger.warning('Could not initialize Firebase.', error: e, stackTrace: s);
      } else {
        rethrow;
      }
    }
  }

  void setPollingEnabled(bool? enablePolling) {
    if (enablePolling == null) return;
    _startOrStopPolling(enablePolling);
    pollingIsEnabled = enablePolling;
  }

  factory PushProvider({
    bool? pollingEnabled,
    PrivacyideaIOClient? ioClient,
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
      Logger.warning('Could not parse push request data.', error: e, verbose: true);
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
      Logger.warning('Could not parse push request data.', error: e, verbose: true);
      rethrow;
    }
    return data;
  }

  // FOREGROUND HANDLING
  Future<void> _foregroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Foreground message received.');

    Map<String, dynamic> data;
    try {
      data = _getAndValidateDataFromRemoteMessage(remoteMessage);
    } on ArgumentError catch (_) {
      Logger.info('Failed to parse push request data. Trying to poll for challenges.');
      await pollForChallenges(isManually: true);
      return;
    }
    // Here we can be sure that the data is valid
    try {
      return _handleIncomingRequestForeground(data);
    } catch (e, s) {
      Logger.error(
        AppLocalizationsEn().unexpectedError,
        error: e,
        stackTrace: s,
      );
    }
  }

  // BACKGROUND HANDLING
  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage remoteMessage) async {
    Logger.info('Background message received.');

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
      Logger.error(
        'Something went wrong while handling the push request in the background.',
        error: e,
        stackTrace: s,
      );
      return;
    }
    if (!success) {
      Logger.warning('Handling the push request in the background failed.');
      return;
    }
    // PiNotifications.show('Push request', 'A new push request has been received.');
    if (remoteMessage.notification == null) {
      PiNotifications.show(
        // message:   (localization) => localization.notificationTitle,
        'Notification Title',
        // message:   (localization) => localization.notificationBody,
        'Notification Body',
      );
    }
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  Future<void> _handleIncomingRequestForeground(Map<String, dynamic> data) async {
    Logger.info('Incoming push challenge.');
    PushRequest pushRequest = PushRequest.fromMessageData(data);
    Logger.info("PushRequest.possibleAnswers: ${pushRequest.possibleAnswers}");
    Logger.info('Parsing data of push request succeeded.');
    final pushToken = (await globalRef?.read(tokenProvider.future))?.getTokenBySerial(pushRequest.serial);
    if (pushToken == null) {
      Logger.warning('No token found for serial ${pushRequest.serial}.');
      return;
    }
    if (!await pushRequest.verifySignature(pushToken, rsaUtils: _rsaUtils)) {
      Logger.warning('Signature verification failed.');
      return;
    }
    Logger.info('Signature verification succeeded, notifying ${_subscribers.length} subscribers.');
    for (var subscriber in _subscribers) {
      subscriber(pushRequest);
    }
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<bool> _handleIncomingRequestBackground(Map<String, dynamic> data) async {
    Logger.info('Incoming push challenge.');
    PushRequest pushRequest = PushRequest.fromMessageData(data);
    final pushToken = (await _defaultTokenRepo.loadTokens()).whereType<PushToken>().firstWhereOrNull((t) => t.serial == pushRequest.serial);
    if (pushToken == null) {
      Logger.warning('No token found for serial ${pushRequest.serial}.');
      return false;
    }
    if (!await pushRequest.verifySignature(pushToken)) {
      Logger.warning('Signature verification failed.');
      return false;
    }

    try {
      await _defaultPushRequestRepo.addRequest(pushRequest);
    } catch (e) {
      Logger.error('Could not save push request state.', error: e);
      return false;
    }
    return true;
  }

  void _startOrStopPolling(bool pollingEnabled) {
    // Start polling if enabled and not already polling
    if (pollingEnabled && _pollTimer == null) {
      Logger.info('Polling is enabled.');
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => pollForChallenges(isManually: false));
      pollForChallenges(isManually: false);
      return;
    }
    // Stop polling if it's disabled and currently polling
    if (!pollingEnabled && _pollTimer != null) {
      Logger.info('Polling is disabled.');
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    // Do nothing if polling is enabled and already polling or disabled and not polling
    return;
  }

  Future<void> pollForChallenges({required bool isManually}) async {
    // Get all push tokens
    final rolledOutPushTokens = await globalRef?.read(tokenProvider.selectAsync((state) => state.rolledOutPushTokens)) ?? [];
    // Disable polling if no push tokens exist
    if (rolledOutPushTokens.isEmpty) {
      if ((await globalRef?.read(settingsProvider.future))?.enablePolling == true) {
        Logger.info('No push token is available for polling, polling is disabled.');
        globalRef?.read(settingsProvider.notifier).setPolling(false);
      }
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (isManually) {
        Logger.info('Tried to poll without any internet connection available.');
        globalRef?.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (localization) => localization.pollingFailed,
          details: (localization) => localization.noNetworkConnection,
        );
      }
      return;
    }

    // Start request for each token
    Logger.info('Polling for challenges: ${rolledOutPushTokens.length} Tokens');
    final List<Future<void>> futures = [];
    for (PushToken p in rolledOutPushTokens) {
      futures.add(pollForChallenge(p, isManually: isManually));
    }
    await Future.wait(futures);
    return;
  }

  Future<void> pollForChallenge(PushToken token, {bool isManually = true}) async {
    if (instance == null) {
      Logger.warning('Polling push tokens failed. PushProvider is not initialized.');
      return;
    }
    String timestamp = DateTime.now().toUtc().toIso8601String();

    String message = '${token.serial}|$timestamp';

    RsaUtils rsaUtils = instance!._rsaUtils;
    Logger.info(rsaUtils.runtimeType.toString());
    String? signature = await rsaUtils.trySignWithToken(token, message);
    if (signature == null) {
      globalRef?.read(statusMessageProvider.notifier).state = StatusMessage(
        message: (localization) => localization.pollingFailedFor(token.serial),
        details: (localization) => localization.couldNotSignMessage,
      );
      Logger.warning('Polling push tokens failed because signing the message failed.');
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
          : await const PrivacyideaIOClient().doGet(url: token.url!, parameters: parameters, sslVerify: token.sslVerify);
    } catch (_) {
      if (isManually) {
        globalRef?.read(statusMessageProvider.notifier).state = StatusMessage(
          message: (localization) => localization.errorWhenPullingChallenges(token.serial),
          details: (localization) => localization.couldNotConnectToServer,
        );
      }
      return;
    }
    final List<Map<String, dynamic>> challengeList;

    switch (response.statusCode) {
      case 200:
        try {
          challengeList = _getAndValidateDataFromResponse(response);
        } catch (_) {
          if (isManually) {
            globalRef?.read(statusMessageProvider.notifier).state = StatusMessage(
              message: (localization) => localization.errorWhenPullingChallenges(token.serial),
              details: (localization) => localization.pushRequestParseError,
            );
          }
          return;
        }
        // Everything is fine, we can just continue
        break;

      case 403:
        final error = getErrorMessageFromResponse(response);
        if (isManually) {
          globalRef?.read(statusMessageProvider.notifier).state = StatusMessage(
            message: (localization) => localization.pollingFailedFor(token.serial),
            details: error != null ? (_) => error : (localization) => localization.statusCode(response.statusCode),
          );
        }
        Logger.warning('Polling push token failed with status code ${response.statusCode}', error: getErrorMessageFromResponse(response));
        return;

      default:
        final error = getErrorMessageFromResponse(response);
        if (isManually) {
          globalRef?.read(statusMessageProvider.notifier).state = StatusMessage(
            message: (localization) => localization.pollingFailedFor(token.serial),
            details: error != null ? (_) => error : (localization) => localization.statusCode(response.statusCode),
          );
        }
        return;
    }
    Logger.info('Received ${challengeList.length} challenge(s) for ${token.label}');

    for (Map<String, dynamic> challengeData in challengeList) {
      _handleIncomingRequestForeground((challengeData));
    }
    return;
  }

  Future<(List<PushToken>, List<PushToken>)?> updateAllFirebaseTokens({String? firebaseToken}) async =>
      globalRef?.read(tokenProvider.notifier).updateAllFirebaseTokens(firebaseToken: firebaseToken);

  void unsubscribe(void Function(PushRequest pushRequest) newRequest) => _subscribers.remove(newRequest);
  void subscribe(void Function(PushRequest pushRequest) newRequest) => _subscribers.add(newRequest);
}

/// This class is a placeholder for the [PushProvider] class. It does not do anything.
/// It is used to prevent the app from crashing when the features of the [PushProvider] are not available (e.g., on web).
class PlaceholderPushProvider implements PushProvider {
  @override
  FirebaseUtils _firebaseUtils = NoFirebaseUtils();
  @override
  FirebaseUtils get firebaseUtils => _firebaseUtils;
  @override
  PrivacyideaIOClient _ioClient = const PrivacyideaIOClient();
  @override
  PrivacyideaIOClient get ioClient => _ioClient;
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
  Future<(List<PushToken>, List<PushToken>)?> updateAllFirebaseTokens({String? firebaseToken}) => Future.value(null);
  @override
  Future<void> initFirebase() async {}
}