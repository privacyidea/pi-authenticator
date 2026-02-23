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
import '../../model/push_request/push_request.dart' show PushRequest;
import '../../model/riverpod_states/push_request_state.dart'
    show PushRequestState;

abstract class PushRequestRepository {
  /// Load the [PushRequestState] from the repository
  Future<PushRequestState> loadState();

  /// Save the [PushRequestState] to the repository
  Future<void> saveState(PushRequestState pushRequestState);

  /// Delete all [PushRequest]s from the [PushRequestState]
  Future<void> clearState();

  /// Add a [PushRequest] to the [PushRequestState]
  Future<PushRequestState> addRequest(
    PushRequest pushRequest, {
    PushRequestState? state,
  });

  /// Remove a [PushRequest] from the [PushRequestState]
  Future<PushRequestState> removeRequest(
    PushRequest pushRequest, {
    PushRequestState? state,
  });
}
