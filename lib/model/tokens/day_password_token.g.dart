// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_password_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayPasswordToken _$DayPasswordTokenFromJson(Map<String, dynamic> json) =>
    DayPasswordToken(
      period: Duration(microseconds: (json['period'] as num).toInt()),
      id: json['id'] as String,
      algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
      digits: (json['digits'] as num).toInt(),
      secret: json['secret'] as String,
      serial: json['serial'] as String?,
      containerSerial: json['containerSerial'] as String?,
      checkedContainer: (json['checkedContainer'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      viewMode: $enumDecodeNullable(
              _$DayPasswordTokenViewModeEnumMap, json['viewMode']) ??
          DayPasswordTokenViewMode.VALIDFOR,
      type: json['type'] as String?,
      tokenImage: json['tokenImage'] as String?,
      sortIndex: (json['sortIndex'] as num?)?.toInt(),
      folderId: (json['folderId'] as num?)?.toInt(),
      pin: json['pin'] as bool?,
      isLocked: json['isLocked'] as bool?,
      isHidden: json['isHidden'] as bool?,
      origin: json['origin'] == null
          ? null
          : TokenOriginData.fromJson(json['origin'] as Map<String, dynamic>),
      label: json['label'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      isOffline: json['isOffline'] as bool? ?? false,
    );

Map<String, dynamic> _$DayPasswordTokenToJson(DayPasswordToken instance) =>
    <String, dynamic>{
      'checkedContainer': instance.checkedContainer,
      'label': instance.label,
      'issuer': instance.issuer,
      'containerSerial': instance.containerSerial,
      'id': instance.id,
      'serial': instance.serial,
      'pin': instance.pin,
      'isLocked': instance.isLocked,
      'isHidden': instance.isHidden,
      'tokenImage': instance.tokenImage,
      'folderId': instance.folderId,
      'isOffline': instance.isOffline,
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
