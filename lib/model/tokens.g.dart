// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOTPToken _$HOTPTokenFromJson(Map<String, dynamic> json) => HOTPToken(
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
      algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: json['secret'] as String,
      relock: json['relock'] ?? false,
      pin: json['pin'] as bool? ?? false,
      imageURL: json['imageURL'] as String?,
      counter: json['counter'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      canToggleLock: json['canToggleLock'] as bool? ?? true,
    )
      ..imageUrl = json['imageUrl'] as String?
      ..sortIndex = json['sortIndex'] as int?
      ..type = json['type'] as String;

Map<String, dynamic> _$HOTPTokenToJson(HOTPToken instance) => <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'sortIndex': instance.sortIndex,
      'canToggleLock': instance.canToggleLock,
      'isLocked': instance.isLocked,
      'type': instance.type,
      'label': instance.label,
      'id': instance.id,
      'issuer': instance.issuer,
      'pin': instance.pin,
      'relock': instance.relock,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm],
      'digits': instance.digits,
      'secret': instance.secret,
      'counter': instance.counter,
      'imageURL': instance.imageURL,
    };

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};

TOTPToken _$TOTPTokenFromJson(Map<String, dynamic> json) => TOTPToken(
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
      algorithm: $enumDecode(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: json['secret'] as String,
      period: json['period'] as int,
      relock: json['relock'] as bool? ?? false,
      pin: json['pin'] as bool? ?? false,
      imageURL: json['imageURL'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      canToggleLock: json['canToggleLock'] as bool? ?? true,
    )
      ..imageUrl = json['imageUrl'] as String?
      ..sortIndex = json['sortIndex'] as int?
      ..type = json['type'] as String;

Map<String, dynamic> _$TOTPTokenToJson(TOTPToken instance) => <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'sortIndex': instance.sortIndex,
      'canToggleLock': instance.canToggleLock,
      'isLocked': instance.isLocked,
      'type': instance.type,
      'label': instance.label,
      'id': instance.id,
      'issuer': instance.issuer,
      'pin': instance.pin,
      'relock': instance.relock,
      'imageURL': instance.imageURL,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm],
      'digits': instance.digits,
      'secret': instance.secret,
      'period': instance.period,
    };

PushToken _$PushTokenFromJson(Map<String, dynamic> json) => PushToken(
      label: json['label'] as String,
      serial: json['serial'] as String,
      issuer: json['issuer'] as String,
      id: json['id'] as String,
      isLocked: json['isLocked'] as bool? ?? false,
      canToggleLock: json['canToggleLock'] as bool? ?? true,
      relock: json['relock'] as bool? ?? false,
      pin: json['pin'] as bool? ?? false,
      sslVerify: json['sslVerify'] as bool?,
      enrollmentCredentials: json['enrollmentCredentials'] as String?,
      url: json['url'] == null ? null : Uri.parse(json['url'] as String),
      listIndex: json['listIndex'] as int?,
      tokenImage: json['tokenImage'] as String?,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
    )
      ..imageUrl = json['imageUrl'] as String?
      ..sortIndex = json['sortIndex'] as int?
      ..type = json['type'] as String
      ..isRolledOut = json['isRolledOut'] as bool
      ..publicServerKey = json['publicServerKey'] as String?
      ..privateTokenKey = json['privateTokenKey'] as String?
      ..publicTokenKey = json['publicTokenKey'] as String?
      ..pushRequests = PushRequestQueue.fromJson(
          json['pushRequests'] as Map<String, dynamic>)
      ..knownPushRequests = CustomIntBuffer.fromJson(
          json['knownPushRequests'] as Map<String, dynamic>);

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
      'relock': instance.relock,
      'imageUrl': instance.imageUrl,
      'sortIndex': instance.sortIndex,
      'canToggleLock': instance.canToggleLock,
      'isLocked': instance.isLocked,
      'type': instance.type,
      'label': instance.label,
      'id': instance.id,
      'issuer': instance.issuer,
      'url': instance.url?.toString(),
      'isRolledOut': instance.isRolledOut,
      'listIndex': instance.listIndex,
      'pin': instance.pin,
      'publicServerKey': instance.publicServerKey,
      'privateTokenKey': instance.privateTokenKey,
      'publicTokenKey': instance.publicTokenKey,
      'serial': instance.serial,
      'sslVerify': instance.sslVerify,
      'enrollmentCredentials': instance.enrollmentCredentials,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'tokenImage': instance.tokenImage,
      'pushRequests': instance.pushRequests,
      'knownPushRequests': instance.knownPushRequests,
    };

PushRequest _$PushRequestFromJson(Map<String, dynamic> json) => PushRequest(
      title: json['title'] as String,
      question: json['question'] as String,
      uri: Uri.parse(json['uri'] as String),
      nonce: json['nonce'] as String,
      sslVerify: json['sslVerify'] as bool,
      id: json['id'] as int,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
    );

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) =>
    <String, dynamic>{
      'expirationDate': instance.expirationDate.toIso8601String(),
      'id': instance.id,
      'nonce': instance.nonce,
      'sslVerify': instance.sslVerify,
      'uri': instance.uri.toString(),
      'question': instance.question,
      'title': instance.title,
    };

PushRequestQueue _$PushRequestQueueFromJson(Map<String, dynamic> json) =>
    PushRequestQueue()
      ..list = (json['list'] as List<dynamic>)
          .map((e) => PushRequest.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PushRequestQueueToJson(PushRequestQueue instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

SerializableRSAPublicKey _$SerializableRSAPublicKeyFromJson(
        Map<String, dynamic> json) =>
    SerializableRSAPublicKey(
      BigInt.parse(json['modulus'] as String),
      BigInt.parse(json['exponent'] as String),
    );

Map<String, dynamic> _$SerializableRSAPublicKeyToJson(
        SerializableRSAPublicKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString(),
    };

SerializableRSAPrivateKey _$SerializableRSAPrivateKeyFromJson(
        Map<String, dynamic> json) =>
    SerializableRSAPrivateKey(
      BigInt.parse(json['modulus'] as String),
      BigInt.parse(json['exponent'] as String),
      BigInt.parse(json['p'] as String),
      BigInt.parse(json['q'] as String),
    );

Map<String, dynamic> _$SerializableRSAPrivateKeyToJson(
        SerializableRSAPrivateKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString(),
      'p': instance.p?.toString(),
      'q': instance.q?.toString(),
    };

CustomIntBuffer _$CustomIntBufferFromJson(Map<String, dynamic> json) =>
    CustomIntBuffer()
      ..list = (json['list'] as List<dynamic>).map((e) => e as int).toList();

Map<String, dynamic> _$CustomIntBufferToJson(CustomIntBuffer instance) =>
    <String, dynamic>{
      'list': instance.list,
    };
