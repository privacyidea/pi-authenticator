/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/repo/secure_storage_mutexed.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import '../../../../../../../utils/view_utils.dart';
import 'globals.dart';
import 'identifiers.dart';
import 'logger.dart';

class FirebaseUtils {
  static FirebaseUtils? _instance;
  final Mutex _initFbMutex = Mutex();
  bool initializedFirebase = false;
  final Mutex _initHandlerMutex = Mutex();
  bool initializedHandler = false;

  FirebaseUtils._();

  factory FirebaseUtils() {
    if (_instance != null) return _instance!;
    if (deviceHasFirebaseMessaging) {
      _instance ??= FirebaseUtils._();
    } else {
      _instance ??= NoFirebaseUtils();
    }

    return _instance!;
  }

  /// Must be used in the main method before runApp() is called.
  Future<FirebaseApp?> initializeApp() async {
    await _initFbMutex.acquire();
    try {
      if (initializedFirebase) {
        Logger.warning('Firebase already initialized');
        _initFbMutex.release();
        return null;
      }
      assert(appFirebaseOptions != null, 'Firebase options must be set before initializing Firebase');
      final FirebaseOptions options = appFirebaseOptions!;
      final app = await Firebase.initializeApp(name: "fb-${options.projectId}", options: options);
      await app.setAutomaticDataCollectionEnabled(false);
      initializedFirebase = true;
      assert(app.isAutomaticDataCollectionEnabled == false, 'Automatic data collection should be disabled');
      _initFbMutex.release();
      return app;
    } catch (e, s) {
      _initFbMutex.release();
      Logger.error('Error while initializing Firebase', error: e, stackTrace: s);
      return null;
    }
  }

  /// This method sets up the Firebase messaging handler for the app. It must be called after initializeApp().
  Future<void> setupHandler({
    required Future<void> Function(RemoteMessage) foregroundHandler,
    required Future<void> Function(RemoteMessage) backgroundHandler,
    required dynamic Function({String? firebaseToken}) updateFirebaseToken,
  }) async {
    await _initFbMutex.acquire();
    if (!initializedFirebase) {
      Logger.error('Initialize Firebase before setting up the handler');
      _initFbMutex.release();
      return;
    }
    _initFbMutex.release();
    await _initHandlerMutex.acquire();
    if (initializedHandler) {
      Logger.warning('Firebase handler already initialized');
      return;
    }

    Logger.info('FirebaseUtils: Initializing Firebase');

    FirebaseMessaging.onMessage.listen(foregroundHandler);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    try {
      String? firebaseToken = await getFBToken();

      if (firebaseToken != await getCurrentFirebaseToken() && firebaseToken != null) {
        updateFirebaseToken(firebaseToken: firebaseToken);
      }
    } catch (error, stackTrace) {
      if (error is PlatformException) {
        if (error.code == FIREBASE_TOKEN_ERROR_CODE) return; // ignore
        showErrorStatusMessage(
          message: (l) => l.pushInitializeUnavailable,
          details: (_) => '${error.code}: ${error.message ?? 'no error message'}',
        );
      }
      if (error is FirebaseException) {
        if (error.code == FIREBASE_TOKEN_ERROR_CODE) return; // ignore
        showErrorStatusMessage(
          message: (l) => l.pushInitializeUnavailable,
          details: (_) => '${error.code}: ${error.message ?? 'no error message'}',
        );
      }

      Logger.error('Unknown Firebase error', error: error, stackTrace: stackTrace);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      if ((await getCurrentFirebaseToken()) != newToken) {
        await setNewFirebaseToken(newToken);
        // TODO what if this fails, when should a retry be attempted?
        try {
          updateFirebaseToken(firebaseToken: newToken);
        } catch (error, stackTrace) {
          Logger.error('Error updating firebase token', error: error, stackTrace: stackTrace);
        }
      }
    });

