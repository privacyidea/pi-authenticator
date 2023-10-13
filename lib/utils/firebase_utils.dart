import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../repo/secure_token_repository.dart';
import 'customizations.dart';
import 'identifiers.dart';
import 'logger.dart';

class FirebaseUtils {
  static FirebaseUtils? _instance;
  bool _initialized = false;

  FirebaseUtils._();

  factory FirebaseUtils() {
    _instance ??= FirebaseUtils._();
    return _instance!;
  }

  Future<void> initFirebase({
    required Future<void> Function(RemoteMessage) foregroundHandler,
    required Future<void> Function(RemoteMessage) backgroundHandler,
    required void Function(String?) updateFirebaseToken,
  }) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await Firebase.initializeApp();

    try {
      await FirebaseMessaging.instance.requestPermission();
    } on FirebaseException catch (e, s) {
      Logger.warning(
        'e.code: ${e.code}, '
        'e.message: ${e.message}, '
        'e.plugin: ${e.plugin},',
        name: 'push_provider.dart#_initFirebase',
        error: e,
        stackTrace: s,
      );
      String errorMessage = e.message ?? 'no error message';
      final SnackBar snackBar = SnackBar(
          content: Text(
        "Firebase notification permission error! ($errorMessage: ${e.code}",
      ));
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    }

    FirebaseMessaging.onMessage.listen(foregroundHandler);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    try {
      String? firebaseToken = await getFBToken();

      if (firebaseToken != await SecureTokenRepository.getCurrentFirebaseToken()) {
        updateFirebaseToken(firebaseToken);
      }
    } on PlatformException catch (error) {
      if (error.code == FIREBASE_TOKEN_ERROR_CODE) {
        // ignore
      } else {
        String errorMessage = error.message ?? 'no error message';
        final SnackBar snackBar = SnackBar(
            content: Text(
          'Push cant be initialized, restart the app and try again. ${error.code}: $errorMessage',
          overflow: TextOverflow.fade,
          softWrap: false,
        ));
        globalSnackbarKey.currentState?.showSnackBar(snackBar);
      }
    } on FirebaseException catch (error) {
      final SnackBar snackBar = SnackBar(
          content: Text(
        "Push cant be initialized, restart the app and try again$error",
        overflow: TextOverflow.fade,
        softWrap: false,
      ));
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    } catch (error) {
      final SnackBar snackBar = SnackBar(
          content: Text(
        "Unknown error: $error",
        overflow: TextOverflow.fade,
        softWrap: false,
      ));
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
      if ((await SecureTokenRepository.getCurrentFirebaseToken()) != newToken) {
        await SecureTokenRepository.setNewFirebaseToken(newToken);
        // TODO what if this fails, when should a retry be attempted?
        try {
          updateFirebaseToken(newToken);
        } catch (error) {
          final SnackBar snackBar = SnackBar(
              content: Text(
            "Unknown error: $error",
            overflow: TextOverflow.fade,
            softWrap: false,
          ));
          globalSnackbarKey.currentState?.showSnackBar(snackBar);
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
      final SnackBar snackBar = SnackBar(
        content: Text(
          "Unable to retrieve Firebase token! ($errorMessage: ${e.code})",
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      );
      Logger.warning('Unable to retrieve Firebase token! ($errorMessage: ${e.code})', name: 'push_provider.dart#getFBToken', error: e, stackTrace: s);
      globalSnackbarKey.currentState?.showSnackBar(snackBar);
    }

    // Fall back to the last known firebase token
    if (firebaseToken == null) {
      firebaseToken = await SecureTokenRepository.getCurrentFirebaseToken();
    } else {
      await SecureTokenRepository.setNewFirebaseToken(firebaseToken);
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
}
