import 'package:json_annotation/json_annotation.dart';

part 'custom_int_buffer.g.dart';

@JsonSerializable()
class CustomIntBuffer {
  final int maxSize;
  const CustomIntBuffer({this.maxSize = 100, List<int> list = const <int>[]}) : _list = list;
  final List<int> _list;
  List<int> toList() => _list.toList();
  CustomIntBuffer put(int value) {
    final newList = _list.toList();
    if (newList.length >= maxSize) newList.removeAt(0);
    newList.add(value);
    return CustomIntBuffer(list: newList);
  }

  int get length => _list.length;
  @override
  String toString() => _list.toString();
  bool contains(int value) => _list.contains(value);
  factory CustomIntBuffer.fromJson(Map<String, dynamic> json) => _$CustomIntBufferFromJson(json);
  Map<String, dynamic> toJson() => _$CustomIntBufferToJson(this);
}
