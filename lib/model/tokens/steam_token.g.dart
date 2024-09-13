// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steam_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SteamToken _$SteamTokenFromJson(Map<String, dynamic> json) => SteamToken(
      id: json['id'] as String,
      secret: json['secret'] as String,
      serial: json['serial'] as String?,
      containerSerial: json['containerSerial'] as String?,
      checkedContainers: (json['checkedContainers'] as List<dynamic>?)
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
    );

Map<String, dynamic> _$SteamTokenToJson(SteamToken instance) =>
    <String, dynamic>{
      'checkedContainers': instance.checkedContainers,
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
      'sortIndex': instance.sortIndex,
      'origin': instance.origin,
      'type': instance.type,
      'secret': instance.secret,
    };
