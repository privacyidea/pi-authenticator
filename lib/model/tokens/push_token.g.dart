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
  checkedContainer:
      (json['checkedContainer'] as List<dynamic>?)
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
  isPollOnly: json['isPollOnly'] as bool?,
  isRolledOut: json['isRolledOut'] as bool?,
  sslVerify: json['sslVerify'] as bool?,
  rolloutState: $enumDecodeNullable(
    _$PushTokenRollOutStateEnumMap,
    json['rolloutState'],
  ),
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
  isOffline: json['isOffline'] as bool? ?? false,
  forceBiometricOption:
      $enumDecodeNullable(
        _$ForceBiometricOptionEnumMap,
        json['forceBiometricOption'],
      ) ??
      ForceBiometricOption.none,
);

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'label': instance.label,
  'issuer': instance.issuer,
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
  'expirationDate': instance.expirationDate?.toIso8601String(),
  'fbToken': instance.fbToken,
  'sslVerify': instance.sslVerify,
  'isPollOnly': instance.isPollOnly,
  'enrollmentCredentials': instance.enrollmentCredentials,
  'url': instance.url?.toString(),
  'isRolledOut': instance.isRolledOut,
  'rolloutState': _$PushTokenRollOutStateEnumMap[instance.rolloutState]!,
  'publicServerKey': instance.publicServerKey,
  'privateTokenKey': instance.privateTokenKey,
  'publicTokenKey': instance.publicTokenKey,
  'serial': instance.serial,
  'isHidden': instance.isHidden,
};

const _$PushTokenRollOutStateEnumMap = {
  PushTokenRollOutState.rolloutNotStarted: 'rolloutNotStarted',
  PushTokenRollOutState.generatingRSAKeyPair: 'generatingRSAKeyPair',
  PushTokenRollOutState.generatingRSAKeyPairFailed:
      'generatingRSAKeyPairFailed',
  PushTokenRollOutState.receivingFirebaseToken: 'receivingFirebaseToken',
  PushTokenRollOutState.receivingFirebaseTokenFailed:
      'receivingFirebaseTokenFailed',
  PushTokenRollOutState.sendRSAPublicKey: 'sendRSAPublicKey',
  PushTokenRollOutState.sendRSAPublicKeyFailed: 'sendRSAPublicKeyFailed',
  PushTokenRollOutState.parsingResponse: 'parsingResponse',
  PushTokenRollOutState.parsingResponseFailed: 'parsingResponseFailed',
  PushTokenRollOutState.rolloutComplete: 'rolloutComplete',
};

const _$ForceBiometricOptionEnumMap = {
  ForceBiometricOption.none: 'none',
  ForceBiometricOption.any: 'any',
  ForceBiometricOption.biometric: 'biometric',
  ForceBiometricOption.pin: 'pin',
};
