// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_origin_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenOriginData _$TokenOriginDataFromJson(Map<String, dynamic> json) => TokenOriginData(
      source: $enumDecode(_$TokenOriginSourceTypeEnumMap, json['source']),
      data: json['data'] as String,
      appName: json['appName'] as String?,
    );

Map<String, dynamic> _$TokenOriginDataToJson(TokenOriginData instance) => <String, dynamic>{
      'source': _$TokenOriginSourceTypeEnumMap[instance.source]!,
      'appName': instance.appName,
      'data': instance.data,
    };

const _$TokenOriginSourceTypeEnumMap = {
  TokenOriginSourceType.backupFile: 'backupFile',
  TokenOriginSourceType.qrScan: 'qrScan',
  TokenOriginSourceType.qrFile: 'qrFile',
  TokenOriginSourceType.link: 'link',
  TokenOriginSourceType.manually: 'manually',
  TokenOriginSourceType.unknown: 'unknown',
};
