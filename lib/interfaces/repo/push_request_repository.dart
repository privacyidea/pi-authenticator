import 'package:privacyidea_authenticator/model/push_request.dart';
import 'package:privacyidea_authenticator/model/states/push_request_state.dart';

abstract class PushRequestRepository {
  Future<PushRequestState> loadState();
  Future<List<PushRequest>> saveState(PushRequestState pushRequestState);
}
