// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steam_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SteamToken _$SteamTokenFromJson(Map<String, dynamic> json) => SteamToken(
      period: json['period'] as int,
      id: json['id'] as String,
      algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: json['secret'] as String,
      tokenImage: json['tokenImage'] as String?,
      sortIndex: json['sortIndex'] as int?,
      pin: json['pin'] as bool?,
      isLocked: json['isLocked'] as bool?,
      isHidden: json['isHidden'] as bool?,
      folderId: json['folderId'] as int?,
      origin: json['origin'] == null
          ? null
          : TokenOriginData.fromJson(json['origin'] as Map<String, dynamic>),
      label: json['label'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
    );

Map<String, dynamic> _$SteamTokenToJson(SteamToken instance) =>
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
