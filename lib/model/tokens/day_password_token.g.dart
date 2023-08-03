// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_password_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayPasswordToken _$DayPasswordTokenFromJson(Map<String, dynamic> json) => DayPasswordToken(
      period: json['period'] == null ? const Duration(hours: 24) : Duration(microseconds: json['period'] as int),
      viewMode: $enumDecodeNullable(_$DayPasswordTokenViewModeEnumMap, json['viewMode']) ?? DayPasswordTokenViewMode.VALIDFOR,
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
      algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: json['secret'] as String,
      type: json['type'] as String?,
      pin: json['pin'] as bool?,
      tokenImage: json['tokenImage'] as String?,
      sortIndex: json['sortIndex'] as int?,
      isLocked: json['isLocked'] as bool? ?? false,
      categoryId: json['categoryId'] as int?,
      isInEditMode: json['isInEditMode'] as bool? ?? false,
    );

Map<String, dynamic> _$DayPasswordTokenToJson(DayPasswordToken instance) => <String, dynamic>{
      'label': instance.label,
      'issuer': instance.issuer,
      'id': instance.id,
      'isLocked': instance.isLocked,
      'pin': instance.pin,
      'tokenImage': instance.tokenImage,
      'categoryId': instance.categoryId,
      'isInEditMode': instance.isInEditMode,
      'sortIndex': instance.sortIndex,
      'type': instance.type,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm]!,
      'digits': instance.digits,
      'secret': instance.secret,
      'viewMode': _$DayPasswordTokenViewModeEnumMap[instance.viewMode]!,
      'period': instance.period.inMicroseconds,
    };

const _$DayPasswordTokenViewModeEnumMap = {
  DayPasswordTokenViewMode.VALIDFOR: 'VALIDFOR',
  DayPasswordTokenViewMode.VALIDUNTIL: 'VALIDUNTIL',
};

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};
