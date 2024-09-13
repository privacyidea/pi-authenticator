// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushToken _$PushTokenFromJson(Map<String, dynamic> json) => PushToken(
      serial: json['serial'] as String,
      label: json['label'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      containerSerial: json['containerSerial'] as String?,
      checkedContainers: (json['checkedContainers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      id: json['id'] as String,
      fbToken: json['fbToken'] as String?,
      url: json['url'] == null ? null : Uri.parse(json['url'] as String),
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      enrollmentCredentials: json['enrollmentCredentials'] as String?,
      publicServerKey: json['publicServerKey'] as String?,
      publicTokenKey: json['publicTokenKey'] as String?,
      privateTokenKey: json['privateTokenKey'] as String?,
      isRolledOut: json['isRolledOut'] as bool?,
      sslVerify: json['sslVerify'] as bool?,
      rolloutState: $enumDecodeNullable(
          _$PushTokenRollOutStateEnumMap, json['rolloutState']),
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
    );

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
      'checkedContainers': instance.checkedContainers,
      'label': instance.label,
      'issuer': instance.issuer,
      'containerSerial': instance.containerSerial,
      'id': instance.id,
      'pin': instance.pin,
      'isLocked': instance.isLocked,
      'isHidden': instance.isHidden,
      'tokenImage': instance.tokenImage,
      'folderId': instance.folderId,
      'sortIndex': instance.sortIndex,
      'origin': instance.origin,
      'type': instance.type,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'serial': instance.serial,
      'fbToken': instance.fbToken,
      'sslVerify': instance.sslVerify,
      'enrollmentCredentials': instance.enrollmentCredentials,
      'url': instance.url?.toString(),
      'isRolledOut': instance.isRolledOut,
      'rolloutState': _$PushTokenRollOutStateEnumMap[instance.rolloutState]!,
      'publicServerKey': instance.publicServerKey,
      'privateTokenKey': instance.privateTokenKey,
      'publicTokenKey': instance.publicTokenKey,
    };

const _$PushTokenRollOutStateEnumMap = {
  PushTokenRollOutState.rolloutNotStarted: 'rolloutNotStarted',
  PushTokenRollOutState.generatingRSAKeyPair: 'generatingRSAKeyPair',
  PushTokenRollOutState.generatingRSAKeyPairFailed:
      'generatingRSAKeyPairFailed',
  PushTokenRollOutState.sendRSAPublicKey: 'sendRSAPublicKey',
  PushTokenRollOutState.sendRSAPublicKeyFailed: 'sendRSAPublicKeyFailed',
  PushTokenRollOutState.parsingResponse: 'parsingResponse',
  PushTokenRollOutState.parsingResponseFailed: 'parsingResponseFailed',
  PushTokenRollOutState.rolloutComplete: 'rolloutComplete',
};
