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
      imageURL: json['imageURL'] as String?,
      pushRequests: json['pushRequests'] == null
          ? null
          : PushRequestQueue.fromJson(
              json['pushRequests'] as Map<String, dynamic>),
      isLocked: json['isLocked'] as bool? ?? false,
      pin: json['pin'] as bool? ?? false,
      sslVerify: json['sslVerify'] as bool?,
      enrollmentCredentials: json['enrollmentCredentials'] as String?,
      url: json['url'] == null ? null : Uri.parse(json['url'] as String),
      sortIndex: json['sortIndex'] as int?,
      tokenImage: json['tokenImage'] as String?,
      publicServerKey: json['publicServerKey'] as String?,
      publicTokenKey: json['publicTokenKey'] as String?,
      privateTokenKey: json['privateTokenKey'] as String?,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      isRolledOut: json['isRolledOut'] as bool? ?? false,
    )..knownPushRequests = CustomIntBuffer.fromJson(
        json['knownPushRequests'] as Map<String, dynamic>);

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
      'label': instance.label,
      'issuer': instance.issuer,
      'id': instance.id,
      'isLocked': instance.isLocked,
      'imageURL': instance.imageURL,
      'type': instance.type,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'serial': instance.serial,
      'sslVerify': instance.sslVerify,
      'enrollmentCredentials': instance.enrollmentCredentials,
      'url': instance.url?.toString(),
      'isRolledOut': instance.isRolledOut,
      'sortIndex': instance.sortIndex,
      'pin': instance.pin,
      'publicServerKey': instance.publicServerKey,
      'privateTokenKey': instance.privateTokenKey,
      'publicTokenKey': instance.publicTokenKey,
      'pushRequests': instance.pushRequests,
      'tokenImage': instance.tokenImage,
      'knownPushRequests': instance.knownPushRequests,
    };
