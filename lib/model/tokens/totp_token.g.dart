// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TOTPToken _$TOTPTokenFromJson(Map<String, dynamic> json) => TOTPToken(
  period: (json['period'] as num).toInt(),
  id: json['id'] as String,
  algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
  digits: (json['digits'] as num).toInt(),
  secret: json['secret'] as String,
  serial: json['serial'] as String?,
  containerSerial: json['containerSerial'] as String?,
  checkedContainer:
      (json['checkedContainer'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  type: json['type'] as String?,
  tokenImage: json['tokenImage'] as String?,
  pin: json['pin'] as bool?,
  isLocked: json['isLocked'] as bool?,
  isHidden: json['isHidden'] as bool?,
  sortIndex: (json['sortIndex'] as num?)?.toInt(),
  folderId: (json['folderId'] as num?)?.toInt(),
  origin: json['origin'] == null
      ? null
      : TokenOriginData.fromJson(json['origin'] as Map<String, dynamic>),
  label: json['label'] as String? ?? '',
  issuer: json['issuer'] as String? ?? '',
  isOffline: json['isOffline'] as bool? ?? false,
  forceBiometricOption:
      $enumDecodeNullable(
        _$ForceBiometricOptionEnumMap,
        json['forceBiometricOption'],
      ) ??
      ForceBiometricOption.none,
);

Map<String, dynamic> _$TOTPTokenToJson(TOTPToken instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'label': instance.label,
  'issuer': instance.issuer,
  'serial': instance.serial,
  'containerSerial': instance.containerSerial,
  'checkedContainer': instance.checkedContainer,
  'pin': instance.pin,
  'forceBiometricOption':
      _$ForceBiometricOptionEnumMap[instance.forceBiometricOption]!,
  'tokenImage': instance.tokenImage,
  'folderId': instance.folderId,
  'isOffline': instance.isOffline,
  'origin': instance.origin,
  'sortIndex': instance.sortIndex,
  'isLocked': instance.isLocked,
  'isHidden': instance.isHidden,
  'algorithm': _$AlgorithmsEnumMap[instance.algorithm]!,
  'digits': instance.digits,
  'secret': instance.secret,
  'period': instance.period,
};

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};

const _$ForceBiometricOptionEnumMap = {
  ForceBiometricOption.none: 'none',
  ForceBiometricOption.any: 'any',
  ForceBiometricOption.biometric: 'biometric',
  ForceBiometricOption.pin: 'pin',
};
