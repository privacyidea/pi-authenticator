/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/riverpod_states/progress_state.dart';
import '../../logger.dart';

class ProgressStateNotifier extends StateNotifier<ProgressState?> {
  ProgressStateNotifier() : super(null);

  double? get progress => state?.progress;

  ProgressState initProgress(int max, int value) {
    Logger.info('Initializing progress state');
    final newState = ProgressState(max: max, value: value);
    state = newState;
    return newState;
  }

  void deleteProgress() {
    Logger.info('Deleting progress state');
    state = null;
  }

  ProgressState? resetProgress() {
    if (state == null) return state;
    Logger.info('Resetting progress state');
    final newState = state!.copyWith(value: 0);
    state = newState;
    return newState;
  }

  ProgressState? setProgressMax(int max) {
    if (state == null) return state;
    Logger.info('Setting progress max to $max');
    final newState = state!.copyWith(max: max);
    state = newState;
    return newState;
  }

  ProgressState? setProgressValue(int value) {
    if (state == null) return state;
    Logger.info('Setting progress value to $value/${state!.max}');
    final newState = state!.copyWith(value: value);
    state = newState;
    return newState;
  }
}
