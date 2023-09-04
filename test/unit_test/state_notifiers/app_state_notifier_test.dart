import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/states/app_state.dart';
import 'package:privacyidea_authenticator/state_notifiers/app_state_notifier.dart';

void main() {
  _testAppStateNotifier();
}

void _testAppStateNotifier() {
  group('AppStateNotifier', () {
    final container = ProviderContainer();
    test('setAppState', () {
      final testProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) => AppStateNotifier());
      final notifier = container.read(testProvider.notifier);
      notifier.setAppState(AppState.pause);
      expect(notifier.state, AppState.pause);
      notifier.setAppState(AppState.resume);
      expect(notifier.state, AppState.resume);
      notifier.setAppState(AppState.running);
      expect(notifier.state, AppState.running);
    });
  });
}
