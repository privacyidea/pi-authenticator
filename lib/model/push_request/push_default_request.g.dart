// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_default_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushDefaultRequest _$PushDefaultRequestFromJson(Map<String, dynamic> json) =>
    PushDefaultRequest(
      title: json['title'] as String,
      question: json['question'] as String,
      nonce: json['nonce'] as String,
      serial: json['serial'] as String,
      signature: json['signature'] as String,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      uri: Uri.parse(json['uri'] as String),
      sslVerify: json['sslVerify'] as bool,
      type: json['type'] as String? ?? PushDefaultRequest.TYPE,
      accepted: json['accepted'] as bool?,
    );

Map<String, dynamic> _$PushDefaultRequestToJson(PushDefaultRequest instance) =>
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
    };
