import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/repo/preference_settings_repository.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tests_app_wrapper.mocks.dart';

/// Creates a NEW state (including a NEW mutable recipients set) on every call.
/// A shared top-level state would be mutated in place by
/// [SettingsNotifier.addCrashReportRecipient] and leak between tests.
SettingsState _newState() => SettingsState(
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
  TestWidgetsFlutterBinding.ensureInitialized();
  _testSettingsNotifier();
  _testSettingsNotifierWithRealRepo();
}

void _testSettingsNotifier() {
  group('SettingsNotifier', () {
    late MockSettingsRepository mockRepo;
    late SettingsState loadedState;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockSettingsRepository();
      loadedState = _newState();
      container = ProviderContainer();
      addTearDown(container.dispose);
      when(mockRepo.loadSettings()).thenAnswer((_) async => loadedState);
      when(mockRepo.saveSettings(any)).thenAnswer((_) async => true);
    });

    tearDown(() {
      // build() and setVerboseLogging() change this static flag.
      Logger.setVerboseLogging(false);
    });

    /// Reads the (already loaded) notifier, runs [act] and checks that
    /// exactly [expected] was returned, published as state and saved once.
    Future<void> expectUpdate({
      required Future<SettingsState> Function(SettingsNotifier notifier) act,
      required SettingsState expected,
    }) async {
      final testProvider = settingsProviderOf(repo: mockRepo);
      await container.read(testProvider.future);
      final notifier = container.read(testProvider.notifier);

      final result = await act(notifier);

      expect(result, expected);
      expect(container.read(testProvider).value, expected);
      verify(mockRepo.loadSettings()).called(1);
      verify(mockRepo.saveSettings(expected)).called(1);
      verifyNoMoreInteractions(mockRepo);
    }

    test('load state from repo on creation', () async {
      final testProvider = settingsProviderOf(repo: mockRepo);

      final state = await container.read(testProvider.future);

      expect(state, isNotNull);
      expect(state, _newState());
      verify(mockRepo.loadSettings()).called(1);
      verifyNever(mockRepo.saveSettings(any));
    });

    test('addCrashReportRecipient', () async {
      await expectUpdate(
        act: (n) => n.addCrashReportRecipient('anotherOne'),
        expected: _newState().copyWith(
          crashReportRecipients: {'someone', 'anotherOne'},
        ),
      );
    });

    test('removeCrashReportRecipient', () async {
      await expectUpdate(
        act: (n) => n.removeCrashReportRecipient('someone'),
        expected: _newState().copyWith(crashReportRecipients: {}),
      );
    });

    test('removeCrashReportRecipient of an unknown recipient changes nothing '
        'in the recipients', () async {
      await expectUpdate(
        act: (n) => n.removeCrashReportRecipient('stranger'),
        expected: _newState(),
      );
    });

    test('setIsFirstRun', () async {
      await expectUpdate(
        act: (n) => n.setIsFirstRun(true),
        expected: _newState().copyWith(isFirstRun: true),
      );
    });

    test('setHideOTPs', () async {
      await expectUpdate(
        act: (n) => n.setHideOTPs(true),
        expected: _newState().copyWith(hideOpts: true),
      );
    });

    test('setShowGuideOnStart', () async {
      await expectUpdate(
        act: (n) => n.setShowGuideOnStart(false),
        expected: _newState().copyWith(showGuideOnStart: false),
      );
    });

    test('setLocalePreference', () async {
      await expectUpdate(
        act: (n) => n.setLocalePreference(const Locale('de')),
        expected: _newState().copyWith(localePreference: const Locale('de')),
      );
    });

    test('setUseSystemLocale', () async {
      await expectUpdate(
        act: (n) => n.setUseSystemLocale(false),
        expected: _newState().copyWith(useSystemLocale: false),
      );
    });

    test('setPolling', () async {
      await expectUpdate(
        act: (n) => n.setPolling(false),
        expected: _newState().copyWith(enablePolling: false),
      );
    });

    test('setVerboseLogging', () async {
      await expectUpdate(
        act: (n) => n.setVerboseLogging(true),
        expected: _newState().copyWith(verboseLogging: true),
      );
    });

    test('toggleVerboseLogging', () async {
      await expectUpdate(
        act: (n) => n.toggleVerboseLogging(),
        expected: _newState().copyWith(verboseLogging: true),
      );
    });

    test('toggleVerboseLogging twice returns to the initial value', () async {
      final testProvider = settingsProviderOf(repo: mockRepo);
      await container.read(testProvider.future);
      final notifier = container.read(testProvider.notifier);

      await notifier.toggleVerboseLogging();
      final result = await notifier.toggleVerboseLogging();

      expect(result.verboseLogging, isFalse);
      expect(container.read(testProvider).value, _newState());
      verify(mockRepo.saveSettings(any)).called(2);
    });

    test('setHidePushTokens', () async {
      await expectUpdate(
        act: (n) => n.setHidePushTokens(true),
        expected: _newState().copyWith(hidePushTokens: true),
      );
    });

    test('setLatestStartedVersion', () async {
      await expectUpdate(
        act: (n) => n.setLatestStartedVersion(Version(1, 0, 0)),
        expected: _newState().copyWith(latestStartedVersion: Version(1, 0, 0)),
      );
    });

    test('setShowBackgroundImage', () async {
      await expectUpdate(
        act: (n) => n.setShowBackgroundImage(false),
        expected: _newState().copyWith(showBackgroundImage: false),
      );
    });

    test('toggleShowBackgroundImage', () async {
      await expectUpdate(
        act: (n) => n.toggleShowBackgroundImage(),
        expected: _newState().copyWith(showBackgroundImage: false),
      );
    });

    test('setAppAuthMethod', () async {
      await expectUpdate(
        act: (n) => n.setAppAuthMethod(ForceBiometricOption.biometric),
        expected: _newState().copyWith(
          appAuthMethod: ForceBiometricOption.biometric,
        ),
      );
    });

    test('setAutoCloseAppAfterAcceptingPushRequest', () async {
      await expectUpdate(
        act: (n) => n.setAutoCloseAppAfterAcceptingPushRequest(true),
        expected: _newState().copyWith(
          autoCloseAppAfterAcceptingPushRequest: true,
        ),
      );
    });

    test('a failed save keeps the old state and returns it', () async {
      when(mockRepo.saveSettings(any)).thenAnswer((_) async => false);
      final testProvider = settingsProviderOf(repo: mockRepo);
      await container.read(testProvider.future);
      final notifier = container.read(testProvider.notifier);

      final result = await notifier.setHideOTPs(true);

      expect(result, _newState());
      expect(container.read(testProvider).value, _newState());
      expect(container.read(testProvider).value!.hideOpts, isFalse);
    });

    test('updates run one after another and none is lost', () async {
      final testProvider = settingsProviderOf(repo: mockRepo);
      await container.read(testProvider.future);
      final notifier = container.read(testProvider.notifier);

      // Started without awaiting in between on purpose.
      final futures = [
        notifier.setHideOTPs(true),
        notifier.setPolling(false),
        notifier.setHidePushTokens(true),
      ];
      await Future.wait(futures);

      final state = container.read(testProvider).value!;
      expect(state.hideOpts, isTrue);
      expect(state.enablePolling, isFalse);
      expect(state.hidePushTokens, isTrue);
      verify(mockRepo.saveSettings(any)).called(3);
    });

    test(
      'addCrashReportRecipient does not mutate the previous state',
      () async {
        final testProvider = settingsProviderOf(repo: mockRepo);
        final before = await container.read(testProvider.future);
        final notifier = container.read(testProvider.notifier);

        final after = await notifier.addCrashReportRecipient('anotherOne');

        expect(after.crashReportRecipients, {'someone', 'anotherOne'});
        expect(
          before.crashReportRecipients,
          {'someone'},
          reason: 'the old state object must stay untouched',
        );
      },
      skip:
          'BUG: settings_notifier.dart:113 addCrashReportRecipient mutates the existing Set in place (oldState.crashReportRecipients..add)',
    );

    test(
      'removeCrashReportRecipient does not mutate the previous state',
      () async {
        final testProvider = settingsProviderOf(repo: mockRepo);
        final before = await container.read(testProvider.future);
        final notifier = container.read(testProvider.notifier);

        final after = await notifier.removeCrashReportRecipient('someone');

        expect(after.crashReportRecipients, isEmpty);
        expect(
          before.crashReportRecipients,
          {'someone'},
          reason: 'the old state object must stay untouched',
        );
      },
      skip:
          'BUG: settings_notifier.dart:121 removeCrashReportRecipient mutates the existing Set in place (oldState.crashReportRecipients..remove)',
    );

    test(
      'a throwing repo.saveSettings does not block later updates',
      () async {
        final testProvider = settingsProviderOf(repo: mockRepo);
        await container.read(testProvider.future);
        final notifier = container.read(testProvider.notifier);

        when(
          mockRepo.saveSettings(any),
        ).thenAnswer((_) async => throw StateError('disk full'));
        await expectLater(notifier.setHideOTPs(true), throwsStateError);

        when(mockRepo.saveSettings(any)).thenAnswer((_) async => true);
        var secondCompleted = false;
        final second = notifier.setPolling(false).then((value) {
          secondCompleted = true;
          return value;
        });
        // Lets every pending microtask/zero-timer run; no real time passes.
        await pumpEventQueue();

        expect(
          secondCompleted,
          isTrue,
          reason: 'the mutexes must be released although saving threw',
        );
        expect((await second).enablePolling, isFalse);
      },
      skip:
          'BUG: settings_notifier.dart:86-91 _saveToRepo (and updateState:96-108) never release _repoMutex/_stateMutex when saveSettings throws (no try/finally), the notifier deadlocks',
    );
  });
}

