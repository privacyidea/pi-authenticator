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
  final bool isLocked;
  @override
  final int? sortIndex;

  const TokenCategory({
    required this.label,
    required this.categoryId,
    this.isExpanded = true,
    this.isLocked = false,
    this.sortIndex,
  });

  @override
  TokenCategory copyWith({
    String? label,
    int? categoryId,
    bool? isExpanded,
    bool? isLocked,
    int? sortIndex,
  }) {
    return TokenCategory(
      label: label ?? this.label,
      categoryId: categoryId ?? this.categoryId,
      sortIndex: sortIndex ?? this.sortIndex,
      isLocked: isLocked ?? this.isLocked,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  factory TokenCategory.fromJson(Map<String, dynamic> json) {
    var tokenCategory = _$TokenCategoryFromJson(json);
    if (tokenCategory.isLocked) tokenCategory = tokenCategory.copyWith(isExpanded: false);
    return tokenCategory;
  }
  Map<String, dynamic> toJson() => _$TokenCategoryToJson(this);
}
