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
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import '../widgets/gap.dart';
import 'logger.dart';
import 'view_utils.dart';

LocalAuthentication _localAuth = LocalAuthentication();
Mutex _authMutex = Mutex();

/// Requests OS-level authentication from the user.
///
/// Returns `true` if authentication succeeds.
/// If the device does not support any authentication method or [forceBiometricOption]
/// is set but the hardware/setup is missing, an appropriate error dialog is shown.
///
/// If [autoAuthIfUnsupported] is `true`, the function returns `true` immediately
/// when the device generally lacks authentication support, bypassing the dialog.
///
/// This method is protected by a mutex to prevent concurrent authentication attempts.
Future<bool> lockAuth({
  required String Function(AppLocalizations) reason,
  required AppLocalizations localization,
  ForceBiometricOption? forceBiometricOption,
  bool autoAuthIfUnsupported = false,
}) async {
  if (_authMutex.isLocked) {
    Logger.info(
      "Authentication already in progress, skipping concurrent request.",
    );
    return false;
  }

  await _authMutex.acquire();

  try {
    final isBiometricForced =
        forceBiometricOption == ForceBiometricOption.biometric;
    if (!await _checkSupport(isBiometricForced, autoAuthIfUnsupported)) {
      return autoAuthIfUnsupported;
    }

    return await _executeAuth(
      isBiometricForced: isBiometricForced,
      localizedReason: reason(localization),
      localization: localization,
    );
  } finally {
    if (_authMutex.isLocked) {
      _authMutex.release();
    }
  }
}

Future<bool> _executeAuth({
  required bool isBiometricForced,
  required String localizedReason,
  required AppLocalizations localization,
}) async {
  try {
    return await _localAuth.authenticate(
      biometricOnly: isBiometricForced,
      localizedReason: localizedReason,
      authMessages: [
        AndroidAuthMessages(
          signInTitle: localization.signInTitle,
          cancelButton: localization.cancel,
        ),
        IOSAuthMessages(cancelButton: localization.cancel),
      ],
    );
  } catch (e, s) {
    if (e is LocalAuthException &&
        e.code == LocalAuthExceptionCode.userCanceled) {
      Logger.info("Authentication canceled by user");
    } else {
      Logger.warning("Authentication failed", error: e, stackTrace: s);
    }
    return false;
  }
}

Future<bool> _checkSupport(bool isBiometricForced, bool autoAuth) async {
  if (autoAuth) return true;
  final isDeviceSupported = await _localAuth.isDeviceSupported() && !kIsWeb;

  if (isBiometricForced) {
    if (!(await _localAuth.canCheckBiometrics)) {
      await _showNoBiometricHwDialog();
      return false;
    }

    if ((await _localAuth.getAvailableBiometrics()).isEmpty) {
      await _showNoBiometricDialog();
      return false;
    }
  }

  if (!isDeviceSupported) {
    await _showNoScreenLockDialog();
    return false;
  }

  return true;
}

Future<void> _showNoScreenLockDialog() async {
  await showAsyncDialog(
    builder: (context) => DefaultDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                AppLocalizations.of(context)!.deviceCredentialsRequiredTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Icon(Icons.lock_outline),
        ],
      ),
      content: Text(
        AppLocalizations.of(context)!.deviceCredentialsSetupDescription,
      ),
      actions: [
        DialogAction(
          label: AppLocalizations.of(context)!.setUpButton,
          intent: ActionIntent.external,
          onPressed: () async {
            if (Platform.isAndroid) {
              await AppSettings.openAppSettings(
                type: AppSettingsType.lockAndPassword,
              );
            }
            if (Platform.isIOS) {
              await AppSettings.openAppSettings();
            }
            final isNowSupported = await _localAuth.isDeviceSupported();
            if (isNowSupported && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    ),
  );
}

Future<void> _showNoBiometricHwDialog() async {
  await showAsyncDialog(
    builder: (context) => DefaultDialog(
      title: ListTile(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.biometricAuthNotSupportedTitle,
          ),
        ),
        leading: const Icon(Symbols.fingerprint_off),
      ),
      content: Row(
        children: [
          Text(AppLocalizations.of(context)!.biometricAuthNotSupportedBody),
          const Icon(Symbols.fingerprint_off),
        ],
      ),
    ),
  );
}

Future<void> _showNoBiometricDialog() async {
  await showAsyncDialog(
    builder: (context) => DefaultDialog(
      title: ListTile(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.biometricAuthNotSetupTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      content: Row(
        children: [
          IconButton(
            iconSize: 48,
            icon: const Icon(Symbols.fingerprint, size: 48),
            onPressed: () {
              if (Platform.isAndroid) {
                AppSettings.openAppSettings(
                  type: AppSettingsType.lockAndPassword,
                );
              }
              if (Platform.isIOS) {
                AppSettings.openAppSettings();
              }
            },
          ),
          Gap(),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.biometricAuthNotSetupBody,
            ),
          ),
        ],
      ),
      actions: [
        DialogAction(
          label: AppLocalizations.of(context)!.setUpButton,
          intent: ActionIntent.external,
          onPressed: () async {
            if (Platform.isAndroid) {
              await AppSettings.openAppSettings(
                type: AppSettingsType.lockAndPassword,
              );
            }
            if (Platform.isIOS) {
              await AppSettings.openAppSettings();
            }
            final hasBiometricsEnrolled =
                (await _localAuth.getAvailableBiometrics()).isNotEmpty;
            if (hasBiometricsEnrolled && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    ),
  );
}

@visibleForTesting
set localAuthInstance(LocalAuthentication auth) => _localAuth = auth;
@visibleForTesting
void resetAuthMutex() {
  if (_authMutex.isLocked) {
    _authMutex.release();
  }
}
