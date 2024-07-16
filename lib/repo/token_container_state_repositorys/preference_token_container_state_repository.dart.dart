import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';

class PreferenceTokenContainerStateRepository implements TokenContainerStateRepository {
  static String prefix = 'token_container_state_';
  final String containerId;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  PreferenceTokenContainerStateRepository(this.containerId);

  @override

  /// Save the container state to the shared preferences
  /// Returns the state that was actually written to the shared preferences
  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async {
    (await _prefs).setString(prefix + containerId, jsonEncode(containerState.toJson()));
    return containerState;
  }

  @override

  /// Load the container state from the shared preferences
  Future<TokenContainerState> loadContainer() async {
    final jsonString = (await _prefs).getString(prefix + containerId);
    if (jsonString == null) {
      return TokenContainerStateUninitialized(
        containerId: containerId,
        description: '',
        type: '',
        tokens: [],
      );
    }
    return TokenContainerState.fromJson(jsonDecode(jsonString));
  }
}
