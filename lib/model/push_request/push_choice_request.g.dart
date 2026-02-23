// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_choice_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushChoiceRequest _$PushChoiceRequestFromJson(Map<String, dynamic> json) =>
    PushChoiceRequest(
      title: json['title'] as String,
      question: json['question'] as String,
      nonce: json['nonce'] as String,
      serial: json['serial'] as String,
      signature: json['signature'] as String,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      uri: Uri.parse(json['uri'] as String),
      sslVerify: json['sslVerify'] as bool,
      possibleAnswers: (json['possibleAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: json['type'] as String? ?? PushChoiceRequest.TYPE,
      selectedAnswer: json['selectedAnswer'] as String?,
      accepted: json['accepted'] as bool?,
    );

Map<String, dynamic> _$PushChoiceRequestToJson(PushChoiceRequest instance) =>
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
      'selectedAnswer': instance.selectedAnswer,
      'possibleAnswers': instance.possibleAnswers,
    };
