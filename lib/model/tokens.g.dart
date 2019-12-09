// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOTPToken _$HOTPTokenFromJson(Map<String, dynamic> json) {
  return HOTPToken(
      json['label'] as String,
      json['serial'] as String,
      json['algorithm'] as String,
      json['digits'] as int,
      (json['secret'] as List)?.map((e) => e as int)?.toList(),
      counter: json['counter'] as int);
}

Map<String, dynamic> _$HOTPTokenToJson(HOTPToken instance) => <String, dynamic>{
      'label': instance.label,
      'serial': instance.serial,
      'algorithm': instance.algorithm,
      'digits': instance.digits,
      'secret': instance.secret,
      'counter': instance.counter
    };

TOTPToken _$TOTPTokenFromJson(Map<String, dynamic> json) {
  return TOTPToken(
      json['label'] as String,
      json['serial'] as String,
      json['algorithm'] as String,
      json['digits'] as int,
      (json['secret'] as List)?.map((e) => e as int)?.toList(),
      json['period'] as int);
}

Map<String, dynamic> _$TOTPTokenToJson(TOTPToken instance) => <String, dynamic>{
      'label': instance.label,
      'serial': instance.serial,
      'algorithm': instance.algorithm,
      'digits': instance.digits,
      'secret': instance.secret,
      'period': instance.period
    };
