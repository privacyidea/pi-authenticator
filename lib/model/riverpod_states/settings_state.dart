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
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/identifiers.dart';
import '../version.dart';

/// This class contains all device specific settings. E.g., the language used, whether to show the guide on start, etc.
class SettingsState {
  static bool get _isFirstRunDefault => true;
  static bool get _showGuideOnStartDefault => true;
  static bool get _hideOtpsDefault => false;
  static bool get _enablePollDefault => false;
  static Set<String> get _crashReportRecipientsDefault => {defaultCrashReportRecipient};
  static Locale get _localePreferenceDefault => AppLocalizations.supportedLocales
      .firstWhere((locale) => locale.languageCode == (!kIsWeb ? Platform.localeName.substring(0, 2) : 'en'), orElse: () => const Locale('en'));

  static bool get _useSystemLocaleDefault => true;
  static bool get _enableLoggingDefault => false;
  static bool get _hidePushTokensDefault => false;
  static Version get _latestStartedVersionDefault => Version.parse('0.0.0');

  final bool isFirstRun;
  final bool showGuideOnStart;
  final bool hideOpts;
  final bool enablePolling;
  final Set<String> crashReportRecipients;
  final Locale localePreference;
  Locale get currentLocale => useSystemLocale
      ? AppLocalizations.supportedLocales
          .firstWhere((locale) => locale.languageCode == (!kIsWeb ? Platform.localeName.substring(0, 2) : 'en'), orElse: () => const Locale('en'))
      : localePreference;
  final bool useSystemLocale;
  final bool verboseLogging;
  final bool hidePushTokens;
  final Version latestStartedVersion;

  SettingsState({
    bool? isFirstRun,
    bool? showGuideOnStart,
    bool? hideOpts,
    bool? enablePolling,
    Set<String>? crashReportRecipients,
    Locale? localePreference,
    bool? useSystemLocale,
    bool? verboseLogging,
    bool? hidePushTokens,
    Version? latestStartedVersion,
  })  : isFirstRun = isFirstRun ?? _isFirstRunDefault,
        showGuideOnStart = showGuideOnStart ?? _showGuideOnStartDefault,
        hideOpts = hideOpts ?? _hideOtpsDefault,
        enablePolling = enablePolling ?? _enablePollDefault,
        crashReportRecipients = crashReportRecipients ?? _crashReportRecipientsDefault,
        localePreference = localePreference ?? _localePreferenceDefault,
        useSystemLocale = useSystemLocale ?? _useSystemLocaleDefault,
        verboseLogging = verboseLogging ?? _enableLoggingDefault,
        hidePushTokens = hidePushTokens ?? _hidePushTokensDefault,
        latestStartedVersion = latestStartedVersion ?? _latestStartedVersionDefault;

  SettingsState copyWith({
    bool? isFirstRun,
    bool? showGuideOnStart,
    bool? hideOpts,
    bool? enablePolling,
    Set<String>? crashReportRecipients,
    Locale? localePreference,
    bool? useSystemLocale,
    bool? verboseLogging,
    bool? hidePushTokens,
    Version? latestStartedVersion,
  }) {
    return SettingsState(
      isFirstRun: isFirstRun ?? this.isFirstRun,
      hideOpts: hideOpts ?? this.hideOpts,
      enablePolling: enablePolling ?? this.enablePolling,
      showGuideOnStart: showGuideOnStart ?? this.showGuideOnStart,
      crashReportRecipients: crashReportRecipients ?? this.crashReportRecipients,
      localePreference: localePreference ?? this.localePreference,
      useSystemLocale: useSystemLocale ?? this.useSystemLocale,
      verboseLogging: verboseLogging ?? this.verboseLogging,
      hidePushTokens: hidePushTokens ?? this.hidePushTokens,
      latestStartedVersion: latestStartedVersion ?? this.latestStartedVersion,
    );
  }

  @override
  String toString() => 'SettingsState(isFirstRun: $isFirstRun, showGuideOnStart: $showGuideOnStart, hideOpts: $hideOpts, enablePolling: $enablePolling, '
      'crashReportRecipients: $crashReportRecipients, localePreference: $localePreference, useSystemLocale: $useSystemLocale, verboseLogging: $verboseLogging, '
      'hidePushTokens: $hidePushTokens)';

  static String encodeLocale(Locale locale) {
    return '${locale.languageCode}#${locale.countryCode}';
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsState &&
        other.isFirstRun == isFirstRun &&
        other.showGuideOnStart == showGuideOnStart &&
        other.hideOpts == hideOpts &&
        other.enablePolling == enablePolling &&
        other.crashReportRecipients.toString() == crashReportRecipients.toString() &&
        other.localePreference.toString() == localePreference.toString() &&
        other.useSystemLocale == useSystemLocale &&
        other.verboseLogging == verboseLogging &&
        other.hidePushTokens == hidePushTokens;
  }

  static Locale decodeLocale(String str) {
    var split = str.split('#');
    return split[1] == 'null' ? Locale(split[0]) : Locale(split[0], split[1]);
  }
}
