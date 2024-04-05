import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';

void main() {
  _testSettingsState();
}

void _testSettingsState() {
  group('SettingsState', () {
    final state = SettingsState(
      isFirstRun: true,
      showGuideOnStart: true,
      hideOpts: true,
      enablePolling: true,
      crashReportRecipients: {'test'},
      localePreference: const Locale('en'),
      useSystemLocale: true,
      verboseLogging: true,
    );
    test('constructor', () {
      expect(state.isFirstRun, true);
      expect(state.showGuideOnStart, true);
      expect(state.hideOpts, true);
      expect(state.enablePolling, true);
      expect(state.crashReportRecipients, {'test'});
      expect(state.localePreference.toLanguageTag(), const Locale('en').toLanguageTag());
      expect(state.useSystemLocale, true);
      expect(state.verboseLogging, true);
    });
    test('copyWith', () {
      final newState = state.copyWith(
        isFirstRun: false,
        showGuideOnStart: false,
        hideOpts: false,
        enablePolling: false,
        crashReportRecipients: {'test2'},
        localePreference: const Locale('de'),
        useSystemLocale: false,
        verboseLogging: false,
      );
      expect(state.isFirstRun, true);
      expect(state.showGuideOnStart, true);
      expect(state.hideOpts, true);
      expect(state.enablePolling, true);
      expect(state.crashReportRecipients, {'test'});
      expect(state.localePreference.toLanguageTag(), const Locale('en').toLanguageTag());
      expect(state.useSystemLocale, true);
      expect(state.verboseLogging, true);
      expect(newState.isFirstRun, false);
      expect(newState.showGuideOnStart, false);
      expect(newState.hideOpts, false);
      expect(newState.enablePolling, false);
      expect(newState.crashReportRecipients, {'test2'});
      expect(newState.localePreference.toLanguageTag(), const Locale('de').toLanguageTag());
      expect(newState.useSystemLocale, false);
      expect(newState.verboseLogging, false);
    });
    test('encodeLocale/decodeLocale', () {
      const locale = Locale('en');
      final encodedLocale = SettingsState.encodeLocale(locale);
      final decodedLocale = SettingsState.decodeLocale(encodedLocale);
      expect(locale.toLanguageTag(), decodedLocale.toLanguageTag());
    });
  });
}
