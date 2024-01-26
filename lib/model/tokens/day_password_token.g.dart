// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_password_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayPasswordToken _$DayPasswordTokenFromJson(Map<String, dynamic> json) =>
    DayPasswordToken(
      period: Duration(microseconds: json['period'] as int),
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
      algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: json['secret'] as String,
      viewMode: $enumDecodeNullable(
              _$DayPasswordTokenViewModeEnumMap, json['viewMode']) ??
          DayPasswordTokenViewMode.VALIDFOR,
      type: json['type'] as String?,
      tokenImage: json['tokenImage'] as String?,
      sortIndex: json['sortIndex'] as int?,
      folderId: json['folderId'] as int?,
      pin: json['pin'] as bool?,
      isLocked: json['isLocked'] as bool?,
      isHidden: json['isHidden'] as bool?,
      origin: json['origin'] == null
          ? null
          : TokenOrigin.fromJson(json['origin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DayPasswordTokenToJson(DayPasswordToken instance) =>
    <String, dynamic>{
      'label': instance.label,
      'issuer': instance.issuer,
      'id': instance.id,
      'pin': instance.pin,
      'isLocked': instance.isLocked,
      'isHidden': instance.isHidden,
      'tokenImage': instance.tokenImage,
      'folderId': instance.folderId,
      'sortIndex': instance.sortIndex,
      'origin': instance.origin,
      'type': instance.type,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm]!,
      'digits': instance.digits,
      'secret': instance.secret,
      'viewMode': _$DayPasswordTokenViewModeEnumMap[instance.viewMode]!,
      'period': instance.period.inMicroseconds,
    };

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};

const _$DayPasswordTokenViewModeEnumMap = {
  DayPasswordTokenViewMode.VALIDFOR: 'VALIDFOR',
  DayPasswordTokenViewMode.VALIDUNTIL: 'VALIDUNTIL',
};
