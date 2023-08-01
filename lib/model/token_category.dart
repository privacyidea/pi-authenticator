import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mixins/sortable_mixin.dart';

part 'token_category.g.dart';

@immutable
@JsonSerializable()
class TokenCategory with SortableMixin {
  final String label;
  final int categoryId;
  final bool isExpanded;
  @override
  final int? sortIndex;

  const TokenCategory({
    required this.label,
    required this.categoryId,
    this.isExpanded = true,
    this.sortIndex,
  });

  @override
  TokenCategory copyWith({
    String? label,
    int? categoryId,
    bool? isExpanded,
    int? sortIndex,
  }) {
    return TokenCategory(
      label: label ?? this.label,
      categoryId: categoryId ?? this.categoryId,
      sortIndex: sortIndex ?? this.sortIndex,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  factory TokenCategory.fromJson(Map<String, dynamic> json) => _$TokenCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$TokenCategoryToJson(this);
}
