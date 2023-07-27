import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/repo/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceSettingsRepository extends SettingsRepository {
  static const String _isFirstRunKey = 'KEY_IS_FIRST_RUN';
  static const String _showGuideOnStartKey = 'KEY_SHOW_GUIDE_ON_START';
  static const String _prefHideOtps = 'KEY_HIDE_OTPS';
  static const String _prefEnablePoll = 'KEY_ENABLE_POLLING';
  static const String _crashReportRecipientsKey = 'KEY_CRASH_REPORT_RECIPIENTS'; // TODO Use this if the server supports it
  static const String _localePreferenceKey = 'KEY_LOCALE_PREFERENCE';
  static const String _useSystemLocaleKey = 'KEY_USE_SYSTEM_LOCALE';
  static const String _enableLoggingKey = 'KEY_VERBOSE_LOGGING';

  late final Future<SharedPreferences> _preferences;
  SettingsState? _lastState;

  PreferenceSettingsRepository() {
    _preferences = SharedPreferences.getInstance();
  }

  @override
  Future<SettingsState> loadSettings() async {
    final isFirstRun = (await _preferences).getBool(_isFirstRunKey);
    final showGuideOnStart = (await _preferences).getBool(_showGuideOnStartKey);
    final hideOpts = (await _preferences).getBool(_prefHideOtps);
    final enablePolling = (await _preferences).getBool(_prefEnablePoll);
    final crashReportRecipients = (await _preferences).getStringList(_crashReportRecipientsKey)?.toSet();
    final localePreference =
        (await _preferences).getString(_localePreferenceKey) != null ? SettingsState.decodeLocale((await _preferences).getString(_localePreferenceKey)!) : null;
    final useSystemLocale = (await _preferences).getBool(_useSystemLocaleKey);
    final verboseLogging = (await _preferences).getBool(_enableLoggingKey);
    _lastState = SettingsState(
      isFirstRun: isFirstRun,
      showGuideOnStart: showGuideOnStart,
      hideOpts: hideOpts,
      enablePolling: enablePolling,
      crashReportRecipients: crashReportRecipients,
      localePreference: localePreference,
      useSystemLocale: useSystemLocale,
      verboseLogging: verboseLogging,
    );
    return _lastState!;
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
      final asd = await (await _preferences).setString(_localePreferenceKey, SettingsState.encodeLocale(settings.localePreference));
      final asdf = SettingsState.decodeLocale((await _preferences).getString(_localePreferenceKey)!);
    }
    if (_lastState?.useSystemLocale != settings.useSystemLocale) (await _preferences).setBool(_useSystemLocaleKey, settings.useSystemLocale);
    if (_lastState?.verboseLogging != settings.verboseLogging) (await _preferences).setBool(_enableLoggingKey, settings.verboseLogging);
    _lastState = settings;
    return true;
  }
}
