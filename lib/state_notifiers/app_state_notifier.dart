import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/states/app_state.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState.running);

  void setAppState(AppState appState) {
    state = appState;
  }
}
