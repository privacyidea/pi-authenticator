import 'dart:convert';

import '../utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/introduction_repository.dart';
import '../model/states/Introductions_state.dart';

class PreferenceIntroductionRepository implements IntroductionRepository {
  static const String _completedIntroductionsKey = 'COMPLETED_INTRODUCTIONS';
  final Future<SharedPreferences> _prefs;
  PreferenceIntroductionRepository() : _prefs = SharedPreferences.getInstance();

  @override
  Future<IntroductionsState> loadCompletedIntroductions() async {
    try {
      final prefs = await _prefs;
      final encodedIntroductions = prefs.getString(_completedIntroductionsKey);
      if (encodedIntroductions == null) return IntroductionsState();
      final decodedIntroductions = jsonDecode(encodedIntroductions);
      final introductionsState = IntroductionsState.fromJson(decodedIntroductions);
      return introductionsState;
    } catch (e, s) {
      Logger.error('Failed to load completed introductions', name: 'PreferenceIntroductionRepository#loadCompletedIntroductions', error: e, stackTrace: s);
      return IntroductionsState();
    }
  }

  @override
  Future<bool> saveCompletedIntroductions(IntroductionsState introductions) async {
    try {
      final prefs = await _prefs;
      final encodedIntroductions = jsonEncode(introductions);
      return prefs.setString(_completedIntroductionsKey, encodedIntroductions);
    } catch (e, s) {
      Logger.error('Failed to save completed introductions', name: 'PreferenceIntroductionRepository#saveCompletedIntroductions', error: e, stackTrace: s);
      return false;
    }
  }
}