    initializedHandler = true;
    _initHandlerMutex.release();
  }

  /// Returns the current firebase token of the app / device. Throws a
  /// PlatformException with a custom error code if retrieving the firebase
  /// token failed. This may happen if, e.g., no network connection is available.
  Future<String?> getFBToken() async {
    String? firebaseToken;
    try {
      firebaseToken = await FirebaseMessaging.instance.getToken();
    } on FirebaseException catch (e, s) {
      String errorMessage = e.message ?? 'no error message';
      Logger.warning('Unable to retrieve Firebase token! ($errorMessage: ${e.code})', error: e, stackTrace: s);
    }

    // Fall back to the last known firebase token
    if (firebaseToken == null) {
      firebaseToken = await getCurrentFirebaseToken();
    } else {
      Logger.info('New Firebase token retrieved');
      await setNewFirebaseToken(firebaseToken);
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

  // ###########################################################################
  // FIREBASE CONFIG
  // ###########################################################################
  static const _FIREBASE_TOKEN_KEY_PREFIX_LEGACY = GLOBAL_SECURE_REPO_PREFIX_LEGACY;
  static const _CURRENT_APP_TOKEN_KEY_LEGACY = 'CURRENT_APP_TOKEN';
  static const _NEW_APP_TOKEN_KEY_LEGACY = 'NEW_APP_TOKEN';

  static const _FIREBASE_TOKEN_KEY_PREFIX = '${GLOBAL_SECURE_REPO_PREFIX}_firebase';
  static const _CURRENT_APP_TOKEN_KEY = 'current';
  static const _NEW_APP_TOKEN_KEY = 'new';

  static final _storageLegacy = SecureStorageMutexed.legacy(storagePrefix: _FIREBASE_TOKEN_KEY_PREFIX_LEGACY);
  static final _storage = SecureStorageMutexed.create(storagePrefix: _FIREBASE_TOKEN_KEY_PREFIX);

  Future<bool> deleteFirebaseToken() async {
    Logger.info('Deleting firebase token..');
    try {
      final app = await Firebase.initializeApp();
      await app.setAutomaticDataCollectionEnabled(false);
      await FirebaseMessaging.instance.deleteToken();
      Logger.warning('Firebase token deleted from Firebase');
    } on FirebaseException catch (e) {
      if (e.message?.contains('IOException') == true) throw SocketException(e.message!);
      rethrow;
    }
    await _storage.delete(key: _CURRENT_APP_TOKEN_KEY);
    await _storage.delete(key: _NEW_APP_TOKEN_KEY);
    Logger.info('Firebase token deleted from secure storage');
    return true;
  }

  Future<void> setCurrentFirebaseToken(String str) {
    Logger.info('Setting current firebase token');
    return _storage.write(key: _CURRENT_APP_TOKEN_KEY, value: str);
  }

  Future<String?> getCurrentFirebaseToken() async {
    final current = await _storage.read(key: _CURRENT_APP_TOKEN_KEY);
    if (current != null) return current;
    final legacyCurrent = await _storageLegacy.read(key: _CURRENT_APP_TOKEN_KEY_LEGACY);
    if (legacyCurrent != null) {
      Logger.info('Loaded legacy current firebase token from secure storage');
      await _storage.write(key: _CURRENT_APP_TOKEN_KEY, value: legacyCurrent);
      await _storageLegacy.delete(key: _CURRENT_APP_TOKEN_KEY_LEGACY);
      Logger.info('Migrated legacy current firebase token to new secure storage');
      return legacyCurrent;
    }
    return null;
  }

  // This is used for checking if the token was updated.
  Future<void> setNewFirebaseToken(String str) {
    Logger.info('Setting new firebase token');
    return _storage.write(key: _NEW_APP_TOKEN_KEY, value: str);
  }

  Future<String?> getNewFirebaseToken() async {
    final newFbToken = await _storage.read(key: _NEW_APP_TOKEN_KEY);
    if (newFbToken != null) return newFbToken;
    final legacyNewFbToken = await _storageLegacy.read(key: _NEW_APP_TOKEN_KEY_LEGACY);
    if (legacyNewFbToken != null) {
      Logger.info('Loaded legacy new firebase token from secure storage');
      await _storage.write(key: _NEW_APP_TOKEN_KEY, value: legacyNewFbToken);
      await _storageLegacy.delete(key: _NEW_APP_TOKEN_KEY_LEGACY);
      Logger.info('Migrated legacy new firebase token to new secure storage');
      return legacyNewFbToken;
    }
    return null;
  }
}

/// This class just is used to disable Firebase for web builds.
class NoFirebaseUtils implements FirebaseUtils {
  @override
  Mutex get _initFbMutex => Mutex();
  @override
  bool initializedFirebase = false;

  @override
  Mutex get _initHandlerMutex => Mutex();
  @override
  bool initializedHandler = false;

  @override
  Future<String> getFBToken() => Future.value(NO_FIREBASE_TOKEN);

  @override
  Future<void> setupHandler({
    required Future<void> Function(RemoteMessage p1) foregroundHandler,
    required Future<void> Function(RemoteMessage p1) backgroundHandler,
    required void Function({String? firebaseToken}) updateFirebaseToken,
  }) async {}

  @override
  Future<bool> deleteFirebaseToken() => Future.value(true);

  static const String NO_FIREBASE_TOKEN = 'no_firebase_token';

  @override
  Future<void> setCurrentFirebaseToken(String str) async {}
  @override
  Future<String?> getCurrentFirebaseToken() => Future.value(NO_FIREBASE_TOKEN);

  @override
  Future<void> setNewFirebaseToken(String str) async {}
  @override
  Future<String?> getNewFirebaseToken() => Future.value(NO_FIREBASE_TOKEN);

  @override
  Future<FirebaseApp?> initializeApp() async => null;
}
