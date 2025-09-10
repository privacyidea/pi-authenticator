/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutex/mutex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../repo/preference_settings_repository.dart';
import '../../../../interfaces/repo/settings_repository.dart';
import '../../../../model/riverpod_states/settings_state.dart';
import '../../../../model/version.dart';
import '../../../logger.dart';

part 'settings_notifier.g.dart';

final settingsProvider = settingsNotifierProviderOf(repo: PreferenceSettingsRepository());
final hidePushTokensProvider = settingsProvider.select<bool>((asyncValue) => asyncValue.value?.hidePushTokens ?? false);

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
  Future<SettingsState> build({required SettingsRepository repo}) async {
    Logger.info('New settings notifier created');
    _repo = _repoOverride ?? repo;
    final newState = await _loadFromRepo();
    return newState;
  }

  Future<SettingsState> _loadFromRepo() async {
    await _repoMutex.acquire();
    final newState = await _repo.loadSettings();
    Logger.info('Loading settings from repo: $newState');
    _repoMutex.release();
    return newState;
  }

  Future<bool> _saveToRepo(SettingsState state) async {
    await _repoMutex.acquire();
    Logger.info('Saving settings to repo: $state');
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
    Logger.info('Crash report recipient added: $email');
    return updateState((oldState) {
      final updatedSet = oldState.crashReportRecipients..add(email);
      return oldState.copyWith(crashReportRecipients: updatedSet);
    });
  }

  Future<SettingsState> removeCrashReportRecipient(String email) async {
    Logger.info('Crash report recipient removed: $email');
    return updateState((oldState) {
      final updatedSet = oldState.crashReportRecipients..remove(email);
      return oldState.copyWith(crashReportRecipients: updatedSet);
    });
  }

  Future<SettingsState> setIsFirstRun(bool value) {
    Logger.info('First run set to $value');
    return updateState((oldState) => oldState.copyWith(isFirstRun: value));
  }

  Future<SettingsState> setHideOTPs(bool value) {
    Logger.info('Hide OTPs set to $value');
    return updateState((oldState) => oldState.copyWith(hideOpts: value));
  }

  Future<SettingsState> setShowGuideOnStart(bool value) {
    Logger.info('Show guide on start set to $value');
    return updateState((oldState) => oldState.copyWith(showGuideOnStart: value));
  }

  Future<SettingsState> setLocalePreference(Locale locale) {
    Logger.info('Locale set to $locale');
    return updateState((oldState) => oldState.copyWith(localePreference: locale));
  }

  Future<SettingsState> setUseSystemLocale(bool value) {
    Logger.info('Use system locale set to $value');
    return updateState((oldState) => oldState.copyWith(useSystemLocale: value));
  }

  Future<SettingsState> setPolling(bool value) {
    Logger.info('Polling set to $value');
    return updateState((oldState) => oldState.copyWith(enablePolling: value));
  }

  Future<SettingsState> setVerboseLogging(bool value) async {
    Logger.info('Verbose logging set to $value');
    final updatedState = await updateState((oldState) => oldState.copyWith(verboseLogging: value));
    Logger.setVerboseLogging(updatedState.verboseLogging);
    return updatedState;
  }

  Future<SettingsState> toggleVerboseLogging() {
    Logger.info('Toggling verbose logging');
    return updateState((oldState) => oldState.copyWith(verboseLogging: !oldState.verboseLogging));
  }

  Future<SettingsState> setHidePushTokens(bool value) {
    Logger.info('Hide push tokens set to $value');
    return updateState((oldState) => oldState.copyWith(hidePushTokens: value));
  }

  Future<SettingsState> setLatestStartedVersion(Version version) {
    Logger.info('Latest started version set to $version');
    return updateState((oldState) => oldState.copyWith(latestStartedVersion: version));
  }

  Future<SettingsState> setShowBackgroundImage(bool value) {
    Logger.info('Show background image set to $value');
    return updateState((oldState) => oldState.copyWith(showBackgroundImage: value));
  }

  Future<SettingsState> toggleShowBackgroundImage() {
    Logger.info('Toggling hide background image');
    return updateState((oldState) => oldState.copyWith(showBackgroundImage: !oldState.showBackgroundImage));
  }

  Future<SettingsState> setAutoCloseAppAfterAcceptingPushRequest(bool value) {
    Logger.info('Auto close app after accepting push request set to $value');
    return updateState((oldState) => oldState.copyWith(autoCloseAppAfterAcceptingPushRequest: value));
  }
}
