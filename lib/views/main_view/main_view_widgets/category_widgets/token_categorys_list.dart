import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/category_widgets/token_category_widget.dart';

class TokenCategorysList extends ConsumerWidget {
  const TokenCategorysList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorys = ref.watch(tokenCategoryProvider).categorys;
    Logger.warning('categorys: $categorys');
    return Column(
      children: [
        for (var category in categorys) TokenCategoryWidget(category),
      ],
    );
  }
}
