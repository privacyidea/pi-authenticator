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

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../model/riverpod_states/progress_state.dart';
import '../../../logger.dart';

part 'progress_state_provider.g.dart';

final progressStateProvider = progressStateNotifierProviderOf(Null);

@riverpod
class ProgressStateNotifier extends _$ProgressStateNotifier {
  @override
  ProgressState build(Type type) {
    Logger.info('Initializing progress state', name: 'ProgressStateNotifier#initProgress');
    return const ProgressState.uninitialized();
  }

  double? get progress => state.progress;

  ProgressState initProgress(int max, int value) {
    Logger.info('Initializing progress state', name: 'ProgressStateNotifier#initProgress');
    final newState = ProgressState(max: max, value: value);
    state = newState;
    return newState;
  }

  void deleteProgress() {
    Logger.info('Deleting progress state', name: 'ProgressStateNotifier#deleteProgress');
    state = const ProgressState.uninitialized();
  }

  ProgressState? resetProgress() {
    if (state is ProgressStateUninitialized) return state;
    Logger.info('Resetting progress state', name: 'ProgressStateNotifier#resetProgress');
    final newState = state.copyWith(value: 0);
    state = newState;
    return newState;
  }

  ProgressState? setProgressMax(int max) {
    assert(state is! ProgressStateUninitialized, 'Progress state is uninitialized');
    assert(max > 0, 'Max value must be greater than 0');
    Logger.info('Setting progress max to $max', name: 'ProgressStateNotifier#setProgressMax');
    final newState = state.copyWith(max: max);
    state = newState;
    return newState;
  }

  ProgressState? setProgressValue(int value) {
    assert(state is! ProgressStateUninitialized, 'Progress state is uninitialized');
    assert(value >= 0, 'Value must be greater than or equal to 0');
    assert(value <= state.max, 'Value must be less than or equal to max value');
    Logger.info('Setting progress value to $value/${state.max}', name: 'ProgressStateNotifier#setProgressValue');
    final newState = state.copyWith(value: value);
    state = newState;
    return newState;
  }
}
