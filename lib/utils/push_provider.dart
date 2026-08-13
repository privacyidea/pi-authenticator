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
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../../../repo/secure_push_request_repository.dart';
import '../../../../../../../utils/pi_notifications.dart';
import '../model/push_request/push_capabilities.dart';
import '../model/push_request/push_requests.dart';
import '../model/tokens/push_token.dart';
import '../repo/secure_token_repository.dart';
import 'firebase_utils.dart';
import 'globals.dart';
import 'helpers/json_canonicalizer.dart';
import 'lock_auth.dart';
import 'logger.dart';
import 'privacyidea_io_client.dart';
import 'riverpod/riverpod_providers/generated_providers/localization_notifier.dart';
import 'riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'rsa_utils.dart';
import 'biometric_push_key_manager.dart';
import 'utils.dart';

@visibleForTesting
Future<void> runPushPollingRequests<T>(
  Iterable<T> targets, {
  required bool sequential,
  required Future<void> Function(T target) request,
}) async {
  if (sequential) {
    for (final target in targets) {
      await request(target);
    }
    return;
  }
  await Future.wait(targets.map(request));
}

/// Authorizes access to a weak-biometric Push private key kept in Dart.
///
/// Automatic polling must never use such a key because it cannot safely open
/// an interactive biometric prompt. Manual polling must authenticate for each
/// use. Native protected keys are authorized by their crypto-bound prompt and
/// therefore bypass this compatibility gate.
@visibleForTesting
Future<bool> authorizePushDartKeyUseForPolling(
  PushToken token, {
  required bool isManually,
  required Future<bool> Function() authenticate,
}) async {
  if (!token.requiresBiometricPromptBeforeDartKeyUse) return true;
  if (!isManually) return false;
  return authenticate();
}

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
  bool _pollInProgress = false;
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
  }) : _firebaseUtils = firebaseUtils ?? FirebaseUtils(),
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
        Logger.warning(
          'Could not initialize Firebase.',
          error: e,
          stackTrace: s,
        );
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

  static Map<String, dynamic> _getAndValidateDataFromRemoteMessage(
    RemoteMessage remoteMessage,
  ) {
    final Map<String, dynamic> data;
    try {
      data = remoteMessage.data;
      PushRequest.verifyMessageData(data);
    } on ArgumentError catch (e) {
      Logger.warning(
        'Could not parse push request data.',
        error: e,
        verbose: true,
      );
      rethrow;
    }
    return data;
  }

  List<Map<String, dynamic>> _getAndValidateDataFromResponse(
    Response response,
  ) {
    final List<Map<String, dynamic>> data;
    try {
      data = jsonDecode(
        response.body,
      )['result']['value'].cast<Map<String, dynamic>>();
      for (Map<String, dynamic> dataUnit in data) {
        // The signature of this message must not be verified as each push
        // request gets verified independently.
        PushRequest.verifyMessageData(dataUnit);
      }
    } on ArgumentError catch (e) {
      Logger.warning(
        'Could not parse push request data.',
        error: e,
        verbose: true,
      );
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
      Logger.info(
        'Failed to parse push request data. Trying to poll for challenges.',
      );
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
  Future<void> _handleIncomingRequestForeground(
    Map<String, dynamic> data,
  ) async {
    Logger.info('Incoming push challenge.');
    PushRequest pushRequest = PushRequestFactory.fromMessageData(data);

    Logger.info('Parsing data of push request succeeded.');
    final pushToken = (await globalRef?.read(
      tokenProvider.future,
    ))?.getTokenBySerial(pushRequest.serial);
    if (pushToken == null) {
      Logger.warning('No token found for serial ${pushRequest.serial}.');
      return;
    }
    if (!pushToken.isRolledOut) {
      Logger.warning(
        'Rejected push request for token ${pushRequest.serial} because the '
        'token is not rolled out.',
      );
      return;
    }
    if (!pushRequest.verifySignature(pushToken, rsaUtils: _rsaUtils)) {
      Logger.warning('Signature verification failed.');
      return;
    }
    Logger.info(
      'Signature verification succeeded, notifying ${_subscribers.length} subscribers.',
    );
    for (var subscriber in _subscribers) {
      subscriber(pushRequest);
    }
  }

  // HANDLING
  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<bool> _handleIncomingRequestBackground(
    Map<String, dynamic> data,
  ) async {
    Logger.info('Incoming push challenge.');
    PushRequest pushRequest = PushRequestFactory.fromMessageData(data);
    final pushToken = (await _defaultTokenRepo.loadTokens())
        .whereType<PushToken>()
        .firstWhereOrNull((t) => t.serial == pushRequest.serial);
    if (pushToken == null) {
      Logger.warning('No token found for serial ${pushRequest.serial}.');
      return false;
    }
    if (!pushToken.isRolledOut) {
      Logger.warning(
        'Rejected push request for token ${pushRequest.serial} because the '
        'token is not rolled out.',
      );
      return false;
    }
    if (!pushRequest.verifySignature(pushToken)) {
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
      _pollTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => pollForChallenges(isManually: false),
      );
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
    if (_pollInProgress) {
      Logger.info('Skipping overlapping Push polling request.');
      return;
    }
    _pollInProgress = true;
    try {
      await _pollForChallenges(isManually: isManually);
    } finally {
      _pollInProgress = false;
    }
  }

  Future<void> _pollForChallenges({required bool isManually}) async {
    // Get all push tokens
    final rolledOutPushTokens =
        await globalRef?.read(
          tokenProvider.selectAsync((state) => state.rolledOutPushTokens),
        ) ??
        [];
    // Disable polling if no push tokens exist
    if (rolledOutPushTokens.isEmpty) {
      if ((await globalRef?.read(settingsProvider.future))?.enablePolling ==
          true) {
        Logger.info(
          'No push token is available for polling, polling is disabled.',
        );
        globalRef?.read(settingsProvider.notifier).setPolling(false);
      }
      return;
    }

    // An auth-per-use key would otherwise open a biometric prompt every three
    // seconds. Such tokens can still be polled explicitly; FCM delivery remains
    // available without using the private key.
    final tokensToPoll = isManually
        ? rolledOutPushTokens
        : rolledOutPushTokens
              .where(
                (token) =>
                    token.forceBiometricOption !=
                    ForceBiometricOption.biometric,
              )
              .toList();
    if (tokensToPoll.isEmpty) {
      Logger.info(
        'Automatic polling skipped because all Push keys require per-use biometrics.',
      );
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (isManually) {
        Logger.info('Tried to poll without any internet connection available.');
        showErrorStatusMessage(
          message: (localization) => localization.pollingFailed,
          details: (localization) => localization.noNetworkConnection,
        );
      }
      return;
    }

    // Start request for each token
    Logger.info('Polling for challenges: ${tokensToPoll.length} Tokens');
    // Manual polling can include several auth-per-use keys. Run those requests
    // one after another so Android/iOS never receive competing biometric
    // prompts. Automatic polling contains only non-protected keys and can stay
    // parallel.
    await runPushPollingRequests(
      tokensToPoll,
      sequential: isManually,
      request: (token) => pollForChallenge(token, isManually: isManually),
    );
  }

  Future<void> pollForChallenge(
    PushToken token, {
    bool isManually = true,
  }) async {
    if (instance == null) {
      Logger.warning(
        'Polling push tokens failed. PushProvider is not initialized.',
      );
      return;
    }
    final ref = globalRef;
    if (ref == null) {
      Logger.warning('Polling requires the current token state.');
      return;
    }
    final challengeList = await ref
        .read(tokenProvider.notifier)
        .withCurrentPushTokenLease<List<Map<String, dynamic>>>(token.id, (
          leasedToken,
          persist,
          current,
        ) async {
          if (leasedToken.isBiometricKeyInvalidated ||
              leasedToken.url == null) {
            if (leasedToken.isBiometricKeyInvalidated) {
              showErrorStatusMessage(
                message: (localization) =>
                    localization.biometricPushTokenInvalidTitle,
                details: (localization) =>
                    localization.biometricPushTokenInvalidBody,
              );
            }
            return null;
          }

          // Weak-biometric compatibility mode cannot bind a cryptographic key
          // on Android. Automatic callers fail closed; an explicit manual poll
          // receives one biometric-only prompt before each Dart-key signature.
          final authorized = await authorizePushDartKeyUseForPolling(
            leasedToken,
            isManually: isManually,
            authenticate: () => lockAuthWithSettings(
              ref: ref,
              localization: ref.read(localizationProvider),
              reason: (l) => l.biometricPushKeyAuthReason,
              forceBiometricOption: ForceBiometricOption.biometric,
            ),
          );
          if (!authorized) return null;

          final timestamp = DateTime.now().toUtc().toIso8601String();
          final message = '${leasedToken.serial}|$timestamp';
          final rsaUtils = instance!._rsaUtils;
          String? signature;
          try {
            signature = await rsaUtils.trySignWithToken(
              leasedToken,
              message,
              onTokenChanged: (updatedToken) async {
                final persisted = await persist(
                  current().copyWith(
                    privateTokenKey: () => updatedToken.privateTokenKey,
                    biometricKeyStatus: updatedToken.biometricKeyStatus,
                  ),
                );
                return persisted != null &&
                    persisted.privateTokenKey == updatedToken.privateTokenKey &&
                    persisted.biometricKeyStatus ==
                        updatedToken.biometricKeyStatus;
              },
            );
          } on BiometricPushKeyException catch (error) {
            if (error.isInvalidated) {
              showErrorStatusMessage(
                message: (localization) =>
                    localization.biometricPushTokenInvalidTitle,
                details: (localization) =>
                    localization.biometricPushTokenInvalidBody,
              );
            } else if (error.isStateNotPersisted) {
              showErrorStatusMessage(
                message: (localization) =>
                    localization.biometricPushKeyPersistenceFailedTitle,
                details: (localization) =>
                    localization.biometricPushKeyPersistenceFailed,
              );
            } else if (isManually) {
              showErrorStatusMessage(
                message: (localization) =>
                    localization.pollingFailedFor(leasedToken.serial),
                details: (localization) => localization.couldNotSignMessage,
              );
            }
            return null;
          }
          if (signature == null || current().isBiometricKeyInvalidated) {
            if (isManually) {
              showErrorStatusMessage(
                message: (localization) =>
                    localization.pollingFailedFor(leasedToken.serial),
                details: (localization) => localization.couldNotSignMessage,
              );
            }
            return null;
          }

          final Response response;
          try {
            response = await instance!._ioClient.doGet(
              url: current().url!,
              parameters: {
                'serial': current().serial,
                'timestamp': timestamp,
                'signature': signature,
                // Not part of the signed message. Older servers ignore it,
                // while capable servers update the token's feature set.
                'capabilities': canonicalizeJson(appPushCapabilities.names),
              },
              sslVerify: current().sslVerify,
            );
          } catch (_) {
            if (isManually) {
              showErrorStatusMessage(
                message: (localization) =>
                    localization.errorWhenPullingChallenges(current().serial),
                details: (localization) => localization.couldNotConnectToServer,
              );
            }
            return null;
          }

          switch (response.statusCode) {
            case 200:
              try {
                return _getAndValidateDataFromResponse(response);
              } catch (_) {
                if (isManually) {
                  showErrorStatusMessage(
                    message: (localization) => localization
                        .errorWhenPullingChallenges(current().serial),
                    details: (localization) =>
                        localization.pushRequestParseError,
                  );
                }
                return null;
              }
            case 403:
              final error = getErrorMessageFromResponse(response);
              if (isManually) {
                showErrorStatusMessage(
                  message: (localization) =>
                      localization.pollingFailedFor(current().serial),
                  details: error != null
                      ? (_) => error
                      : (localization) =>
                            localization.statusCode(response.statusCode),
                );
              }
              Logger.warning(
                'Polling push token failed with status code ${response.statusCode}',
                error: error,
              );
              return null;
            default:
              final error = getErrorMessageFromResponse(response);
              if (isManually) {
                showErrorStatusMessage(
                  message: (localization) =>
                      localization.pollingFailedFor(current().serial),
                  details: error != null
                      ? (_) => error
                      : (localization) =>
                            localization.statusCode(response.statusCode),
                );
              }
              return null;
          }
        });
    if (challengeList == null) return;
    Logger.info(
      'Received ${challengeList.length} challenge(s) for ${token.label}',
    );

    for (Map<String, dynamic> challengeData in challengeList) {
      _handleIncomingRequestForeground((challengeData));
    }
    return;
  }

  Future<(List<PushToken>, List<PushToken>)?> updateAllFirebaseTokens({
    String? firebaseToken,
  }) async => globalRef
      ?.read(tokenProvider.notifier)
      .updateAllFirebaseTokens(firebaseToken: firebaseToken);

  void unsubscribe(void Function(PushRequest pushRequest) newRequest) =>
      _subscribers.remove(newRequest);
  void subscribe(void Function(PushRequest pushRequest) newRequest) =>
      _subscribers.add(newRequest);
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
  bool _pollInProgress = false;
  @override
  bool pollingIsEnabled = false;
  @override
  Future<void> _foregroundHandler(RemoteMessage remoteMessage) async {}
  @override
  List<Map<String, dynamic>> _getAndValidateDataFromResponse(
    Response response,
  ) => [];
  @override
  Future<void> _handleIncomingRequestForeground(
    Map<String, dynamic> data,
  ) async {}
  @override
  void _startOrStopPolling(bool pollingEnabled) {}
  @override
  List<Function(PushRequest p1)> get _subscribers => [];
  @override
  Future<void> pollForChallenge(
    PushToken token, {
    bool isManually = true,
  }) async {}
  @override
  Future<void> pollForChallenges({required bool isManually}) async {}
  @override
  Future<void> _pollForChallenges({required bool isManually}) async {}
  @override
  void setPollingEnabled(bool? enablePolling) {}
  @override
  void subscribe(void Function(PushRequest pushRequest) newRequest) {}
  @override
  void unsubscribe(void Function(PushRequest pushRequest) newRequest) {}
  @override
  Future<(List<PushToken>, List<PushToken>)?> updateAllFirebaseTokens({
    String? firebaseToken,
  }) => Future.value();
  @override
  Future<void> initFirebase() async {}
}
