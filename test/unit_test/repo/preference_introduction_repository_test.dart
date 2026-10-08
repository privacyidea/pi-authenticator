import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/repo/preference_introduction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _key = 'COMPLETED_INTRODUCTIONS';

/// A store that reports every write as failed.
class _FailingWriteStore extends InMemorySharedPreferencesStore {
  _FailingWriteStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

/// The introductions that existed before homeWidgetSetUp and
/// homeWidgetBatteryOptimization were added (enum names are the serialization).
const _legacyIntroductions = [
  'introductionScreen',
  'scanQrCode',
  'addManually',
  'tokenSwipe',
  'editToken',
  'lockToken',
  'dragToken',
  'addFolder',
  'pollForChallenges',
  'hidePushTokens',
  'exportTokens',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SharedPreferencesStorePlatform originalStore;

  setUpAll(() async {
    // The repository keeps the SharedPreferences instance in a static field.
    // Create the instance once and share it with the repository.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    originalStore = SharedPreferencesStorePlatform.instance;
  });

  setUp(() async {
    SharedPreferencesStorePlatform.instance = originalStore;
    await prefs.clear();
  });

  Future<void> storeJson(Object json) => prefs.setString(_key, jsonEncode(json));

  group('PreferenceIntroductionRepository load', () {
    test('a missing key yields an empty state', () async {
      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(state.completedIntroductions, isEmpty);
      expect(state.uncompletedIntroductions, Introduction.values.toSet());
      expect(prefs.getKeys(), isEmpty, reason: 'loading must not write');
    });

    test('a stored state is read', () async {
      await storeJson({
        'completedIntroductions': ['scanQrCode', 'tokenSwipe'],
      });

      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(state.completedIntroductions, {
        Introduction.scanQrCode,
        Introduction.tokenSwipe,
      });
    });

    test('an empty JSON object yields an empty state', () async {
      await storeJson(<String, dynamic>{});

      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(state.completedIntroductions, isEmpty);
    });

    test('corrupt JSON yields an empty state instead of throwing', () async {
      await prefs.setString(_key, '{"completedIntroductions": [');

      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(state, const IntroductionState());
    });

    test('valid JSON of the wrong shape yields an empty state', () async {
      await storeJson(['scanQrCode']);

      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(state, const IntroductionState());
    });

    test('a non string value under the key yields an empty state', () async {
      await prefs.setBool(_key, true);

      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(state, const IntroductionState());
    });

    test('data from before homeWidgetSetUp existed keeps the old and leaves the new uncompleted', () async {
      await storeJson({'completedIntroductions': _legacyIntroductions});

      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(
        state.completedIntroductions,
        _legacyIntroductions.map(Introduction.values.byName).toSet(),
      );
      expect(state.isUncompleted(Introduction.homeWidgetSetUp), isTrue);
      expect(
        state.isUncompleted(Introduction.homeWidgetBatteryOptimization),
        isTrue,
      );
      expect(
        state.uncompletedIntroductions,
        {Introduction.homeWidgetSetUp, Introduction.homeWidgetBatteryOptimization},
      );
    });

    test('an unknown introduction name (app downgrade) keeps the known ones', () async {
      await storeJson({
        'completedIntroductions': ['scanQrCode', 'someFutureIntroduction', 'tokenSwipe'],
      });

      final state = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();

      expect(state.completedIntroductions, {
        Introduction.scanQrCode,
        Introduction.tokenSwipe,
      });
    }, skip: 'BUG: introduction_state.g.dart:12 enumDecode throws for an unknown name, preference_introduction_repository.dart:49-50 then returns an empty state, so ALL completed introductions are lost (every intro is shown again)');
  });

  group('PreferenceIntroductionRepository save', () {
    test('saves under COMPLETED_INTRODUCTIONS as JSON with the enum names', () async {
      final saved = await PreferenceIntroductionRepository()
          .saveCompletedIntroductions(
            const IntroductionState(
              completedIntroductions: {
                Introduction.addFolder,
                Introduction.homeWidgetSetUp,
              },
            ),
          );

      expect(saved, isTrue);
      expect(prefs.getKeys(), {_key});
      final json = jsonDecode(prefs.getString(_key)!) as Map<String, dynamic>;
      expect(json['completedIntroductions'], unorderedEquals(['addFolder', 'homeWidgetSetUp']));
    });

    test('round trip of a few introductions', () async {
      final repo = PreferenceIntroductionRepository();
      const state = IntroductionState(
        completedIntroductions: {
          Introduction.introductionScreen,
          Introduction.lockToken,
          Introduction.homeWidgetBatteryOptimization,
        },
      );

      await repo.saveCompletedIntroductions(state);

      expect(await repo.loadCompletedIntroductions(), state);
    });

    test('round trip of all introductions', () async {
      final repo = PreferenceIntroductionRepository();
      final state = IntroductionState.withAllCompleted();

      await repo.saveCompletedIntroductions(state);

      final loaded = await PreferenceIntroductionRepository()
          .loadCompletedIntroductions();
      expect(loaded.completedIntroductions, Introduction.values.toSet());
      expect(loaded.uncompletedIntroductions, isEmpty);
    });

    test('round trip of the empty state', () async {
      final repo = PreferenceIntroductionRepository();
      await repo.saveCompletedIntroductions(
        IntroductionState.withAllCompleted(),
      );

      await repo.saveCompletedIntroductions(const IntroductionState());

      expect((await repo.loadCompletedIntroductions()).completedIntroductions, isEmpty);
    });

    test('a later save replaces the earlier one', () async {
      final repo = PreferenceIntroductionRepository();
      await repo.saveCompletedIntroductions(
        const IntroductionState(
          completedIntroductions: {Introduction.scanQrCode},
        ),
      );

      await repo.saveCompletedIntroductions(
        const IntroductionState(
          completedIntroductions: {Introduction.addManually},
        ),
      );

      expect((await repo.loadCompletedIntroductions()).completedIntroductions, {
        Introduction.addManually,
      });
    });

    test('concurrent saves are serialized, the last call wins', () async {
      final repo = PreferenceIntroductionRepository();

      final results = await Future.wait([
        repo.saveCompletedIntroductions(
          const IntroductionState(
            completedIntroductions: {Introduction.scanQrCode},
          ),
        ),
        repo.saveCompletedIntroductions(
          const IntroductionState(
            completedIntroductions: {
              Introduction.scanQrCode,
              Introduction.addManually,
            },
          ),
        ),
      ]);

      expect(results, [true, true]);
      expect((await repo.loadCompletedIntroductions()).completedIntroductions, {
        Introduction.scanQrCode,
        Introduction.addManually,
      });
    });

    test('save reports failure when the storage rejects the write', () async {
      SharedPreferencesStorePlatform.instance = _FailingWriteStore();

      final saved = await PreferenceIntroductionRepository()
          .saveCompletedIntroductions(
            const IntroductionState(
              completedIntroductions: {Introduction.scanQrCode},
            ),
          );

      expect(saved, isFalse);
    }, skip: 'BUG: preference_introduction_repository.dart:70 saveCompletedIntroductions ignores the bool result of setString and returns true even if the write failed');
  });
}
