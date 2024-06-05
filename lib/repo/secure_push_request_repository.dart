// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';

import '../interfaces/repo/push_request_repository.dart';
import '../model/push_request.dart';
import '../model/states/push_request_state.dart';
import '../utils/custom_int_buffer.dart';

class SecurePushRequestRepository implements PushRequestRepository {
  const SecurePushRequestRepository();

  // Use this to lock critical sections of code.
  static final Mutex _m = Mutex();

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  static Future<T> protect<T>(Future<T> Function() f) => _m.protect<T>(f);
  Future<Map<String, String>> readAllPushRequests() async {
    final value = await _storage.readAll();
    final result = <String, String>{};
    for (var key in value.keys) {
      if (key.startsWith(_securePushRequestKey)) {
        result[key] = value[key]!;
      }
    }
    return result;
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _securePushRequestKey = 'app_v3_pr_state';

  @override

  /// Save the state to the secure storage.
  /// This is a critical section, so it is protected by Mutex.
  Future<void> saveState(PushRequestState pushRequestState) => protect<void>(() => _saveState(pushRequestState));
  Future<void> _saveState(PushRequestState pushRequestState) async {
    final stateJson = jsonEncode(pushRequestState.toJson());
    await _storage.write(key: _securePushRequestKey, value: stateJson);
  }

  @override

  /// Load the state from the secure storage.
  /// If no state is found, an empty state is returned.
  /// This is a critical section, so it is protected by Mutex.
  Future<PushRequestState> loadState() => protect<PushRequestState>(_loadState);
  Future<PushRequestState> _loadState() async {
    final String? stateJson = await _storage.read(key: _securePushRequestKey);
    if (stateJson == null) {
      return const PushRequestState(pushRequests: [], knownPushRequests: CustomIntBuffer(list: []));
    }
    return PushRequestState.fromJson(jsonDecode(stateJson));
  }

  @override

  /// Adds a push request in the given state if it is not already known.
  /// If no state is given, the current state is loaded from the secure storage.
  /// This is a critical section, so it is protected by Mutex.
  Future<PushRequestState> add(PushRequest pushRequest, {PushRequestState? state}) => protect<PushRequestState>(() async {
        state ??= await _loadState();
        if (state!.knowsRequest(pushRequest)) {
          return state!;
        }
        final newState = state!.withRequest(pushRequest);
        await _saveState(newState);
        return newState;
      });

  @override

  /// Remove a push request from the state.
  /// If no state is given, the current state is loaded from the secure storage.
  /// This is a critical section, so it is protected by Mutex.
  Future<PushRequestState> remove(PushRequest pushRequest, {PushRequestState? state}) => protect<PushRequestState>(() async {
        state ??= await _loadState();
        final newState = state!.withoutRequest(pushRequest);
        await _saveState(newState);
        return newState;
      });

  @override

  /// Removes all push requests from the repository.
  /// If no state is saved, nothing will happen.
  /// This is a critical section, so it is protected by Mutex.
  Future<void> clearState() => protect<void>(() => _clearState());
  Future<void> _clearState() => _storage.delete(key: _securePushRequestKey);
}
