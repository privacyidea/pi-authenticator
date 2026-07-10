/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'logger.dart';

const MethodChannel _settingsChannel = MethodChannel(
  'it.netknights.piauthenticator/settings',
);

Future<bool> Function(Uri url) _launchUrl = (url) =>
    url_launcher.launchUrl(url);

/// Opens the device's screen lock / biometrics enrollment settings.
///
/// On Android this launches `Settings.ACTION_SECURITY_SETTINGS` directly via
/// a platform channel, falling back to the app's own settings page if that
/// fails. On iOS there is no dedicated deep link for this, so the app's
/// general settings page is opened instead.
Future<void> openLockAndPasswordSettings() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      try {
        await _settingsChannel.invokeMethod('openLockAndPasswordSettings');
      } catch (e, s) {
        Logger.warning(
          'Failed to open security settings',
          error: e,
          stackTrace: s,
        );
      }
      return;
    case TargetPlatform.iOS:
      final success = await _launchUrl(Uri.parse('app-settings:'));
      if (!success) {
        Logger.warning('Failed to open security settings');
      }
      return;
    default:
      return;
  }
}

@visibleForTesting
set launchUrlOverride(Future<bool> Function(Uri url) launcher) =>
    _launchUrl = launcher;
@visibleForTesting
void resetLaunchUrlOverride() =>
    _launchUrl = (url) => url_launcher.launchUrl(url);
