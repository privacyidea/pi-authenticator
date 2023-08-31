import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interfaces/repo/settings_repository.dart';

import '../model/states/settings_state.dart';

/// This class provies access to the device specific settings.
/// It also ensures that the settings are saved to the device.
/// To Update a state use: ref.read(settingsProvider.notifier).anyMethod(value)
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;
  late final Future<void> _isInitialized;

  SettingsNotifier({
    required SettingsRepository repository,
    required SettingsState initialState,
  })  : _repo = repository,
        super(initialState) {
    _isInitialized = Future<void>(() => _loadFromRepo());
  }
  void _loadFromRepo() async => state = await _repo.loadSettings();

  Future<bool> _saveToRepo() => _repo.saveSettings(state);

  void addCrashReportRecipient(String email) async {
    await _isInitialized;
    var updatedSet = state.crashReportRecipients..add(email);
    state = state.copyWith(crashReportRecipients: updatedSet);
  }

  void setLocalePreference(Locale locale) async {
    await _isInitialized;
    state = state.copyWith(localePreference: locale);
    _saveToRepo();
  }

  void setUseSystemLocale(bool value) async {
    await _isInitialized;
    state = state.copyWith(useSystemLocale: value);
    _saveToRepo();
  }

  void setPolling(bool value) async {
    await _isInitialized;
    state = state.copyWith(enablePolling: value);
    _saveToRepo();
  }

  void setVerboseLogging(bool value) async {
    await _isInitialized;
    state = state.copyWith(verboseLogging: value);
    _saveToRepo();
  }

  void toggleVerboseLogging() async {
    await _isInitialized;
    state = state.copyWith(verboseLogging: !state.verboseLogging);
    _saveToRepo();
  }

  void setFirstRun(bool value) async {
    await _isInitialized;
    state = state.copyWith(isFirstRun: value);
    _saveToRepo();
  }
}
