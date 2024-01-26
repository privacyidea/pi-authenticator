// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_origin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenOrigin _$TokenOriginFromJson(Map<String, dynamic> json) => TokenOrigin(
      source: $enumDecode(_$TokenSourceTypeEnumMap, json['source']),
      data: json['data'] as String,
      appName: json['app'] as String?,
    );

Map<String, dynamic> _$TokenOriginToJson(TokenOrigin instance) => <String, dynamic>{
      'source': _$TokenSourceTypeEnumMap[instance.source]!,
      'app': instance.appName,
      'data': instance.data,
    };

const _$TokenSourceTypeEnumMap = {
  TokenOriginSourceType.link: 'link',
  TokenOriginSourceType.manually: 'manual',
  TokenOriginSourceType.import: 'import',
  TokenOriginSourceType.unknown: 'unknown',
};
