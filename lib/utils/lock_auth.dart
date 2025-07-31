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
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import 'logger.dart';
import 'view_utils.dart';

bool _authenticationInProgress = false;

/// Sends a request to the OS to authenticate the user. Returns true if the user was authenticated, false otherwise.
/// If the device does not support authentication or authentication is not set up, a dialog is shown to the user.
/// If [autoAuthIfUnsupported] is set to true and the device does not support authentication, the function will return true.
Future<bool> lockAuth({required String Function(AppLocalizations) reason, required AppLocalizations localization, bool autoAuthIfUnsupported = false}) async {
  bool didAuthenticate = false;
  LocalAuthentication localAuth = LocalAuthentication();
  final isDeviceSupported = await localAuth.isDeviceSupported();
  if (!isDeviceSupported && autoAuthIfUnsupported) return true;
  if (kIsWeb || !isDeviceSupported) {
    await showAsyncDialog(
      builder: (context) {
        return DefaultDialog(
          scrollable: true,
          title: ListTile(
            title: Center(
              child: Text(
                AppLocalizations.of(context)!.authNotSupportedTitle,
                style: Theme.of(context).textTheme.titleMedium,
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
    biometricRequiredTitle: localization.biometricRequiredTitle,
    biometricHint: localization.biometricHint,
    biometricNotRecognized: localization.biometricNotRecognized,
    biometricSuccess: localization.biometricSuccess,
    deviceCredentialsRequiredTitle: localization.deviceCredentialsRequiredTitle,
    deviceCredentialsSetupDescription: localization.deviceCredentialsSetupDescription,
    signInTitle: localization.signInTitle,
    goToSettingsButton: localization.goToSettingsButton,
    goToSettingsDescription: localization.goToSettingsDescription,
    cancelButton: localization.cancel,
  );

  IOSAuthMessages iOSAuthStrings = IOSAuthMessages(
    lockOut: localization.lockOut,
    goToSettingsButton: localization.goToSettingsButton,
    goToSettingsDescription: localization.goToSettingsDescription,
    cancelButton: localization.cancel,
  );

  try {
    if (!_authenticationInProgress) {
      _authenticationInProgress = true;
      didAuthenticate = await localAuth.authenticate(localizedReason: reason(localization), authMessages: [
        androidAuthStrings,
        iOSAuthStrings,
      ]);
    }
  } on PlatformException catch (e, s) {
    Logger.warning("Authentication failed", error: e, stackTrace: s);
  } finally {
    _authenticationInProgress = false;
  }
  return didAuthenticate;
}
