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
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => Token.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerToJson(TokenContainer instance) =>
    <String, dynamic>{
      'containerId': instance.containerId,
      'description': instance.description,
      'type': instance.type,
      'tokens': instance.tokens,
    };
