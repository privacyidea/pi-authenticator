// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenCategory _$TokenCategoryFromJson(Map<String, dynamic> json) =>
    TokenCategory(
      label: json['label'] as String,
      categoryId: json['categoryId'] as int,
      sortIndex: json['sortIndex'] as int?,
    );

Map<String, dynamic> _$TokenCategoryToJson(TokenCategory instance) =>
    <String, dynamic>{
      'label': instance.label,
      'categoryId': instance.categoryId,
      'sortIndex': instance.sortIndex,
    };
