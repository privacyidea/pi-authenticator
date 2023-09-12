import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interfaces/repo/settings_repository.dart';

import '../model/states/settings_state.dart';

/// This class provies access to the device specific settings.
/// It also ensures that the settings are saved to the device.
/// To Update a state use: ref.read(settingsProvider.notifier).anyMethod(value)
class SettingsNotifier extends StateNotifier<SettingsState> {
  late Future<void> isLoading;
  final SettingsRepository _repo;

  SettingsNotifier({
    required SettingsRepository repository,
    SettingsState? initialState,
  })  : _repo = repository,
        super(initialState ?? SettingsState()) {
    loadFromRepo();
  }
  void loadFromRepo() async {
    isLoading = Future<void>(() async {
      state = await _repo.loadSettings();
    });
  }

  Future<bool> _saveToRepo() => _repo.saveSettings(state);

  void addCrashReportRecipient(String email) async {
    await isLoading;
    var updatedSet = state.crashReportRecipients..add(email);
    state = state.copyWith(crashReportRecipients: updatedSet);
  }

  void setLocalePreference(Locale locale) async {
    await isLoading;
    state = state.copyWith(localePreference: locale);
    _saveToRepo();
  }

  void setUseSystemLocale(bool value) async {
    await isLoading;
    state = state.copyWith(useSystemLocale: value);
    _saveToRepo();
  }

  void setPolling(bool value) async {
    await isLoading;
    state = state.copyWith(enablePolling: value);
    _saveToRepo();
  }

  void setVerboseLogging(bool value) async {
    await isLoading;
    state = state.copyWith(verboseLogging: value);
    _saveToRepo();
  }

  void toggleVerboseLogging() async {
    await isLoading;
    state = state.copyWith(verboseLogging: !state.verboseLogging);
    _saveToRepo();
  }

  void setFirstRun(bool value) async {
    await isLoading;
    state = state.copyWith(isFirstRun: value);
    _saveToRepo();
  }
}
