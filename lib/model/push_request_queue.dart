import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/model/push_request.dart';

part 'push_request_queue.g.dart';

@JsonSerializable()
class PushRequestQueue {
  PushRequestQueue();

  List<PushRequest>? _list;

  // The get and set methods are needed for serialization.
  List<PushRequest> get list {
    _list ??= [];
    return _list!;
  }

  set list(List<PushRequest> l) {
    if (_list != null) {
      throw ArgumentError('Initializing [list] in [PushRequestQueue] is only allowed once.');
    }

    this._list = l;
  }

  int get length => list.length;

  void forEach(void f(PushRequest request)) => list.forEach((f));

  void removeWhere(bool f(PushRequest request)) => list.removeWhere(f);

  Iterable<PushRequest> where(bool f(PushRequest request)) => list.where(f);

  bool any(bool f(PushRequest element)) => list.any(f);

  void remove(PushRequest request) => list.remove(request);

  bool get isEmpty => list.isEmpty;

  bool get isNotEmpty => list.isNotEmpty;

  bool contains(PushRequest r) => list.contains(r);

  void add(PushRequest pushRequest) => list.add(pushRequest);

  PushRequest peek() => list.first;

  PushRequest pop() => list.removeAt(0);

  @override
  String toString() {
    return 'PushRequestQueue{_list: $list}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PushRequestQueue && runtimeType == other.runtimeType && _listsAreEqual(list, other.list);

  bool _listsAreEqual(List<PushRequest> l1, List<PushRequest> l2) {
    if (l1.length != l2.length) return false;

    for (int i = 0; i < l1.length - 1; i++) {
      if (l1[i] != l2[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => list.hashCode;

  factory PushRequestQueue.fromJson(Map<String, dynamic> json) => _$PushRequestQueueFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestQueueToJson(this);
}
