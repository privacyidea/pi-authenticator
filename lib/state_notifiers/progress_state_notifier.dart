import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/states/progress_state.dart';
import '../utils/logger.dart';

class ProgressStateNotifier extends StateNotifier<ProgressState?> {
  ProgressStateNotifier() : super(null);

  double? get progress => state?.progress;

  ProgressState initProgress(int max, int value) {
    Logger.info('Initializing progress state', name: 'ProgressStateNotifier#initProgress');
    final newState = ProgressState(max, value);
    state = newState;
    return newState;
  }

  void deleteProgress() {
    Logger.info('Deleting progress state', name: 'ProgressStateNotifier#deleteProgress');
    state = null;
  }

  ProgressState? resetProgress() {
    if (state == null) return state;
    Logger.info('Resetting progress state', name: 'ProgressStateNotifier#resetProgress');
    final newState = state!.copyWith(value: 0);
    state = newState;
    return newState;
  }

  ProgressState? setProgressMax(int max) {
    if (state == null) return state;
    Logger.info('Setting progress max to $max', name: 'ProgressStateNotifier#setProgressMax');
    final newState = state!.copyWith(max: max);
    state = newState;
    return newState;
  }

  ProgressState? setProgressValue(int value) {
    if (state == null) return state;
    Logger.info('Setting progress value to $value/${state!.max}', name: 'ProgressStateNotifier#setProgressValue');
    final newState = state!.copyWith(value: value);
    state = newState;
    return newState;
  }
}
