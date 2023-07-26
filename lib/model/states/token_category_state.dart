import 'dart:math';

import 'package:flutter/material.dart';

import '../token_category.dart';

@immutable
class TokenCategoryState {
  final List<TokenCategory> categorys;

  const TokenCategoryState({required this.categorys});

  TokenCategoryState copyWith({List<TokenCategory>? categorys}) {
    return TokenCategoryState(
      categorys: categorys ?? this.categorys,
    );
  }

  TokenCategoryState withCategory(String name) {
    final newCategorys = List<TokenCategory>.from(categorys);
    newCategorys.add(TokenCategory(label: name, categoryId: newCategoryId));
    return copyWith(categorys: newCategorys);
  }

  //replace all categorys where the categoryid is the same
  TokenCategoryState withUpdated({List<TokenCategory>? categorys}) {
    final newCategorys = List<TokenCategory>.from(this.categorys);
    categorys?.forEach((newCategory) {
      final index = newCategorys.indexWhere((oldCategory) => oldCategory.categoryId == newCategory.categoryId);
      if (index != -1) {
        newCategorys[index] = newCategory;
      }
    });
    return copyWith(categorys: newCategorys);
  }

  TokenCategoryState withoutCategory(TokenCategory category) {
    final newCategorys = List<TokenCategory>.from(categorys);
    newCategorys.removeWhere((element) => element.categoryId == category.categoryId);
    return copyWith(categorys: newCategorys);
  }

  get newCategoryId => categorys.fold(0, (previousValue, element) => max(previousValue, element.categoryId)) + 1;
}
