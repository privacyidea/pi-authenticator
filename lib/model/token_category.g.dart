// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenCategory _$TokenCategoryFromJson(Map<String, dynamic> json) =>
    TokenCategory(
      label: json['label'] as String,
      categoryId: json['categoryId'] as int,
      isExpanded: json['isExpanded'] as bool? ?? true,
      sortIndex: json['sortIndex'] as int?,
    );

Map<String, dynamic> _$TokenCategoryToJson(TokenCategory instance) =>
    <String, dynamic>{
      'label': instance.label,
      'categoryId': instance.categoryId,
      'isExpanded': instance.isExpanded,
      'sortIndex': instance.sortIndex,
    };
