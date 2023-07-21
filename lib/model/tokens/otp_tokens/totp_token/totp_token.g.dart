// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TOTPToken _$TOTPTokenFromJson(Map<String, dynamic> json) => TOTPToken(
      period: json['period'] as int,
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
    );

Map<String, dynamic> _$TOTPTokenToJson(TOTPToken instance) => <String, dynamic>{
      'label': instance.label,
      'issuer': instance.issuer,
      'id': instance.id,
      'isLocked': instance.isLocked,
      'imageURL': instance.imageURL,
      'categoryId': instance.categoryId,
      'sortIndex': instance.sortIndex,
      'type': instance.type,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm]!,
      'digits': instance.digits,
      'secret': instance.secret,
      'pin': instance.pin,
      'period': instance.period,
    };

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};
