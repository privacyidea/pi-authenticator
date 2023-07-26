import 'dart:ui';

/// This class contains all device specific settings. E.g., the language used, whether to show the guide on start, etc.
class SettingsState {
  final bool isFirstRun;
  final bool showGuideOnStart;
  final bool hideOpts;
  final bool enablePolling;
  final Set<String> crashReportRecipients;
  final Locale localePreference;
  final bool useSystemLocale;
  final bool verboseLogging;

  SettingsState(
      {required this.isFirstRun,
      required this.showGuideOnStart,
      required this.hideOpts,
      required this.enablePolling,
      required this.crashReportRecipients,
      required this.localePreference,
      required this.useSystemLocale,
      required this.verboseLogging});

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
}
