import 'dart:ui';

/// This class contains all device specific settings. E.g., the language used, whether to show the guide on start, etc.
class SettingsState {
  final bool _isFirstRun;
  bool get isFirstRun => _isFirstRun;
  final bool _showGuideOnStart;
  bool get showGuideOnStart => _showGuideOnStart;
  final bool _hideOpts;
  bool get hideOpts => _hideOpts;
  final bool _enablePolling;
  bool get pollingEnabled => _enablePolling;
  final Set<String> _crashReportRecipients;
  Set<String> get crashReportRecipients => _crashReportRecipients;
  final Locale _localePreference;
  Locale get localePreference => _localePreference;
  final bool _useSystemLocale;
  bool get useSystemLocale => _useSystemLocale;
  final bool _verboseLogging;
  bool get verboseLogging => _verboseLogging;

  SettingsState(
      {required bool isFirstRun,
      required bool showGuideOnStart,
      required bool hideOpts,
      required bool enablePolling,
      required Set<String> crashReportRecipients,
      required Locale localePreference,
      required bool useSystemLocale,
      required bool verboseLogging})
      : _isFirstRun = isFirstRun,
        _showGuideOnStart = showGuideOnStart,
        _hideOpts = hideOpts,
        _enablePolling = enablePolling,
        _crashReportRecipients = crashReportRecipients,
        _localePreference = localePreference,
        _useSystemLocale = useSystemLocale,
        _verboseLogging = verboseLogging;

  SettingsState copyWith({
    bool? isFirstRun,
    bool? showGuideOnStart,
    bool? hideOpts,
    bool? enablePolling,
    Set<String>? crashReportRecipients,
    Locale? locale,
    bool? useSystemLocale,
    bool? verboseLogging,
  }) {
    return SettingsState(
      isFirstRun: isFirstRun ?? this._isFirstRun,
      hideOpts: hideOpts ?? this._hideOpts,
      enablePolling: enablePolling ?? this._enablePolling,
      showGuideOnStart: showGuideOnStart ?? this._showGuideOnStart,
      crashReportRecipients: crashReportRecipients ?? this._crashReportRecipients,
      localePreference: locale ?? this._localePreference,
      useSystemLocale: useSystemLocale ?? this._useSystemLocale,
      verboseLogging: verboseLogging ?? this._verboseLogging,
    );
  }

  @override
  String toString() =>
      'SettingsState(isFirstRun: $_isFirstRun, showGuideOnStart: $_showGuideOnStart, hideOpts: $_hideOpts, enablePolling: $_enablePolling, crashReportRecipients: $_crashReportRecipients, localePreference: $_localePreference, useSystemLocale: $_useSystemLocale, verboseLogging: $_verboseLogging)';
}
