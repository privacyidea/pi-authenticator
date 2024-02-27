import 'package:privacyidea_authenticator/model/states/push_request_state.dart';

import '../../model/push_request.dart';

abstract class PushRequestRepository {
  Future<PushRequestState> loadState();
  Future<void> saveState(PushRequestState pushRequestState);
  Future<void> clearState();

  Future<PushRequestState> add(PushRequest pushRequest, {PushRequestState? state});
  Future<PushRequestState> remove(PushRequest pushRequest, {PushRequestState? state});
}