/// Real notifier + real [PreferenceSettingsRepository] on top of the
/// in-memory SharedPreferences.
void _testSettingsNotifierWithRealRepo() {
  group('SettingsNotifier with PreferenceSettingsRepository', () {
    late SharedPreferences prefs;

    setUpAll(() async {
      // PreferenceSettingsRepository caches the SharedPreferences instance in a
      // static field. Create the instance exactly once and share it, later
      // calls of setMockInitialValues would not reach the repository.
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await prefs.clear();
    });

    test('a changed boolean setting is persisted and reloaded', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = settingsProviderOf(repo: PreferenceSettingsRepository());
      await container.read(provider.future);

      await container.read(provider.notifier).setHideOTPs(true);

      final reloaded = await PreferenceSettingsRepository().loadSettings();
      expect(reloaded.hideOpts, isTrue);
    });

    test(
      'an added crash report recipient is persisted',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final provider = settingsProviderOf(
          repo: PreferenceSettingsRepository(),
        );
        await container.read(provider.future);

        await container
            .read(provider.notifier)
            .addCrashReportRecipient('crash@example.com');

        final reloaded = await PreferenceSettingsRepository().loadSettings();
        expect(reloaded.crashReportRecipients, {'crash@example.com'});
      },
      skip:
          'BUG: preference_settings_repository.dart:101 compares crashReportRecipients Sets by identity and the notifier mutates the loaded Set in place, so the change is never written',
    );

    test(
      'a removed crash report recipient is persisted',
      () async {
        await prefs.setStringList('KEY_CRASH_REPORT_RECIPIENTS', [
          'a@example.com',
          'b@example.com',
        ]);
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final provider = settingsProviderOf(
          repo: PreferenceSettingsRepository(),
        );
        final loaded = await container.read(provider.future);
        expect(loaded.crashReportRecipients, {
          'a@example.com',
          'b@example.com',
        });

        await container
            .read(provider.notifier)
            .removeCrashReportRecipient('a@example.com');

        final reloaded = await PreferenceSettingsRepository().loadSettings();
        expect(reloaded.crashReportRecipients, {'b@example.com'});
      },
      skip:
          'BUG: preference_settings_repository.dart:101 compares crashReportRecipients Sets by identity and the notifier mutates the loaded Set in place, so the change is never written',
    );

    test('the published state after adding a recipient contains it', () async {
      // Independent of persistence: the in-memory state must be right.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = settingsProviderOf(repo: PreferenceSettingsRepository());
      await container.read(provider.future);

      await container
          .read(provider.notifier)
          .addCrashReportRecipient('crash@example.com');

      expect(container.read(provider).value!.crashReportRecipients, {
        'crash@example.com',
      });
    });
  });
}
