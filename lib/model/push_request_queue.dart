// import 'dart:collection';
// import 'package:json_annotation/json_annotation.dart';

// import 'push_request.dart';

// part 'push_request_queue.g.dart';

// @JsonSerializable()
// class PushRequestQueue implements Iterable<PushRequest> {
//   const PushRequestQueue({List<PushRequest>? list}) : _list = list ?? const <PushRequest>[];
//   final List<PushRequest> _list;
//   List<PushRequest> get list => _list;

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is PushRequestQueue && _listsAreEqual(list, other.list);
//   }

//   @override
//   int get hashCode => list.hashCode;

//   bool _listsAreEqual(List<PushRequest> l1, List<PushRequest> l2) {
//     if (l1.length != l2.length) return false;
//     for (int i = 0; i < l1.length - 1; i++) {
//       if (l1[i] != l2[i]) return false;
//     }
//     return true;
//   }

//   factory PushRequestQueue.fromJson(Map<String, dynamic> json) => _$PushRequestQueueFromJson(json);
//   Map<String, dynamic> toJson() => _$PushRequestQueueToJson(this);

//   @override
//   PushRequest get first => list.first;
//   @override
//   PushRequest get last => list.last;
//   @override
//   int get length => list.length;
//   void add(PushRequest value) => list.add(value);
//   bool replace(PushRequest value) {
//     final index = list.indexWhere((element) => element.id == value.id);
//     if (index == -1) return false;
//     list[index] = value;
//     return true;
//   }

//   void addOrReplace(PushRequest value) {
//     final index = list.indexWhere((element) => element.id == value.id);
//     if (index != -1) {
//       list[index] = value;
//     } else {
//       list.add(value);
//     }
//   }

//   void addAll(Iterable<PushRequest> iterable) => list.addAll(iterable);
//   void addFirst(PushRequest value) => list.insert(0, value);
//   @override
//   bool any(bool Function(PushRequest element) test) => list.any(test);
//   @override
//   Queue<R> cast<R>() => list.cast<R>() as Queue<R>;
//   void clear() => list.clear();
//   @override
//   bool contains(Object? element) => list.contains(element);
//   @override
//   PushRequest elementAt(int index) => list.elementAt(index);
//   @override
//   bool every(bool Function(PushRequest element) test) => list.every(test);
//   @override
//   Iterable<T> expand<T>(Iterable<T> Function(PushRequest element) toElements) => list.expand(toElements);
//   @override
//   PushRequest firstWhere(bool Function(PushRequest element) test, {PushRequest Function()? orElse}) => list.firstWhere(test, orElse: orElse);
//   @override
//   T fold<T>(T initialValue, T Function(T previousValue, PushRequest element) combine) => list.fold(initialValue, combine);
//   @override
//   Iterable<PushRequest> followedBy(Iterable<PushRequest> other) => list.followedBy(other);
//   @override
//   void forEach(void Function(PushRequest element) action) => list.forEach(action);
//   @override
//   bool get isEmpty => list.isEmpty;
//   @override
//   bool get isNotEmpty => list.isNotEmpty;
//   @override
//   Iterator<PushRequest> get iterator => list.iterator;
//   @override
//   String join([String separator = ""]) => list.join(separator);
//   @override
//   PushRequest lastWhere(bool Function(PushRequest element) test, {PushRequest Function()? orElse}) => list.lastWhere(test, orElse: orElse);
//   @override
//   Iterable<T> map<T>(T Function(PushRequest e) toElement) => list.map(toElement);
//   @override
//   PushRequest reduce(PushRequest Function(PushRequest value, PushRequest element) combine) => list.reduce(combine);
//   bool remove(Object? value) => list.remove(value);
//   PushRequest? peek() => list.isNotEmpty ? list.first : null;
//   PushRequest pop() => list.removeAt(0);
//   PushRequest? tryPop() => list.isNotEmpty ? pop() : null;
//   @override
//   PushRequest get single => list.single;
//   @override
//   PushRequest singleWhere(bool Function(PushRequest element) test, {PushRequest Function()? orElse}) => list.singleWhere(test, orElse: orElse);
//   @override
//   Iterable<PushRequest> skip(int count) => list.skip(count);
//   @override
//   Iterable<PushRequest> skipWhile(bool Function(PushRequest value) test) => list.skipWhile(test);
//   @override
//   Iterable<PushRequest> take(int count) => list.take(count);
//   @override
//   Iterable<PushRequest> takeWhile(bool Function(PushRequest value) test) => list.takeWhile(test);
//   @override
//   List<PushRequest> toList({bool growable = true}) => list.toList(growable: growable);
//   PushRequestQueue copy() => PushRequestQueue(list: list.toList());
//   @override
//   Set<PushRequest> toSet() => list.toSet();
//   @override
//   Iterable<PushRequest> where(bool Function(PushRequest element) test) => list.where(test);
//   @override
//   Iterable<T> whereType<T>() => list.whereType<T>();
// }
