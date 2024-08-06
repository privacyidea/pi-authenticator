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

import 'dart:ui';

import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/repo/preference_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../interfaces/repo/settings_repository.dart';
import '../../../../model/riverpod_states/settings_state.dart';
import '../../../../model/version.dart';
import '../../../logger.dart';

part 'settings_provider.g.dart';

final settingsProvider = settingsNotifierProviderOf(repo: PreferenceSettingsRepository());

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  final Mutex _repoMutex = Mutex();
  final Mutex _stateMutex = Mutex();

  SettingsNotifier({SettingsRepository? repoOverride}) : _repoOverride = repoOverride;

  @override
  SettingsRepository get repo => _repo;
  final SettingsRepository? _repoOverride;
  late final SettingsRepository _repo;

  @override
  Future<SettingsState> build({
    required SettingsRepository repo,
  }) async {
    Logger.info('New settings notifier created', name: 'settings_notifier.dart#build');
    _repo = _repoOverride ?? repo;
    final newState = await _loadFromRepo();
    return newState;
  }

  Future<SettingsState> _loadFromRepo() async {
    await _repoMutex.acquire();
    final newState = await _repo.loadSettings();
    Logger.info('Loading settings from repo: $newState', name: 'settings_notifier.dart#_loadFromRepo');
    _repoMutex.release();
    return newState;
  }

  Future<bool> _saveToRepo(SettingsState state) async {
    await _repoMutex.acquire();
    Logger.info('Saving settings to repo: $state', name: 'settings_notifier.dart#_saveToRepo');
    final success = await _repo.saveSettings(state);
    _repoMutex.release();
    return success;
  }

  Future<SettingsState> updateState(SettingsState Function(SettingsState oldState) updater) async {
    await _stateMutex.acquire();
    final oldState = await future;
    final newState = updater(oldState);
    final success = await _saveToRepo(newState);
    if (success) {
      state = AsyncValue.data(newState);
      _stateMutex.release();
      return newState;
    } else {
      _stateMutex.release();
      return oldState;
    }
  }

  Future<SettingsState> addCrashReportRecipient(String email) async {
    Logger.info('Crash report recipient added: $email', name: 'settings_notifier.dart#addCrashReportRecipient');
    return updateState((oldState) {
      final updatedSet = oldState.crashReportRecipients..add(email);
      return oldState.copyWith(crashReportRecipients: updatedSet);
    });
  }

  Future<SettingsState> removeCrashReportRecipient(String email) async {
    Logger.info('Crash report recipient removed: $email', name: 'settings_notifier.dart#removeCrashReportRecipient');
    return updateState((oldState) {
      final updatedSet = oldState.crashReportRecipients..remove(email);
      return oldState.copyWith(crashReportRecipients: updatedSet);
    });
  }

  Future<SettingsState> setisFirstRun(bool value) {
    Logger.info('First run set to $value', name: 'settings_notifier.dart#setFirstRun');
    return updateState((oldState) => oldState.copyWith(isFirstRun: value));
  }

  Future<SettingsState> sethideOTPs(bool value) {
    Logger.info('Hide OTPs set to $value', name: 'settings_notifier.dart#setHideOTPs');
    return updateState((oldState) => oldState.copyWith(hideOpts: value));
  }

  Future<SettingsState> setshowGuideOnStart(bool value) {
    Logger.info('Show guide on start set to $value', name: 'settings_notifier.dart#setShowGuideOnStart');
    return updateState((oldState) => oldState.copyWith(showGuideOnStart: value));
  }

  Future<SettingsState> setLocalePreference(Locale locale) {
    Logger.info('Locale set to $locale', name: 'settings_notifier.dart#setLocalePreference');
    return updateState((oldState) => oldState.copyWith(localePreference: locale));
  }

  Future<SettingsState> setUseSystemLocale(bool value) {
    Logger.info('Use system locale set to $value', name: 'settings_notifier.dart#setUseSystemLocale');
    return updateState((oldState) => oldState.copyWith(useSystemLocale: value));
  }

  Future<SettingsState> enablePolling() {
    Logger.info('Polling set to true', name: 'settings_notifier.dart#enablePolling');
    return updateState((oldState) => oldState.copyWith(enablePolling: true));
  }

  Future<SettingsState> disablePolling() {
    Logger.info('Polling set to false', name: 'settings_notifier.dart#disablePolling');
    return updateState((oldState) => oldState.copyWith(enablePolling: false));
  }

  Future<SettingsState> setPolling(bool value) {
    Logger.info('Polling set to $value', name: 'settings_notifier.dart#setPolling');
    return updateState((oldState) => oldState.copyWith(enablePolling: value));
  }

  Future<SettingsState> setLocale(Locale locale) {
    Logger.info('Locale set to $locale', name: 'settings_notifier.dart#setLocale');
    return updateState((oldState) => oldState.copyWith(localePreference: locale));
  }

  Future<SettingsState> setVerboseLogging(bool value) {
    Logger.info('Verbose logging set to $value', name: 'settings_notifier.dart#setVerboseLogging');
    return updateState((oldState) => oldState.copyWith(verboseLogging: value));
  }

  Future<SettingsState> toggleVerboseLogging() {
    Logger.info('Toggling verbose logging', name: 'settings_notifier.dart#toggleVerboseLogging');
    return updateState((oldState) => oldState.copyWith(verboseLogging: !oldState.verboseLogging));
  }

  Future<SettingsState> setFirstRun(bool value) {
    Logger.info('First run set to $value', name: 'settings_notifier.dart#setFirstRun');
    return updateState((oldState) => oldState.copyWith(isFirstRun: value));
  }

  Future<SettingsState> setHidePushTokens(bool value) {
    Logger.info('Hide push tokens set to $value', name: 'settings_notifier.dart#setHidePushTokens');
    return updateState((oldState) => oldState.copyWith(hidePushTokens: value));
  }

  Future<SettingsState> setLatestStartedVersion(Version version) {
    Logger.info('Latest started version set to $version', name: 'settings_notifier.dart#setLatestStartedVersion');
    return updateState((oldState) => oldState.copyWith(latestStartedVersion: version));
  }
}
