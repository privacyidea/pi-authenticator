import 'package:json_annotation/json_annotation.dart';

part 'custom_int_buffer.g.dart';

@JsonSerializable()
class CustomIntBuffer {
  final int maxSize = 30;

  CustomIntBuffer();

  List<int>? _list;

  // The get and set methods are needed for serialization.
  List<int> get list {
    _list ??= [];
    return _list!;
  }

  set list(List<int> l) {
    if (_list != null) {
      throw ArgumentError('Initializing [list] in [CustomStringBuffer] is only allowed once.');
    }

    if (l.length > maxSize) {
      throw ArgumentError('The list $l is to long for a buffer of size $maxSize');
    }

    this._list = l;
  }

  void put(int value) {
    if (list.length >= maxSize) list.removeAt(0);
    list.add(value);
  }

  int get length => list.length;

  bool contains(int value) => list.contains(value);

  factory CustomIntBuffer.fromJson(Map<String, dynamic> json) => _$CustomIntBufferFromJson(json);

  Map<String, dynamic> toJson() => _$CustomIntBufferToJson(this);
}
