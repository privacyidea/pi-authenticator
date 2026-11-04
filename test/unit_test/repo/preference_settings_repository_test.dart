import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/force_biometric_option.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart';
import 'package:privacyidea_authenticator/model/version.dart';
import 'package:privacyidea_authenticator/repo/preference_settings_repository.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Runs first on purpose: PreferenceSettingsRepository keeps a static snapshot of the
  // last state, and the first moved test needs it to be untouched (null).
  _testPreferenceSettingsRepositoryStorage();

  test('persists auto-close after accepting a push request', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = PreferenceSettingsRepository();

    final initialSettings = await repository.loadSettings();
    expect(initialSettings.autoCloseAppAfterAcceptingPushRequest, isFalse);

    final saved = await repository.saveSettings(
      initialSettings.copyWith(autoCloseAppAfterAcceptingPushRequest: true),
    );
    expect(saved, isTrue);

    final reloadedSettings = await PreferenceSettingsRepository()
        .loadSettings();
    expect(reloadedSettings.autoCloseAppAfterAcceptingPushRequest, isTrue);
  });
}

const _isFirstRunKey = 'KEY_IS_FIRST_RUN';
const _showGuideOnStartKey = 'KEY_SHOW_GUIDE_ON_START';
const _hideOtpsKey = 'KEY_HIDE_OTPS';
const _enablePollKey = 'KEY_ENABLE_POLLING';
const _crashReportRecipientsKey = 'KEY_CRASH_REPORT_RECIPIENTS';
const _localeKey = 'KEY_LOCALE_PREFERENCE';
const _useSystemLocaleKey = 'KEY_USE_SYSTEM_LOCALE';
const _verboseLoggingKey = 'KEY_VERBOSE_LOGGING';
const _hidePushTokensKey = 'KEY_HIDE_PUSH_TOKENS';
const _latestVersionKey = 'KEY_LATEST_VERSION';
const _showBackgroundImageKey = 'KEY_HIDE_BACKGROUND_IMAGE';
const _allowScreenshotKey = 'KEY_ALLOW_SCREENSHOTS';
const _appAuthMethodKey = 'KEY_APP_AUTH_METHOD';
const _autoCloseKey = 'KEY_AUTO_CLOSE_APP_AFTER_ACCEPTING_PUSH_REQUEST';

/// A store that reports every write as failed.
class _FailingWriteStore extends InMemorySharedPreferencesStore {
  _FailingWriteStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

class _FieldCase {
  final String name;
  final String key;
  final SettingsState Function(SettingsState) change;
  final Object rawValue;

