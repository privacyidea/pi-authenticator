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
      id: (json['id'] as num).toInt(),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      serial: json['serial'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      accepted: json['accepted'] as bool?,
      possibleAnswers: (json['answers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      selectedAnswer: (json['selectedAnswer'] as String?),
    );

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) => <String, dynamic>{
      'title': instance.title,
      'question': instance.question,
      'id': instance.id,
      'uri': instance.uri.toString(),
      'nonce': instance.nonce,
      'sslVerify': instance.sslVerify,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'serial': instance.serial,
      'signature': instance.signature,
      'accepted': instance.accepted,
      'answers': instance.possibleAnswers,
      'selectedAnswer': instance.selectedAnswer,
    };
