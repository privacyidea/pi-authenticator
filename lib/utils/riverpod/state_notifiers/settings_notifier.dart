// /*
//  * privacyIDEA Authenticator
//  *
//  * Author: Frank Merkel <frank.merkel@netknights.it>
//  *
//  * Copyright (c) 2024 NetKnights GmbH
//  *
//  * Licensed under the Apache License, Version 2.0 (the 'License');
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an 'AS IS' BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
// import 'dart:ui';

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../interfaces/repo/settings_repository.dart';
// import '../../../model/riverpod_states/settings_state.dart';
// import '../../../model/version.dart';
// import '../../logger.dart';
// import '../../push_provider.dart';

// /// This class provies access to the device specific settings.
// /// It also ensures that the settings are saved to the device.
// /// To Update a state use: ref.read(settingsProvider.notifier).anyMethod(value)
// class SettingsNotifier extends StateNotifier<SettingsState> {
//   late Future<SettingsState> loadingRepo;
//   final SettingsRepository _repo;

//   SettingsNotifier({
//     required SettingsRepository repository,
//     SettingsState? initialState,
//   })  : _repo = repository,
//         super(initialState ?? SettingsState()) {
//     loadFromRepo();
//   }
//   Future<void> loadFromRepo() async {
//     loadingRepo = Future(() async {
//       final newState = await _repo.loadSettings();
//       PushProvider.instance?.setPollingEnabled(state.enablePolling);
//       state = newState;
//       Logger.info('Loading settings from repo: $newState');
//       return newState;
//     });
//     await loadingRepo;
//   }

//   void _saveToRepo() async {
//     loadingRepo = Future(() async {
//       await _repo.saveSettings(state);
//       Logger.info('Saving settings to repo: $state');
//       return state;
//     });
//   }

//   void addCrashReportRecipient(String email) {
//     Logger.info('Crash report recipient added: $email');
//     var updatedSet = state.crashReportRecipients..add(email);
//     state = state.copyWith(crashReportRecipients: updatedSet);
//     _saveToRepo();
//   }

//   set isFirstRun(bool value) {
//     Logger.info('First run set to $value');
//     state = state.copyWith(isFirstRun: value);
//     _saveToRepo();
//   }

//   set hideOTPs(bool value) {
//     Logger.info('Hide OTPs set to $value');
//     state = state.copyWith(hideOpts: value);
//     _saveToRepo();
//   }

//   set showGuideOnStart(bool value) {
//     Logger.info('Show guide on start set to $value');
//     state = state.copyWith(showGuideOnStart: value);
//     _saveToRepo();
//   }

//   void setLocalePreference(Locale locale) {
//     Logger.info('Locale set to $locale');
//     state = state.copyWith(localePreference: locale);
//     _saveToRepo();
//   }

//   void setUseSystemLocale(bool value) {
//     Logger.info('Use system locale set to $value');
//     state = state.copyWith(useSystemLocale: value);
//     _saveToRepo();
//   }

//   void enablePolling() {
//     Logger.info('Polling set to true');
//     state = state.copyWith(enablePolling: true);
//     _saveToRepo();
//   }

//   void disablePolling() {
//     Logger.info('Polling set to false');
//     state = state.copyWith(enablePolling: false);
//     _saveToRepo();
//   }

//   void setPolling(bool value) {
//     Logger.info('Polling set to $value');
//     state = state.copyWith(enablePolling: value);
//     _saveToRepo();
//   }

//   void setLocale(Locale locale) {
//     Logger.info('Locale set to $locale');
//     state = state.copyWith(localePreference: locale);
//     _saveToRepo();
//   }

//   void setVerboseLogging(bool value) {
//     Logger.info('Verbose logging set to $value');
//     state = state.copyWith(verboseLogging: value);
//     _saveToRepo();
//   }

//   void toggleVerboseLogging() {
//     final value = !state.verboseLogging;
//     Logger.info('Verbose logging set to $value');
//     state = state.copyWith(verboseLogging: value);
//     _saveToRepo();
//   }

//   void setFirstRun(bool value) {
//     Logger.info('First run set to $value');
//     state = state.copyWith(isFirstRun: value);
//     _saveToRepo();
//   }

//   void setHidePushTokens(bool value) {
//     Logger.info('Hide push tokens set to $value');
//     state = state.copyWith(hidePushTokens: value);
//     _saveToRepo();
//   }

//   void setLatestStartedVersion(Version version) {
//     if (state.latestStartedVersion >= version) return;
//     Logger.info('Latest started version set to $version');
//     state = state.copyWith(latestStartedVersion: version);
//     _saveToRepo();
//   }
// }
