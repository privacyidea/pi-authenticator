// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'question': instance.question,
      'nonce': instance.nonce,
      'serial': instance.serial,
      'signature': instance.signature,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'uri': instance.uri.toString(),
      'sslVerify': instance.sslVerify,
      'accepted': instance.accepted,
      'hashCode': instance.hashCode,
    };
