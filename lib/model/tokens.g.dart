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
