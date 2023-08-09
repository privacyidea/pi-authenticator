// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

import 'logger.dart';

Future<bool> lockAuth({required BuildContext context, required String localizedReason}) async {
  bool didAuthenticate = false;
  LocalAuthentication localAuth = LocalAuthentication();

  if (!(await localAuth.isDeviceSupported())) {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
        });
    return didAuthenticate;
  }

  AndroidAuthMessages androidAuthStrings = AndroidAuthMessages(
    biometricRequiredTitle: AppLocalizations.of(context)!.biometricRequiredTitle,
    biometricHint: AppLocalizations.of(context)!.biometricHint,
    biometricNotRecognized: AppLocalizations.of(context)!.biometricNotRecognized,
    biometricSuccess: AppLocalizations.of(context)!.biometricSuccess,
    deviceCredentialsRequiredTitle: AppLocalizations.of(context)!.deviceCredentialsRequiredTitle,
    deviceCredentialsSetupDescription: AppLocalizations.of(context)!.deviceCredentialsSetupDescription,
    signInTitle: AppLocalizations.of(context)!.signInTitle,
    goToSettingsButton: AppLocalizations.of(context)!.goToSettingsButton,
    goToSettingsDescription: AppLocalizations.of(context)!.goToSettingsDescription,
    cancelButton: AppLocalizations.of(context)!.cancel,
  );

  IOSAuthMessages iOSAuthStrings = IOSAuthMessages(
    lockOut: AppLocalizations.of(context)!.lockOut,
    goToSettingsButton: AppLocalizations.of(context)!.goToSettingsButton,
    goToSettingsDescription: AppLocalizations.of(context)!.goToSettingsDescription,
    cancelButton: AppLocalizations.of(context)!.cancel,
  );

  try {
    didAuthenticate = await localAuth.authenticate(localizedReason: localizedReason, authMessages: [
      androidAuthStrings,
      iOSAuthStrings,
    ]);
  } on PlatformException catch (error) {
    Logger.error('Error: ${error.code}', name: 'token_widgets.dart#lockAuth');
  }
  return didAuthenticate;
}
