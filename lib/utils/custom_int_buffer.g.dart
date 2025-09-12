// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_int_buffer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomIntBuffer _$CustomIntBufferFromJson(Map<String, dynamic> json) =>
    CustomIntBuffer(
      maxSize: (json['maxSize'] as num?)?.toInt() ?? 100,
      list:
          (json['list'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CustomIntBufferToJson(CustomIntBuffer instance) =>
    <String, dynamic>{'maxSize': instance.maxSize, 'list': instance.list};
