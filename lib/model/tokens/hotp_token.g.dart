// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotp_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOTPToken _$HOTPTokenFromJson(Map<String, dynamic> json) => HOTPToken(
      counter: json['counter'] as int? ?? 0,
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
      algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: json['secret'] as String,
      type: json['type'] as String?,
      pin: json['pin'] as bool?,
      imageURL: json['imageURL'] as String?,
      sortIndex: json['sortIndex'] as int?,
      isLocked: json['isLocked'] as bool? ?? false,
      categoryId: json['categoryId'] as int?,
      isInEditMode: json['isInEditMode'] as bool? ?? false,
    );

Map<String, dynamic> _$HOTPTokenToJson(HOTPToken instance) => <String, dynamic>{
      'label': instance.label,
      'issuer': instance.issuer,
      'id': instance.id,
      'isLocked': instance.isLocked,
      'imageURL': instance.imageURL,
      'categoryId': instance.categoryId,
      'sortIndex': instance.sortIndex,
      'isInEditMode': instance.isInEditMode,
      'type': instance.type,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm]!,
      'digits': instance.digits,
      'secret': instance.secret,
      'pin': instance.pin,
      'counter': instance.counter,
    };

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};
