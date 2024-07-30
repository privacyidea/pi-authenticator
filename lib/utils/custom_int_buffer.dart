import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'custom_int_buffer.g.dart';

@JsonSerializable()
class CustomIntBuffer {
  final int maxSize;
  final List<int> list;
  CustomIntBuffer({this.maxSize = 100, List<int> list = const []}) : list = list.sublist(max(list.length - maxSize, 0), list.length);

  CustomIntBuffer copyWith({int? maxSize, List<int>? list}) {
    return CustomIntBuffer(
      maxSize: maxSize ?? this.maxSize,
      list: list ?? this.list,
    );
  }

  List<int> toList() => list.toList();
  CustomIntBuffer put(int value) {
    final newList = list.toList()..add(value);
    if (newList.length > maxSize) newList.removeAt(0);
    return CustomIntBuffer(maxSize: maxSize, list: newList);
  }

  CustomIntBuffer putList(List<int> values) {
    final newList = list.toList()..addAll(values);
    while (newList.length > maxSize) {
      newList.removeAt(0);
    }
    return CustomIntBuffer(maxSize: maxSize, list: newList);
  }

  int get length => list.length;
  @override
  String toString() => 'CustomIntBuffer{maxSize: $maxSize, list: $list}';
  bool contains(int value) => list.contains(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomIntBuffer && listEquals(other.list, list);
  }

  @override
  int get hashCode => Object.hashAll([maxSize, ...list]);

  factory CustomIntBuffer.fromJson(Map<String, dynamic> json) => _$CustomIntBufferFromJson(json);
  Map<String, dynamic> toJson() => _$CustomIntBufferToJson(this);
}
