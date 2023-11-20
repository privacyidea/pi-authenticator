import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/introduction_repository.dart';
import '../model/states/introduction_state.dart';
import '../utils/logger.dart';

class PreferenceIntroductionRepository implements IntroductionRepository {
  static const String _completedIntroductionsKey = 'COMPLETED_INTRODUCTIONS';
  final Future<SharedPreferences> _prefs;
  PreferenceIntroductionRepository() : _prefs = SharedPreferences.getInstance();

  @override
  Future<IntroductionState> loadCompletedIntroductions() async {
    try {
      final prefs = await _prefs;
      final encodedIntroductions = prefs.getString(_completedIntroductionsKey);
      if (encodedIntroductions == null) return const IntroductionState();
      final decodedIntroductions = jsonDecode(encodedIntroductions);
      final introductionsState = IntroductionState.fromJson(decodedIntroductions);
      return introductionsState;
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
  Future<bool> saveCompletedIntroductions(IntroductionState introductions) async {
    try {
      final prefs = await _prefs;
      final encodedIntroductions = jsonEncode(introductions);
      return prefs.setString(_completedIntroductionsKey, encodedIntroductions);
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
