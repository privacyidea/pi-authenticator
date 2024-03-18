import '../../model/push_request.dart' show PushRequest;
import '../../model/states/push_request_state.dart' show PushRequestState;

abstract class PushRequestRepository {
  Future<PushRequestState> loadState();
  Future<void> saveState(PushRequestState pushRequestState);
  Future<void> clearState();

  Future<PushRequestState> add(PushRequest pushRequest, {PushRequestState? state});
  Future<PushRequestState> remove(PushRequest pushRequest, {PushRequestState? state});
}
