import 'dart:convert';

import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/introduction_repository.dart';
import '../model/states/introduction_state.dart';
import '../utils/logger.dart';

class PreferenceIntroductionRepository implements IntroductionRepository {
  static const String _completedIntroductionsKey = 'COMPLETED_INTRODUCTIONS';
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  static final Mutex _m = Mutex();
  static Future<T> _protect<T>(Future<T> Function() f) => _m.protect<T>(f);

  @override
  Future<IntroductionState> loadCompletedIntroductions() async => _protect(_loadCompletedIntroductions);
  Future<IntroductionState> _loadCompletedIntroductions() async {
    try {
      final encodedIntroductions = (await _prefs).getString(_completedIntroductionsKey);
      if (encodedIntroductions == null) return const IntroductionState();
      final decodedIntroductions = jsonDecode(encodedIntroductions);
      return IntroductionState.fromJson(decodedIntroductions);
    } catch (e, s) {
      Logger.warning(
        'Failed to load completed introductions',
        name: 'PreferenceIntroductionRepository#loadCompletedIntroductions',
        error: e,
        stackTrace: s,
        verbose: true,
      );
      return const IntroductionState();
    }
  }

  @override
  Future<bool> saveCompletedIntroductions(IntroductionState introductions) async => _protect(() => _saveCompletedIntroductions(introductions));
  Future<bool> _saveCompletedIntroductions(IntroductionState introductions) async {
    try {
      final encodedIntroductions = jsonEncode(introductions);
      await (await _prefs).setString(_completedIntroductionsKey, encodedIntroductions);
      return true;
    } catch (e, s) {
      Logger.warning(
        'Failed to load completed introductions',
        name: 'PreferenceIntroductionRepository#loadCompletedIntroductions',
        error: e,
        stackTrace: s,
        verbose: true,
      );
      return false;
    }
  }
}
