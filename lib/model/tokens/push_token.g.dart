// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushToken _$PushTokenFromJson(Map<String, dynamic> json) => PushToken(
      serial: json['serial'] as String,
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
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
      pushRequests: json['pushRequests'] == null
          ? null
          : PushRequestQueue.fromJson(
              json['pushRequests'] as Map<String, dynamic>),
      knownPushRequests: json['knownPushRequests'] == null
          ? null
          : CustomIntBuffer.fromJson(
              json['knownPushRequests'] as Map<String, dynamic>),
      type: json['type'] as String?,
      sortIndex: json['sortIndex'] as int?,
      tokenImage: json['tokenImage'] as String?,
      folderId: json['folderId'] as int?,
      pin: json['pin'] as bool?,
      isLocked: json['isLocked'] as bool?,
      isHidden: json['isHidden'] as bool?,
      origin: json['origin'] == null
          ? null
          : TokenOriginData.fromJson(json['origin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
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
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'serial': instance.serial,
      'sslVerify': instance.sslVerify,
      'enrollmentCredentials': instance.enrollmentCredentials,
      'url': instance.url?.toString(),
      'isRolledOut': instance.isRolledOut,
      'rolloutState': _$PushTokenRollOutStateEnumMap[instance.rolloutState]!,
      'publicServerKey': instance.publicServerKey,
      'privateTokenKey': instance.privateTokenKey,
      'publicTokenKey': instance.publicTokenKey,
      'pushRequests': instance.pushRequests,
      'knownPushRequests': instance.knownPushRequests,
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
