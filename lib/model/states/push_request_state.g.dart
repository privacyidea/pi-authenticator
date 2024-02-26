// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushRequestState _$PushRequestStateFromJson(Map<String, dynamic> json) =>
    PushRequestState(
      pushRequests: (json['pushRequests'] as List<dynamic>?)
          ?.map((e) => PushRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      knownPushRequests: json['knownPushRequests'] == null
          ? null
          : CustomIntBuffer.fromJson(
              json['knownPushRequests'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PushRequestStateToJson(PushRequestState instance) =>
    <String, dynamic>{
      'pushRequests': instance.pushRequests,
      'knownPushRequests': instance.knownPushRequests,
    };
