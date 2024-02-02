// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_origin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenOriginData _$TokenOriginFromJson(Map<String, dynamic> json) => TokenOriginData(
      source: $enumDecode(_$TokenSourceTypeEnumMap, json['source']),
      data: json['data'] as String,
      appName: json['app'] as String?,
    );

Map<String, dynamic> _$TokenOriginToJson(TokenOriginData instance) => <String, dynamic>{
      'source': _$TokenSourceTypeEnumMap[instance.source]!,
      'app': instance.appName,
      'data': instance.data,
    };

const _$TokenSourceTypeEnumMap = {
  TokenOriginSourceType.link: 'link',
  TokenOriginSourceType.manually: 'manual',
  TokenOriginSourceType.backupFile: 'backupFile',
  TokenOriginSourceType.unknown: 'unknown',
};
