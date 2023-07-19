import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';

class MainViewTokensList extends ConsumerWidget {
  final List<Token> tokens;
  const MainViewTokensList(this.tokens, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool tokenGotSortIndex = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tokenGotSortIndex) {
        updateTokens(ref, tokens: tokens);
      }
    });
    return SlidableAutoCloseBehavior(
      child: ReorderableListView.builder(
        itemBuilder: (context, index) {
          if (tokens[index].sortIndex == null) {
            tokens[index] = tokens[index].copyWith(sortIndex: index);
            tokenGotSortIndex = true;
          }
          Token token = tokens[index];
          return TokenWidgetBuilder.fromToken(token);
        },
        // add padding for floating action button
        padding: EdgeInsets.only(bottom: 80),
        itemCount: tokens.length,
        onReorder: (int oldIndex, int newIndex) {
          final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
          final token = tokens.removeAt(oldIndex);
          tokens.insert(index, token);

          ref.read(tokenProvider.notifier).updateTokens(tokens);
        },
      ),
    );
  }

  void updateTokens(WidgetRef ref, {required List<Token> tokens}) {
    ref.read(tokenProvider.notifier).updateTokens(tokens);
  }
}
