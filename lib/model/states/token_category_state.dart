import 'dart:math';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/token_category.dart';

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
    newCategorys.add(TokenCategory(title: name, categoryId: newCategoryId));
    return copyWith(categorys: newCategorys);
  }

  get newCategoryId => categorys.fold(0, (previousValue, element) => max(previousValue, element.categoryId)) + 1;
}
