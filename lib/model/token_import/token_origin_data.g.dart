// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_origin_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenOriginData _$TokenOriginDataFromJson(Map<String, dynamic> json) =>
    TokenOriginData(
      source: $enumDecode(_$TokenOriginSourceTypeEnumMap, json['source']),
      data: json['data'] as String,
      isPrivacyIdeaToken: json['isPrivacyIdeaToken'] as bool?,
      appName: json['appName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      piServerVersion: json['piServerVersion'] == null
          ? null
          : Version.fromJson(json['piServerVersion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TokenOriginDataToJson(TokenOriginData instance) =>
    <String, dynamic>{
      'source': _$TokenOriginSourceTypeEnumMap[instance.source]!,
      'appName': instance.appName,
      'data': instance.data,
      'isPrivacyIdeaToken': instance.isPrivacyIdeaToken,
      'createdAt': instance.createdAt.toIso8601String(),
      'piServerVersion': instance.piServerVersion,
    };

const _$TokenOriginSourceTypeEnumMap = {
  TokenOriginSourceType.backupFile: 'backupFile',
  TokenOriginSourceType.qrScan: 'qrScan',
  TokenOriginSourceType.qrFile: 'qrFile',
  TokenOriginSourceType.qrScanImport: 'qrScanImport',
  TokenOriginSourceType.link: 'link',
  TokenOriginSourceType.linkImport: 'linkImport',
  TokenOriginSourceType.manually: 'manually',
  TokenOriginSourceType.unknown: 'unknown',
};
