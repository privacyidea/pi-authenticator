// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOTPToken _$HOTPTokenFromJson(Map<String, dynamic> json) {
  return HOTPToken(
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      uuid: json['uuid'] as String,
      algorithm: _$enumDecodeNullable(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: (json['secret'] as List)?.map((e) => e as int)?.toList(),
      counter: json['counter'] as int);
}

Map<String, dynamic> _$HOTPTokenToJson(HOTPToken instance) => <String, dynamic>{
      'label': instance.label,
      'uuid': instance.uuid,
      'issuer': instance.issuer,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm],
      'digits': instance.digits,
      'secret': instance.secret,
      'counter': instance.counter
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$AlgorithmsEnumMap = <Algorithms, dynamic>{
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512'
};

TOTPToken _$TOTPTokenFromJson(Map<String, dynamic> json) {
  return TOTPToken(
      label: json['label'] as String,
      issuer: json['issuer'] as String,
      uuid: json['uuid'] as String,
      algorithm: _$enumDecodeNullable(_$AlgorithmsEnumMap, json['algorithm']),
      digits: json['digits'] as int,
      secret: (json['secret'] as List)?.map((e) => e as int)?.toList(),
      period: json['period'] as int);
}

Map<String, dynamic> _$TOTPTokenToJson(TOTPToken instance) => <String, dynamic>{
      'label': instance.label,
      'uuid': instance.uuid,
      'issuer': instance.issuer,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm],
      'digits': instance.digits,
      'secret': instance.secret,
      'period': instance.period
    };

PushToken _$PushTokenFromJson(Map<String, dynamic> json) {
  return PushToken(
      label: json['label'] as String,
      serial: json['serial'] as String,
      issuer: json['issuer'] as String,
      uuid: json['uuid'] as String,
      sslVerify: json['sslVerify'] as bool,
      enrollmentCredentials: json['enrollmentCredentials'] as String,
      url: json['url'] == null ? null : Uri.parse(json['url'] as String),
      firebaseToken: json['firebaseToken'] as String,
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String))
    ..isRolledOut = json['isRolledOut'] as bool
    ..privateModulus = json['privateModulus'] == null
        ? null
        : BigInt.parse(json['privateModulus'] as String)
    ..privateExponent = json['privateExponent'] == null
        ? null
        : BigInt.parse(json['privateExponent'] as String)
    ..privateP = json['privateP'] == null
        ? null
        : BigInt.parse(json['privateP'] as String)
    ..privateQ = json['privateQ'] == null
        ? null
        : BigInt.parse(json['privateQ'] as String)
    ..publicModulus = json['publicModulus'] == null
        ? null
        : BigInt.parse(json['publicModulus'] as String)
    ..publicExponent = json['publicExponent'] == null
        ? null
        : BigInt.parse(json['publicExponent'] as String)
    ..hasPendingRequest = json['hasPendingRequest'] as bool
    ..requestUri = json['requestUri'] == null
        ? null
        : Uri.parse(json['requestUri'] as String)
    ..requestNonce = json['requestNonce'] as String
    ..requestSSLVerify = json['requestSSLVerify'] as bool;
}

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
      'label': instance.label,
      'uuid': instance.uuid,
      'issuer': instance.issuer,
      'isRolledOut': instance.isRolledOut,
      'privateModulus': instance.privateModulus?.toString(),
      'privateExponent': instance.privateExponent?.toString(),
      'privateP': instance.privateP?.toString(),
      'privateQ': instance.privateQ?.toString(),
      'publicModulus': instance.publicModulus?.toString(),
      'publicExponent': instance.publicExponent?.toString(),
      'hasPendingRequest': instance.hasPendingRequest,
      'requestUri': instance.requestUri?.toString(),
      'requestNonce': instance.requestNonce,
      'requestSSLVerify': instance.requestSSLVerify,
      'firebaseToken': instance.firebaseToken,
      'serial': instance.serial,
      'sslVerify': instance.sslVerify,
      'enrollmentCredentials': instance.enrollmentCredentials,
      'url': instance.url?.toString(),
      'expirationDate': instance.expirationDate?.toIso8601String()
    };
