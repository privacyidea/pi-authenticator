// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushRequest _$PushRequestFromJson(Map<String, dynamic> json) => PushRequest(
      title: json['title'] as String,
      question: json['question'] as String,
      uri: Uri.parse(json['uri'] as String),
      nonce: json['nonce'] as String,
      sslVerify: json['sslVerify'] as bool,
      id: json['id'] as int,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
    );

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) =>
    <String, dynamic>{
      'expirationDate': instance.expirationDate.toIso8601String(),
      'id': instance.id,
      'nonce': instance.nonce,
      'sslVerify': instance.sslVerify,
      'uri': instance.uri.toString(),
      'question': instance.question,
      'title': instance.title,
    };
