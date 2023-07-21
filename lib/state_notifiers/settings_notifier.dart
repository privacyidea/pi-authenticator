import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This class provies access to the device specific settings.
/// It also ensures that the settings are saved to the device.
/// To Update a state use: ref.read(settingsProvider.notifier).anyMethod(value)
class SettingsNotifier extends StateNotifier<SettingsState> {
  static String _isFirstRunKey = 'KEY_IS_FIRST_RUN';
  static bool get _isFirstRunDefault => true;
  static String _showGuideOnStartKey = 'KEY_SHOW_GUIDE_ON_START';
  static bool get _showGuideOnStartDefault => true;
  static String _prefHideOtps = 'KEY_HIDE_OTPS';
  static bool get _hideOtpsDefault => false;
  static String _prefEnablePoll = 'KEY_ENABLE_POLLING';
  static bool get _enablePollDefault => false;
  static String _crashReportRecipientsKey = 'KEY_CRASH_REPORT_RECIPIENTS'; // TODO Use this if the server supports it
  static Set<String> get _crashReportRecipientsDefault => {defaultCrashReportRecipient};
  static String _localePreferenceKey = 'KEY_LOCALE_PREFERENCE';
  static String get _localePreferenceDefault => _encodeLocale(
        AppLocalizations.supportedLocales.firstWhere((locale) => locale.languageCode == Platform.localeName.substring(0, 2), orElse: () => Locale('en')),
      );
  static String _useSystemLocaleKey = 'KEY_USE_SYSTEM_LOCALE';
  static bool get _useSystemLocaleDefault => true;
  static String _enableLoggingKey = 'KEY_VERBOSE_LOGGING';
  static bool get _enableLoggingDefault => false;

  SharedPreferences? _preferences;
  late SettingsState _lastState;

  SettingsNotifier(SharedPreferences? preferences)
      : _preferences = preferences,
        super(SettingsState(
          isFirstRun: preferences?.getBool(_isFirstRunKey) ?? _isFirstRunDefault,
          showGuideOnStart: preferences?.getBool(_showGuideOnStartKey) ?? _showGuideOnStartDefault,
          hideOpts: preferences?.getBool(_prefHideOtps) ?? _hideOtpsDefault,
          enablePolling: preferences?.getBool(_prefEnablePoll) ?? _enablePollDefault,
          crashReportRecipients: preferences?.getStringList(_crashReportRecipientsKey)?.toSet() ?? _crashReportRecipientsDefault,
          localePreference: preferences?.getString(_localePreferenceKey) != null
              ? _decodeLocale(preferences?.getString(_localePreferenceKey) ?? _localePreferenceDefault)
              : _decodeLocale(_localePreferenceDefault),
          useSystemLocale: preferences?.getBool(_useSystemLocaleKey) ?? _useSystemLocaleDefault,
          verboseLogging: preferences?.getBool(_enableLoggingKey) ?? _enableLoggingDefault,
        )) {
    _lastState = state;
    addListener((state) {
      print('Got new state: $state');
      _savePreferences(state);
    });
  }

  void addCrashReportRecipient(String email) {
    var updatedSet = state.crashReportRecipients..add(email);
    state = state.copyWith(crashReportRecipients: updatedSet);
  }

  set isFirstRun(bool value) => state = state.copyWith(isFirstRun: value);

  set hideOTPs(bool value) => state = state.copyWith(hideOpts: value);

  set showGuideOnStart(bool value) => state = state.copyWith(showGuideOnStart: value);

  void setLocalePreference(Locale locale) => state = state.copyWith(locale: locale);

  void setUseSystemLocale(bool value) => state = state.copyWith(useSystemLocale: value);

  void enablePolling() => state = state.copyWith(enablePolling: true);

  void disablePolling() => state = state.copyWith(enablePolling: false);

  void setPolling(bool value) => state = state.copyWith(enablePolling: value);

  void setLocale(Locale locale) => state = state.copyWith(locale: locale);

  void setVerboseLogging(bool value) => state = state.copyWith(verboseLogging: value);

  void toggleVerboseLogging() => state = state.copyWith(verboseLogging: !state.verboseLogging);

  void setFirstRun(bool value) => state = state.copyWith(isFirstRun: value);

  static String _encodeLocale(Locale locale) {
    return '${locale.languageCode}#${locale.countryCode}';
  }

  static Locale _decodeLocale(String str) {
    var split = str.split('#');
    return split[1] == 'null' ? Locale(split[0]) : Locale(split[0], split[1]);
  }

  void _savePreferences(SettingsState state) {
    if (_lastState.isFirstRun != state.isFirstRun) _preferences?.setBool(_isFirstRunKey, state.isFirstRun);
    if (_lastState.showGuideOnStart != state.showGuideOnStart) _preferences?.setBool(_showGuideOnStartKey, state.showGuideOnStart);
    if (_lastState.hideOpts != state.hideOpts) _preferences?.setBool(_prefHideOtps, state.hideOpts);
    if (_lastState.pollingEnabled != state.pollingEnabled) _preferences?.setBool(_prefEnablePoll, state.pollingEnabled);
    if (_lastState.crashReportRecipients != state.crashReportRecipients)
      _preferences?.setStringList(_crashReportRecipientsKey, state.crashReportRecipients.toList());
    if (_lastState.localePreference != state.localePreference) _preferences?.setString(_localePreferenceKey, _encodeLocale(state.localePreference));
    if (_lastState.useSystemLocale != state.useSystemLocale) _preferences?.setBool(_useSystemLocaleKey, state.useSystemLocale);
    if (_lastState.verboseLogging != state.verboseLogging) _preferences?.setBool(_enableLoggingKey, state.verboseLogging);
    _lastState = state;
  }
}
