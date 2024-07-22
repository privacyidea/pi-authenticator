import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/custom_int_buffer.dart';
import '../push_request.dart';

part 'push_request_state.g.dart';

@JsonSerializable()
class PushRequestState {
  final List<PushRequest> pushRequests;
  final CustomIntBuffer knownPushRequests;
  const PushRequestState({required this.pushRequests, required this.knownPushRequests});

  bool knowsRequestId(int id) => knownPushRequests.contains(id);
  bool knowsRequest(PushRequest pushRequest) => knowsRequestId(pushRequest.id);

  /// Adds the given push request to a new state and returns it.
  PushRequestState withRequest(PushRequest pushRequest) => PushRequestState(
        pushRequests: pushRequests.toList()..add(pushRequest),
        knownPushRequests: knownPushRequests.put(pushRequest.id),
      );

  PushRequestState withoutRequest(PushRequest pushRequest) => PushRequestState(
        pushRequests: pushRequests.toList()..remove(pushRequest),
        knownPushRequests: knownPushRequests.copyWith(),
      );

  PushRequestState addOrReplace(PushRequest pushRequest) {
    final requests = pushRequests.toList();
    final knowenIds = knownPushRequests.toList();
    if (requests.contains(pushRequest)) {
      return PushRequestState(
        pushRequests: requests
          ..remove(pushRequest)
          ..add(pushRequest),
        knownPushRequests: knownPushRequests,
      );
    }
    knowenIds.add(pushRequest.id);
    return PushRequestState(
      pushRequests: requests..add(pushRequest),
      knownPushRequests: CustomIntBuffer(list: knowenIds),
    );
  }

  (PushRequestState, bool) replaceRequest(PushRequest pushRequest) {
    final newRequests = pushRequests.toList();
    final index = newRequests.indexWhere((element) => element.id == pushRequest.id);
    if (index == -1) {
      return (this, false);
    }
    newRequests[index] = pushRequest;
    return (PushRequestState(pushRequests: newRequests, knownPushRequests: knownPushRequests), true);
  }

  PushRequest? currentOf(PushRequest pushRequest) => pushRequests.firstWhere((element) => element.id == pushRequest.id);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PushRequestState && listEquals(other.pushRequests, pushRequests) && other.knownPushRequests == knownPushRequests;
  }

  @override
  int get hashCode => Object.hashAll([pushRequests.hashCode, knownPushRequests.hashCode]);

  @override
  String toString() => 'PushRequestState(pushRequests: $pushRequests, knownPushRequests: $knownPushRequests)';

  /*
  //////////////////////////////////////////////////
  /////////////// Json Serialization ///////////////
  //////////////////////////////////////////////////
  */
  Map<String, dynamic> toJson() => {
        'pushRequests': pushRequests.map((e) => e.toJson()).toList(),
        'knownPushRequests': knownPushRequests.toJson(),
      };

  factory PushRequestState.fromJson(Map<String, dynamic> json) => PushRequestState(
        pushRequests: (json['pushRequests'] as List).map((e) => PushRequest.fromJson(e)).toList(),
        knownPushRequests: CustomIntBuffer.fromJson(json['knownPushRequests']),
      );
}
