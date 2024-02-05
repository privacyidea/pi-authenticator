import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import 'globals.dart';
import 'logger.dart';
import 'view_utils.dart';

bool authenticationInProgress = false;

/// Sends a request to the OS to authenticate the user. Returns true if the user was authenticated, false otherwise.
Future<bool> lockAuth({required String localizedReason}) async {
  bool didAuthenticate = false;
  LocalAuthentication localAuth = LocalAuthentication();

  if (kIsWeb || !(await localAuth.isDeviceSupported())) {
    await showAsyncDialog(
      builder: (context) {
        return DefaultDialog(
          scrollable: true,
          title: ListTile(
            title: Center(
              child: Text(
                AppLocalizations.of(context)!.authNotSupportedTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            leading: const Icon(Icons.lock),
            trailing: const Icon(Icons.lock),
          ),
          content: Text(
            AppLocalizations.of(context)!.authNotSupportedBody,
          ),
        );
      },
    );
    return didAuthenticate;
  }

  AndroidAuthMessages androidAuthStrings = AndroidAuthMessages(
    biometricRequiredTitle: AppLocalizations.of(globalNavigatorKey.currentContext!)!.biometricRequiredTitle,
    biometricHint: AppLocalizations.of(globalNavigatorKey.currentContext!)!.biometricHint,
    biometricNotRecognized: AppLocalizations.of(globalNavigatorKey.currentContext!)!.biometricNotRecognized,
    biometricSuccess: AppLocalizations.of(globalNavigatorKey.currentContext!)!.biometricSuccess,
    deviceCredentialsRequiredTitle: AppLocalizations.of(globalNavigatorKey.currentContext!)!.deviceCredentialsRequiredTitle,
    deviceCredentialsSetupDescription: AppLocalizations.of(globalNavigatorKey.currentContext!)!.deviceCredentialsSetupDescription,
    signInTitle: AppLocalizations.of(globalNavigatorKey.currentContext!)!.signInTitle,
    goToSettingsButton: AppLocalizations.of(globalNavigatorKey.currentContext!)!.goToSettingsButton,
    goToSettingsDescription: AppLocalizations.of(globalNavigatorKey.currentContext!)!.goToSettingsDescription,
    cancelButton: AppLocalizations.of(globalNavigatorKey.currentContext!)!.cancel,
  );

  IOSAuthMessages iOSAuthStrings = IOSAuthMessages(
    lockOut: AppLocalizations.of(globalNavigatorKey.currentContext!)!.lockOut,
    goToSettingsButton: AppLocalizations.of(globalNavigatorKey.currentContext!)!.goToSettingsButton,
    goToSettingsDescription: AppLocalizations.of(globalNavigatorKey.currentContext!)!.goToSettingsDescription,
    cancelButton: AppLocalizations.of(globalNavigatorKey.currentContext!)!.cancel,
  );

  try {
    if (!authenticationInProgress) {
      authenticationInProgress = true;
      didAuthenticate = await localAuth.authenticate(localizedReason: localizedReason, authMessages: [
        androidAuthStrings,
        iOSAuthStrings,
      ]);
      authenticationInProgress = false;
    }
  } on PlatformException catch (e, s) {
    authenticationInProgress = false;
    Logger.info("Authentication failed", error: e, stackTrace: s);
  }
  return didAuthenticate;
}
