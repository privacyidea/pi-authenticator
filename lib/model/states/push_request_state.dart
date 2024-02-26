import 'package:json_annotation/json_annotation.dart';

import '../../utils/custom_int_buffer.dart';
import '../push_request.dart';

// TODO part 'push_request_state.g.dart';

@JsonSerializable()
class PushRequestState {
  final List<PushRequest> pushRequests;
  final CustomIntBuffer knownPushRequests;
  const PushRequestState({List<PushRequest>? pushRequests, CustomIntBuffer? knownPushRequests})
      : pushRequests = pushRequests ?? const <PushRequest>[],
        knownPushRequests = knownPushRequests ?? const CustomIntBuffer();

  bool knowsRequestId(int id) => knownPushRequests.contains(id);
  bool knowsRequest(PushRequest pushRequest) => knowsRequestId(pushRequest.id);

  /// Adds the given push request to a new state and returns it.
  PushRequestState withRequest({required PushRequest pushRequest}) {
    return PushRequestState(
      pushRequests: pushRequests.toList()..add(pushRequest),
      knownPushRequests: knownPushRequests.put(pushRequest.id),
    );
  }

  PushRequestState withoutRequest(PushRequest pushRequest) {
    return PushRequestState(
      pushRequests: pushRequests.toList()..remove(pushRequest),
      knownPushRequests: knownPushRequests,
    );
  }

  PushRequestState addOrReplaceRequest(PushRequest pushRequest) {
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
