/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/settings_repository.dart';
import '../model/riverpod_states/settings_state.dart';
import '../model/version.dart';

class PreferenceSettingsRepository extends SettingsRepository {
  static const String _isFirstRunKey = 'KEY_IS_FIRST_RUN';
  static const String _showGuideOnStartKey = 'KEY_SHOW_GUIDE_ON_START';
  static const String _prefHideOtps = 'KEY_HIDE_OTPS';
  static const String _prefEnablePoll = 'KEY_ENABLE_POLLING';
  static const String _crashReportRecipientsKey = 'KEY_CRASH_REPORT_RECIPIENTS'; // TODO Use this if the server supports it
  static const String _localePreferenceKey = 'KEY_LOCALE_PREFERENCE';
  static const String _useSystemLocaleKey = 'KEY_USE_SYSTEM_LOCALE';
  static const String _enableLoggingKey = 'KEY_VERBOSE_LOGGING';
  static const String _hidePushTokensKey = 'KEY_HIDE_PUSH_TOKENS';
  static const String _latestVersionKey = 'KEY_LATEST_VERSION';

  static final Future<SharedPreferences> _preferences = SharedPreferences.getInstance();
  static SettingsState? _lastState;

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  static final Mutex _m = Mutex();
  static Future<T> _protect<T>(Future<T> Function() f) => _m.protect<T>(f);
  @override
  Future<SettingsState> loadSettings() => _protect(_loadSettings);
  Future<SettingsState> _loadSettings() async {
    final prefs = await _preferences;
    final newState = SettingsState(
      isFirstRun: prefs.getBool(_isFirstRunKey),
      showGuideOnStart: prefs.getBool(_showGuideOnStartKey),
      hideOpts: prefs.getBool(_prefHideOtps),
      enablePolling: prefs.getBool(_prefEnablePoll),
      crashReportRecipients: prefs.getStringList(_crashReportRecipientsKey)?.toSet(),
      localePreference: prefs.getString(_localePreferenceKey) != null ? SettingsState.decodeLocale(prefs.getString(_localePreferenceKey)!) : null,
      useSystemLocale: prefs.getBool(_useSystemLocaleKey),
      verboseLogging: prefs.getBool(_enableLoggingKey),
      hidePushTokens: prefs.getBool(_hidePushTokensKey),
      latestStartedVersion: prefs.getString(_latestVersionKey) != null ? Version.parse(prefs.getString(_latestVersionKey)!) : null,
    );
    _lastState = newState;
    return newState;
  }

  @override
  Future<bool> saveSettings(SettingsState settings) => _protect(() => _saveSettings(settings));
  Future<bool> _saveSettings(SettingsState settings) async {
    final prefs = await _preferences;
    final futures = <Future>[
      if (_lastState?.isFirstRun != settings.isFirstRun) prefs.setBool(_isFirstRunKey, settings.isFirstRun),
      if (_lastState?.showGuideOnStart != settings.showGuideOnStart) prefs.setBool(_showGuideOnStartKey, settings.showGuideOnStart),
      if (_lastState?.hideOpts != settings.hideOpts) prefs.setBool(_prefHideOtps, settings.hideOpts),
      if (_lastState?.enablePolling != settings.enablePolling) prefs.setBool(_prefEnablePoll, settings.enablePolling),
      if (_lastState?.crashReportRecipients != settings.crashReportRecipients)
        prefs.setStringList(_crashReportRecipientsKey, settings.crashReportRecipients.toList()),
      if (_lastState?.localePreference != settings.localePreference)
        prefs.setString(_localePreferenceKey, SettingsState.encodeLocale(settings.localePreference)),
      if (_lastState?.useSystemLocale != settings.useSystemLocale) prefs.setBool(_useSystemLocaleKey, settings.useSystemLocale),
      if (_lastState?.verboseLogging != settings.verboseLogging) prefs.setBool(_enableLoggingKey, settings.verboseLogging),
      if (_lastState?.hidePushTokens != settings.hidePushTokens) prefs.setBool(_hidePushTokensKey, settings.hidePushTokens),
      if (_lastState?.latestStartedVersion != settings.latestStartedVersion) prefs.setString(_latestVersionKey, settings.latestStartedVersion.toString()),
    ];
    await Future.wait(futures);
    _lastState = settings;

    return true;
  }
}
