import 'dart:io';
import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/identifiers.dart';

/// This class contains all device specific settings. E.g., the language used, whether to show the guide on start, etc.
class SettingsState {
  static bool get _isFirstRunDefault => true;
  static bool get _showGuideOnStartDefault => true;
  static bool get _hideOtpsDefault => false;
  static bool get _enablePollDefault => false;
  static Set<String> get _crashReportRecipientsDefault => {defaultCrashReportRecipient};
  static Locale get _localePreferenceDefault =>
      AppLocalizations.supportedLocales.firstWhere((locale) => locale.languageCode == Platform.localeName.substring(0, 2), orElse: () => const Locale('en'));

  static bool get _useSystemLocaleDefault => true;
  static bool get _enableLoggingDefault => false;

  final bool isFirstRun;
  final bool showGuideOnStart;
  final bool hideOpts;
  final bool enablePolling;
  final Set<String> crashReportRecipients;
  final Locale localePreference;
  Locale get currentLocale => useSystemLocale
      ? AppLocalizations.supportedLocales.firstWhere((locale) => locale.languageCode == Platform.localeName.substring(0, 2), orElse: () => const Locale('en'))
      : localePreference;
  final bool useSystemLocale;
  final bool verboseLogging;

  SettingsState({
    bool? isFirstRun,
    bool? showGuideOnStart,
    bool? hideOpts,
    bool? enablePolling,
    Set<String>? crashReportRecipients,
    Locale? localePreference,
    bool? useSystemLocale,
    bool? verboseLogging,
  })  : isFirstRun = isFirstRun ?? _isFirstRunDefault,
        showGuideOnStart = showGuideOnStart ?? _showGuideOnStartDefault,
        hideOpts = hideOpts ?? _hideOtpsDefault,
        enablePolling = enablePolling ?? _enablePollDefault,
        crashReportRecipients = crashReportRecipients ?? _crashReportRecipientsDefault,
        localePreference = localePreference ?? _localePreferenceDefault,
        useSystemLocale = useSystemLocale ?? _useSystemLocaleDefault,
        verboseLogging = verboseLogging ?? _enableLoggingDefault;

  SettingsState copyWith({
    bool? isFirstRun,
    bool? showGuideOnStart,
    bool? hideOpts,
    bool? enablePolling,
    Set<String>? crashReportRecipients,
    Locale? localePreference,
    bool? useSystemLocale,
    bool? verboseLogging,
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
    );
  }

  @override
  String toString() =>
      'SettingsState(isFirstRun: $isFirstRun, showGuideOnStart: $showGuideOnStart, hideOpts: $hideOpts, enablePolling: $enablePolling, crashReportRecipients: $crashReportRecipients, localePreference: $localePreference, useSystemLocale: $useSystemLocale, verboseLogging: $verboseLogging)';

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
        other.verboseLogging == verboseLogging;
  }

  static Locale decodeLocale(String str) {
    var split = str.split('#');
    return split[1] == 'null' ? Locale(split[0]) : Locale(split[0], split[1]);
  }
}
