import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import '../widgets/default_dialog.dart';
import 'customizations.dart';
import 'view_utils.dart';

import 'logger.dart';

bool authenticationInProgress = false;

Future<bool> lockAuth({required BuildContext context, required String localizedReason}) async {
  bool didAuthenticate = false;
  LocalAuthentication localAuth = LocalAuthentication();

  if (!(await localAuth.isDeviceSupported())) {
    await showAsyncDialog(
      builder: (context) {
        return DefaultDialog(
          scrollable: true,
          title: ListTile(
            title: Center(
              child: Text(
                AppLocalizations.of(context)!.authNotSupportedTitle,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            leading: const Icon(Icons.lock),
            trailing: const Icon(Icons.lock),
          ),
          content: Text(
            AppLocalizations.of(context)!.authNotSupportedBody,
            overflow: TextOverflow.fade,
            softWrap: false,
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
    Logger.error('Error: ${e.code}', name: 'token_widgets.dart#lockAuth', error: e, stackTrace: s);
  }
  return didAuthenticate;
}
