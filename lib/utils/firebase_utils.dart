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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';

import '../../../../../../../utils/view_utils.dart';
import 'identifiers.dart';
import 'logger.dart';

class FirebaseUtils {
  static FirebaseUtils? _instance;
  bool _initializedHandler = false;

  FirebaseUtils._();

  factory FirebaseUtils() {
    if (kIsWeb) _instance ??= FirebaseUtilsWeb();
    _instance ??= FirebaseUtils._();
    return _instance!;
  }

  Future<void> initFirebase({
    required Future<void> Function(RemoteMessage) foregroundHandler,
    required Future<void> Function(RemoteMessage) backgroundHandler,
    required dynamic Function(String?) updateFirebaseToken,
  }) async {
    if (_initializedHandler) {
      return;
    }
    _initializedHandler = true;
    Logger.info('FirebaseUtils: Initializing Firebase');

    FirebaseMessaging.onMessage.listen(foregroundHandler);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    try {
      String? firebaseToken = await getFBToken();

      if (firebaseToken != await getCurrentFirebaseToken() && firebaseToken != null) {
        updateFirebaseToken(firebaseToken);
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
          updateFirebaseToken(newToken);
        } catch (error, stackTrace) {
          Logger.error('Error updating firebase token', error: error, stackTrace: stackTrace);
        }
      }
    });
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
  static const _CURRENT_APP_TOKEN_KEY = '${GLOBAL_SECURE_REPO_PREFIX}CURRENT_APP_TOKEN';
  static const _NEW_APP_TOKEN_KEY = '${GLOBAL_SECURE_REPO_PREFIX}NEW_APP_TOKEN';
  static const _storage = FlutterSecureStorage();
  static final _m = Mutex();
  static Future<T> _protect<T>(Future<T> Function() f) => _m.protect<T>(f);

  // Future<bool> deleteFirebaseToken() => _protect(() async {
  //       final firebaseToken = await getCurrentFirebaseToken();
  //       if (firebaseToken == null) {
  //         return false;
  //       }
  //       await _storage.delete(key: _CURRENT_APP_TOKEN_KEY);
  //       return true;
  //     });

  // Future<String?> renewFirebaseToken() async {
  //   if (_initialized == false || await deleteFirebaseToken() == false) {
  //     return null;
  //   }

  //   String? newToken = await FirebaseMessaging.instance.getToken();
  //   if (newToken == null) {
  //     return null;
  //   }
  //   await setNewFirebaseToken(newToken);
  //   await setCurrentFirebaseToken(newToken);
  //   return newToken;
  // }

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

  // FIXME: WHY CURRENT AND NEW TOKEN?
  Future<void> setCurrentFirebaseToken(String str) {
    Logger.info('Setting current firebase token');
    return _protect(() => _storage.write(key: _CURRENT_APP_TOKEN_KEY, value: str));
  }

  Future<String?> getCurrentFirebaseToken() => _protect(() => _storage.read(key: _CURRENT_APP_TOKEN_KEY));

  // This is used for checking if the token was updated.
  Future<void> setNewFirebaseToken(String str) => _protect(() {
        Logger.info('Setting new firebase token');
        return _storage.write(key: _NEW_APP_TOKEN_KEY, value: str);
      });
  Future<String?> getNewFirebaseToken() => _protect(() => _storage.read(key: _NEW_APP_TOKEN_KEY));

  Future<FirebaseApp?> initializeApp({required String name, required FirebaseOptions options}) => Firebase.initializeApp(name: name, options: options);
}

/// This class just is used to disable Firebase for web builds.
class FirebaseUtilsWeb implements FirebaseUtils {
  @override
  bool _initializedHandler = false;

  @override
  Future<String?> getFBToken() => Future.value(_currentFbToken);

  @override
  Future<void> initFirebase({
    required Future<void> Function(RemoteMessage p1) foregroundHandler,
    required Future<void> Function(RemoteMessage p1) backgroundHandler,
    required void Function(String? p1) updateFirebaseToken,
  }) async {}

  @override
  Future<bool> deleteFirebaseToken() => Future.value(true);

  static String _currentFbToken = 'currentFbToken';
  static String _newFbToken = 'newFbToken';

  @override
  Future<void> setCurrentFirebaseToken(String str) async => _currentFbToken = str;
  @override
  Future<String?> getCurrentFirebaseToken() => Future.value(_currentFbToken);

  @override
  Future<void> setNewFirebaseToken(String str) async => _newFbToken = str;
  @override
  Future<String?> getNewFirebaseToken() => Future.value(_newFbToken);

  @override
  Future<FirebaseApp?> initializeApp({required String name, required FirebaseOptions options}) async => null;
}
