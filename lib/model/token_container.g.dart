// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenContainer _$TokenContainerFromJson(Map<String, dynamic> json) =>
    TokenContainer(
      containerId: json['containerId'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      tokenTemplates: (json['tokenTemplates'] as List<dynamic>)
          .map((e) => TokenTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerToJson(TokenContainer instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokenTemplates': instance.tokenTemplates,
    };

TokenTemplate _$TokenTemplateFromJson(Map<String, dynamic> json) =>
    TokenTemplate(
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TokenTemplateToJson(TokenTemplate instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
