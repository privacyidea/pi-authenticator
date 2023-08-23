// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushToken _$PushTokenFromJson(Map<String, dynamic> json) => PushToken(
      label: json['label'] as String,
      serial: json['serial'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
      type: json['type'] as String?,
      tokenImage: json['tokenImage'] as String?,
      pushRequests: json['pushRequests'] == null ? null : PushRequestQueue.fromJson(json['pushRequests'] as Map<String, dynamic>),
      isLocked: json['isLocked'] as bool? ?? false,
      pin: json['pin'] as bool? ?? false,
      sslVerify: json['sslVerify'] as bool?,
      enrollmentCredentials: json['enrollmentCredentials'] as String?,
      url: json['url'] == null ? null : Uri.parse(json['url'] as String),
      sortIndex: json['sortIndex'] as int?,
      publicServerKey: json['publicServerKey'] as String?,
      publicTokenKey: json['publicTokenKey'] as String?,
      privateTokenKey: json['privateTokenKey'] as String?,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      isRolledOut: json['isRolledOut'] as bool? ?? false,
      rolloutState: $enumDecodeNullable(_$PushTokenRollOutStateEnumMap, json['rolloutState']) ?? PushTokenRollOutState.rolloutNotStarted,
      knownPushRequests: json['knownPushRequests'] == null ? null : CustomIntBuffer.fromJson(json['knownPushRequests'] as Map<String, dynamic>),
      folderId: json['folderId'] as int?,
      isInEditMode: json['isInEditMode'] as bool? ?? false,
    );

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
      'label': instance.label,
      'issuer': instance.issuer,
      'id': instance.id,
      'isLocked': instance.isLocked,
      'pin': instance.pin,
      'tokenImage': instance.tokenImage,
      'folderId': instance.folderId,
      'isInEditMode': instance.isInEditMode,
      'sortIndex': instance.sortIndex,
      'type': instance.type,
      'expirationDate': instance.expirationDate.toIso8601String(),
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
  PushTokenRollOutState.generateingRSAKeyPair: 'generateingRSAKeyPair',
  PushTokenRollOutState.generateingRSAKeyPairFailed: 'generateingRSAKeyPairFailed',
  PushTokenRollOutState.sendRSAPublicKey: 'sendRSAPublicKey',
  PushTokenRollOutState.sendRSAPublicKeyFailed: 'sendRSAPublicKeyFailed',
  PushTokenRollOutState.parsingResponse: 'parsingResponse',
  PushTokenRollOutState.parsingResponseFailed: 'parsingResponseFailed',
  PushTokenRollOutState.rolloutComplete: 'rolloutComplete',
};
