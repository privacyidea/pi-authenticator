import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';

import '../../tests_app_wrapper.mocks.dart';

final _state = SettingsState(
  isFirstRun: false,
  hideOpts: false,
  showGuideOnStart: true,
  localePreference: const Locale('en'),
  useSystemLocale: true,
  enablePolling: true,
  verboseLogging: false,
  crashReportRecipients: {'someone'},
);

void main() {
  _testSettingsNotifier();
}

void _testSettingsNotifier() {
  group('SettingsNotifier', () {
    final mockRepo = MockSettingsRepository();

    test('load state from repo on creation', () async {
      final container = ProviderContainer();
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      final testProvider = settingsProviderOf(repo: mockRepo);

      final state = await container.read(testProvider.future);
      expect(state, isNotNull);
      expect(state, _state);
      verify(mockRepo.loadSettings()).called(1);
    });

    test('addCrashReportRecipient', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        crashReportRecipients: {'someone', 'anotherOne'},
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.addCrashReportRecipient('anotherOne');
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('removeCrashReportRecipient', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(crashReportRecipients: {});
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.removeCrashReportRecipient('someone');
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setIsFirstRun', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(isFirstRun: !_state.isFirstRun);
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setIsFirstRun(!_state.isFirstRun);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setHideOpts', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(hideOpts: !_state.hideOpts);
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setHideOTPs(!_state.hideOpts);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setShowGuideOnStart', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        showGuideOnStart: !_state.showGuideOnStart,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setShowGuideOnStart(!_state.showGuideOnStart);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setLocalePreference', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        localePreference: const Locale('en'),
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setLocalePreference(const Locale('en'));
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });
    test('setUseSystemLocale', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        useSystemLocale: !_state.useSystemLocale,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setUseSystemLocale(!_state.useSystemLocale);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setPolling', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        enablePolling: !_state.enablePolling,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setPolling(!_state.enablePolling);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });
    test('setVerboseLogging', () async {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        verboseLogging: !_state.verboseLogging,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setVerboseLogging(!_state.verboseLogging);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });
    test('toggleVerboseLogging', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        verboseLogging: !_state.verboseLogging,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.toggleVerboseLogging();
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setHidePushTokens', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        hidePushTokens: !_state.hidePushTokens,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setHidePushTokens(!_state.hidePushTokens);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setLatestStartedVersion', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        latestStartedVersion: Version(1, 0, 0),
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setLatestStartedVersion(Version(1, 0, 0));
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('setShowBackgroundImage', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        showBackgroundImage: !_state.showBackgroundImage,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.setShowBackgroundImage(!_state.showBackgroundImage);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });

    test('toggleShowBackgroundImage', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        showBackgroundImage: !_state.showBackgroundImage,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(
        mockRepo.saveSettings(copyWithSettings),
      ).thenAnswer((_) async => true);

      final testProvider = settingsProviderOf(repo: mockRepo);
      final notifier = container.read(testProvider.notifier);
      notifier.toggleShowBackgroundImage();
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });
  });
}
