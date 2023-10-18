import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/tokens/token.dart';
import '../../../utils/riverpod_providers.dart';
import 'token_widgets/token_widget_builder.dart';

class MainViewTokensListFiltered extends ConsumerWidget {
  const MainViewTokensListFiltered({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenFilterProvider)?.filterTokens(ref.watch(tokenProvider).tokens);
    return Container(
      color: Theme.of(context).canvasColor,
      height: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ..._mapTokensToWidgets(tokens ?? []),
        ],
      ),
    );
  }

  List<Widget> _mapTokensToWidgets(List<Token> tokens) {
    final List<Widget> widgets = [];
    for (int i = 0; i < tokens.length; i++) {
      widgets.add(TokenWidgetBuilder.fromToken(tokens[i]));
      if (i != tokens.length - 1) {
        widgets.add(const Divider());
      }
    }
    return widgets;
  }
}
