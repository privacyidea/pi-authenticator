import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'custom_int_buffer.g.dart';

@JsonSerializable()
class CustomIntBuffer {
  final int maxSize;
  final List<int> _list;
  const CustomIntBuffer({this.maxSize = 100, List<int> list = const []}) : _list = list;

  CustomIntBuffer copyWith({int? maxSize, List<int>? list}) {
    return CustomIntBuffer(
      maxSize: maxSize ?? this.maxSize,
      list: list ?? _list,
    );
  }

  List<int> toList() => _list.toList();
  CustomIntBuffer put(int value) {
    final newList = _list.toList()..add(value);
    if (newList.length > maxSize) newList.removeAt(0);
    return CustomIntBuffer(maxSize: maxSize, list: newList);
  }

  CustomIntBuffer putList(List<int> values) {
    final newList = _list.toList()..addAll(values);
    while (newList.length > maxSize) {
      newList.removeAt(0);
    }
    return CustomIntBuffer(maxSize: maxSize, list: newList);
  }

  int get length => _list.length;
  @override
  String toString() => 'CustomIntBuffer{maxSize: $maxSize, _list: $_list}';
  bool contains(int value) => _list.contains(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomIntBuffer && listEquals(other._list, _list);
  }

  @override
  int get hashCode => Object.hashAll([maxSize, ..._list]);

  factory CustomIntBuffer.fromJson(Map<String, dynamic> json) => _$CustomIntBufferFromJson(json);
  Map<String, dynamic> toJson() => _$CustomIntBufferToJson(this);
}
