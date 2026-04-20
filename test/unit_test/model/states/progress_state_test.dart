import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/progress_state.dart';

void main() {
  group('ProgressState', () {
    test('uninitialized has default max=0 and value=0', () {
      const state = ProgressState.uninitialized();
      expect(state.max, 0);
      expect(state.value, 0);
    });

    test('progress calculates correctly', () {
      const state = ProgressState(max: 10, value: 5);
      expect(state.progress, 0.5);
    });

    test('progress is 1.0 when value equals max', () {
      const state = ProgressState(max: 100, value: 100);
      expect(state.progress, 1.0);
    });

    test('progress is 0.0 when value is 0', () {
      const state = ProgressState(max: 100, value: 0);
      expect(state.progress, 0.0);
    });

    test('copyWith works correctly', () {
      const state = ProgressState(max: 10, value: 3);
      final updated = state.copyWith(value: 7);
      expect(updated.value, 7);
      expect(updated.max, 10);
    });
  });
}
