import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../model/tokens/token.dart';
import 'token_action.dart';

class TokenWidgetSlideable extends StatelessWidget {
  final Token token;
  final List<TokenAction> actions;
  final List<Widget> stack;
  final Widget tile;

  const TokenWidgetSlideable({
    required this.token,
    required this.actions,
    required this.stack,
    required this.tile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        tile,
        for (var item in stack) item,
      ],
    );
    return actions.isNotEmpty
        ? Slidable(
            key: ValueKey(token.id),
            groupTag: 'myTag', // This is used to only let one be open at a time.
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 1,
              children: actions,
            ),
            child: child,
          )
        : child;
  }
}
