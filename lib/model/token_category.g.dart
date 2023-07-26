// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenCategory _$TokenCategoryFromJson(Map<String, dynamic> json) => TokenCategory(
      label: json['title'] as String,
      categoryId: json['categoryId'] as int,
      sortIndex: json['sortIndex'] as int?,
    );

Map<String, dynamic> _$TokenCategoryToJson(TokenCategory instance) => <String, dynamic>{
      'title': instance.label,
      'categoryId': instance.categoryId,
      'sortIndex': instance.sortIndex,
    };
