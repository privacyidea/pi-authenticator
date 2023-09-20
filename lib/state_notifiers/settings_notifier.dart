import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

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
    Logger.info('Loading settings from repo: $state', name: 'settings_notifier.dart#_loadFromRepo');
  }

  void _saveToRepo() async {
    Logger.info('Saving settings to repo: $state', name: 'settings_notifier.dart#_saveToRepo');
    await _repo.saveSettings(state);
  }

  void addCrashReportRecipient(String email) {
    Logger.info('Crash report recipient added: $email', name: 'settings_notifier.dart#addCrashReportRecipient');
    var updatedSet = state.crashReportRecipients..add(email);
    state = state.copyWith(crashReportRecipients: updatedSet);
  }

  set isFirstRun(bool value) {
    Logger.info('First run set to $value', name: 'settings_notifier.dart#setFirstRun');
    state = state.copyWith(isFirstRun: value);
  }

  set hideOTPs(bool value) {
    Logger.info('Hide OTPs set to $value', name: 'settings_notifier.dart#setHideOTPs');
    state = state.copyWith(hideOpts: value);
  }

  set showGuideOnStart(bool value) {
    Logger.info('Show guide on start set to $value', name: 'settings_notifier.dart#setShowGuideOnStart');
    state = state.copyWith(showGuideOnStart: value);
  }

  void setLocalePreference(Locale locale) {
    Logger.info('Locale set to $locale', name: 'settings_notifier.dart#setLocalePreference');
    state = state.copyWith(localePreference: locale);
  }

  void setUseSystemLocale(bool value) {
    Logger.info('Use system locale set to $value', name: 'settings_notifier.dart#setUseSystemLocale');
    state = state.copyWith(useSystemLocale: value);
  }

  void enablePolling() {
    Logger.info('Polling set to true', name: 'settings_notifier.dart#enablePolling');
    state = state.copyWith(enablePolling: true);
  }

  void disablePolling() {
    Logger.info('Polling set to false', name: 'settings_notifier.dart#disablePolling');
    state = state.copyWith(enablePolling: false);
  }

  void setPolling(bool value) {
    Logger.info('Polling set to $value', name: 'settings_notifier.dart#setPolling');
    state = state.copyWith(enablePolling: value);
  }

  void setLocale(Locale locale) {
    Logger.info('Locale set to $locale', name: 'settings_notifier.dart#setLocale');
    state = state.copyWith(localePreference: locale);
  }

  void setVerboseLogging(bool value) {
    Logger.info('Verbose logging set to $value', name: 'settings_notifier.dart#setVerboseLogging');
    state = state.copyWith(verboseLogging: value);
  }

  void toggleVerboseLogging() {
    final value = !state.verboseLogging;
    Logger.info('Verbose logging set to $value', name: 'settings_notifier.dart#setVerboseLogging');
    state = state.copyWith(verboseLogging: value);
  }

  void setFirstRun(bool value) {
    Logger.info('First run set to $value', name: 'settings_notifier.dart#setFirstRun');
    state = state.copyWith(isFirstRun: value);
  }
}
