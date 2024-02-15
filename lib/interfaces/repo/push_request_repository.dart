import '../../model/push_request.dart';

abstract class PushRequestRepository {
  Future<bool> saveOrReplacePushRequests(List<PushRequest> pushRequests);
  Future<List<PushRequest>> loadPushRequests();
  Future<bool> deletePushRequest(PushRequest pushRequest);
}
