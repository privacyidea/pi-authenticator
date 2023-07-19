import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
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
          return TokenWidgetBuilder.fromToken(token, key: ValueKey(token.id));
        },
        // add padding for floating action button
        padding: EdgeInsets.only(bottom: 80),
        itemCount: tokens.length,
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex == newIndex) return;
          //If the selected token moved down all other tokens between old and new index must decrease their sort index by 1 to move up
          //If the selected token moved up all other tokens between old and new index must increase their sort index by 1 to move down
          final selectedTokenMovedDown = newIndex > oldIndex;
          if (selectedTokenMovedDown) newIndex--;
          final reorderedTokens = <Token>[];
          for (int i = min(oldIndex, newIndex); i <= max(oldIndex, newIndex); i++) {
            final token = tokens[i];
            if (i == oldIndex) {
              Logger.info('Token ${token.label}: ${token.sortIndex} -> $newIndex');
              reorderedTokens.add(token.copyWith(sortIndex: newIndex));
              continue;
            }

            final newIndexThisToken = selectedTokenMovedDown ? i - 1 : i + 1;
            Logger.info('Token ${token.label}: ${token.sortIndex} -> $newIndexThisToken');
            reorderedTokens.add(token.copyWith(sortIndex: newIndexThisToken));
          }

          ref.read(tokenProvider.notifier).updateTokens(reorderedTokens);
        },
      ),
    );
  }

  void updateTokens(WidgetRef ref, {required List<Token> tokens}) {
    ref.read(tokenProvider.notifier).updateTokens(tokens);
  }
}
