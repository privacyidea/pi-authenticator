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
import 'package:gms_check/gms_check.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/repo/secure_storage.dart';

import '../../../../../../../utils/view_utils.dart';
import 'globals.dart';
import 'identifiers.dart';
import 'logger.dart';

class FirebaseUtils {
  static FirebaseUtils? _instance;
  static bool? _isMessagingAvailable;

  final Mutex _initFbMutex = Mutex();
  bool initializedFirebase = false;
  final Mutex _initHandlerMutex = Mutex();
  bool initializedHandler = false;

  static const FIREBASE_TOKEN_KEY_PREFIX_LEGACY =
      GLOBAL_SECURE_REPO_PREFIX_LEGACY;
  static const CURRENT_APP_TOKEN_KEY_LEGACY = 'CURRENT_APP_TOKEN';
  static const NEW_APP_TOKEN_KEY_LEGACY = 'NEW_APP_TOKEN';

  static const FIREBASE_TOKEN_KEY_PREFIX =
      '${GLOBAL_SECURE_REPO_PREFIX}_firebase';
  static const CURRENT_APP_TOKEN_KEY = 'current';
  static const NEW_APP_TOKEN_KEY = 'new';

  final SecureStorage _storageLegacy;
  final SecureStorage _storage;

  FirebaseUtils._({SecureStorage? storage, SecureStorage? legacyStorage})
    : _storage =
          storage ??
          SecureStorage(
            storagePrefix: FIREBASE_TOKEN_KEY_PREFIX,
            storage: SecureStorage.defaultStorage,
          ),
      _storageLegacy =
          legacyStorage ??
          SecureStorage(
            storagePrefix: FIREBASE_TOKEN_KEY_PREFIX_LEGACY,
            storage: SecureStorage.legacyStorage,
          );

  factory FirebaseUtils({
    SecureStorage? storage,
    SecureStorage? legacyStorage,
  }) {
    if (storage != null || legacyStorage != null) {
      return FirebaseUtils._(storage: storage, legacyStorage: legacyStorage);
    }

    if (_instance != null) return _instance!;

    final isAvailable = _isMessagingAvailable ?? false;

    if (isAvailable) {
      _instance ??= FirebaseUtils._();
    } else {
      _instance ??= NoFirebaseUtils();
    }

    return _instance!;
  }

  static Future<void> preInitializeStatus() async {
    if (_isMessagingAvailable != null) return;
    _isMessagingAvailable = switch (true) {
      _ when Platform.isAndroid => await _checkGmsAvailability(),
      _ when Platform.isIOS || Platform.isMacOS => true,
      _ => false,
    };
  }

