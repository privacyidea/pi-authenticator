import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/utils/riverpod/state_notifiers/settings_notifier.dart';
import 'package:mockito/annotations.dart';

import 'settings_notifier_test.mocks.dart';

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

@GenerateMocks([SettingsRepository])
void main() {
  _testSettingsNotifier();
}

void _testSettingsNotifier() {
  group('SettingsNotifier', () {
    final mockRepo = MockSettingsRepository();
    test('load state from repo on creation', () async {
      final container = ProviderContainer();
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: SettingsState(
              isFirstRun: true,
              hideOpts: true,
              showGuideOnStart: false,
              localePreference: const Locale('de'),
              useSystemLocale: false,
              enablePolling: false,
              verboseLogging: true,
              crashReportRecipients: {'someone'},
            ),
            repository: MockSettingsRepository(),
          ));
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, _state);
        verify(mockRepo.loadSettings()).called(1);
      });
    });

    test('addCrashReportRecipient', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        crashReportRecipients: {'someone', 'anotherOne'},
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(mockRepo.saveSettings(copyWithSettings)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: _state,
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      notifier.addCrashReportRecipient('anotherOne');
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
      when(mockRepo.saveSettings(copyWithSettings)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: _state,
            repository: mockRepo,
          ));
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
      when(mockRepo.saveSettings(copyWithSettings)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: _state,
            repository: mockRepo,
          ));
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
      when(mockRepo.saveSettings(copyWithSettings)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: _state,
            repository: mockRepo,
          ));
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
      when(mockRepo.saveSettings(copyWithSettings)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: _state,
            repository: mockRepo,
          ));
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
      when(mockRepo.saveSettings(copyWithSettings)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: _state,
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      notifier.toggleVerboseLogging();
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });
    test('setFirstRun', () {
      final container = ProviderContainer();
      final copyWithSettings = _state.copyWith(
        isFirstRun: !_state.isFirstRun,
      );
      when(mockRepo.loadSettings()).thenAnswer((_) async => _state);
      when(mockRepo.saveSettings(copyWithSettings)).thenAnswer((_) async => true);
      final testProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(
            initialState: _state,
            repository: mockRepo,
          ));
      final notifier = container.read(testProvider.notifier);
      notifier.setFirstRun(!_state.isFirstRun);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        final state = container.read(testProvider);
        expect(state, isNotNull);
        expect(state, copyWithSettings);
        verify(mockRepo.saveSettings(copyWithSettings)).called(1);
      });
    });
  });
}
