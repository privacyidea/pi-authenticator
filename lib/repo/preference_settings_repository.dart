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

  late final Future<SharedPreferences> _preferences;
  SettingsState? _lastState;

  PreferenceSettingsRepository() {
    _preferences = SharedPreferences.getInstance();
  }

  @override
  Future<SettingsState> loadSettings() async {
    final newState = SettingsState(
      isFirstRun: (await _preferences).getBool(_isFirstRunKey),
      showGuideOnStart: (await _preferences).getBool(_showGuideOnStartKey),
      hideOpts: (await _preferences).getBool(_prefHideOtps),
      enablePolling: (await _preferences).getBool(_prefEnablePoll),
      crashReportRecipients: (await _preferences).getStringList(_crashReportRecipientsKey)?.toSet(),
      localePreference: (await _preferences).getString(_localePreferenceKey) != null
          ? SettingsState.decodeLocale((await _preferences).getString(_localePreferenceKey)!)
          : null,
      useSystemLocale: (await _preferences).getBool(_useSystemLocaleKey),
      verboseLogging: (await _preferences).getBool(_enableLoggingKey),
      hidePushTokens: (await _preferences).getBool(_hidePushTokensKey),
    );
    _lastState = newState;
    return newState;
  }

  @override
  Future<bool> saveSettings(SettingsState settings) async {
    if (_lastState?.isFirstRun != settings.isFirstRun) (await _preferences).setBool(_isFirstRunKey, settings.isFirstRun);
    if (_lastState?.showGuideOnStart != settings.showGuideOnStart) (await _preferences).setBool(_showGuideOnStartKey, settings.showGuideOnStart);
    if (_lastState?.hideOpts != settings.hideOpts) (await _preferences).setBool(_prefHideOtps, settings.hideOpts);
    if (_lastState?.enablePolling != settings.enablePolling) (await _preferences).setBool(_prefEnablePoll, settings.enablePolling);
    if (_lastState?.crashReportRecipients != settings.crashReportRecipients) {
      (await _preferences).setStringList(_crashReportRecipientsKey, settings.crashReportRecipients.toList());
    }
    if (_lastState?.localePreference != settings.localePreference) {
      await (await _preferences).setString(_localePreferenceKey, SettingsState.encodeLocale(settings.localePreference));
    }
    if (_lastState?.useSystemLocale != settings.useSystemLocale) (await _preferences).setBool(_useSystemLocaleKey, settings.useSystemLocale);
    if (_lastState?.verboseLogging != settings.verboseLogging) (await _preferences).setBool(_enableLoggingKey, settings.verboseLogging);
    _lastState = settings;
    return true;
  }
}