  static Future<bool> _checkGmsAvailability() async {
    try {
      return await GmsCheck().checkGmsAvailability() ?? false;
    } catch (e, s) {
      Logger.error(
        'Error while checking GMS availability',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  static bool get isMessagingAvailable => _isMessagingAvailable ?? false;

  Future<FirebaseApp?> initializeApp() async {
    await _initFbMutex.acquire();
    try {
      if (initializedFirebase) {
        Logger.warning('Firebase already initialized');
        _initFbMutex.release();
        return null;
      }
      assert(
        appFirebaseOptions != null,
        'Firebase options must be set before initializing Firebase',
      );
      final FirebaseOptions options = appFirebaseOptions!;
      final app = await Firebase.initializeApp(
        name: "fb-${options.projectId}",
        options: options,
      );
      await app.setAutomaticDataCollectionEnabled(false);
      initializedFirebase = true;
      assert(
        app.isAutomaticDataCollectionEnabled == false,
        'Automatic data collection should be disabled',
      );
      _initFbMutex.release();
      return app;
    } catch (e, s) {
      _initFbMutex.release();
      Logger.error(
        'Error while initializing Firebase',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

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
      _initHandlerMutex.release();
      return;
    }

    Logger.info('FirebaseUtils: Initializing Firebase');

    FirebaseMessaging.onMessage.listen(foregroundHandler);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    try {
      String? firebaseToken = await getFBToken();

      if (firebaseToken != await getCurrentFirebaseToken() &&
          firebaseToken != null) {
        updateFirebaseToken(firebaseToken: firebaseToken);
      }
    } catch (error, stackTrace) {
      if (error is PlatformException) {
        if (error.code == FIREBASE_TOKEN_ERROR_CODE) {
          _initHandlerMutex.release();
          return;
        }
        showErrorStatusMessage(
          message: (l) => l.pushInitializeUnavailable,
          details: (_) =>
              '${error.code}: ${error.message ?? 'no error message'}',
        );
      }
      if (error is FirebaseException) {
        if (error.code == FIREBASE_TOKEN_ERROR_CODE) {
          _initHandlerMutex.release();
          return;
        }
        showErrorStatusMessage(
          message: (l) => l.pushInitializeUnavailable,
          details: (_) =>
              '${error.code}: ${error.message ?? 'no error message'}',
        );
      }

      Logger.error(
        'Unknown Firebase error',
        error: error,
        stackTrace: stackTrace,
      );
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      if ((await getCurrentFirebaseToken()) != newToken) {
        await setNewFirebaseToken(newToken);
        try {
          updateFirebaseToken(firebaseToken: newToken);
        } catch (error, stackTrace) {
          Logger.error(
            'Error updating firebase token',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    });

    initializedHandler = true;
    _initHandlerMutex.release();
  }

  Future<String?> getFBToken() async {
    String? firebaseToken;
    try {
      firebaseToken = await FirebaseMessaging.instance.getToken();
    } on FirebaseException catch (e, s) {
      String errorMessage = e.message ?? 'no error message';
      Logger.warning(
        'Unable to retrieve Firebase token! ($errorMessage: ${e.code})',
        error: e,
        stackTrace: s,
      );
    }

    if (firebaseToken == null) {
      firebaseToken = await getCurrentFirebaseToken();
    } else {
      Logger.info('New Firebase token retrieved');
      await setNewFirebaseToken(firebaseToken);
    }

    if (firebaseToken == null) {
      throw PlatformException(
        message:
            'Firebase token could not be retrieved, the only know cause of this is'
            ' that the firebase servers could not be reached.',
        code: FIREBASE_TOKEN_ERROR_CODE,
      );
    }

    return firebaseToken;
  }

  Future<bool> deleteFirebaseToken() async {
    Logger.info('Deleting firebase token..');
    try {
      final app = await Firebase.initializeApp();
      await app.setAutomaticDataCollectionEnabled(false);
      await FirebaseMessaging.instance.deleteToken();
      Logger.warning('Firebase token deleted from Firebase');
    } on FirebaseException catch (e) {
      if (e.message?.contains('IOException') == true) {
        throw SocketException(e.message!);
      }
      rethrow;
    }
    await _storage.delete(key: CURRENT_APP_TOKEN_KEY);
    await _storage.delete(key: NEW_APP_TOKEN_KEY);
    Logger.info('Firebase token deleted from secure storage');
    return true;
  }

  Future<void> setCurrentFirebaseToken(String str) {
    Logger.info('Setting current firebase token');
    return _storage.write(key: CURRENT_APP_TOKEN_KEY, value: str);
  }

  Future<String?> getCurrentFirebaseToken() async {
    final current = await _storage.read(key: CURRENT_APP_TOKEN_KEY);
    if (current != null) return current;
    final legacyCurrent = await _storageLegacy.read(
      key: CURRENT_APP_TOKEN_KEY_LEGACY,
    );
    if (legacyCurrent != null) {
      Logger.info('Loaded legacy current firebase token from secure storage');
      await _storage.write(key: CURRENT_APP_TOKEN_KEY, value: legacyCurrent);
      await _storageLegacy.delete(key: CURRENT_APP_TOKEN_KEY_LEGACY);
      Logger.info(
        'Migrated legacy current firebase token to new secure storage',
      );
      return legacyCurrent;
    }
    return null;
  }

  Future<void> setNewFirebaseToken(String str) {
    Logger.info('Setting new firebase token');
    return _storage.write(key: NEW_APP_TOKEN_KEY, value: str);
  }

  Future<String?> getNewFirebaseToken() async {
    final newFbToken = await _storage.read(key: NEW_APP_TOKEN_KEY);
    if (newFbToken != null) return newFbToken;
    final legacyNewFbToken = await _storageLegacy.read(
      key: NEW_APP_TOKEN_KEY_LEGACY,
    );
    if (legacyNewFbToken != null) {
      Logger.info('Loaded legacy new firebase token from secure storage');
      await _storage.write(key: NEW_APP_TOKEN_KEY, value: legacyNewFbToken);
      await _storageLegacy.delete(key: NEW_APP_TOKEN_KEY_LEGACY);
      Logger.info('Migrated legacy new firebase token to new secure storage');
      return legacyNewFbToken;
    }
    return null;
  }
}

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
    required dynamic Function({String? firebaseToken}) updateFirebaseToken,
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

  @override
  final SecureStorage _storage = SecureStorage(
    storagePrefix: FirebaseUtils.FIREBASE_TOKEN_KEY_PREFIX,
    storage: SecureStorage.defaultStorage,
  );

  @override
  final SecureStorage _storageLegacy = SecureStorage(
    storagePrefix: FirebaseUtils.FIREBASE_TOKEN_KEY_PREFIX_LEGACY,
    storage: SecureStorage.legacyStorage,
  );
}
