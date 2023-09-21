// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request_queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushRequestQueue _$PushRequestQueueFromJson(Map<String, dynamic> json) =>
    PushRequestQueue()
      ..list = (json['list'] as List<dynamic>)
          .map((e) => PushRequest.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PushRequestQueueToJson(PushRequestQueue instance) =>
    <String, dynamic>{
      'list': instance.list,
    };
