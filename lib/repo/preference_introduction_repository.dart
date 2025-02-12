/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:convert';

import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/repo/introduction_repository.dart';
import '../model/riverpod_states/introduction_state.dart';
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
        error: e,
        stackTrace: s,
        verbose: true,
      );
      return false;
    }
  }
}
