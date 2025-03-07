/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
