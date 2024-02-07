import 'package:privacyidea_authenticator/utils/version.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/settings_repository.dart';
import '../model/states/settings_state.dart';

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

  late final Future<SharedPreferences> _preferences;
  SettingsState? _lastState;

  PreferenceSettingsRepository() {
    _preferences = SharedPreferences.getInstance();
  }

  @override
  Future<SettingsState> loadSettings() async {
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
      latestVersion: prefs.getString(_latestVersionKey) != null ? Version.parse(prefs.getString(_latestVersionKey)!) : null,
    );
    _lastState = newState;
    return newState;
  }

  @override
  Future<bool> saveSettings(SettingsState settings) async {
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
