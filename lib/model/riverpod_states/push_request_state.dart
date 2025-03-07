/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
  Map<String, dynamic> toJson() => _$PushRequestStateToJson(this);

  factory PushRequestState.fromJson(Map<String, dynamic> json) => _$PushRequestStateFromJson(json);
}
