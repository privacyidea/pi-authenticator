// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenContainer _$TokenContainerFromJson(Map<String, dynamic> json) =>
    TokenContainer(
      serial: json['serial'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      syncedTokenTemplates: (json['syncedTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      localTokenTemplates: (json['localTokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerToJson(TokenContainer instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'description': instance.description,
      'type': instance.type,
      'syncedTokenTemplates': instance.syncedTokenTemplates,
      'localTokenTemplates': instance.localTokenTemplates,
    };

TokenTemplate _$TokenTemplateFromJson(Map<String, dynamic> json) =>
    TokenTemplate(
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TokenTemplateToJson(TokenTemplate instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
