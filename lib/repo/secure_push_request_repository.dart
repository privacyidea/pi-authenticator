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
      if (key.startsWith(_PR_PREFIX)) {
        result[key] = value[key]!;
      }
    }
    return result;
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _PR_PREFIX = 'app_v3_PR_';
  static const String _KNOWN_PUSH_REQUESTS = 'known_push_requests';

  @override
  Future<List<PushRequest>> saveState(PushRequestState pushRequestState) => protect<List<PushRequest>>(() async {
        await _saveKnownPushRequests(pushRequestState.knownPushRequests);
        return await _savePushRequests(pushRequestState.pushRequests);
      });

  @override
  Future<PushRequestState> loadState() => protect<PushRequestState>(() async {
        final pushRequests = await _loadPushRequests();
        final knownPushRequests = await _loadKnownPushRequests();
        return PushRequestState(pushRequests: pushRequests, knownPushRequests: knownPushRequests);
      });

  Future<List<PushRequest>> _savePushRequests(List<PushRequest> pushRequests) async {
    final List<PushRequest> failedRequests = <PushRequest>[];
    for (var key in (await readAllPushRequests()).keys) {
      int index = pushRequests.indexWhere((element) => key == _keyOf(element));
      if (index == -1) {
        await _storage.delete(key: key);
      } else {
        try {
          await _storage.write(
            key: key,
            value: jsonEncode(pushRequests[index].toJson()),
          );
        } catch (e) {
          failedRequests.add(pushRequests[index]);
          continue;
        }
        pushRequests.removeAt(index);
      }
    }
    return failedRequests;
  }

  Future<List<PushRequest>> _loadPushRequests() async {
    const pushRequests = <PushRequest>[];
    final Map<String, String> all = await readAllPushRequests();
    for (var key in all.keys) {
      final jsonString = all[key];
      if (jsonString != null) {
        pushRequests.add(PushRequest.fromJson(jsonDecode(jsonString)));
      }
    }
    return pushRequests;
  }

  Future<CustomIntBuffer> _loadKnownPushRequests() async {
    final String? knownPushRequests = await _storage.read(key: '$_PR_PREFIX$_KNOWN_PUSH_REQUESTS');
    if (knownPushRequests == null) {
      return const CustomIntBuffer();
    }
    return CustomIntBuffer.fromJson(jsonDecode(knownPushRequests));
  }

  Future<bool> _saveKnownPushRequests(CustomIntBuffer knownPushRequests) async {
    try {
      await _storage.write(
        key: '$_PR_PREFIX$_KNOWN_PUSH_REQUESTS',
        value: jsonEncode(knownPushRequests.toJson()),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  String _keyOf(PushRequest pushRequest) => '$_PR_PREFIX${pushRequest.id}';
}
