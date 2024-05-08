import '../../model/push_request.dart' show PushRequest;
import '../../model/states/push_request_state.dart' show PushRequestState;

abstract class PushRequestRepository {
  /// Load the [PushRequestState] from the repository
  Future<PushRequestState> loadState();

  /// Save the [PushRequestState] to the repository
  Future<void> saveState(PushRequestState pushRequestState);

  /// Delete all [PushRequest]s from the [PushRequestState]
  Future<void> clearState();

  /// Add a [PushRequest] to the [PushRequestState]
  Future<PushRequestState> add(PushRequest pushRequest, {PushRequestState? state});

  /// Remove a [PushRequest] from the [PushRequestState]
  Future<PushRequestState> remove(PushRequest pushRequest, {PushRequestState? state});
}
