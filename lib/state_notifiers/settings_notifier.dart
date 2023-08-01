import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/states/settings_state.dart';
import '../repo/settings_repository.dart';

/// This class provies access to the device specific settings.
/// It also ensures that the settings are saved to the device.
/// To Update a state use: ref.read(settingsProvider.notifier).anyMethod(value)
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;
  SettingsNotifier({required SettingsRepository repository, required SettingsState initialState})
      : _repo = repository,
        super(initialState) {
    _loadFromRepo();
    addListener((state) {
      if (state != initialState) _saveToRepo();
    });
  }
  void _loadFromRepo() async {
    state = await _repo.loadSettings();
  }

  void _saveToRepo() async {
    await _repo.saveSettings(state);
  }

  void addCrashReportRecipient(String email) {
    var updatedSet = state.crashReportRecipients..add(email);
    state = state.copyWith(crashReportRecipients: updatedSet);
  }

  set isFirstRun(bool value) => state = state.copyWith(isFirstRun: value);

  set hideOTPs(bool value) => state = state.copyWith(hideOpts: value);

  set showGuideOnStart(bool value) => state = state.copyWith(showGuideOnStart: value);

  void setLocalePreference(Locale locale) => state = state.copyWith(localePreference: locale);

  void setUseSystemLocale(bool value) => state = state.copyWith(useSystemLocale: value);

  void enablePolling() => state = state.copyWith(enablePolling: true);

  void disablePolling() => state = state.copyWith(enablePolling: false);

  void setPolling(bool value) => state = state.copyWith(enablePolling: value);

  void setLocale(Locale locale) => state = state.copyWith(localePreference: locale);

  void setVerboseLogging(bool value) => state = state.copyWith(verboseLogging: value);

  void toggleVerboseLogging() => state = state.copyWith(verboseLogging: !state.verboseLogging);

  void setFirstRun(bool value) => state = state.copyWith(isFirstRun: value);
}