  const _FieldCase(this.name, this.key, this.change, this.rawValue);
}

final _fieldCases = <_FieldCase>[
  _FieldCase(
    'isFirstRun',
    _isFirstRunKey,
    (s) => s.copyWith(isFirstRun: false),
    false,
  ),
  _FieldCase(
    'showGuideOnStart',
    _showGuideOnStartKey,
    (s) => s.copyWith(showGuideOnStart: false),
    false,
  ),
  _FieldCase(
    'hideOpts',
    _hideOtpsKey,
    (s) => s.copyWith(hideOpts: true),
    true,
  ),
  _FieldCase(
    'enablePolling',
    _enablePollKey,
    (s) => s.copyWith(enablePolling: true),
    true,
  ),
  _FieldCase(
    'crashReportRecipients',
    _crashReportRecipientsKey,
    (s) => s.copyWith(crashReportRecipients: {'a@example.com'}),
    ['a@example.com'],
  ),
  _FieldCase(
    'localePreference',
    _localeKey,
    (s) => s.copyWith(localePreference: const Locale('fr', 'CA')),
    'fr#CA',
  ),
  _FieldCase(
    'useSystemLocale',
    _useSystemLocaleKey,
    (s) => s.copyWith(useSystemLocale: false),
    false,
  ),
  _FieldCase(
    'verboseLogging',
    _verboseLoggingKey,
    (s) => s.copyWith(verboseLogging: true),
    true,
  ),
  _FieldCase(
    'hidePushTokens',
    _hidePushTokensKey,
    (s) => s.copyWith(hidePushTokens: true),
    true,
  ),
  _FieldCase(
    'latestStartedVersion',
    _latestVersionKey,
    (s) => s.copyWith(latestStartedVersion: Version(1, 2, 3)),
    '1.2.3',
  ),
  _FieldCase(
    'showBackgroundImage',
    _showBackgroundImageKey,
    (s) => s.copyWith(showBackgroundImage: false),
    false,
  ),
  _FieldCase(
    'allowScreenshots',
    _allowScreenshotKey,
    (s) => s.copyWith(allowScreenshots: true),
    true,
  ),
  _FieldCase(
    'autoCloseAppAfterAcceptingPushRequest',
    _autoCloseKey,
    (s) => s.copyWith(autoCloseAppAfterAcceptingPushRequest: true),
    true,
  ),
  _FieldCase(
    'appAuthMethod',
    _appAuthMethodKey,
    (s) => s.copyWith(appAuthMethod: ForceBiometricOption.biometric),
    'biometric',
  ),
];

/// A state in which every field differs from its default.
SettingsState _allNonDefaultState() => SettingsState(
  isFirstRun: false,
  showGuideOnStart: false,
  hideOpts: true,
  enablePolling: true,
  crashReportRecipients: {'a@example.com', 'b@example.com'},
  localePreference: const Locale('de', 'AT'),
  useSystemLocale: false,
  verboseLogging: true,
  hidePushTokens: true,
  latestStartedVersion: Version(1, 2, 3),
  showBackgroundImage: false,
  allowScreenshots: true,
  autoCloseAppAfterAcceptingPushRequest: true,
  appAuthMethod: ForceBiometricOption.biometric,
);

void _testPreferenceSettingsRepositoryStorage() {
  group('PreferenceSettingsRepository storage', () {
    late SharedPreferences prefs;
    late SharedPreferencesStorePlatform originalStore;

    setUpAll(() async {
      // PreferenceSettingsRepository keeps the SharedPreferences instance in a
      // static field, so later setMockInitialValues calls would not reach it.
      // Create the instance once and share it with the repository.
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      originalStore = SharedPreferencesStorePlatform.instance;
    });

    setUp(() async {
      SharedPreferencesStorePlatform.instance = originalStore;
      await prefs.clear();
    });

    group('PreferenceSettingsRepository save', () {
      // Must stay the first test of this file: PreferenceSettingsRepository
      // keeps a static snapshot of the last state, which is only null before the
      // first load or save of the whole test process.
      test('save without a prior load persists the complete state', () async {
        final expected = _allNonDefaultState();

        final saved = await PreferenceSettingsRepository().saveSettings(
          expected,
        );

        expect(saved, isTrue);
        final reloaded = await PreferenceSettingsRepository().loadSettings();
        expect(reloaded, expected);
        expect(prefs.getKeys(), _fieldCases.map((c) => c.key).toSet());
      });

      for (final fieldCase in _fieldCases) {
        test(
          'changing only ${fieldCase.name} writes only ${fieldCase.key}',
          () async {
            final repo = PreferenceSettingsRepository();
            final loaded = await repo.loadSettings();
            final changed = fieldCase.change(loaded);
            expect(
              changed,
              isNot(loaded),
              reason:
                  'test precondition: the change must differ from the default',
            );

            final saved = await repo.saveSettings(changed);

            expect(saved, isTrue);
            expect(prefs.getKeys(), {fieldCase.key});
            expect(prefs.get(fieldCase.key), fieldCase.rawValue);
            expect(
              await PreferenceSettingsRepository().loadSettings(),
              changed,
            );
          },
        );
      }

      test('saving an unchanged state writes nothing', () async {
        final repo = PreferenceSettingsRepository();
        final loaded = await repo.loadSettings();

        final saved = await repo.saveSettings(loaded);

        expect(saved, isTrue);
        expect(prefs.getKeys(), isEmpty);
      });

      test(
        'a value set back to its default is persisted as the default',
        () async {
          final repo = PreferenceSettingsRepository();
          final loaded = await repo.loadSettings();
          await repo.saveSettings(loaded.copyWith(hideOpts: true));
          expect(prefs.getBool(_hideOtpsKey), isTrue);

          await repo.saveSettings(loaded.copyWith(hideOpts: false));

          expect(prefs.getBool(_hideOtpsKey), isFalse);
          expect(
            (await PreferenceSettingsRepository().loadSettings()).hideOpts,
            isFalse,
          );
        },
      );

      test('a second save writes only the difference to the first', () async {
        final repo = PreferenceSettingsRepository();
        final loaded = await repo.loadSettings();
        await repo.saveSettings(loaded.copyWith(hideOpts: true));
        await prefs.remove(_hideOtpsKey);

        await repo.saveSettings(
          loaded.copyWith(hideOpts: true, enablePolling: true),
        );

        expect(prefs.getKeys(), {_enablePollKey});
      });

      test('concurrent saves are serialized and none is lost', () async {
        final repo = PreferenceSettingsRepository();
        final loaded = await repo.loadSettings();
        final first = loaded.copyWith(hideOpts: true);
        final second = first.copyWith(enablePolling: true);

        final results = await Future.wait([
          repo.saveSettings(first),
          repo.saveSettings(second),
        ]);

        expect(results, [true, true]);
        expect(await PreferenceSettingsRepository().loadSettings(), second);
      });

      test(
        'saveSettings reports failure when the storage rejects the write',
        () async {
          final repo = PreferenceSettingsRepository();
          final loaded = await repo.loadSettings();
          SharedPreferencesStorePlatform.instance = _FailingWriteStore();

          final saved = await repo.saveSettings(
            loaded.copyWith(hideOpts: true),
          );

          expect(saved, isFalse);
        },
        skip:
            'BUG: preference_settings_repository.dart:135 saveSettings ignores the results of Future.wait(futures), returns true and updates _lastState even if SharedPreferences.set* returned false, so the change is never retried',
      );

      test(
        'a notifier-style in-place mutation of the loaded recipients Set is persisted',
        () async {
          final repo = PreferenceSettingsRepository();
          await prefs.setStringList(_crashReportRecipientsKey, [
            'a@example.com',
          ]);
          final loaded = await repo.loadSettings();

          // This is exactly what SettingsNotifier.addCrashReportRecipient does:
          // the Set of the old state is mutated and handed on via copyWith.
          final updatedSet = loaded.crashReportRecipients..add('b@example.com');
          final saved = await repo.saveSettings(
            loaded.copyWith(crashReportRecipients: updatedSet),
          );

          expect(saved, isTrue);
          expect(
            prefs.getStringList(_crashReportRecipientsKey),
            unorderedEquals(['a@example.com', 'b@example.com']),
          );
        },
        skip:
            'BUG: preference_settings_repository.dart:101 compares crashReportRecipients Sets with != (identity), a Set that is mutated in place and passed on is never written',
      );

      test(
        'a second repository instance shares the snapshot of the first consistently',
        () async {
          // _lastState and the SharedPreferences instance are both static, so
          // they always describe the same storage.
          final first = PreferenceSettingsRepository();
          final loaded = await first.loadSettings();
          await first.saveSettings(loaded.copyWith(hideOpts: true));

          final second = PreferenceSettingsRepository();
          final loadedBySecond = await second.loadSettings();
          expect(loadedBySecond.hideOpts, isTrue);
          await second.saveSettings(loadedBySecond.copyWith(hideOpts: false));

          expect(prefs.getBool(_hideOtpsKey), isFalse);
          expect((await first.loadSettings()).hideOpts, isFalse);
        },
      );
    });

    group('PreferenceSettingsRepository load', () {
      test('empty storage yields the defaults of every field', () async {
        final settings = await PreferenceSettingsRepository().loadSettings();

        expect(settings.isFirstRun, SettingsState.isFirstRunDefault);
        expect(
          settings.showGuideOnStart,
          SettingsState.showGuideOnStartDefault,
        );
        expect(settings.hideOpts, SettingsState.hideOtpsDefault);
        expect(settings.enablePolling, SettingsState.enablePollingDefault);
        expect(settings.crashReportRecipients, isEmpty);
        expect(settings.localePreference, SettingsState.localeDefault);
        expect(settings.useSystemLocale, SettingsState.useSystemLocaleDefault);
        expect(settings.verboseLogging, SettingsState.verboseLoggingDefault);
        expect(settings.hidePushTokens, SettingsState.hidePushTokensDefault);
        expect(settings.latestStartedVersion, Version(0, 0, 0));
        expect(
          settings.showBackgroundImage,
          SettingsState.showBackgroundImageDefault,
        );
        expect(
          settings.allowScreenshots,
          SettingsState.allowScreenshotsDefault,
        );
        expect(settings.autoCloseAppAfterAcceptingPushRequest, isFalse);
        expect(settings.appAuthMethod, ForceBiometricOption.any);
        expect(prefs.getKeys(), isEmpty, reason: 'loading must not write');
      });

      test('every stored value is read from its key', () async {
        await prefs.setBool(_isFirstRunKey, false);
        await prefs.setBool(_showGuideOnStartKey, false);
        await prefs.setBool(_hideOtpsKey, true);
        await prefs.setBool(_enablePollKey, true);
        await prefs.setStringList(_crashReportRecipientsKey, [
          'a@example.com',
          'b@example.com',
        ]);
        await prefs.setString(_localeKey, 'de#AT');
        await prefs.setBool(_useSystemLocaleKey, false);
        await prefs.setBool(_verboseLoggingKey, true);
        await prefs.setBool(_hidePushTokensKey, true);
        await prefs.setString(_latestVersionKey, '1.2.3');
        await prefs.setBool(_showBackgroundImageKey, false);
        await prefs.setBool(_allowScreenshotKey, true);
        await prefs.setBool(_autoCloseKey, true);
        await prefs.setString(_appAuthMethodKey, 'biometric');

        final settings = await PreferenceSettingsRepository().loadSettings();

        expect(settings, _allNonDefaultState());
      });

      test('a locale without country is stored and restored', () async {
        final repo = PreferenceSettingsRepository();
        final loaded = await repo.loadSettings();

        await repo.saveSettings(
          loaded.copyWith(localePreference: const Locale('it')),
        );

        expect(prefs.getString(_localeKey), 'it#null');
        final reloaded = await PreferenceSettingsRepository().loadSettings();
        expect(reloaded.localePreference, const Locale('it'));
        expect(reloaded.localePreference.countryCode, isNull);
      });

      test('appAuthMethod is parsed tolerant (prefix, case)', () async {
        Future<ForceBiometricOption> loadWith(String raw) async {
          await prefs.setString(_appAuthMethodKey, raw);
          return (await PreferenceSettingsRepository().loadSettings())
              .appAuthMethod;
        }

        expect(
          await loadWith('ForceBiometricOption.pin'),
          ForceBiometricOption.pin,
        );
        expect(await loadWith('BIOMETRIC'), ForceBiometricOption.biometric);
        expect(await loadWith('none'), ForceBiometricOption.none);
      });

      test('an unknown appAuthMethod falls back to the default', () async {
        await prefs.setString(_appAuthMethodKey, 'retinaScan');

        final settings = await PreferenceSettingsRepository().loadSettings();

        expect(settings.appAuthMethod, SettingsState.appAuthMethodDefault);
      });

      group('corrupt storage', () {
        test(
          'a locale without "#" falls back to the default locale',
          () async {
            await prefs.setString(_localeKey, 'de');

            final settings = await PreferenceSettingsRepository()
                .loadSettings();

            expect(settings.localePreference, SettingsState.localeDefault);
          },
          skip:
              'BUG: preference_settings_repository.dart:66 loadSettings has no try/catch, SettingsState.decodeLocale throws RangeError for a locale without "#"',
        );

        test(
          'an unparsable version falls back to the default version',
          () async {
            await prefs.setString(_latestVersionKey, 'abc');

            final settings = await PreferenceSettingsRepository()
                .loadSettings();

            expect(settings.latestStartedVersion, Version(0, 0, 0));
          },
          skip:
              'BUG: preference_settings_repository.dart:72 loadSettings has no try/catch, Version.parse throws FormatException for "abc"',
        );

        test(
          'a string under a bool key falls back to the default',
          () async {
            await prefs.setString(_hideOtpsKey, 'yes');

            final settings = await PreferenceSettingsRepository()
                .loadSettings();

            expect(settings.hideOpts, SettingsState.hideOtpsDefault);
          },
          skip:
              'BUG: preference_settings_repository.dart:60 loadSettings has no try/catch, prefs.getBool throws a TypeError for a String value',
        );

        test(
          'a bool under the recipients key falls back to the default',
          () async {
            await prefs.setBool(_crashReportRecipientsKey, true);

            final settings = await PreferenceSettingsRepository()
                .loadSettings();

            expect(settings.crashReportRecipients, isEmpty);
          },
          skip:
              'BUG: preference_settings_repository.dart:63 loadSettings has no try/catch, prefs.getStringList throws a TypeError for a bool value',
        );

        test(
          'one corrupt value does not discard the other valid values',
          () async {
            await prefs.setBool(_enablePollKey, true);
            await prefs.setString(_latestVersionKey, 'abc');

            final settings = await PreferenceSettingsRepository()
                .loadSettings();

            expect(settings.enablePolling, isTrue);
          },
          skip:
              'BUG: preference_settings_repository.dart:72 loadSettings has no try/catch, one corrupt value makes the whole load throw',
        );

        test('the repository is usable again after a failed load', () async {
          await prefs.setString(_latestVersionKey, 'abc');
          final repo = PreferenceSettingsRepository();
          await repo.loadSettings().then<void>((_) {}, onError: (Object _) {});
          await prefs.remove(_latestVersionKey);
          await prefs.setBool(_hideOtpsKey, true);

          final settings = await repo.loadSettings();

          expect(settings.hideOpts, isTrue);
        });
      });
    });

    group('SettingsNotifier + PreferenceSettingsRepository (new setters)', () {
      Future<ProviderContainer> containerWithRealRepo() async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        await container.read(
          settingsProviderOf(repo: PreferenceSettingsRepository()).future,
        );
        return container;
      }

      test('setAutoCloseAppAfterAcceptingPushRequest persists', () async {
        final container = await containerWithRealRepo();
        final provider = settingsProviderOf(
          repo: PreferenceSettingsRepository(),
        );

        final state = await container
            .read(provider.notifier)
            .setAutoCloseAppAfterAcceptingPushRequest(true);

        expect(state.autoCloseAppAfterAcceptingPushRequest, isTrue);
        expect(prefs.getBool(_autoCloseKey), isTrue);
        final reloaded = await PreferenceSettingsRepository().loadSettings();
        expect(reloaded.autoCloseAppAfterAcceptingPushRequest, isTrue);
      });

      test('setAppAuthMethod persists', () async {
        final container = await containerWithRealRepo();
        final provider = settingsProviderOf(
          repo: PreferenceSettingsRepository(),
        );

        final state = await container
            .read(provider.notifier)
            .setAppAuthMethod(ForceBiometricOption.biometric);

        expect(state.appAuthMethod, ForceBiometricOption.biometric);
        expect(prefs.getString(_appAuthMethodKey), 'biometric');
        final reloaded = await PreferenceSettingsRepository().loadSettings();
        expect(reloaded.appAuthMethod, ForceBiometricOption.biometric);
      });
    });

    group('appAuthMethodProvider', () {
      ProviderContainer containerFor(MockSettingsRepository repo) {
        final container = ProviderContainer(
          overrides: [
            settingsProvider.overrideWith(
              () => SettingsNotifier(repoOverride: repo),
            ),
          ],
        );
        addTearDown(container.dispose);
        return container;
      }

      Future<ForceBiometricOption> loadedValueFor(
        ForceBiometricOption stored,
      ) async {
        final repo = MockSettingsRepository();
        when(
          repo.loadSettings(),
        ).thenAnswer((_) async => SettingsState(appAuthMethod: stored));
        final container = containerFor(repo);
        await container.read(settingsProvider.future);
        return container.read(appAuthMethodProvider);
      }

      test('biometric stays biometric', () async {
        expect(
          await loadedValueFor(ForceBiometricOption.biometric),
          ForceBiometricOption.biometric,
        );
      });

      test('any stays any', () async {
        expect(
          await loadedValueFor(ForceBiometricOption.any),
          ForceBiometricOption.any,
        );
      });

      test('legacy none is normalized to any', () async {
        expect(
          await loadedValueFor(ForceBiometricOption.none),
          ForceBiometricOption.any,
        );
      });

      test('pin is normalized to any', () async {
        expect(
          await loadedValueFor(ForceBiometricOption.pin),
          ForceBiometricOption.any,
        );
      });

      test('while loading the value is any', () {
        final repo = MockSettingsRepository();
        when(
          repo.loadSettings(),
        ).thenAnswer((_) => Completer<SettingsState>().future);
        final container = containerFor(repo);

        expect(container.read(settingsProvider).isLoading, isTrue);
        expect(container.read(appAuthMethodProvider), ForceBiometricOption.any);
      });

      test('after a load error the value is any', () async {
        final repo = MockSettingsRepository();
        when(
          repo.loadSettings(),
        ).thenAnswer((_) async => throw StateError('cannot load'));
        final container = containerFor(repo);

        await expectLater(
          container.read(settingsProvider.future),
          throwsStateError,
        );

        expect(container.read(settingsProvider).hasError, isTrue);
        expect(container.read(appAuthMethodProvider), ForceBiometricOption.any);
      });

      test('follows a later change from any to biometric', () async {
        final repo = MockSettingsRepository();
        when(repo.loadSettings()).thenAnswer((_) async => SettingsState());
        when(repo.saveSettings(any)).thenAnswer((_) async => true);
        final container = containerFor(repo);
        await container.read(settingsProvider.future);
        expect(container.read(appAuthMethodProvider), ForceBiometricOption.any);

        await container
            .read(settingsProvider.notifier)
            .setAppAuthMethod(ForceBiometricOption.biometric);

        expect(
          container.read(appAuthMethodProvider),
          ForceBiometricOption.biometric,
        );
      });
    });
  });
}
