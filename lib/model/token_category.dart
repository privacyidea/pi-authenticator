import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@immutable
@JsonSerializable()
class TokenCategory {
  final String title;
  final int categoryId;

  const TokenCategory({required this.title, required this.categoryId});

  TokenCategory copyWith({String? name, int? categoryId}) {
    return TokenCategory(
      title: name ?? this.title,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
